#!/bin/sh

export COMPOSE_FILE_PATH="${PWD}/target/classes/docker/docker-compose.yml"

if [ -z "${M2_HOME}" ]; then
  export MVN_EXEC="mvn"
else
  export MVN_EXEC="${M2_HOME}/bin/mvn"
fi

start() {
    docker volume create helloworld-cm-acs-volume
    docker volume create helloworld-cm-db-volume
    docker volume create helloworld-cm-ass-volume
    docker-compose -f "$COMPOSE_FILE_PATH" up --build -d
}

start_share() {
    docker-compose -f "$COMPOSE_FILE_PATH" up --build -d helloworld-cm-share
}

start_acs() {
    docker-compose -f "$COMPOSE_FILE_PATH" up --build -d helloworld-cm-acs
}

down() {
    if [ -f "$COMPOSE_FILE_PATH" ]; then
        docker-compose -f "$COMPOSE_FILE_PATH" down
    fi
}

purge() {
    docker volume rm -f helloworld-cm-acs-volume
    docker volume rm -f helloworld-cm-db-volume
    docker volume rm -f helloworld-cm-ass-volume
}

build() {
    $MVN_EXEC clean package
}

build_share() {
    docker-compose -f "$COMPOSE_FILE_PATH" kill helloworld-cm-share
    yes | docker-compose -f "$COMPOSE_FILE_PATH" rm -f helloworld-cm-share
    $MVN_EXEC clean package -pl helloworld-cm-share,helloworld-cm-share-docker
}

build_acs() {
    docker-compose -f "$COMPOSE_FILE_PATH" kill helloworld-cm-acs
    yes | docker-compose -f "$COMPOSE_FILE_PATH" rm -f helloworld-cm-acs
    $MVN_EXEC clean package -pl helloworld-cm-integration-tests,helloworld-cm-platform,helloworld-cm-platform-docker
}

tail() {
    docker-compose -f "$COMPOSE_FILE_PATH" logs -f
}

tail_all() {
    docker-compose -f "$COMPOSE_FILE_PATH" logs --tail="all"
}

prepare_test() {
    $MVN_EXEC verify -DskipTests=true -pl helloworld-cm-platform,helloworld-cm-integration-tests,helloworld-cm-platform-docker
}

test() {
    $MVN_EXEC verify -pl helloworld-cm-platform,helloworld-cm-integration-tests
}

case "$1" in
  build_start)
    down
    build
    start
    tail
    ;;
  build_start_it_supported)
    down
    build
    prepare_test
    start
    tail
    ;;
  start)
    start
    tail
    ;;
  stop)
    down
    ;;
  purge)
    down
    purge
    ;;
  tail)
    tail
    ;;
  reload_share)
    build_share
    start_share
    tail
    ;;
  reload_acs)
    build_acs
    start_acs
    tail
    ;;
  build_test)
    down
    build
    prepare_test
    start
    test
    tail_all
    down
    ;;
  test)
    test
    ;;
  *)
    echo "Usage: $0 {build_start|build_start_it_supported|start|stop|purge|tail|reload_share|reload_acs|build_test|test}"
esac