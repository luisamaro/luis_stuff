#!/usr/bin/env bash

NOW=$(date "+%F_%H-%M-%S")

DOCKER_PROXY_CONF_FILE=/etc/systemd/system/docker.service.d/http-proxy.conf

PROXY=
LOGS_DIR_PATH=
SK4_BASE_VOLUME=
ENV_NAME=$(hostname -f | awk -F'.' '{print $(NF-1)}')

collect_container_logs(){
  local _container=$1
  { docker container logs "${_container}" 2> /dev/null || echo "no such container - ${_container}"; } > "container_log_${_container}.log";
}

collect_all_container_logs(){
  local _array=( sk4tomcat sk4consoleconsumer sk4appconnect sk4siemconsumer sk4kafka sk4healthreport sk4userinformation sk4taskmanagement sk4zookeeper sk4postgres sk4graphite )
  for i in "${_array[@]}"
  do
    collect_container_logs "${i}"
  done
}

collect_thread_dump(){
  local _container=$1
  { docker container exec "${_container}" bash -c 'curl http://localhost:8081/threads' 2> /dev/null || echo "no such container - ${_container}"; } > "threaddump_${_container}.log";
}

collect_all_thread_dumps(){
  local _array=( sk4consoleconsumer sk4appconnect sk4siemconsumer sk4healthreport sk4userinformation sk4taskmanagement )
  for i in "${_array[@]}"
  do
    collect_thread_dump "${i}"
  done
}

find_proxy_from_file(){

    local _proxy=""

    if [[ -f ${DOCKER_PROXY_CONF_FILE} ]]
    then
        # detect_existing_proxy_settings
        vars=$(cat ${DOCKER_PROXY_CONF_FILE})
        proxyFullNew="HTTPS_PROXY=(.*)"
        envFile="EnvironmentFile=(.*)"
        if [[ "$vars" =~ $proxyFullNew ]]; then
           _proxy=${BASH_REMATCH[1]}
        elif [[ "$vars" =~ $envFile ]]; then
           _envFile=${BASH_REMATCH[1]}
           if [[ -f "${_envFile}" ]]
           then
               vars=$(cat "${_envFile}")
               if [[ "$vars" =~ $proxyFullNew ]]; then
                   _proxy="${BASH_REMATCH[1]}"
               fi
            fi
        fi
    fi

    echo "${_proxy}"
}


get_volume_local_path() {
    local _volumeName; _volumeName="${1}"
    local _path; _path="$(docker volume inspect --format='{{.Options.device}}' "${_volumeName}")"
    if [[ "${_path}" == "<no value>" ]]; then
      docker volume inspect --format='{{.Mountpoint}}' "${_volumeName}"
    else
      echo "${_path}"
    fi
}

update_base() {
    local _serviceFile; _serviceFile="${1}"
    local _composeFileRegex; _composeFileRegex="-f (.*)/docker-compose.yml .*up"
    local _fileAsString; _fileAsString="$(cat "${_serviceFile}")"

    if [[ "${_fileAsString}" =~ ${_composeFileRegex} ]]
    then
        SK4_BASE_VOLUME="${BASH_REMATCH[1]}"
        echo "Base volume set to $SK4_BASE_VOLUME"
    else
        echo "$_serviceFile doesn't contain docker compose yml file"
        exit 1
    fi
}

COMPOSE_SERVICE_FILE=/etc/systemd/system/sk4compose.service

if [[ ! -f ${COMPOSE_SERVICE_FILE} ]]
then
    echo "Pre-compose installation. Please contact support at support@skyformation.com"
    exit 1
fi

# use configured proxy is exists
# detect_existing_proxy_settings
PROXY=$(find_proxy_from_file)

if [[ ${PROXY} ]] ; then
    echo "Using proxy: $PROXY"
    export "https_proxy=${PROXY}"
fi

update_base ${COMPOSE_SERVICE_FILE}
LOGS_DIR_PATH=$(get_volume_local_path sk4_logs)

if [[ -z "$LOGS_DIR_PATH" ]]
then
  echo "no installation found!"
  exit 1
fi

echo "LOGS_DIR_PATH: ${LOGS_DIR_PATH}"

GRAPHITE_DIR_PATH=$(get_volume_local_path sk4_graphite_data)
if [[ -d "${GRAPHITE_DIR_PATH}" ]]
then
    echo "Collecting Graphite data"
    tar -zcf graphite-data.tar.gz "${GRAPHITE_DIR_PATH}"
    mkdir -p "${LOGS_DIR_PATH}/graphite-data"
    mv "graphite-data.tar.gz" "${LOGS_DIR_PATH}/graphite-data/"
else
    echo "> Graphite data folder not found"
fi

echo "Anonymizing docker-compose yml"
mkdir -p "${LOGS_DIR_PATH}/docker-compose-yml"
cp "${SK4_BASE_VOLUME}/docker-compose*.yml" "${LOGS_DIR_PATH}/docker-compose-yml/"
sed -i -E 's/SKYFORMATION_ENC_KEY\=\w+/SKYFORMATION_ENC_KEY\=HIDDEN/g' "${LOGS_DIR_PATH}/docker-compose-yml/docker-compose.yml"

echo "Collecting install and update logs"
mkdir -p "${LOGS_DIR_PATH}/install-and-upgrade-logs"
cp "${HOME}/sk4-installation-at-*" "${LOGS_DIR_PATH}/install-and-upgrade-logs/"
cp "${HOME}/sk4-update-at-*" "${LOGS_DIR_PATH}/install-and-upgrade-logs/"

echo "Collecting service file"
mkdir -p "${LOGS_DIR_PATH}/systemd-service"
cp "${COMPOSE_SERVICE_FILE}" "${LOGS_DIR_PATH}/systemd-service/"

echo "Collecting container logs"
mkdir -p "${LOGS_DIR_PATH}/container-logs"
collect_all_container_logs
mv container_log_* "${LOGS_DIR_PATH}/container-logs"

echo "Collecting thread dumps"
mkdir -p "${LOGS_DIR_PATH}/thread-dumps"
collect_all_thread_dumps
mv threaddump_* "${LOGS_DIR_PATH}/thread-dumps"

FILE_NAME="logs-${NOW}-${ENV_NAME}.tar.gz"

# tar and compress logs
tar czf ~/"${FILE_NAME}" "${LOGS_DIR_PATH}"

