# boundary-psql-ssh-demo

![](img/img.png)

TODO
* RDP
* SSH Vault Integration
* Boundary Exec
* MySQL Static Secret Engine
* More ACLs

## 1. terraform
```
terraform apply
```

## 2. boundary
```
boundary dev
```

```
cd boundary
terraform apply
```

## 3. Postgres
```
docker run --rm -d \
    -e POSTGRES_PASSWORD=secret \
    -e POSTGRES_DB="boundarydemo" \
    --name  boundarydemo\
    -p 5432:5432 \
    -v postgres-tmp:/var/lib/postgresql/data-for-boundary-demo \
    postgres:12-alpine
```

```
$ psql -d postgres -h 127.0.0.1 -p 5432 -U postgres
# create role vault with superuser login createrole password 'vault-password';
```

## 4. Vault Setup

### 4-1. PSQL Secret Engine
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

```shell script
psql -d postgres -h 127.0.0.1 -p 5432 -U v-root-dba-yiY3EJlpngXg0wYvRN7p-1625629960
```

### 4-2. SSH Secret Engine
```shell script
vault secrets enable ssh
```

### 4-3. Prepare for boundary Integration
```shell script
vault policy write psql-dba dba-policy.hcl
vault policy write boundary-controller boundary-controller-policy.hcl
```

```shell script
vault token create \
  -no-default-policy=true \
  -policy="boundary-controller" \
  -policy="psql-dba" \
  -orphan=true \
  -renewable=true
```

## (Example)Boundary Credentials Store Manual Setup

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

### PSQL

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

```shell script
boundary targets authorize-session -id ttcp_df0SBRpSzE -format json | jq .
```

```shell script
boundary connect postgres -target-id ttcp_df0SBRpSzE -dbname postgres
```

### SSH
