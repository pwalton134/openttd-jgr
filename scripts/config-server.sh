 #!/bin/bash 
echo "==================================="
echo "| OpenTTD-JGR Patch Configurator  |"
echo "==================================="
echo "|Docker file Ver: $BUILD_V"
echo "|Author: pwalton134"
echo "|Game version requested: ${GAME_VERSION}"
echo "-----------------------------------"

#============================================================================
#INITIAL CHECKS TO DETERMINE CURRENT SERVER STATUS AND WHAT TO DO
#============================================================================
#Check latest version available
LAT_V="$(curl -s https://api.github.com/repos/JGRennison/OpenTTD-patches/releases/latest | grep tag_name | cut -d '"' -f4)"
if [ -z $LAT_V ]; then				#ref https://ryanstutorials.net/bash-scripting-tutorial/bash-if-statements.php and https://stackoverflow.com/questions/18096670/what-does-z-mean-in-bash and https://tldp.org/LDP/abs/html/comparison-ops.html
	echo "Error:  Could not determine latest available version.  Is the server able to access the internet, or has the source file on github moved or been changed?  If latest was selected during container setup, the build will fail.  Enter a game version manually in the interim, i.e. jgrpp-0.38.0"
else
	echo "Latest available: $LAT_V"
fi

#Define version of game to install.  If latest, then use result from LAT_V
if [ "${GAME_VERSION}" = "latest" ]; then
	INSTALL_V=$LAT_V
else
	INSTALL_V=${GAME_VERSION}
fi

#Check if game is already installed
if [ ! -f /usr/local/games/openttd ]; then
	INSTALLED=0
	echo "---OpenTTD not found---"
else
	INSTALLED=1
	echo "---OpenTTD found---"
fi

#Check current installed version if installed
if [ $INSTALLED = 1 ]; then
	INSTALLED_V="$(find ${SERVER_DIR}/ -name installed_v_* -print -quit)"
	INSTALLED_V="${INSTALLED_V##*_}"	#ref https://stackoverflow.com/questions/19482123/extract-part-of-a-string-using-bash-cut-split
	if [ -z ${INSTALLED_V} ]; then
		echo "WARNING: Could not determine installed version or directory not clean.  Deleting all files with names begining 'installed_v_*' in the /serverdata/serverfiles/ directory and building fresh"
		rm ${SERVER_DIR}/installed_v_*
		INSTALLED=0
	else
		echo "Installed version: $INSTALLED_V"
		DOWNLOAD_INSTALL=0
	fi
fi


#Download requested version if not installed and extract to /compileopenttd.
if [ $INSTALLED = 0 ]; then
	echo "---Downloading OpenTTD---"
	echo "Clearing any old build data"
	rm -r ${SERVER_DIR}/compileopenttd
	rm jgrpp*

	echo "Downloading: https://github.com/JGRennison/OpenTTD-patches/archive/jgrpp-$INSTALL_V.tar.gz"
		if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${SERVER_DIR}/$INSTALL_V https://github.com/JGRennison/OpenTTD-patches/archive/$INSTALL_V.tar.gz ; then
          		echo "Successfully downloaded OpenTTD v$INSTALL_V---"
			mkdir ${SERVER_DIR}/compileopenttd
			echo "Extracting ${SERVER_DIR}/$INSTALL_V.tar.gz to ${SERVER_DIR}/compileopenttd/"
			tar -xf ${SERVER_DIR}/$INSTALL_V -C ${SERVER_DIR}/compileopenttd/
			DOWNLOAD_INSTALL=1
		else
        		DOWNLOAD_INSTALL=0
			echo "FATAL: Can't download OpenTTD v$INSTALL_V putting server into sleep mode.  Check URLs, connectivity and/or try again later."
            		sleep infinity
		fi
fi

#Configure, make and install downloaded files
if [ $DOWNLOAD_INSTALL == 1 ]; then
	echo "---Installing OpenTTD---"
	echo "Running build scripts"
	#find cmake for dedicated server build
	BUILDDED="$(find ${SERVER_DIR}/compileopenttd -name build-dedicated.sh -print -quit)"
	#find cmake for building installer bundle (.deb) - not currently used by JGRennison but may be in future
	#BUILDBUN="$(find ${SERVER_DIR}/compileopenttd -name make_bundle.sh -print -quit)"
	#Set root dir
	COMPVDIR="$(dirname $BUILDDED)"

	if [ ! -z "${COMPILE_CORES}" ]; then
    		CORES_AVAILABLE=${COMPILE_CORES}
	else
		CORES_AVAILABLE="$(getconf _NPROCESSORS_ONLN)"
	fi

	echo "Cores available: $CORES_AVAILABLE"
	echo "...compiling Openttd"
	$BUILDDED

	cd ${COMPVDIR}/build

	echo "...making Openttd"
	make --jobs=$CORES_AVAILABLE

	#echo "...making install bundle"
	#$BUILDBUN <-- don't use this script as it throws a versioning issue error when installing the .deb via dpkg / apt.  Use make and make install as per JGR compile instructions.

	echo "...installing OpenTTD"
	make install

	echo "...removing temporary compiler dir"
	rm -R ${SERVER_DIR}/compileopenttd

	echo "...renaming $INSTALL_V to installed_v_$INSTALL_V"
	cd $SERVER_DIR
	mv ./$INSTALL_V ./installed_v_$INSTALL_V

	echo "...checking Openttd installed correctly"
	if [ ! -f /usr/local/games/openttd ]; then 
		echo "FATAL: Something went wrong, couldn't install OpenTTD v$INSTALL_V---"
		sleep infinity
    	else
                echo "...exporting path to openttd"
                export PATH=$PATH:/usr/local/games/
		echo "---OpenTTD v$INSTALL_V installed successfully!---"
    	fi
	echo "Build and installation complete!"
else
	echo "Installation not required.  Skipping compile"
fi

#Move game data dir to /.openTTD
	if [ ! -d ${SERVER_DIR}/.openttd ]; then
		echo "Copying data dir to user space"
		cp /root/.openttd ${SERVER_DIR}/ -r
	else
		echo "Data dir found in user space"
	fi

#Install Baseset, if required
    	if [ ! -d ${SERVER_DIR}/.openttd/baseset ]; then
		echo "---OpenGFX setup---"
	        echo "Baseset directory not found.  Creating..."
		cd ${SERVER_DIR}/.openttd
        	mkdir baseset
	        cd ${SERVER_DIR}/.openttd/baseset
        fi

	if [ -z "$(ls -A ${SERVER_DIR}/.openttd/baseset)" ]; then
		echo "Baseset directory found, but empty"
                echo "---OpenGFX not found, downloading...---"
		cd ${SERVER_DIR}/.openttd/baseset
                if wget -q -nc --show-progress --progress=bar:force:noscroll ${GFXPACK_URL} ; then
                        echo "---Successfully downloaded OpenGFX---"
                else
                        echo "FATAL: Can't download OpenGFX putting server into sleep mode---"
                        sleep infinity
                fi
                unzip ${GFXPACK_URL##*/}
                TAR="$( echo "${GFXPACK_URL##*/}" | rev | cut -d "." -f2- | rev)"
                tar -xf $TAR.tar
                mv ${SERVER_DIR}/.openttd/baseset/${TAR}/* ${SERVER_DIR}/.openttd/baseset
                rm ${GFXPACK_URL##*/}
                rm -R $TAR
                rm $TAR.tar
                GFX="$(find ${SERVER_DIR}/.openttd/baseset -maxdepth 1 -name '*grf')"
                if [ -z "$GFX" ]; then
                        echo "FATAL: Something went wrong, couldn't install OpenGFX---"
                        sleep infinity
                fi

	else
		echo "---OpenGFX found---"
	fi

	chown -R openTTD:users ${SERVER_DIR}/.openttd

#Setup Complete
echo "==================================="
echo "| OpenTTD configuration complete! |"
echo "==================================="
echo ""

echo "Checking permissions and clearing logs..."
chown -R openTTD:users ${DATA_DIR}
chmod -R ${DATA_PERM} ${DATA_DIR}
find ${SERVER_DIR} -name "masterLog.*" -exec rm -f {} \;
echo "...done!"
echo "---Server Ready!---"
echo "Calling server execution script..."
su ${USER} -c "/opt/scripts/start-server.sh"

