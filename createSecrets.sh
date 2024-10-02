#!/bin/bash

DOCKER_REGISTRY=""
DOCKER_USER=""
DOCKER_PASSWORD=""
DB_PASSWORD=""

function parse_params() {
    while getopts r:d:u:p:hw arg; do
        CLEAN_ARG=`echo ${OPTARG} | tr -d '[:cntrl:]'`
        case $arg in
            h)
                echo "./${0} [-r <Docker registry: eg: docker.io> -u <Docker User: eg: ${USER}@some.where> -p <Docker Password: eg: secret>]"
                exit
                ;;
            r)
                DOCKER_REGISTRY="${CLEAN_ARG}"
                ;;
            u)
                DOCKER_USER="${CLEAN_ARG}"
                ;;
            p)
                DOCKER_PASSWORD="${CLEAN_ARG}"
                ;;
            d)
                DB_PASSWORD="${CLEAN_ARG}"
                ;;
        esac
    done
}

# parse command line parameters if we have some
if [ $# -ge 1 ]; then
    parse_params $@;
fi

if [ -z "${DOCKER_REGISTRY}" ] || [ -z "${DOCKER_USER}" ] || [ -z "${DOCKER_PASSWORD}" ] || [ -z "${DB_PASSWORD}" ]; then
    echo "Please specify docker registry (-r), user (-u), registry password (-p), and DB password (-d)"
    exit 1
fi

PASSWD=`echo "${DOCKER_USER}:${DOCKER_PASSWORD}" | tr -d '\n' | base64`

CONFIG="\
{
    \"auths\": {
        \"${DOCKER_REGISTRY}\": {
            \"auth\": \"${PASSWD}\"
        }
    }
}"

echo "Writing to secrets/.dockerconfigjson"
printf "${CONFIG}" > secrets/.dockerconfigjson

echo "Writing to secrets/secrets.env"
printf "DB_PASSWORD=${DB_PASSWORD}" > secrets/secrets.env