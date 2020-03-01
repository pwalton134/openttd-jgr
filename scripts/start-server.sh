#!/bin/bash
echo "Game version = ${GAME_VERSION}"

if [ "${GAME_VERSION}" = "latest" ]; then
	echo "---Getting latest OpenTTD build version...---"
    LAT_V="$(curl -s https://api.github.com/repos/JGRennison/OpenTTD-patches/releases/latest | grep tag_name | cut -d '"' -f4)"
    echo "---Latest OpenTTD build version is: $LAT_V---"
    INSTALL_V=$LAT_V
    if [ -z $LAT_V ]; then
    	echo "---Something went wrong, couldn't get latest build version---"
        sleep infinity
    fi
else
	INSTALL_V=${GAME_VERSION}
fi

if [ ! -f ${SERVER_DIR}/games/openttd ]; then
	echo
    echo "-------------------------------------"
	echo "---OpenTTD not found! Downloading,---"
    echo "---compiling and installing v$INSTALL_V---"
    echo "---Please be patient, this can take--"
    echo "---some time, waiting 15 seconds..---"
    echo "-------------------------------------"
    sleep 15
    cd ${SERVER_DIR}
    if [ "${GAME_VERSION}" = "latest" ]; then
    	##if wget -q -nc --show-progress --progress=bar:force:noscroll -O installed_v_$INSTALL_V https://github.com/JGRennison/OpenTTD-patches/archive/jgrpp-$INSTALL_V.tar.gz ; then
    	if wget -q -nc --show-progress --progress=bar:force:noscroll -O installed_v_$INSTALL_V https://github.com/JGRennison/OpenTTD-patches/archive/$INSTALL_V.tar.gz ; then
        	echo "---Successfully downloaded OpenTTD v$INSTALL_V---"
		else
        	echo "---Can't download OpenTTD v$INSTALL_V putting server into sleep mode---"
            sleep infinity
		fi
    else
    	if wget -q -nc --show-progress --progress=bar:force:noscroll -O installed_v_$INSTALL_V https://github.com/JGRennison/OpenTTD-patches/archive/jgrpp-$INSTALL_V.tar.gz ; then
          	echo "---Successfully downloaded OpenTTD v$INSTALL_V---"
		else
        	echo "---Can't download OpenTTD v$INSTALL_V putting server into sleep mode---"
            sleep infinity
		fi
    fi
    mkdir compileopenttd
	tar -xf installed_v_$INSTALL_V -C ${SERVER_DIR}/compileopenttd/
	COMPVDIR="$(find ${SERVER_DIR}/compileopenttd -name open* -print -quit)"
	cd $COMPVDIR
	$COMPVDIR/configure --prefix-dir=/serverdata/serverfiles --enable-dedicated --personal-dir=/serverfiles/openttd
    if [ ! -z "${COMPILE_CORES}" ]; then
    	CORES_AVAILABLE=${COMPILE_CORES}
    else
		CORES_AVAILABLE="$(getconf _NPROCESSORS_ONLN)"
    fi
	make --jobs=$CORES_AVAILABLE
	make install
	rm -R ${SERVER_DIR}/compileopenttd
	if [ ! -f ${SERVER_DIR}/games/openttd ]; then 
		echo "---Something went wrong, couldn't install OpenTTD v$INSTALL_V---"
        sleep infinity
    else
    	echo "---OpenTTD v$INSTALL_V installed---"
    fi
    if [ ! -d ${SERVER_DIR}/games/baseset ]; then
    	echo "---OpenGFX not found, downloading...---"
        cd ${SERVER_DIR}/games
        mkdir baseset
        cd ${SERVER_DIR}/games/baseset
        if wget -q -nc --show-progress --progress=bar:force:noscroll ${GFXPACK_URL} ; then
        	echo "---Successfully downloaded OpenGFX---"
		else
        	echo "---Can't download OpenGFX putting server into sleep mode---"
            sleep infinity
		fi
		unzip ${GFXPACK_URL##*/}
		TAR="$( echo "${GFXPACK_URL##*/}" | rev | cut -d "." -f2- | rev)"
		tar -xf $TAR.tar
        mv ${SERVER_DIR}/games/baseset/${TAR}/* ${SERVER_DIR}/games/baseset
		rm ${GFXPACK_URL##*/}
        rm -R $TAR
		rm $TAR.tar
        GFX="$(find ${SERVER_DIR}/games/baseset -maxdepth 1 -name '*grf')"
        if [ -z "$GFX" ]; then
        	echo "---Something went wrong, couldn't install OpenGFX---"
            sleep infinity
        fi
	else
    	echo "---OpenGFX found---"
    fi
fi

CUR_V="$(find ${SERVER_DIR} -name installed_v_* | cut -d "_" -f3)"
if [ "$INSTALL_V" != "$CUR_V" ]; then
	echo
    echo "-------------------------------------------------"
	echo "---Version missmatch, installing v$INSTALL_V----------"
	echo "------Changing from v$CUR_V to v$INSTALL_V-------------"
    echo "----Please be patient this can take some time----"
    echo "---------------Waiting 15 seconds----------------"
    echo "-------------------------------------------------"
    echo
    sleep 15
    cd ${SERVER_DIR}
    rm installed_v_$CUR_V
    rm -R games
    rm -R share
    if [ "${GAME_VERSION}" = "latest" ]; then
    	if wget -q -nc --show-progress --progress=bar:force:noscroll -O installed_v_$INSTALL_V https://github.com/JGRennison/OpenTTD-patches/archive/$INSTALL_V.tar.gz ; then
        	echo "---Successfully downloaded OpenTTD v$INSTALL_V---"
		else
        	echo "---Can't download OpenTTD v$INSTALL_V putting server into sleep mode---"
            sleep infinity
		fi
    else
    	if wget -q -nc --show-progress --progress=bar:force:noscroll -O installed_v_$INSTALL_V https://github.com/JGRennison/OpenTTD-patches/archive/jgrpp-$INSTALL_V.tar.gz ; then
          	echo "---Successfully downloaded OpenTTD v$INSTALL_V---"
		else
        	echo "---Can't download OpenTTD v$INSTALL_V putting server into sleep mode---"
            sleep infinity
		fi
    fi
	mkdir compileopenttd
	tar -xf installed_v_$INSTALL_V -C ${SERVER_DIR}/compileopenttd/
	COMPVDIR="$(find ${SERVER_DIR}/compileopenttd -name openttd-* -print -quit)"
	cd $COMPVDIR
	$COMPVDIR/configure --prefix-dir=/serverdata/serverfiles --enable-dedicated --personal-dir=/serverfiles/openttd
    if [ ! -z "${COMPILE_CORES}" ]; then
    	CORES_AVAILABLE=${COMPILE_CORES}
    else
		CORES_AVAILABLE="$(getconf _NPROCESSORS_ONLN)"
    fi
	make --jobs=$CORES_AVAILABLE
	make install
	rm -R ${SERVER_DIR}/compileopenttd
	if [ ! -f ${SERVER_DIR}/games/openttd ]; then 
		echo "---Something went wrong, couldn't install OpenTTD v$INSTALL_V---"
        sleep infinity
    else
    	echo "---OpenTTD v$INSTALL_V installed---"
    fi
    if [ ! -d ${SERVER_DIR}/games/baseset ]; then
    	echo "---OpenGFX not found, downloading...---"
        cd ${SERVER_DIR}/games
        mkdir baseset
        cd ${SERVER_DIR}/games/baseset
        if wget -q -nc --show-progress --progress=bar:force:noscroll ${GFXPACK_URL} ; then
        	echo "---Successfully downloaded OpenGFX---"
		else
        	echo "---Can't download OpenGFX putting server into sleep mode---"
            sleep infinity
		fi
		unzip ${GFXPACK_URL##*/}
		TAR="$( echo "${GFXPACK_URL##*/}" | rev | cut -d "." -f2- | rev)"
		tar -xf $TAR.tar
        mv ${SERVER_DIR}/games/baseset/${TAR}/* ${SERVER_DIR}/games/baseset
		rm ${GFXPACK_URL##*/}
        rm -R $TAR
		rm $TAR.tar
        GFX="$(find ${SERVER_DIR}/games/baseset -maxdepth 1 -name '*grf')"
        if [ -z "$GFX" ]; then
        	echo "---Something went wrong, couldn't install OpenGFX---"
            sleep infinity
        fi
	else
    	echo "---OpenGFX found---"
    fi
else
	echo "---OpenTTD v$LAT_V found---"
fi

if [ ! -d ${SERVER_DIR}/games/baseset ]; then
	echo "---OpenGFX not found, downloading...---"
    cd ${SERVER_DIR}/games
    mkdir baseset
    cd ${SERVER_DIR}/games/baseset
	if wget -q -nc --show-progress --progress=bar:force:noscroll ${GFXPACK_URL} ; then
		echo "---Successfully downloaded OpenGFX---"
	else
		echo "---Can't download OpenGFX putting server into sleep mode---"
		sleep infinity
	fi
	unzip ${GFXPACK_URL##*/}
	TAR="$( echo "${GFXPACK_URL##*/}" | rev | cut -d "." -f2- | rev)"
	tar -xf $TAR.tar
    mv ${SERVER_DIR}/games/baseset/${TAR}/* ${SERVER_DIR}/games/baseset
	rm ${GFXPACK_URL##*/}
    rm -R $TAR
	rm $TAR.tar
    GFX="$(find ${SERVER_DIR}/games/baseset -maxdepth 1 -name '*grf')"
    if [ -z "$GFX" ]; then
    	echo "---Something went wrong, couldn't install OpenGFX---"
        sleep infinity
    fi
else
	echo "---OpenGFX found---"
fi

echo "---Prepare Server---"
chmod -R ${DATA_PERM} ${DATA_DIR}
echo "---Checking for old logs---"
find ${SERVER_DIR} -name "masterLog.*" -exec rm -f {} \;
echo "---Server ready---"

echo "---Start Server---"
cd ${SERVER_DIR}
screen -S OpenTTD -L -Logfile ${SERVER_DIR}/masterLog.0 -d -m ${SERVER_DIR}/games/openttd -D ${GAME_PARAMS}
sleep 2
tail -f ${SERVER_DIR}/masterLog.0
