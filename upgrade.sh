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

#FOLDER HIERARCHY
BASE="$(pwd)"
CODE="$BASE/code"
DEVELOPMENT="$BASE/build"
KEEPERS="$BASE/keepers"
DEPENDENCIES="$BASE/dependencies"

if [ -d "$DEPENDENCIES"/boost ]; then
  BUILD_BOOST=true
fi

if [ -d "$DEPENDENCIES"/SDL2 ]; then
  BUILD_SDL2=true
fi

if [ -d "$DEPENDENCIES"/osg ]; then
  BUILD_OSG=true
fi

if [ -d "$DEPENDENCIES"/bullet ]; then
  BUILD_BULLET=true
fi

if [ -d "$DEPENDENCIES"/mygui ]; then
  BUILD_MYGUI=true
fi

if [ -d "$DEPENDENCIES"/openal ]; then
  BUILD_OPENAL=true
fi

if [ -d "$DEPENDENCIES"/ffmpeg ]; then
  BUILD_FFMPEG=true
fi

#DEPENDENCY LOCATIONS
CALLFF_LOCATION="$DEPENDENCIES"/callff
RAKNET_LOCATION="$DEPENDENCIES"/raknet
TERRA_LOCATION="$DEPENDENCIES"/terra
#Set for other deps if needed 
if [ $BUILD_BOOST ]; then BOOST_LOCATION="$DEPENDENCIES"/boost
	export BOOST_ROOT="${BOOST_LOCATION}"/install
	export LD_LIBRARY_PATH="$LD_LIBRARY_PATH":"${BOOST_LOCATION}"/install/lib 
fi
if [ $BUILD_SDL2 ]; then SDL2_LOCATION="$DEPENDENCIES"/SDL2
	export SDL2DIR="${SDL2_LOCATION}"/install
	export LD_LIBRARY_PATH="$LD_LIBRARY_PATH":"${SDL2_LOCATION}"/install/lib 
fi
if [ $BUILD_OSG ]; then OSG_LOCATION="$DEPENDENCIES"/osg
	export LD_LIBRARY_PATH="$LD_LIBRARY_PATH":"${OSG_LOCATION}"/install/lib
	export OSG_ROOT="${OSG_LOCATION}"/install 
fi
if [ $BUILD_BULLET ]; then BULLET_LOCATION="$DEPENDENCIES"/bullet
	export LD_LIBRARY_PATH="$LD_LIBRARY_PATH":"${BULLET_LOCATION}"/install/lib
	export BULLET_ROOT="${BULLET_LOCATION}"/install
fi

if [ $BUILD_MYGUI ]; then MYGUI_LOCATION="$DEPENDENCIES"/mygui
	export MYGUI_HOME="${MYGUI_LOCATION}"/install
	export LD_LIBRARY_PATH="$LD_LIBRARY_PATH":"${MYGUI_LOCATION}"/install/lib
fi
if [ $BUILD_OPENAL ]; then OPENAL_LOCATION="$DEPENDENCIES"/openal
	export OPENALDIR="${OPENAL_LOCATION}"/install
	export LD_LIBRARY_PATH="$LD_LIBRARY_PATH":"${OPENAL_LOCATION}"/install/lib
fi
if [ $BUILD_FFMPEG ]; then FFMPEG_LOCATION="$DEPENDENCIES"/ffmpeg
	export FFMPEG_HOME="${FFMPEG_LOCATION}"/install
	export LD_LIBRARY_PATH="$LD_LIBRARY_PATH":"${FFMPEG_LOCATION}"/install/lib
fi

#CHECK IF THERE ARE CHANGES IN THE GIT REMOTE
echo -e "\n>> Checking the git repository for changes"
cd "$CODE"
#git pull --dry-run | grep -q -v 'Already up-to-date.'
git remote update
test $(git rev-parse @) != $(git rev-parse @{u})
if [ $? -eq 0 ]; then
  echo -e "\nNEW CHANGES on the git repository"
  GIT_CHANGES=true
else
  echo -e "\nNo changes on the git repository"
fi
cd "$BASE"

#OPTION TO UPGRADE
if [ "$2" = "--install" ]; then
  UPGRADE="YES"
elif [ "$2" = "--check-changes" ]; then
  if [ $GIT_CHANGES ]; then
    UPGRADE="YES"
  else
    echo -e "\nNo new commits, exiting."
    exit 0
  fi
else
  echo -e "\nDo you wish to rebuild TES3MP? (type YES to continue)"
  read UPGRADE
fi

#REBUILD OPENMW/TES3MP
if [ "$UPGRADE" = "YES" ]; then

  #PULL CODE CHANGES FROM THE GIT REPOSITORY
  echo -e "\n>> Pulling code changes from git"
  cd "$CODE"
  git pull
  echo -e "\n>>Try pulling code changes from git for server plugins"
  cd "$KEEPERS"/PluginExamples
  git pull
  cd "$BASE"

  echo -e "\n>> Doing a clean build of TES3MP"

  rm -rf "$DEVELOPMENT"
  mkdir "$DEVELOPMENT"

  cd "$DEVELOPMENT"
  
  export CODE_COVERAGE=0 #if is on it have some link err in msys2 
  export BUILD_SERVER=ON
  
  if [ "${CC}" = "clang" ]; then export CODE_COVERAGE=0;
  elif [ "$ENVTYPE" == "Msys" ]; then 
    export COMPILER_NAME=gcc
    export CXX=g++
    export CC=gcc  
  else 
    export COMPILER_NAME=gcc
    export CXX=g++-6
    export CC=gcc-6
    export BUILD_SERVER=ON
  fi

#CHECK IF GCC HAS C++14 SUPPORT, DISPLAY A MESSAGE AND ABORT OTHERWISE - fixme don't work now 
#echo -e "\n>> Checking if the compiler has the necessary features"
# GCCVERSION=$(gcc -dumpversion)
# GCCVERSION_F=$(echo $GCCVERSION | sed -e 's/\.\([0-9][0-9]\)/\1/g' -e 's/\.\([0-9]\)/0\1/g' -e 's/^[0-9]\{3,4\}$$/&00/')
# GCCVERSION_P=$((${GCCVERSION_F}*(10**(5-${#GCCVERSION_F}))))
#  if [ $GCCVERSION_P -lt 60100 ]; then
#     echo -e "\nTES3MP requires some fairly recent C++ features.\nCurrent GCC version is $GCCVERSION.\nUpdate GCC to at least version 6.1 to proceed.\n\nOnly upgrade your toolchain if you know what you are doing.\nProceed at your own risk."
#     exit 1
#  fi
 
case $ENVTYPE in
   "MacOS" )
 	   echo -e "You seem to be running MacOS X Env"
	    # TODO Here
	;;  
  
   "Msys" | "Cygwin" ) # fixme So... where is Msys1 OR Msys2?
     
	 echo -e "Building on Windows family OS, or other Windows-like build type"
	
    #Check Windows Env And setup build parms
	 echo -e "\n>> Checking which environment is use"
	  case $ENVPLATFOM in
	"MINGW64*" | "MINGW64_NT-6.1-WOW" | "MINGW64_NT-6.1-7601" | "MINGW64_NT-10.0-WOW" | "MINGW64_NT-10.0-19045" | "MINGW32_NT-5.1" | "MINGW32_NT-6.1" | "MSYS_NT-6.1" | "MSYS_NT-6.1-WOW" | "MSYS_NT-10.0-WOW" )
	   echo -e "Building on MINGW32 or MINGW64 Env"
	    # TODO Here	    
	CMAKE_PARAMS=" -DDESIRED_QT_VERSION=5 -DBUILD_OPENMW_MP="${BUILD_SERVER}" -DBUILD_WITH_CODE_COVERAGE="${CODE_COVERAGE}" -DBUILD_BSATOOL=ON -DBUILD_ESMTOOL=ON -DBUILD_ESSIMPORTER=ON -DBUILD_LAUNCHER=ON -DBUILD_MWINIIMPORTER=ON -DBUILD_MYGUI_PLUGIN=OFF -DBUILD_OPENCS=ON -DBUILD_WIZARD=ON -DBUILD_BROWSER=ON -DBUILD_WITH_LUA=ON -DFORCE_LUA=ON -DBUILD_WITH_PAWN=OFF -DBUILD_UNITTESTS=1 -DCMAKE_INSTALL_PREFIX="${DEVELOPMENT}" -DBINDIR="${DEVELOPMENT}" -DCMAKE_BUILD_TYPE="None" -DUSE_SYSTEM_TINYXML=FALSE \
      -DCMAKE_CXX_STANDARD=14 \
      -DCMAKE_CXX_FLAGS=\"-std=c++14\" \
	  -DCallFF_INCLUDES="${CALLFF_LOCATION}"/include \
      -DCallFF_LIBRARY="${CALLFF_LOCATION}"/build/src/libcallff.a \
      -DRakNet_INCLUDES="${RAKNET_LOCATION}"/include \
      -DRakNet_LIBRARY_DEBUG="${RAKNET_LOCATION}"/build/lib/libRakNetLibStatic.a \
      -DRakNet_LIBRARY_RELEASE="${RAKNET_LOCATION}"/build/lib/libRakNetLibStatic.a " # Terra temporary deactivated for testing other func
	  
	  if [ "$ENVPLATFOM" == "MINGW64_NT-6.1-WOW" -o "MINGW64_NT-6.1-7601" -o "MINGW64_NT-10.0-WOW" -o "MINGW64_NT-10.0-19045" ]; then
	  CMAKE_PARAMS="$CMAKE_PARAMS \
		-DLuaJIT_INCLUDE_DIR=/mingw64/include/luajit-2.0 \
		-DLuaJIT_LIBRARY=/mingw64/lib/libluajit-5.1.dll.a \
		-DGTEST_LIBRARY=/mingw64/lib/libgtest.dll.a \
		-DGTEST_MAIN_LIBRARY=/mingw64/lib/libgtest_main.dll.a \
		-DGTEST_INCLUDE_DIR=/mingw64/include \
		-DBoost_DIR=/mingw64 \
		-DBoost_INCLUDE_DIR=/mingw64/include \
		-DBoost_LIBRARY_DIR=/mingw64/lib \
		-DBoost_SYSTEM_LIBRARY_RELEASE=/mingw64/lib/libboost_system-mt.dll.a \
		-DBoost_PROGRAM_OPTIONS_LIBRARY_RELEASE=/mingw64/lib/libboost_program_options-mt.dll.a \
		-DBoost_FILESYSTEM_LIBRARY_RELEASE=/mingw64/lib/libboost_filesystem-mt.dll.a \
		-DBoost_LOCALE_LIBRARY_RELEASE=/mingw64/lib/libboost_locale-mt.dll.a \
		-DBULLET_ROOT=/mingw64 \
		-DBullet_INCLUDE_DIR=/mingw64/include/bullet \
		-DBullet_BulletCollision_LIBRARY=/mingw64/lib/libBulletCollision.dll.a \
		-DBullet_LinearMath_LIBRARY=/mingw64/lib/libLinearMath.dll.a \
		-DFFMPEG_HOME=/mingw64 \
		-DFFmpeg_AVCODEC_INCLUDE_DIR=/mingw64/include \
		-DFFmpeg_AVCODEC_LIBRARY=/mingw64/lib/libavcodec.dll.a \
		-DFFmpeg_AVFORMAT_INCLUDE_DIR=/mingw64/include \
		-DFFmpeg_AVFORMAT_LIBRARY=/mingw64/lib/libavformat.dll.a \
		-DFFmpeg_AVUTIL_INCLUDE_DIR=/mingw64/include \
		-DFFmpeg_AVUTIL_LIBRARY=/mingw64/lib/libavutil.dll.a \
		-DFFmpeg_SWSCALE_INCLUDE_DIR=/mingw64/include \
		-DFFmpeg_SWSCALE_LIBRARY=/mingw64/lib/libswscale.dll.a \
		-DFFmpeg_SWRESAMPLE_INCLUDE_DIR=/mingw64/include \
		-DFFmpeg_SWRESAMPLE_LIBRARY=/mingw64/lib/libswresample.dll.a \
		-DOPENALDIR=/mingw64 \
		-DOPENAL_LIBRARY=/mingw64/lib/libopenal.dll.a \
		-DSDL2DIR=/mingw64 \ 
		-DSDL2_LIBRARY=/mingw64/lib/libSDL2.dll.a \
		-DSDL2MAIN_LIBRARY=/mingw64/lib/libSDL2main.a \
		-DOSG_ROOT=/mingw64 " # Fixme TES3MP bug in Find*.cmake 
		ln -s /mingw64/x86_64-w64-mingw32/lib/libws2_32.a /mingw64/x86_64-w64-mingw32/lib/libws2_32.lib # Fixme bug in cmake filename extension *.lib instead *.a
		ln -s /mingw64/x86_64-w64-mingw32/lib/libmingw32.a /mingw64/x86_64-w64-mingw32/lib/libmingw32.lib
		ln -s /mingw64/x86_64-w64-mingw32/lib/libwinmm.a /mingw64/x86_64-w64-mingw32/lib/libwinmm.lib
		ln -s /mingw64/x86_64-w64-mingw32/lib/libimm32.a /mingw64/x86_64-w64-mingw32/lib/libimm32.lib
		ln -s /mingw64/x86_64-w64-mingw32/lib/libversion.a /mingw64/x86_64-w64-mingw32/lib/libversion.lib
		ln -s /mingw64/x86_64-w64-mingw32/lib/libmsimg32.a /mingw64/x86_64-w64-mingw32/lib/libmsimg32.lib
		ln -s /mingw64/x86_64-w64-mingw32/lib/libopengl32.a /mingw64/x86_64-w64-mingw32/lib/libopengl32.lib
		ln -s /mingw64/x86_64-w64-mingw32/lib/libshlwapi.a /mingw64/x86_64-w64-mingw32/lib/libshlwapi.lib
	  else
	  CMAKE_PARAMS="$CMAKE_PARAMS \
	  	-DLuaJIT_INCLUDE_DIR=/mingw32/include/luajit-2.0 \
		-DLuaJIT_LIBRARY=/mingw32/lib/libluajit-5.1.dll.a \
		-DGTEST_LIBRARY=/mingw32/lib/libgtest.dll.a \
		-DGTEST_MAIN_LIBRARY=/mingw32/lib/libgtest_main.dll.a \
		-DGTEST_INCLUDE_DIR=/mingw32/include \
		-DBoost_DIR=/mingw32 \
		-DBoost_INCLUDE_DIR=/mingw32/include \
		-DBoost_LIBRARY_DIR=/mingw32/lib \
		-DBoost_SYSTEM_LIBRARY_RELEASE=/mingw32/lib/libboost_system-mt.dll.a \
		-DBoost_PROGRAM_OPTIONS_LIBRARY_RELEASE=/mingw32/lib/libboost_program_options-mt.dll.a \
		-DBoost_FILESYSTEM_LIBRARY_RELEASE=/mingw32/lib/libboost_filesystem-mt.dll.a \
		-DBoost_LOCALE_LIBRARY_RELEASE=/mingw32/lib/libboost_locale-mt.dll.a \
		-DBULLET_ROOT=/mingw32 \
		-DBullet_INCLUDE_DIR=/mingw32/include/bullet \
		-DBullet_BulletCollision_LIBRARY=/mingw32/lib/libBulletCollision.dll.a \
		-DBullet_LinearMath_LIBRARY=/mingw32/lib/libLinearMath.dll.a \
		-DFFMPEG_HOME=/mingw32 \
		-DFFmpeg_AVCODEC_INCLUDE_DIR=/mingw32/include \
		-DFFmpeg_AVCODEC_LIBRARY=/mingw32/lib/libavcodec.dll.a \
		-DFFmpeg_AVFORMAT_INCLUDE_DIR=/mingw32/include \
		-DFFmpeg_AVFORMAT_LIBRARY=/mingw32/lib/libavformat.dll.a \
		-DFFmpeg_AVUTIL_INCLUDE_DIR=/mingw32/include \
		-DFFmpeg_AVUTIL_LIBRARY=/mingw32/lib/libavutil.dll.a \
		-DFFmpeg_SWSCALE_INCLUDE_DIR=/mingw32/include \
		-DFFmpeg_SWSCALE_LIBRARY=/mingw32/lib/libswscale.dll.a \
		-DFFmpeg_SWRESAMPLE_INCLUDE_DIR=/mingw32/include \
		-DFFmpeg_SWRESAMPLE_LIBRARY=/mingw32/lib/libswresample.dll.a \
		-DOPENALDIR=/mingw32 \
		-DOPENAL_LIBRARY=/mingw32/lib/libopenal.dll.a \
		-DSDL2DIR=/mingw32 \ 
		-DSDL2_TARGET_SPECIFIC=mingw32
		-DSDL2_LIBRARY=/mingw32/lib/libSDL2.dll.a \
		-DSDL2MAIN_LIBRARY=/mingw32/lib/libSDL2main.a \
		-DOSG_ROOT=/mingw32 " # Fixme TES3MP bug in Find*.cmake 
		ln -s /mingw32/i686-w64-mingw32/lib/libws2_32.a /mingw32/i686-w64-mingw32/lib/libws2_32.lib # Fixme bug in cmake filename extension *.lib instead *.a
		ln -s /mingw32/i686-w64-mingw32/lib/libmingw32.a /mingw32/i686-w64-mingw32/lib/libmingw32.lib
		ln -s /mingw32/i686-w64-mingw32/lib/libwinmm.a /mingw32/i686-w64-mingw32/lib/libwinmm.lib
		ln -s /mingw32/i686-w64-mingw32/lib/libimm32.a /mingw32/i686-w64-mingw32/lib/libimm32.lib
		ln -s /mingw32/i686-w64-mingw32/lib/libversion.a /mingw32/i686-w64-mingw32/lib/libversion.lib
		ln -s /mingw32/i686-w64-mingw32/lib/libmsimg32.a /mingw32/i686-w64-mingw32/lib/libmsimg32.lib
		ln -s /mingw32/i686-w64-mingw32/lib/libopengl32.a /mingw32/i686-w64-mingw32/lib/libopengl32.lib
		ln -s /mingw32/i686-w64-mingw32/lib/libshlwapi.a /mingw32/i686-w64-mingw32/lib/libshlwapi.lib
		fi

        if [ $BUILD_BOOST ]; then
         CMAKE_PARAMS="$CMAKE_PARAMS \
        -DBoost_DIR="${BOOST_LOCATION}"/install \
		-DBoost_INCLUDE_DIR="${BOOST_LOCATION}"/install/include \
		-DBoost_LIBRARY_DIR="${BOOST_LOCATION}"/install/lib \
		-DBoost_SYSTEM_LIBRARY_RELEASE="${BOOST_LOCATION}"/install/lib/libboost_system-mt.dll.a \
		-DBoost_PROGRAM_OPTIONS_LIBRARY_RELEASE="${BOOST_LOCATION}"/install/lib/libboost_program_options-mt.dll.a \
		-DBoost_FILESYSTEM_LIBRARY_RELEASE="${BOOST_LOCATION}"/install/lib/libboost_filesystem-mt.dll.a \
		-DBoost_LOCALE_LIBRARY_RELEASE="${BOOST_LOCATION}"/install/lib/libboost_locale-mt.dll.a  "
         export BOOST_ROOT="${BOOST_LOCATION}"/install
         export LD_LIBRARY_PATH="$LD_LIBRARY_PATH":"${BOOST_LOCATION}"/install/lib
        fi
   
        if [ $BUILD_OPENAL ]; then
         CMAKE_PARAMS="$CMAKE_PARAMS \
        -DOPENAL_INCLUDE_DIR="${OPENAL_LOCATION}"/install/include/AL \
		-DOPENAL_LIBRARY="${OPENAL_LOCATION}"/install/lib/libopenal.dll.a "
         export OPENALDIR="${OPENAL_LOCATION}"/install
         export LD_LIBRARY_PATH="$LD_LIBRARY_PATH":"${OPENAL_LOCATION}"/install/lib
        fi
   
        if [ $BUILD_FFMPEG ]; then
         CMAKE_PARAMS="$CMAKE_PARAMS \
        -DFFmpeg_AVCODEC_INCLUDE_DIR="${FFMPEG_LOCATION}"/install/include \
		-DFFmpeg_AVCODEC_LIBRARY="${FFMPEG_LOCATION}"/install/lib/libavcodec.dll.a \
		-DFFmpeg_AVFORMAT_INCLUDE_DIR="${FFMPEG_LOCATION}"/install/include \
		-DFFmpeg_AVFORMAT_LIBRARY="${FFMPEG_LOCATION}"/install/lib/libavformat.dll.a \
		-DFFmpeg_AVUTIL_INCLUDE_DIR="${FFMPEG_LOCATION}"/install/include \
		-DFFmpeg_AVUTIL_LIBRARY="${FFMPEG_LOCATION}"/install/lib/libavutil.dll.a \
		-DFFmpeg_SWSCALE_INCLUDE_DIR="${FFMPEG_LOCATION}"/install/include \
		-DFFmpeg_SWSCALE_LIBRARY="${FFMPEG_LOCATION}"/install/lib/libswscale.dll.a \
		-DFFmpeg_SWRESAMPLE_INCLUDE_DIR="${FFMPEG_LOCATION}"/install/include \
		-DFFmpeg_SWRESAMPLE_LIBRARY="${FFMPEG_LOCATION}"/install/lib/libswresample.dll.a  "
         export FFMPEG_HOME="${FFMPEG_LOCATION}"/install
         export LD_LIBRARY_PATH="$LD_LIBRARY_PATH":"${FFMPEG_LOCATION}"/install/lib
        fi
   
        if [ $BUILD_SDL2 ]; then
         CMAKE_PARAMS="$CMAKE_PARAMS \
        -DSDL2_INCLUDE_DIR="${SDL2_LOCATION}"/install/include/SDL2 \
		-DSDL2_TARGET_SPECIFIC=mingw32 \
		-DSDL2_LIBRARY="${SDL2_LOCATION}"/install/lib/libSDL2.a \
		-DSDL2MAIN_LIBRARY="${SDL2_LOCATION}"/install/lib/libSDL2main.a "
         export SDL2DIR="${SDL2_LOCATION}"/install
         export LD_LIBRARY_PATH="$LD_LIBRARY_PATH":"${SDL2_LOCATION}"/install/lib
        fi
   
        if [ $BUILD_MYGUI ]; then
          CMAKE_PARAMS="$CMAKE_PARAMS \
         -DMyGUI_INCLUDE_DIR="${MYGUI_LOCATION}"/install/include/MYGUI  \
		 -DMyGUI_LIBRARY="${MYGUI_LOCATION}"/install/lib/RelWithDebInfo/libMyGUIEngine.dll.a "
          export MYGUI_HOME="${MYGUI_LOCATION}"/install
          export LD_LIBRARY_PATH="$LD_LIBRARY_PATH":"${MYGUI_LOCATION}"/install/lib
        fi
		
		if [ $BUILD_OSG ]; then
       CMAKE_PARAMS="$CMAKE_PARAMS \
      -DOPENTHREADS_INCLUDE_DIR="${OSG_LOCATION}"/install/include \
      -DOPENTHREADS_LIBRARY="${OSG_LOCATION}"/install/lib/libOpenThreads.dll.a \
      -DOSG_INCLUDE_DIR="${OSG_LOCATION}"/install/include \
      -DOSG_LIBRARY="${OSG_LOCATION}"/install/lib/libosg.dll.a \
      -DOSGANIMATION_INCLUDE_DIR="${OSG_LOCATION}"/install/include \
      -DOSGANIMATION_LIBRARY="${OSG_LOCATION}"/install/lib/libosgAnimation.dll.a \
      -DOSGDB_INCLUDE_DIR="${OSG_LOCATION}"/install/include \
      -DOSGDB_LIBRARY="${OSG_LOCATION}"/install/lib/libosgDB.dll.a \
      -DOSGFX_INCLUDE_DIR="${OSG_LOCATION}"/install/include \
      -DOSGFX_LIBRARY="${OSG_LOCATION}"/install/lib/libosgFX.dll.a \
      -DOSGGA_INCLUDE_DIR="${OSG_LOCATION}"/install/include \
      -DOSGGA_LIBRARY="${OSG_LOCATION}"/install/lib/libosgGA.dll.a \
      -DOSGPARTICLE_INCLUDE_DIR="${OSG_LOCATION}"/install/include \
      -DOSGPARTICLE_LIBRARY="${OSG_LOCATION}"/install/lib/libosgParticle.dll.a \
      -DOSGTEXT_INCLUDE_DIR="${OSG_LOCATION}"/install/include \
      -DOSGTEXT_LIBRARY="${OSG_LOCATION}"/install/lib/libosgText.dll.a \
      -DOSGUTIL_INCLUDE_DIR="${OSG_LOCATION}"/install/include \
      -DOSGUTIL_LIBRARY="${OSG_LOCATION}"/install/lib/libosgUtil.dll.a \
      -DOSGVIEWER_INCLUDE_DIR="${OSG_LOCATION}"/install/include \
      -DOSGVIEWER_LIBRARY="${OSG_LOCATION}"/install/lib/libosgViewer.dll.a"
	export LD_LIBRARY_PATH="$LD_LIBRARY_PATH":"${OSG_LOCATION}"/install/lib
    export OSG_ROOT="${OSG_LOCATION}"/install
  fi
  
  if [ $BUILD_BULLET ]; then
    CMAKE_PARAMS="$CMAKE_PARAMS \
      -DBullet_INCLUDE_DIR="${BULLET_LOCATION}"/install/include/bullet \
      -DBullet_BulletCollision_LIBRARY="${BULLET_LOCATION}"/install/lib/libBulletCollision.dll.a \
      -DBullet_LinearMath_LIBRARY="${BULLET_LOCATION}"/install/lib/libLinearMath.dll.a"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH":"${BULLET_LOCATION}"/install/lib
    export BULLET_ROOT="${BULLET_LOCATION}"/install
  fi
		
		;;
	"CYGWIN*" | "CYGWIN_NT-5.1" )
	   echo -e "Buiding on CYGWIN Env"
	    # TODO Here
	
	   ;; 
	*)
     echo -e "Could not determine your Env Type, press ENTER to exit"
        read
	  ;;
     esac
	  
  ;;
  
  "GNU/Linux" | "Linux" | "Unix" )
      echo -e "Bulding on Unix or Linux"


  CMAKE_PARAMS="-DBUILD_OPENMW_MP="${BUILD_SERVER}" -DBUILD_WITH_CODE_COVERAGE="${CODE_COVERAGE}" -DBUILD_BSATOOL=ON -DBUILD_ESMTOOL=ON -DBUILD_ESSIMPORTER=ON -DBUILD_LAUNCHER=ON -DBUILD_MWINIIMPORTER=ON -DBUILD_MYGUI_PLUGIN=OFF -DBUILD_OPENCS=ON -DBUILD_WIZARD=ON -DBUILD_BROWSER=ON -DBUILD_UNITTESTS=1 -DCMAKE_INSTALL_PREFIX="${DEVELOPMENT}" -DBINDIR="${DEVELOPMENT}"  -DCMAKE_BUILD_TYPE="None" -DUSE_SYSTEM_TINYXML=TRUE \
      -DCMAKE_CXX_STANDARD=14 \
      -DCMAKE_CXX_FLAGS=\"-std=c++14\" \
      -DRakNet_INCLUDES="${RAKNET_LOCATION}"/include \
      -DRakNet_LIBRARY_DEBUG="${RAKNET_LOCATION}"/build/lib/LibStatic/libRakNetLibStatic.a \
      -DRakNet_LIBRARY_RELEASE="${RAKNET_LOCATION}"/build/lib/LibStatic/libRakNetLibStatic.a \
      -DTerra_INCLUDES="${TERRA_LOCATION}"/include \
      -DTerra_LIBRARY_RELEASE="${TERRA_LOCATION}"/lib/libterra.a"

   if [ $BUILD_BOOST ]; then
    CMAKE_PARAMS="$CMAKE_PARAMS \
      -DBOOST_INCLUDE_DIR="${BOOST_LOCATION}"/include "
      export BOOST_ROOT="${BOOST_LOCATION}"/install
      export LD_LIBRARY_PATH="$LD_LIBRARY_PATH":"${BOOST_LOCATION}"/install/lib
   fi
   
   if [ $BUILD_OPENAL ]; then
    CMAKE_PARAMS="$CMAKE_PARAMS \
      -DOPENAL_INCLUDE_DIR="${OPENAL_LOCATION}"/install/include "
      export OPENALDIR="${OPENAL_LOCATION}"/install
      export LD_LIBRARY_PATH="$LD_LIBRARY_PATH":"${OPENAL_LOCATION}"/install/lib
   fi
   
   if [ $BUILD_FFMPEG ]; then
    CMAKE_PARAMS="$CMAKE_PARAMS \
      -DFFMPEG_INCLUDE_DIR="${FFMPEG_LOCATION}"/install/include "
      export FFMPEG_HOME="${FFMPEG_LOCATION}"/install
      export LD_LIBRARY_PATH="$LD_LIBRARY_PATH":"${FFMPEG_LOCATION}"/install/lib
   fi
   
   if [ $BUILD_MYGUI ]; then
    CMAKE_PARAMS="$CMAKE_PARAMS \
      -DMYGUI_INCLUDE_DIR="${MYGUI_LOCATION}"/include "
      export MYGUI_HOME="${MYGUI_LOCATION}"/install
      export LD_LIBRARY_PATH="$LD_LIBRARY_PATH":"${MYGUI_LOCATION}"/install/lib
   fi
 
  if [ $BUILD_OSG ]; then
    CMAKE_PARAMS="$CMAKE_PARAMS \
      -DOPENTHREADS_INCLUDE_DIR="${OSG_LOCATION}"/include \
      -DOPENTHREADS_LIBRARY="${OSG_LOCATION}"/build/lib/libOpenThreads.so \
      -DOSG_INCLUDE_DIR="${OSG_LOCATION}"/include \
      -DOSG_LIBRARY="${OSG_LOCATION}"/build/lib/libosg.so \
      -DOSGANIMATION_INCLUDE_DIR="${OSG_LOCATION}"/include \
      -DOSGANIMATION_LIBRARY="${OSG_LOCATION}"/build/lib/libosgAnimation.so \
      -DOSGDB_INCLUDE_DIR="${OSG_LOCATION}"/include \
      -DOSGDB_LIBRARY="${OSG_LOCATION}"/build/lib/libosgDB.so \
      -DOSGFX_INCLUDE_DIR="${OSG_LOCATION}"/include \
      -DOSGFX_LIBRARY="${OSG_LOCATION}"/build/lib/libosgFX.so \
      -DOSGGA_INCLUDE_DIR="${OSG_LOCATION}"/include \
      -DOSGGA_LIBRARY="${OSG_LOCATION}"/build/lib/libosgGA.so \
      -DOSGPARTICLE_INCLUDE_DIR="${OSG_LOCATION}"/include \
      -DOSGPARTICLE_LIBRARY="${OSG_LOCATION}"/build/lib/libosgParticle.so \
      -DOSGTEXT_INCLUDE_DIR="${OSG_LOCATION}"/include \
      -DOSGTEXT_LIBRARY="${OSG_LOCATION}"/build/lib/libosgText.so \
      -DOSGUTIL_INCLUDE_DIR="${OSG_LOCATION}"/include \
      -DOSGUTIL_LIBRARY="${OSG_LOCATION}"/build/lib/libosgUtil.so \
      -DOSGVIEWER_INCLUDE_DIR="${OSG_LOCATION}"/include \
      -DOSGVIEWER_LIBRARY="${OSG_LOCATION}"/build/lib/libosgViewer.so"
  fi
  
  if [ $BUILD_BULLET ]; then
    CMAKE_PARAMS="$CMAKE_PARAMS \
      -DBullet_INCLUDE_DIR="${BULLET_LOCATION}"/install/include/bullet \
      -DBullet_BulletCollision_LIBRARY="${BULLET_LOCATION}"/install/lib/libBulletCollision.so \
      -DBullet_LinearMath_LIBRARY="${BULLET_LOCATION}"/install/lib/libLinearMath.so"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH":"${BULLET_LOCATION}"/install/lib
    export BULLET_ROOT="${BULLET_LOCATION}"/install
  fi
  
    ;;

  *)
      echo -e "Could not determine your GNU/Linux distro, press ENTER to exit"
      read

  ;;
esac

  echo -e "\n\n$CMAKE_PARAMS\n\n"
 if [ "$ENVTYPE" == "Msys" ]; then
  cd "$DEVELOPMENT"
  rm CMakeCache.txt
  cmake $CMAKE_PARAMS -G "MSYS Makefiles" ../code
 else
  cd "$DEVELOPMENT"
  rm CMakeCache.txt
  cmake "$CODE" $CMAKE_PARAMS
 fi
  make -j $CORES 2>&1 | tee "${BASE}"/build.log

fi

#CREATE SYMLINKS FOR THE CONFIG FILES INSIDE THE NEW BUILD FOLDER
echo -e "\n>> Creating symlinks of the config files in the build folder"
for file in "$KEEPERS"/*
do
  FILEPATH=$file
  FILENAME=$(basename $file)
    mv "$DEVELOPMENT/$FILENAME" "$DEVELOPMENT/$FILENAME.bkp" 2> /dev/null
    ln -s "$KEEPERS/$FILENAME" "$DEVELOPMENT/"
done

#CREATE USEFUL SYNLINKS ON THE BASE DIRECTORY
echo -e "\n>> Creating symlinks of useful stuffs in the base directory"
#ln -s "${DEVELOPMENT}"/tes3mp-browser "${BASE}"/ >/dev/null

#ALL DONE
echo -e "\n\n\nAll done! Press any key to exit.\nMay Vehk bestow his blessing upon your Muatra."
read
