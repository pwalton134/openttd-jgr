#FROM ich777/debian-baseimage
#FROM ubuntu:latest
FROM debian:stable-slim

LABEL maintainer="github@pwalton134.co.uk"

ENV BUILD_V=58
ENV TZ=Europe/London
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && \
	apt-get -y install --no-install-recommends unzip xz-utils curl liblzma-dev build-essential libsdl1.2-dev zlib1g-dev liblzo2-dev timidity dpatch libfontconfig-dev libicu-dev screen cmake wget locales procps file nano && \
	touch /etc/locale.gen && \
	echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
	locale-gen && \
	apt-get -y install --reinstall ca-certificates && \
	rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
	
ENV DATA_DIR="/serverdata"
ENV SERVER_DIR="${DATA_DIR}/serverfiles"
ENV GAME_PARAMS="template"
ENV GAME_PORT=3979
ENV SERVER_IP=""
ENV GAME_VERSION=1.9.1
ENV COMPILE_CORES=""
ENV GFXPACK_URL=""
ENV UMASK=000
ENV UID=99
ENV GID=100
ENV DATA_PERM=770
ENV USER="openTTD"

EXPOSE $GAME_PORT/tcp
EXPOSE $GAME_PORT/udp
EXPOSE 3978/tcp
EXPOSE 3978/udp

RUN mkdir $DATA_DIR && \
	mkdir $SERVER_DIR && \
	useradd -d $DATA_DIR/serverfiles -s /bin/bash $USER && \
	chown -R $USER $DATA_DIR && \
	ulimit -n 2048

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]
