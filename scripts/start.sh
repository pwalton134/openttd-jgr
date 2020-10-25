#!/bin/bash
echo "================================"
echo "|      Init server scripts     |"
echo "|------------------------------|"
echo "Docker build: $BUILD_V"
echo "================================"
echo "---Checking if UID: ${UID} matches user---"
usermod -u ${UID} ${USER}
echo "---Checking if GID: ${GID} matches user---"
usermod -g ${GID} ${USER}
echo "---Setting umask to ${UMASK}---"
umask ${UMASK}

echo "---Checking for optional scripts---"
if [ -f /opt/scripts/user.sh ]; then
	echo "---Found optional script, executing---"
    chmod +x /opt/scripts/user.sh
    /opt/scripts/user.sh
else
	echo "---No optional script found, continuing---"
fi

echo "---Starting...---"
chown -R ${UID}:${GID} /opt/scripts
/opt/scripts/config-server.sh
