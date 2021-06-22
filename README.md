# boundary-psql-ssh-demo

## terraform
```
terraform apply
```

## boundary
```
boundary dev
```

```
cd boundary
terraform apply
```

## Postgres
```
run --rm -d \
    -p 5432:5432 \
    -v postgres-tmp:/var/lib/postgresql/data \
    -e POSTGRES_HOST_AUTH_METHOD=trust \
    postgres:12-alpine
```