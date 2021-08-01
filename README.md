# boundary-psql-ssh-demo

![](img/img.png)

```shell script
git clone thisrepo
cd thisrepo
```

## Pre-requisite
1. Setup Azure OIDC. Retrieve and set as `TF_VAR`.
* issuer
* client_id
* client secret
* subject

2. Setup Azure Virtual Desktop
* AVD cannot be fully terraformed. Please follow [this instruction](https://docs.microsoft.com/en-us/azure/virtual-desktop/getting-started-feature).
    * Create a workspace and a VM.
    * Associate public IP for the VM.

```shell script
export TF_VAR_issuer=
export TF_VAR_client_id=
export TF_VAR_client_secret=
export TF_VAR_subject=
```

**For quick start, remove OIDC related settings**
Commenting out the code in `tf/baundary/boundary-auth.tf` from the line of `//oidc` to `//passsword` and set the dummy values.

```shell script
export TF_VAR_issuer=https://dummy
export TF_VAR_client_id=dummy
export TF_VAR_client_secret=dummy
export TF_VAR_subject=dummy
```

3. Create GKE Cluster
```shell script
gcloud container clusters create lab-cluster --num-nodes=3 --zone asia-northeast1-a
```


## 0. CA Public Key for GCP VM 
```shell script
vault secrets enable ssh
vault write ssh/config/ca generate_signing_key=true
vault write ssh/roles/ubuntu -<<"EOH"
{
  "allow_user_certificates": true,
  "allowed_users": "ubuntu",
  "default_extensions": [
    {
      "permit-pty": ""
    }
  ],
  "key_type": "ca",
  "default_user": "ubuntu",
  "ttl": "60m0s"
}
EOH
curl -o trusted-user-ca-keys.pem http://127.0.0.1:8200/v1/ssh/public_key
```


## 1. Infra
```shell script
cd tf/infra
terraform apply
```

## 2. Postgres & MySQL
```shell script
docker run --rm -d \
    -e POSTGRES_PASSWORD=secret \
    -e POSTGRES_DB="boundarydemo" \
    --name  boundarydemo\
    -p 5432:5432 \
    -v postgres-tmp:/Users/Shared/data-for-boundary-demo \
    postgres:12-alpine
```

```shell script
psql -d postgres -h 127.0.0.1 -p 5432 -U postgres
# create role vault with superuser login createrole password 'vault-password';
```

```shell script
docker run --rm -d \
  --name mysql \
  -e MYSQL_ROOT_PASSWORD=rooooot \
  -p 3306:3306 \
  mysql:latest

mysql -uroot -p -h 127.0.0.1
> CREATE USER 'boundarydemo-mysql' IDENTIFIED BY 'password';
```

## 3. Vault Setup

### 3-1. KV Secret Engine
```shell script
vault secrets enable -path=boundary kv
vault kv put boundary/mysql-user username=boundarydemo-mysql password=password
vault kv put boundary/rdp-user username=(RDP USERNAME) password=(RDP PASSWORD)
```

#### Test
```shell script
vault kv get boundary/mysql-user
vault kv get boundary/rdp-user
```

### 3-2. PSQL Secret Engine
```shell script
vault secrets enable database
```

```shell script
vault write database/config/postgres \
      plugin_name=postgresql-database-plugin \
      connection_url="postgresql://{{username}}:{{password}}@localhost:5432/postgres?sslmode=disable" \
      allowed_roles=dba \
      username="vault" \
      password="vault-password"
```

```shell script
vault write database/roles/dba \
      db_name=postgres \
      creation_statements=@dba.sql \
      default_ttl=3m \
      max_ttl=60m
```

```shell script
vault read database/creds/dba
```

#### Test

```shell script
psql -d postgres -h 127.0.0.1 -p 5432 -U v-root-dba-yiY3EJlpngXg0wYvRN7p-1625629960
```

### 3-3. SSH Secret Engine
```shell script
cd rootofthisrepo
ssh-keygen -t rsa -f boundarydemo
vault write -field=signed_key ssh/sign/ubuntu \
    public_key=@boundarydemo.pub > boundarydemo-signed-cert.pub
ssh-keygen -Lf boundarydemo-signed-cert.pub
```

**Replace ``public_key`` in `tf` -> `boundary` -> `creds.tf` -> `boundary_credential_library_vault` -> `htt_request_body` -> `public_key` with `boundarydemo.pub`

#### Test

```shell script
ssh -i boundarydemo-signed-cert.pub \
  -i boundarydemo \
  ubuntu@35.75.209.86 #GCP's IP
```

### 3-4. Prepare for Boundary Integration
```shell script
vault policy write policies/psql-dba dba-policy.hcl
vault policy write policies/ssh-ubuntu ssh-policy.hcl
vault policy write policies/kv-mysql kv-mysql.hcl
vault policy write policies/kv-rdp kv-rdp.hcl
vault policy write policies/boundary-controller boundary-controller-policy.hcl
```

```shell script
vault token create \
  -no-default-policy=true \
  -policy="boundary-controller" \
  -policy="psql-dba" \
  -policy="ssh-ubuntu" \
  -policy="kv-mysql" \
  -policy="kv-rdp" \
  -orphan=true \
  -renewable=true \
  -period=765h
```

## 4. Boundary Setup
```shell script
boundary dev
```

**Replace variables.tf**

```shell script
cd tf/boundary
terraform apply
```

## 5. Test Connections

```shell script
boundary authenticate password \
  -auth-method-id=ampw_1234567890 \
  -login-name=admin \
  -password=password
```

### 5-1. PSQL by Vault Dynamic Secret

```shell script
boundary connect postgres -target-id ttcp_df0SBRpSzE -dbname postgres
```

### 5-2. SSH to GCP by Vault Dynamic Secret

**SSH Helper is not supported yet. Secret should be injected manually.**

```shell script
boundary targets authorize-session -id ttcp_5tcclnDIWi
```

* **Copy `signed_key` and paste to `boundarydemo-signed-cert.pub`**
* **Copy `authorization_token`** 

```shell script
boundary connect -authz-token=(authorization_token)

ssh ubuntu@127.0.0.1 -p 55680 \
  -i boundarydemo \
  -i boundarydemo-signed-cert.pub
```

### 5-3. SSH to AWS by User's Secret
```shell script
boundary connect ssh -target-id ttcp_9s8h0NtEry -username=ubuntu
# default password=happyhacking
```

### 5-4. MySQL by Vault Static Secret

**Exec Helper is not supported yet. Secret should be injected manually.**

```shell script
boundary targets authorize-session -id ttcp_iJRMp3bYQc
# Copy the password output
# Copy `authorization_token` 
boundary connect -authz-token=(authorization_token)
mysql -uboundarydemo-mysql -p -P 55680 --protocol=tcp
```

### 5-5. RDP by Vault Static Secret

**RDP Helper is not supported yet. Secret should be injected manually.**

```shell script
boundary connect rdp -target-id ttcp_DqXzkcPfqN
```

### 5-6. kubectl by the User's credential

```shell script
boundary connect kube -target-id ttcp_DqXzkcPfqN -- get pods
```

## (Additional) Trying PSQL Helper with KV Secret Engine
```shell script
vault kv put boundary/mysql-user username=postgres password=secret
```

Change `psql-target` in `boundary-target-psql.tf` to

```
resource "boundary_target" "psql-target" {
  name         = "PSQL Target"
  type         = "tcp"
  default_port = "5432"
  scope_id     = boundary_scope.project.id
  host_set_ids = [
    boundary_host_set.local.id
  ]
  application_credential_library_ids = [
    boundary_credential_library_vault.kv_mysql.id
  ]
}
```

```shell script
terraform apply
boundary connect postgres -target-id ttcp_CSIYmhPn4s -dbname postgres
```

This means PSQL helper is able to get secrets from Vault KV and inject them automatically. 


## (Example) Boundary Credentials Store Manual Setup without Terraform

```shell script
boundary authenticate password \
  -auth-method-id=ampw_1234567890 \
  -login-name=admin \
  -password=password

boundary credential-stores create vault -scope-id "p_zq23isyBRw" \
  -vault-address "http://127.0.0.1:8200" \
  -vault-token "s.maCJtXp5wcMQ207kEawkv3Kq"
```

```
Credential Store information:
  Created Time:        Wed, 07 Jul 2021 14:03:29 JST
  ID:                  csvlt_fBc2bMCGqP
  Type:                vault
  Updated Time:        Wed, 07 Jul 2021 14:03:29 JST
  Version:             1

  Scope:
    ID:                p_zq23isyBRw
    Name:              Demo Project
    Parent Scope ID:   o_Kae5eGF51p
    Type:              project

  Authorized Actions:
    no-op
    read
    update
    delete

  Attributes:
    Address:           http://127.0.0.1:8200
    Token HMAC:        46GzT0vKXZwJ37ARowCa-_Xgj9lB_s5J8qyNBqaQdQI
```

```shell script
boundary credential-libraries create vault \
    -credential-store-id csvlt_fBc2bMCGqP \
    -vault-path "database/creds/dba" \
    -name "psql dba"
```

```
Credential Library information:
  Created Time:          Wed, 07 Jul 2021 14:05:03 JST
  Credential Store ID:   csvlt_fBc2bMCGqP
  ID:                    clvlt_kRhQ0nmkpZ
  Name:                  psql dba
  Type:                  vault
  Updated Time:          Wed, 07 Jul 2021 14:05:03 JST
  Version:               1

  Scope:
    ID:                  p_zq23isyBRw
    Name:                Demo Project
    Parent Scope ID:     o_Kae5eGF51p
    Type:                project

  Authorized Actions:
    no-op
    read
    update
    delete

  Attributes:
    HTTP Method:         GET
    Path:                database/creds/dba
```

```shell script
boundary targets add-credential-libraries \
  -id=ttcp_df0SBRpSzE \
  -application-credential-library=clvlt_kRhQ0nmkpZ
```

```
Target information:
  Created Time:               Wed, 07 Jul 2021 12:55:10 JST
  ID:                         ttcp_df0SBRpSzE
  Name:                       PSQL Target
  Session Connection Limit:   1
  Session Max Seconds:        28800
  Type:                       tcp
  Updated Time:               Wed, 07 Jul 2021 14:07:30 JST
  Version:                    3

  Scope:
    ID:                       p_zq23isyBRw
    Name:                     Demo Project
    Parent Scope ID:          o_Kae5eGF51p
    Type:                     project

  Authorized Actions:
    no-op
    read
    update
    delete
    add-host-sets
    set-host-sets
    remove-host-sets
    add-credential-libraries
    set-credential-libraries
    remove-credential-libraries
    authorize-session

  Host Sets:
    Host Catalog ID:          hcst_fATCAUna0o
    ID:                       hsst_sDElOIx3ls

  Application Credential Libraries:
    Credential Store ID:      csvlt_fBc2bMCGqP
    ID:                       clvlt_kRhQ0nmkpZ

  Attributes:
    Default Port:             5432
```


kubectl get serviceaccount/get-pods-sa -o jsonpath='{.secrets[0].name}'
kubectl get secret get-pods-sa-token-hhc9n -o jsonpath='{.data.token}'| base64 --decode
kubectl config set-credentials get-pods-sa --token=${TOKEN}
kubectl config set-context get-pods-context --cluster=gke_se-kabu_us-central1-c_lab-cluster --user get-pods-sa 
kubectl config use-context get-pods-context