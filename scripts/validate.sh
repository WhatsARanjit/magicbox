#!/bin/bash

echo 'Pipe in code, or paste and it ctrl-d when done'
code=$(</dev/stdin)
data="{ \"code\": \"$code\", \"lang\": \"puppet\" }"

curl -d "$data" http://localhost:8443/api/1.0/validate
