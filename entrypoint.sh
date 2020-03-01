#!/bin/bash

DATADIR="/config"

echo "Creating user..."
USER_ID=${LOCAL_USER_ID:-1000}
adduser --home /config --disabled-password --shell /bin/false --gecos "" --uid $USER_ID openttd

echo "Setting necessary permissions..."
chown -R openttd:openttd "$DATADIR"

echo "Starting OpenTTD..."
LASTAUTOSAVE=$(ls --sort=time ${DATADIR}/save/autosave/ | tail -n 1)
if [ -z "$LASTAUTOSAVE" ];
then
    echo "Couldn't find an autosave, starting new game"
    sudo -u openttd /usr/local/bin/openttd -D
else
    echo "Starting from last autosave"
    sudo -u openttd /usr/local/bin/openttd -D -g ${DATADIR}/save/autosave/$LASTAUTOSAVE
fi
