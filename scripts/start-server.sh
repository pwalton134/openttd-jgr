#!/bin/bash

#START SERVER
echo "================================"
echo "|     Starting Game Server     |"
echo "|------------------------------|"
echo "Docker build: $BUILD_V"
echo "================================"

echo "Starting server execution script"
echo "...exporting path to openttd"
export PATH=$PATH:/usr/local/games/
echo "---Start Server---"
cd ${SERVER_DIR} 

if [ "$GAME_PARAMS" = "last-game" ]; then
        if [ -z "$(ls -A ${SERVER_DIR}/.openttd/save/autosave)" ]; then
                echo "Autosave directory found, but empty"
                echo "Starting a new game instead..."
                screen -S OpenTTD -L -Logfile ${SERVER_DIR}/masterLog.0 -d -m openttd -D ${SERVER_IP}:${GAME_PORT}
        else
                savegame=${SERVER_DIR}/.openttd/save/autosave/`ls -rt ${SERVER_DIR}/.openttd/save/autosave/ | tail -n1`
                if [ -r ${savegame} ]; then
                        echo "Last-game option specified.  Attempting to load now..."
                        echo "Loading ${savegame}"
                        #screen -S OpenTTD -L -Logfile ${SERVER_DIR}/masterLog.0 -d -m ${SERVER_DIR}/openttd/openttd -D -g ${savegame} -x
                        screen -S OpenTTD -L -Logfile ${SERVER_DIR}/masterLog.0 -d -m openttd -D ${SERVER_IP}:${GAME_PORT} -g ${savegame} -x
                        
                else
                        echo "${savegame} not found..."
                        screen -S OpenTTD -L -Logfile ${SERVER_DIR}/masterLog.0 -d -m openttd -D ${SERVER_IP}:${GAME_PORT}
                fi
        fi
else
        echo "Load last game not specified (use last-game parameter to invoke)"
        screen -S OpenTTD -L -Logfile ${SERVER_DIR}/masterLog.0 -d -m openttd -D ${SERVER_IP}:${GAME_PORT} ${GAME_PARAMS}
fi

sleep 2
tail -f ${SERVER_DIR}/masterLog.0
sleep infinity
