create role "{{name}}"
with login password '{{password}}'
valid until '{{expiration}}' inherit;
grant postgres to "{{name}}";