#!/bin/bash
wait-for-url() {
    echo "Testing $1"
    timeout --foreground -s TERM 30s bash -c \
        'while [[ "$(curl -s -o /dev/null -m 3 -L -w ''%{http_code}'' ${0})" != "200" ]];\
        do echo "Waiting for ${0}" && sleep 2;\
        done' ${1}
    echo "authenticate cli" 
    /opt/keycloak/bin/kcadm.sh config credentials --server http://10.5.0.5:8080 --realm master --user ${KEYCLOAK_ADMIN} --password ${KEYCLOAK_ADMIN_PASSWORD} 
    echo "importing realm" 
    /opt/keycloak/bin/kcadm.sh create realms --server http://10.5.0.5:8080 -f /opt/docker/realm-export.json 
    echo "create user admin" 
    /opt/keycloak/bin/kcadm.sh create users -r superset -s username=admin -s enabled=true -s email=admin@superset.com 
    echo "set password for user admin" 
    /opt/keycloak/bin/kcadm.sh set-password -r superset --username admin --new-password admin 
    echo "assign role for user admin" 
    /opt/keycloak/bin/kcadm.sh add-roles -r superset --uusername admin --cclientid superset --rolename admin 
}

echo "Wait for URLs: $@"

for var in "$@"; do
    wait-for-url "$var"
done