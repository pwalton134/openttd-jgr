#Docker conf cloned from https://github.com/mijndert/openttd-docker/blob/master/Dockerfile
#All work derived from and credit to go to https://github.com/mijndert

FROM debian:stable-slim
LABEL maintainer P W "docker@pwalton134.co.uk"

ARG OPENTTD_VERSION="0.33.2"
ARG OPENGFX_VERSION="0.5.5"

# Get things ready
RUN mkdir -p /config \
    && mkdir /tmp/build

# Install some build dependencies (we remove these later to save space)
RUN apt-get update && \
    apt-get install -y \
    unzip \
    sudo \
    wget \
    git \
    g++ \
    make \
    patch \
    zlib1g-dev \
    liblzma-dev \
    liblzo2-dev \
    pkg-config

# Build OpenTTD itself
WORKDIR /tmp/build

RUN git clone https://github.com/JGRennison/OpenTTD-patches.git . \
    && git fetch --tags \
    && git checkout ${OPENTTD_VERSION}

RUN /tmp/build/configure \
    --enable-dedicated \
    --binary-dir=bin \
    --personal-dir=/ \
    —-enable-debug

RUN make -j4 \
    && make install

## Install OpenGFX
RUN mkdir -p /usr/local/share/games/openttd/baseset/ \
    && cd /usr/local/share/games/openttd/baseset/ \
    && wget -q http://bundles.openttdcoop.org/opengfx/releases/${OPENGFX_VERSION}/opengfx-${OPENGFX_VERSION}.zip \
    && unzip opengfx-${OPENGFX_VERSION}.zip \
    && tar -xf opengfx-${OPENGFX_VERSION}.tar \
    && rm -rf opengfx-*.tar opengfx-*.zip

# Add the entrypoint
ADD entrypoint.sh /entrypoint.sh

# Expose the volume
VOLUME /config

# Expose the gameplay port
EXPOSE 3979/tcp
EXPOSE 3979/udp

# Expose the admin port
EXPOSE 3977/tcp

# Tidy up after ourselves
# note: we don't remove libraries and compilers otherwise bad linking things happen
RUN apt-get remove -y \
    make \
    patch \
    git \
    wget

RUN rm -r /tmp/build

# Finally, let's run OpenTTD!
ENTRYPOINT ["/entrypoint.sh"]
CMD [""]
