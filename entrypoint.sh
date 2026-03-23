#!/bin/bash

set -e

if [ -v PASSWORD_FILE ]; then
    PASSWORD="$(< $PASSWORD_FILE)"
fi

# set the postgres database host, port, user and password according to the environment
# and pass them as arguments to the odoo process if not present in the config file
: ${HOST:=${DB_PORT_5432_TCP_ADDR:='db'}}
: ${PORT:=${DB_PORT_5432_TCP_PORT:=5432}}
: ${USER:=${DB_ENV_POSTGRES_USER:=${POSTGRES_USER:='odoo'}}}
: ${PASSWORD:=${DB_ENV_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD:='odoo'}}}
: ${ADMIN_PASSWD:='S0tLMDkwOTA5ODk4NA=='}
: ${DB_NAME:=${DB_ENV_POSTGRES_DB_NAME:='False'}}
: ${WORKER:=${ENV_WORKER:=0}}
: ${CRON_WORKER:=0}
: ${ADDONS_PATH:=''}}

DB_ARGS=()
function check_config() {
    param="$1"
    value="$2"
    if grep -q -E "^\s*\b${param}\b\s*=" "$ODOO_RC" ; then       
        value=$(grep -E "^\s*\b${param}\b\s*=" "$ODOO_RC" |cut -d " " -f3|sed 's/["\n\r]//g')
    fi;
    DB_ARGS+=("--${param}")
    DB_ARGS+=("${value}")
}

ODOO_ARGS=()
function check_odoo_config() {
    param="$1"
    value="$2"
    if grep -q -E "^\s*\b${param}\b\s*=" "$ODOO_RC" ; then       
        value=$(grep -E "^\s*\b${param}\b\s*=" "$ODOO_RC" |cut -d " " -f3|sed 's/["\n\r]//g')
    fi;
    ODOO_ARGS+=("--${param}")
    ODOO_ARGS+=("${value}")
}
check_config "db_host" "$HOST"
check_config "db_port" "$PORT"
check_config "db_user" "$USER"
check_config "db_password" "$PASSWORD"

check_odoo_config "db_host" "$HOST"
check_odoo_config "db_port" "$PORT"
check_odoo_config "db_user" "$USER"
check_odoo_config "db_password" "$PASSWORD"
# check_odoo_config "admin_passwd" "$ADMIN_PASSWD"
check_odoo_config "database" "$DB_NAME"
check_odoo_config "workers" "$WORKER"
check_odoo_config "max-cron-threads" "$CRON_WORKER"
check_odoo_config "addons-path" "$ADDONS_PATH"
check_odoo_config "without-demo" "True"


case "$1" in
    -- | odoo)
        shift
        if [[ "$1" == "scaffold" ]] ; then
            exec odoo "$@"
        else
            wait-for-psql.py ${DB_ARGS[@]} --timeout=30
            exec odoo "$@" "${ODOO_ARGS[@]}"
        fi
        ;;
    -*)
        wait-for-psql.py ${DB_ARGS[@]} --timeout=30
        exec odoo "$@" "${ODOO_ARGS[@]}"
        ;;
    *)
        exec "$@"
esac

exit 1

