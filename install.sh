#!/bin/bash 

if [ "$(whoami)" == 'root' ]; then 
  echo "Ахтунг: под учетной записью рута работать отказываюсь!" 
  exit 1 
fi

#NUMBER OF CPU CORES USED FOR COMPILATION
if [ "$1" == "" ]; then
    CORES="$(cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l)"
else
    CORES="$1"
fi

ENVPLATFOM="$(uname)"
ENVARCH="$(uname -m)"
ENVTYPE="$(uname -o)"
ENVREL="$(uname -r)"

#ENVPLATFOM="MSYS_NT-5.1"
#ENVARCH="Test"
#ENVTYPE="Msys"
#ENVREL="1.0.11(0.46/3/2)"

echo "$ENVPLATFOM" "$ENVREL" "$ENVARCH" "$ENVTYPE"

case $ENVTYPE in
   "MacOS" ) # fixme add support this platform
 	   echo -e "You seem to be running MacOS X Env"
	    # TODO Here
	;;  
  
   "Msys" | "Cygwin" )
     
	 echo -e "You seem to be running either Windows family OS, or other Windows-like build type"
	
    #Check Windows Env And Install Deps
	 echo -e "\n>> Checking which environment is use"
	  case $ENVPLATFOM in
	"MINGW64*" | "MINGW32_NT-5.1" | "MSYS_NT-5.1" ) # fixme add other ver MINGW/MSYS
	
		if [ "$ENVREL" == "1.0.11(0.46/3/2)" ]; then # Is Msys1 OR Msys2? fixme is not work correct & add other ver for msys 1
		echo -e "You seem to be running MSYS 1 MINGW32 Env"
		# TODO Here
		# Msys1 prepare
		
		else
	    echo -e "You seem to be running MSYS 2 MINGW32 Env"
	    # TODO Here
		# Msys2 prepare
		#Install MSYS2 MINGW32 / MINGW64
		
		#echo -e "Update the package list. You might have to restart your shell again."
		# pacman -Syuu   # update the package list, broken on nt-5.1
		
	    #If you installed 64-bit MSYS2, then do
		# pacman -S base-devel mingw-w64-x86_64-toolchain
		#If you installed 32-bit MSYS2, then do
		 pacman -Sy base-devel mingw-w64-i686-toolchain   
		
		 pacman -Sy git mingw-w64-i686-cmake mingw-w64-i686-boost mingw-w64-i686-openal mingw-w64-i686-OpenSceneGraph mingw-w64-i686-bullet mingw-w64-i686-qt5 mingw-w64-i686-ffmpeg mingw-w64-x86_64-SDL2 mingw-w64-i686-ncurses mingw-w64-i686-clang mingw-w64-i686-llvm #unshield #mygui  #clang35 llvm35 #libxkbcommon-x11
		
	    #echo -e "\nIf you wish to build OpenSceneGraph from source\nhttps://wiki.openmw.org/index.php?title=Development_Environment_Setup#Build_and_install_OSG\n\nType YES if you want the script to do it automatically (THIS IS BROKEN ATM)\nIf you already have it installed or want to do it manually,\npress ENTER to continue"
        #read INPUT
        #if [ "$INPUT" == "YES" ]; then
        #      echo -e "\nOpenSceneGraph will be built from source"
        #      BUILD_OSG=true       
        #fi
        
        BUILD_UNSHIELD=true
    	#BUILD_BOOST=true
    	#BUILD_SDL2=true    	
        #BUILD_OSG=true
        #BUILD_BULLET=true
        BUILD_MYGUI=true
        #BUILD_OPENAL=true
    	#BUILD_FFMPEG=true
        BUILD_TERRA=true
		
		fi
		;;
	"CYGWIN*" | "CYGWIN_NT-5.1" | "CYGWIN_NT-10.0-WOW" | "CYGWIN_NT-10.0" ) # fixme add other ver CYGWIN
	   echo -e "You seem to be running CYGWIN Env"
	    # TODO Here
	    # Cygwin prepare
	    #apt-cyg is a Cygwin package manager. It includes a command-line installer for Cygwin
	    # which cooperates with Cygwin Setup and uses the same repository.
	    # github.com/transcode-open/apt-cyg
	    
	    #apt-cyg is a simple script. To install:
		if [ ! -f /bin/apt-cyg ]; then
        #lynx -source rawgit.com/transcode-open/apt-cyg/master/apt-cyg > apt-cyg
        wget https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg -O apt-cyg # If don't hawe lynx, use wget
        install apt-cyg /bin
	    fi
		
	    apt-cyg update
	    #some need for use MXE
	    apt-cyg install git cmake p7zip bison flex gperf intltool scons ruby cygport gcc-fortran diffutils binutils libass-devel autogen libgda5.0-devel libminizip-devel libxml2-devel libfftw3-devel libchromaprint-devel texinfo libgdk_pixbuf2.0-devel libboost-devel libopenal-devel libogg-devel libvorbis-devel libjpeg-devel libpng-devel libtiff-devel libgif-devel libjasper-devel libSDL2-devel libX11-devel libQt5Core-devel libQt53D-devel libncurses-devel libgmp-devel libnettle-devel libfreetype-devel lua5.1-devel gnutls-devel ladspa-sdk openssl-devel gcc-g++ make yasm ncurses gettext-devel w32api-headers doxygen wget lynx clang llvm libclang-devel libllvm3.5-devel subversion #libQtCore4-devel #cygwin64-gcc-g++ #cygwin64-w32api-headers   #& other deps etc...
        
        # If use MinGW under Cygwin then do (not implement/tested yet )
        # for x32
		#if [ "$ENVPLATFOM" == "CYGWIN_NT-10.0" ]; then 
        #apt-cyg install mingw64-i686-openal mingw64-i686-SDL2 mingw64-i686-qt5-base mingw64-i686-freetype2 mingw64-i686-gcc-g++ mingw64-i686-ncurses #mingw64-i686-clang #mingw64-i686-llvm 
        #
		#else
        # or x64
        #apt-cyg install mingw64-x86_64-openal mingw64-x86_64-SDL2 mingw64-x86_64-qt5-base mingw64-x86_64-freetype2 mingw64-x86_64-gcc-g++ mingw64-x86_64-ncurses #mingw64-x86_64-clang #mingw64-x86_64-llvm
        #
		#fi
		
		#USEMXE=true #build deps uses MXE
		
        BUILD_UNSHIELD=true # good
    	#BUILD_BOOST=true # not tested yet
    	#BUILD_SDL2=true # not implement/tested yet   	
        BUILD_OSG=true #Fixme building not work on cygwin OpenThreads broken? ...
        BUILD_BULLET=true #Not work: error MUST_IMPLEMENT_PLATFORM
        BUILD_MYGUI=true
        #BUILD_OPENAL=true # not tested yet
    	#BUILD_FFMPEG=true #Fixme building not work
        #BUILD_TERRA=true #Fixme There is no solution to the problem for clang version & path detect func
        
	   ;; 
	*)
     echo -e "Could not determine your Env Type, press ENTER to continue without installing dependencies"
        read
	  ;;
     esac
	  
  ;;
  
"GNU/Linux" | "Linux" | "Unix" )
      echo -e "You seem to be running Unix or Linux"

#LINUX DISTRO 
DISTRO="$(lsb_release -si | awk '{print tolower($0)}')"


#CHECK DISTRO AND INSTALL DEPENDENCIES
echo -e "\n>> Checking which GNU/Linux distro is installed"
  case $DISTRO in
  "arch" | "parabola" | "manjarolinux" )
      echo -e "You seem to be running either Arch Linux, Parabola GNU/Linux-libre or Manjaro"
      sudo pacman -Sy git cmake boost openal openscenegraph mygui bullet qt5-base ffmpeg sdl2 unshield libxkbcommon-x11 ncurses #clang35 llvm35

      if [ ! -d "/usr/share/licenses/gcc-libs-multilib/" ]; then
            sudo pacman -S gcc-libs
      fi

      echo -e "\nCreating symlinks for ncurses compatibility"
      LIBTINFO_VER=6
      NCURSES_VER="$(pacman -Q ncurses | awk '{sub(/-[0-9]+/, "", $2); print $2}')"
      sudo ln -s /usr/lib/libncursesw.so."$NETCURSES_VER" /usr/lib/libtinfo.so."$LIBTINFO_VER" 2> /dev/null
      sudo ln -s /usr/lib/libtinfo.so."$LIBTINFO_VER" /usr/lib/libtinfo.so 2> /dev/null
  ;;

  "debian" | "devuan" )
      echo -e "You seem to be running Debian or Devuan"
      sudo apt-get update
      sudo apt-get install git libopenal-dev qt5-default libqt5opengl5-dev libopenscenegraph-3.4-dev libsdl2-dev libqt4-dev libboost-filesystem-dev libboost-thread-dev libboost-program-options-dev libboost-system-dev libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libswresample-dev libmygui-dev libunshield-dev cmake build-essential libqt4-opengl-dev g++ libncurses5-dev #libclang-dev llvm-dev #llvm-3.5 clang-3.5 libclang-3.5-dev llvm-3.5-dev #libbullet-dev
      #echo -e "\nDebian users are required to build OpenSceneGraph from source\nhttps://wiki.openmw.org/index.php?title=Development_Environment_Setup#Build_and_install_OSG\n\nType YES if you want the script to do it automatically (THIS IS BROKEN ATM)\nIf you already have it installed or want to do it manually,\npress ENTER to continue"
      #read INPUT
      #if [ "$INPUT" == "YES" ]; then
      #      echo -e "\nOpenSceneGraph will be built from source"
      #      BUILD_OSG=true
      #      sudo apt-get build-dep openscenegraph libopenscenegraph-dev
      #fi      
      sudo apt-get build-dep bullet
        BUILD_BULLET=true
        #BUILD_UNSHIELD=true
    	#BUILD_BOOST=true #Fix me building not work
    	#BUILD_SDL2=true 
      #sudo apt-get build-dep openscenegraph   	
        #BUILD_OSG=true         
        #BUILD_MYGUI=true
        #BUILD_OPENAL=true
    	#BUILD_FFMPEG=true #Fix me building not work
        #BUILD_TERRA=true #Fix me building not work needed llvm3.5 & clang3.5
  ;;

  "ubuntu" | "linuxmint" )
      echo -e "You seem to be running either Ubuntu or Mint"
      echo -e "\nUbuntu and Mint users are required to enable the OpenMW PPA repository\nhttps://wiki.openmw.org/index.php?title=Development_Environment_Setup#Ubuntu\n\nType YES if you want the script to do it automatically\nIf you already have it enabled or want to do it manually,\npress ENTER to continue"
      read INPUT
      if [ "$INPUT" == "YES" ]; then
            echo -e "\nEnabling the OpenMW PPA repository..."
            sudo add-apt-repository ppa:openmw/openmw
            echo -e "Done!"
      fi
      sudo apt-get update
      sudo apt-get install cmake git libopenal-dev qt5-default libopenscenegraph-3.4-dev libsdl2-dev libqt4-dev libboost-filesystem-dev libboost-thread-dev libboost-program-options-dev libboost-system-dev libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libswresample-dev libmygui-dev libunshield-dev cmake build-essential libqt4-opengl-dev g++ libncurses5-dev #clang llvm libclang-dev llvm-dev #llvm-3.5 clang-3.5 libclang-3.5-dev llvm-3.5-dev #libbullet-dev
     
      sudo apt-get build-dep bullet
        BUILD_BULLET=true
        BUILD_UNSHIELD=true
    	#BUILD_BOOST=true #Fix me building not work
    	#BUILD_SDL2=true 
      sudo apt-get build-dep openscenegraph   	
        BUILD_OSG=true         
        BUILD_MYGUI=true
        BUILD_OPENAL=true
    	#BUILD_FFMPEG=true #Fix me building not work
        #BUILD_TERRA=true #Fix me building not work needed llvm3.5 & clang3.5
  ;;

  "fedora" )
      echo -e "You seem to be running Fedora"
      echo -e "\nFedora users are required to enable the RPMFusion FREE and NON-FREE repositories\nhttps://wiki.openmw.org/index.php?title=Development_Environment_Setup#Fedora_Workstation\n\nType YES if you want the script to do it automatically\nIf you already have it enabled or want to do it manually,\npress ENTER to continue"
      read INPUT
      if [ "$INPUT" == "YES" ]; then
            echo -e "\nEnabling RPMFusion..."
            su -c 'dnf install http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm'
            echo -e "Done!"
      fi
      sudo dnf --refresh groupinstall development-tools 
      sudo dnf --refresh install openal-devel OpenSceneGraph-qt-devel SDL2-devel qt4-devel boost-filesystem git boost-thread boost-program-options boost-system ffmpeg-devel ffmpeg-libs bullet-devel gcc-c++ mygui-devel unshield-devel tinyxml-devel cmake ncurses #llvm35 llvm clang 
      BUILD_BULLET=true
  ;;

  *)
      echo -e "Could not determine your GNU/Linux distro, press ENTER to continue without installing dependencies"
      read
    ;;
  esac
  ;;
  
  *)
    echo -e "Could not determine your System & Env Type, press ENTER to continue without installing dependencies"
     read
  ;;
esac

#FOLDER HIERARCHY
BASE="$(pwd)"
CODE="$BASE/code"
DEVELOPMENT="$BASE/build"
KEEPERS="$BASE/keepers"
DEPENDENCIES="$BASE/dependencies"

#CREATE FOLDER HIERARCHY
echo -e ">> Creating folder hierarchy"
mkdir "$DEVELOPMENT" "$KEEPERS" "$DEPENDENCIES"

    
#PULL SOFTWARE VIA GIT
echo -e "\n>> Downloading software"
git clone https://github.com/TES3MP/openmw-tes3mp.git "$CODE"
git clone https://github.com/Koncord/CallFF "$DEPENDENCIES"/callff
git clone https://github.com/TES3MP/RakNet.git "$DEPENDENCIES"/raknet 
#if [ $BUILD_OSG ]; then git clone https://github.com/openscenegraph/OpenSceneGraph.git "$DEPENDENCIES"/osg ; fi
#osg on steroids) (speed up OpenMW team fork)
if [ $BUILD_OSG ]; then git clone https://github.com/OpenMW/osg.git "$DEPENDENCIES"/osg ; fi
if [ $BUILD_MYGUI ]; then git clone https://github.com/MyGUI/mygui.git "$DEPENDENCIES"/mygui ; fi
if [ $BUILD_BULLET ]; then git clone https://github.com/bulletphysics/bullet3.git "$DEPENDENCIES"/bullet ; fi
if [ $BUILD_TERRA ]; then git clone https://github.com/zdevito/terra.git "$DEPENDENCIES"/terra 

elif [ "$ENVTYPE" == "Msys" -o "$ENVTYPE" == "Cygwin" ]; then # fixme So... OR func don't work & where is arch type i686 OR x86_64 OR etc...?
echo -e "\n>> Downloading terra Windows binary "
 wget https://github.com/zdevito/terra/releases/download/release-2016-03-25/terra-Windows-x86_64-332a506.zip -O "$DEPENDENCIES"/terra.zip;
elif [ "$ENVTYPE" == "Linux" -o "GNU/Linux" ]; then # fixme So... where is arch type i686 OR x86_64 OR etc...?
echo -e "\n>> Downloading terra Linux binary "
 wget https://github.com/zdevito/terra/releases/download/release-2016-03-25/terra-Linux-x86_64-332a506.zip -O "$DEPENDENCIES"/terra.zip; 
elif [ "$ENVTYPE" == "MacOS" ]; then
echo -e "\n>> Downloading terra MacOS X binary "
 wget https://github.com/zdevito/terra/releases/download/release-2016-03-25/terra-OSX-x86_64-332a506.zip -O "$DEPENDENCIES"/terra.zip; 
else
echo -e "WARNING! Could not determine your Env Type, press ENTER to continue" ; read
fi

echo -e "\n>> Clone server-side plugins scripts"
git clone https://github.com/TES3MP/PluginExamples.git "$KEEPERS"/PluginExamples

#COPY STATIC SERVER AND CLIENT CONFIGS
echo -e "\n>> Copying server and client configs to their permanent place"
cp "$CODE"/files/tes3mp/tes3mp-{client,server}-default.cfg "$KEEPERS"

#SET home VARIABLE IN tes3mp-server-default.cfg
echo -e "\n>> Autoconfiguring"
sed -i "s|~/ClionProjects/PS-dev|$KEEPERS/PluginExamples|g" "${KEEPERS}"/tes3mp-server-default.cfg

#DIRTY HACKS
echo -e "\n>> Applying some dirty hacks"
sed -i "s|tes3mp.lua,chat_parser.lua|server.lua|g" "${KEEPERS}"/tes3mp-server-default.cfg #Fixes server scripts
sed -i "s|Y #key for switch chat mode enabled/hidden/disabled|Right Alt|g" "${KEEPERS}"/tes3mp-client-default.cfg #Changes the chat key
#sed -i "s|mp.tes3mp.com|grimkriegor.zalkeen.us|g" "${KEEPERS}"/tes3mp-client-default.cfg #Sets Grim's server as the default


echo -e "\n>> Setup compiler setings"
 export CODE_COVERAGE=1
  
  if [ "${CC}" = "clang" ]; then export CODE_COVERAGE=0; 
  elif [ "$ENVTYPE" == "Cygwin" ]; then # fixme if use mingw maybe its not working
    export COMPILER_NAME=gcc
    export CXX=g++
    export CC=gcc
  else 
    export COMPILER_NAME=gcc
    export CXX=g++-6
    export CC=gcc-6
  fi

 
 if [ $USEMXE ]; then  
   
 echo -e "\n>> Uses MXE to build OpenMW/TES3MP deps.\nExiting..."
   cd "$DEPENDENCIES"
   git clone https://github.com/mxe/mxe.git mxe
   cd "$DEPENDENCIES"/mxe
   
   #TARGET="i686-w64-mingw32.shared"
   #TARGET="i686-w64-mingw32.shared.posix"
   #TARGET="i686-w64-mingw32.shared.cmake"
   #MXE_TARGETS='x86_64-w64-mingw32.static i686-w64-mingw32.static'
   export MXE="$DEPENDENCIES/mxe/usr"
   export PREFIX="$DEPENDENCIES/3rdParty"
    make TARGET="i686-w64-mingw32.shared" ffmpeg openscenegraph bullet -j$CORES 

    if [ $? -ne 0 ]; then
      echo -e "Failed to build OpenMW/TES3MP deps.\nExiting..."
      exit 1
    fi

  export OSG_3RDPARTY_DIR="$DEPENDENCIES"/3rdParty
fi  
  
#BUILD_UNSHIELD
if [ $BUILD_UNSHIELD ]; then
    echo -e "\n>> Building unshield tools"
    git clone https://github.com/twogood/unshield.git "$DEPENDENCIES"/unshield --depth 1
	 mkdir "$DEPENDENCIES"/unshield/build 
	 cd "$DEPENDENCIES"/unshield/build 
     rm CMakeCache.txt
     cmake -DCMAKE_INSTALL_PREFIX="$DEPENDENCIES"/unshield/install -DCMAKE_BUILD_TYPE=Release ..
     make -j$CORES

      if [ $? -ne 0 ]; then
        echo -e "Failed to build unshield.\nExiting..."
       exit 1
      fi

    make install
	
	export PATH="$DEPENDENCIES"/unshield/install/bin:"$PATH"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH":"$DEPENDENCIES"/unshield/install/lib
    
    cd "$BASE"
fi

#BUILD_BOOST 
if [ $BUILD_BOOST ]; then # building not work 
    echo -e "\n>> Building Boost libraries"
     #BOOST_URL="https://downloads.sourceforge.net/project/boost/boost/1.61.0/boost_1_61_0.7z"
     #BOOST_SOURCE="$DEPENDENCIES"/boost
    git clone https://github.com/Orphis/boost-cmake.git "$DEPENDENCIES"/boost --depth 1
	 mkdir "$DEPENDENCIES"/boost/build 
	 cd "$DEPENDENCIES"/boost/build 
     rm CMakeCache.txt
     cmake -DCMAKE_INSTALL_PREFIX="$DEPENDENCIES"/boost/install -DCMAKE_BUILD_TYPE=Release ..
     make -j$CORES

      if [ $? -ne 0 ]; then
        echo -e "Failed to build Boost.\nExiting..."
       exit 1
      fi

    make install
    
    cd "$BASE"
fi

#BUILD OpenAL
if [ $BUILD_OPENAL ]; then
echo -e "\n>> Building OpenAL libraries"
cd "$DEPENDENCIES"
wget -c http://kcat.strangesoft.net/openal-releases/openal-soft-1.16.0.tar.bz2
echo -e "\n>> Unpacking and preparing OpenAL"
tar -xvjf openal-soft-1.16.0.tar.bz2
rm openal-soft-*.bz2
mv openal-soft-* openal
mkdir "$DEPENDENCIES"/openal/build 
cd "$DEPENDENCIES"/openal/build
rm CMakeCache.txt
cmake -DCMAKE_INSTALL_PREFIX="$DEPENDENCIES"/openal/install \
-DCMAKE_CXX_FLAGS="-march=native" ..
make -j$CORES

if [ $? -ne 0 ]; then
  echo -e "Failed to build OpenAL.\nExiting..."
  exit 1
fi

make install

cd "$BASE"

fi

#BUILD FFMPEG
if [ $BUILD_FFMPEG ]; then # not build need fix (deps! cap)
# ToDo Here
echo -e "\n>> Building FFMPEG libraries"
cd "$DEPENDENCIES"
if [ ! -e ffmpeg ]; then
  git clone https://github.com/sardylan/ffmpeg-cmake.git ./ffmpeg
fi
cd ffmpeg
git pull
git checkout cmake

if [ "$ENVTYPE" == "Cygwin" ]; then

cd "$DEPENDENCIES"
if [ ! -f /bin/libbluray ]; then
git clone https://github.com/cygwinports-extras/libbluray.git cygwin-ports-libbluray
cd "$DEPENDENCIES"/cygwin-ports-libbluray
echo -e "\n>> Building FFMPEG deps libbluray use Cygport"
cygport ./libbluray.cygport download
cygport ./libbluray.cygport all

if [ $? -ne 0 ]; then
  echo -e "Failed to build FFMPEG deps libbluray.\nExiting..."
  exit 1
fi

fi

cd "$DEPENDENCIES"
#git clone https://git.code.sf.net/p/cygwin-ports/ffmpeg cygwin-ports-ffmpeg
git clone https://github.com/cygwinports-extras/ffmpeg.git cygwin-ports-ffmpeg
cd "$DEPENDENCIES"/cygwin-ports-ffmpeg
echo -e "\n>> Building FFMPEG libraries use Cygport"
cygport ./ffmpeg.cygport download
cygport ./ffmpeg.cygport all
#cp -rv "$DEPENDENCIES"/cygwin-ports-ffmpeg
else
mkdir "$DEPENDENCIES"/ffmpeg/build 
cd "$DEPENDENCIES"/ffmpeg/build
rm CMakeCache.txt
cmake -DCMAKE_INSTALL_PREFIX="$DEPENDENCIES"/ffmpeg/install -DCMAKE_BUILD_TYPE=Release ..
make -j$CORES
fi
if [ $? -ne 0 ]; then
  echo -e "Failed to build FFMPEG.\nExiting..."
  exit 1
fi

make install

cd "$BASE"

fi

#BUILD OPENSCENEGRAPH
if [ $BUILD_OSG ]; then
 if [ $BUILD_OSG_DEPS ]; then # not work & not right (msys2 have repo) fix it!
  # Win-specific prebuld steps
   echo -e "\n>> Building OpenSceneGraph 3rdparty deps.\nExiting..."
   cd "$DEPENDENCIES"
   git clone --recursive https://github.com/CyberSys/osg-3rdparty-cmake.git osg_deps
   cd "$DEPENDENCIES"/osg_deps
   # Remove because is already have cmake support and create some err
   rm -rf {./zlib,./minizip,./libpng,./libjpeg,./libtiff,./jasper,./freetype,./glut,./curl}
 
   #git clone https://github.com/CyberSys/zlib.git zlib
   git clone https://github.com/nmoinvaz/minizip.git minizip    
   #git clone https://github.com/CyberSys/libpng.git libpng
   #git clone https://github.com/CyberSys/libjpeg.git libjpeg
   #git clone https://github.com/CyberSys/libtiff.git libtiff
   #git clone https://github.com/CyberSys/jasper.git jasper
   #git clone https://github.com/CyberSys/curl.git curl
   #git clone https://github.com/CyberSys/glut.git glut #is don't have cmake
   #git clone https://github.com/CyberSys/giflib.git giflib # is don't have cmake
   
   mkdir "$DEPENDENCIES"/osg_deps/build
   cd "$DEPENDENCIES"/osg_deps/build    
    rm CMakeCache.txt
    cmake -DCMAKE_INSTALL_PREFIX="$DEPENDENCIES"/osg_deps/install \ 
	-DMINIZIP_SOURCE_DIR="$DEPENDENCIES"/osg_deps/minizip \
	-DCMAKE_BUILD_TYPE=Release ..
     #-DZLIB_SOURCE_DIR="$DEPENDENCIES"/osg_3rdparty/zlib 
     
     #-DLIBPNG_SOURCE_DIR="$DEPENDENCIES"/osg_3rdparty/libpng 
     #-DLIBJPEG_SOURCE_DIR="$DEPENDENCIES"/osg_3rdparty/libjpeg 
     #-DLIBJASPER_SOURCE_DIR="$DEPENDENCIES"/osg_3rdparty/jasper 
     #-DLIBTIFF_SOURCE_DIR="$DEPENDENCIES"/osg_3rdparty/libtiff  
     #-DGIFLIB_SOURCE_DIR="$DEPENDENCIES"/osg_3rdparty/giflib  
     #-DFREETYPE_SOURCE_DIR="$DEPENDENCIES"/osg_3rdparty/freetype 
     #-DGLUT_SOURCE_DIR="$DEPENDENCIES"/osg_3rdparty/glut 
     #-DCURL_SOURCE_DIR="$DEPENDENCIES"/osg_3rdparty/curl  
     
    make -j$CORES

    if [ $? -ne 0 ]; then
      echo -e "Failed to build OpenSceneGraph 3rdparty deps.\nExiting..."
      exit 1
    fi
	
	make install

  export OSG_3RDPARTY_DIR="$DEPENDENCIES"/osg_deps/install

    cd "$BASE"
  
 
  else #Add other platform-specific steps
   echo -e "\n>>Warning!!! build OpenSceneGraph 3rdparty deps first before try build osg"
  fi
echo -e "\n>> Building OpenSceneGraph" 
    cd "$DEPENDENCIES"/osg
    mkdir "$DEPENDENCIES"/osg/build
    git checkout tags/OpenSceneGraph-3.4.0 
    cd "$DEPENDENCIES"/osg/build
    rm CMakeCache.txt
    cmake -DCMAKE_LEGACY_CYGWIN_WIN32=0 -DCMAKE_INSTALL_PREFIX="$DEPENDENCIES"/osg/install \
    -DBUILD_OSG_PLUGINS_BY_DEFAULT=0 -DBUILD_OSG_PLUGIN_OSG=1 -DBUILD_OSG_PLUGIN_DDS=1 \
    -DBUILD_OSG_PLUGIN_TGA=1 -DBUILD_OSG_PLUGIN_BMP=1 -DBUILD_OSG_PLUGIN_JPEG=1 \
    -DBUILD_OSG_PLUGIN_PNG=1 -DBUILD_OSG_DEPRECATED_SERIALIZERS=0 ..
    make -j$CORES

    if [ $? -ne 0 ]; then
      echo -e "Failed to build OpenSceneGraph.\nExiting..."
      exit 1
    fi
	
	make install

    cd "$BASE"
 
fi

#BUILD BULLET
if [ $BUILD_BULLET ]; then
    echo -e "\n>> Building Bullet Physics"
    cd "$DEPENDENCIES"/bullet
    mkdir "$DEPENDENCIES"/bullet/build
    git checkout tags/2.86
    cd "$DEPENDENCIES"/bullet/build
    rm CMakeCache.txt
    cmake -DCMAKE_INSTALL_PREFIX="$DEPENDENCIES"/bullet/install -DBUILD_SHARED_LIBS=1 -DINSTALL_LIBS=1 -DINSTALL_EXTRA_LIBS=1 -DCMAKE_BUILD_TYPE=Release ..
    make -j$CORES

    if [ $? -ne 0 ]; then
      echo -e "Failed to build Bullet.\nExiting..."
      exit 1
    fi

    make install
    
    cd "$BASE"
fi

#BUILD MyGUI
if [ $BUILD_MYGUI ]; then
echo -e "\n>> Building MyGUI libraries"
cd "$DEPENDENCIES"
if [ ! -e mygui ]; then
  git clone https://github.com/MyGUI/mygui
fi
cd mygui
#git pull
git checkout tags/MyGUI3.2.2
mkdir "$DEPENDENCIES"/mygui/build 
cd "$DEPENDENCIES"/mygui/build
rm CMakeCache.txt
cmake -DCMAKE_INSTALL_PREFIX="$DEPENDENCIES"/mygui/install \
-DFREETYPE_INCLUDE_DIR=/usr/include/freetype2/ \
-DMYGUI_RENDERSYSTEM=4 \
-DMYGUI_BUILD_DEMOS:BOOL=OFF \
-DMYGUI_BUILD_DOCS:BOOL=OFF \
-DMYGUI_BUILD_TEST_APP:BOOL=OFF \
-DMYGUI_BUILD_TOOLS:BOOL=OFF \
-DMYGUI_BUILD_PLUGINS:BOOL=OFF \
-DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo \
-DCMAKE_CXX_FLAGS="-march=native" ..
make -j$CORES

if [ $? -ne 0 ]; then
  echo -e "Failed to build MyGUI.\nExiting..."
  exit 1
fi

make install

cd "$BASE"

fi

#BUILD CALLFF #Windows support not implement yet (exept cygwin)
echo -e "\n>> Building CallFF"
 mkdir "$DEPENDENCIES"/callff/build
 cd "$DEPENDENCIES"/callff/build
 cmake ..
 make -j$CORES

  if [ $? -ne 0 ]; then
        echo -e "Failed to build CallFF.\nExiting..."
        exit 1
  fi

cd "$BASE"

#BUILD RAKNET
echo -e "\n>> Building RakNet"
cd "$DEPENDENCIES"/raknet
mkdir "$DEPENDENCIES"/raknet/build
cd "$DEPENDENCIES"/raknet/build
rm CMakeCache.txt
cmake -DCMAKE_BUILD_TYPE=Release -DRAKNET_ENABLE_DLL=OFF -DRAKNET_ENABLE_SAMPLES=OFF -DRAKNET_ENABLE_STATIC=ON -DRAKNET_GENERATE_INCLUDE_ONLY_DIR=ON ..
make -j$CORES

if [ $? -ne 0 ]; then
  echo -e "Failed to build RakNet.\nExiting..."
  exit 1
fi

ln -s "$DEPENDENCIES"/raknet/include/RakNet "$DEPENDENCIES"/raknet/include/raknet #Stop being so case sensitive
ln -s "$DEPENDENCIES"/raknet/lib "$DEPENDENCIES"/raknet/Lib

cd "$BASE"

#BUILD TERRA
if [ $BUILD_TERRA ]; then
    echo -e "\n>>Prepare to building Terra"
	if [ "$ENVTYPE" == "Msys" -o "$ENVTYPE" == "Cygwin" ]; then
	echo -e "\n>>for build Terra need clang+llvm 3.5, you need install this first"
	cd "$DEPENDENCIES"
	wget http://releases.llvm.org/3.5.0/LLVM-3.5.0-win32.exe -O "$DEPENDENCIES"/LLVM-3.5.0-win32.exe
    chmod 775 "$DEPENDENCIES"/LLVM-3.5.0-win32.exe
	"$DEPENDENCIES"/LLVM-3.5.0-win32.exe
	else
	echo -e "\n>> Building Terra"
	fi
	cd "$DEPENDENCIES"/terra
	
    make -j$CORES

    if [ $? -ne 0 ]; then
      echo -e "Failed to build Terra.\nExiting..."
      exit 1
    fi
else
    echo -e "\n>> Unpacking and preparing Terra"
    cd "$DEPENDENCIES"
    unzip terra.zip
    mv terra-* terra
    rm terra.zip
fi

cd "$BASE"

#CALL upgrade.sh TO BUILD TES3MP
echo -e "\n>>Preparing to build TES3MP"
bash ./upgrade.sh "$CORES" --install
read
