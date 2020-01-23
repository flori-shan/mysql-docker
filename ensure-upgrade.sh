#!/bin/bash

script_name=${0##*/}

function timestamp() {
  date +"%Y/%m/%d %T"
}

function log() {
  local type="$1"
  local msg="$2"
  echo "$(timestamp) [$script_name] [$type] $msg"
}


log "INFO" "Starting mysql server with 'docker-entrypoint.sh mysqld $@'..."
docker-entrypoint.sh mysqld $@ &

pid=$!
log "INFO" "The process id of mysqld is '$pid'"

# wait for the mysql server be running (alive)
log "INFO" "Waiting for the mysql server be running (alive)"
for i in {900..0}; do
  out=$(mysqladmin -uroot --password=${MYSQL_ROOT_PASSWORD} ping 2>/dev/null)
  if [[ "$out" == "mysqld is alive" ]]; then
    break
  fi

  echo -n .
  sleep 1
done

if [[ "$i" == "0" ]]; then
  echo ""
  log "ERROR" "Server start failed ..."
  exit 1
fi

log "INFO" "Server is ready"
log "INFO" "Ensuring the mysql server is upgrading"
mysql_upgrade --user root --password=${MYSQL_ROOT_PASSWORD} --socket /var/run/mysqld/mysqld.sock --force --host=localhost --port=3306

log "INFO" "Waiting for the 'mysqld' process (process id ${pid}) ..."
wait ${pid}
