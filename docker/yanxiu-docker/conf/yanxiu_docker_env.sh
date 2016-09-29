#!/bin/bash -
export DOCKER_CTX_ROOT="/var/yanxiu"

export DOCKER_LOG_ROOT="${DOCKER_CTX_ROOT}/logs"
export DOCKER_CTN_LOG="${DOCKER_LOG_ROOT}/docker"
if ! [ -d "$DOCKER_CTN_LOG" ]; then
	mkdir -p $DOCKER_CTN_LOG
fi

export DOCKER_SYS_LOG="${DOCKER_LOG_ROOT}/docker-sys"
if ! [ -d "$DOCKER_SYS_LOG" ]; then
	mkdir -p $DOCKER_SYS_LOG
fi

export DOCKER_DATA_ROOT="${DOCKER_CTX_ROOT}/data/docker"
if ! [ -d "$DOCKER_DATA_ROOT" ]; then
	mkdir -p $DOCKER_DATA_ROOT
fi

export DOCKER_RES_CACHE="$DOCKER_DATA_ROOT/res_cache"
if ! [ -d "$DOCKER_RES_CACHE" ]; then
	mkdir -p $DOCKER_RES_CACHE
fi

export DOCKER_REGISTRY_PORT="5000"
export DOCKER_REGISTRY_DOMAIN="registry.docker.yanxiu.com"
export DOCKER_REGISTRY="${DOCKER_REGISTRY_DOMAIN}:${DOCKER_REGISTRY_PORT}"

INSECURE_OPTS="--insecure-registry ${DOCKER_REGISTRY}"
if [ -z "${DOCKER_OPTS}" ]; then 
    export DOCKER_OPTS="${INSECURE_OPTS}"
else
    export DOCKER_OPTS="${INSECURE_OPTS} ${DOCKER_OPTS}"
fi

