#!/usr/bin/env bash

# Output colors
NORMAL="\\033[0;39m"
RED="\\033[1;31m"
BLUE="\\033[1;34m"

# Names to identify images and containers of this app
IMAGE_NAME='docker_solr'
CONTAINER_NAME="docker_solr_1"

# Useful to run commands as non-root user inside containers
USER="solr"
HOMEDIR="/home/$USER"
EXECUTE_AS="sudo -u $USER HOME=$HOME_DIR"
SCRIPT_DIR=$(dirname "${BASH_SOURCE}")


log() {
  echo -e "$BLUE > $1 $NORMAL"
}

error() {
  echo ""
  echo -e "$RED >>> ERROR - $1$NORMAL"
}

help() {
  echo "-----------------------------------------------------------------------"
  echo "                      Available commands                              -"
  echo "-----------------------------------------------------------------------"
  echo -e -n "$BLUE"
  echo "   > build - To build the Docker image"
  echo "   > serve - To serve Solr on localhost:8983"
  echo "   > up - Remove, build and serve"
  echo "   > stop - Stop the container"
  echo "   > start - Start the container"
  echo "   > bash - Log you into the container"
  echo "   > remove - Remove the container"
  echo "   > help - Display this help"
  echo -e -n "$NORMAL"
  echo "-----------------------------------------------------------------------"

}

build() {
  docker build -t $IMAGE_NAME .

  [ $? != 0 ] && error "Docker image build failed !" && exit 100
}

serve() {
  log "Solr serve"
  docker run -it -d --name="$CONTAINER_NAME" -p 8983:8983 $IMAGE_NAME

  [ $? != 0 ] && error "Solr serve failed !" && exit 105
}

up() {
  echo "Installing"
  remove
  build
  serve
}

bash() {
  log "BASH"
  docker run -it --rm -v $(pwd):/app $IMAGE_NAME /bin/bash
}

stop() {
  docker stop $CONTAINER_NAME
}

start() {
  docker start $CONTAINER_NAME
}

status() {
  state="$(docker inspect -f {{.State.Running}} $CONTAINER_NAME)"
  if [[ "$state" == "true" ]]; then
    CONTAINER_ID=$(docker inspect -f {{.Id}} $CONTAINER_NAME | cut -c 1-10)
    IMAGE_ID=$(docker inspect -f {{.Image}} $CONTAINER_NAME | cut -c 1-10)
    CONTAINER_SCHEMA=$(docker exec $CONTAINER_ID md5sum /opt/solr/server/solr/ccmapper/conf/schema.xml | awk '{print $1;}')
    LOCAL_SCHEMA=$(md5sum "$SCRIPT_DIR/ccmapper/conf/schema.xml" | awk '{print $1;}')
    log "Image id: $IMAGE_ID"
    log "  - Created at: $(docker inspect -f {{.Created}} $IMAGE_ID)"
    log "A container is running"
    log "  - Container id: $CONTAINER_ID"
    log "  - Started at: $(docker inspect -f {{.State.StartedAt}} $CONTAINER_NAME)"
    log "  - Container schema version: $CONTAINER_SCHEMA"
    if [[ "$CONTAINER_SCHEMA" != "$LOCAL_SCHEMA" ]]; then
      log "  !! Container schema is outdated. Latest version is $LOCAL_SCHEMA"
    fi

  else
    log "The container is not running"
  fi
  # docker ps -f "name=$IMAGE_NAME"
}

remove() {
  log "Removing previous container $CONTAINER_NAME" && \
      docker rm -f $CONTAINER_NAME &> /dev/null || true
}

$*