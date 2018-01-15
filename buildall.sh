#!/bin/bash

set -ex -o pipefail -o posix

# --------------------------------------------------------------------------------

date

declare -a vars=(PATH ANDROID_HOME NDK_HOME)

for var in "${vars[@]}"
do
  echo "\$${var}=${!var}"
done

if ! test -d "$NDK_HOME"
then
  echo "\$NDK_HOME ($NDK_HOME) is not a valid directory"
  exit 1
fi

PATH=$NDK_HOME:$PATH

if ! test -d "$ANDROID_HOME" || \
  ! test -d "$ANDROID_HOME/tools"
then
  echo "\$ANDROID_HOME ($ANDROID_HOME) is not a valid directory"
  exit 1
fi

PATH=$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$PATH

# --------------------------------------------------------------------------------
# Command line parameters

quick_rebuild=false

if [ "$#" -eq 1 -a "$1" = "-q" ]; then
  shift
  quick_rebuild=true
fi

# --------------------------------------------------------------------------------
# Install required android components

add_package() {
  local package_name=$1
  if test -z "$packages_to_install"
  then
    packages_to_install=$package_name
  else
    packages_to_install=$packages_to_install,$package_name
  fi  
}

build_tools_version=23.0.3
min_api_level=9
max_api_level=23

if ! test -d "$ANDROID_HOME/platform-tools"
then
    add_package "platform-tools"
fi

if ! test -d "$ANDROID_HOME/build-tools/$build_tools_version"
then
  add_package "build-tools-$build_tools_version"
fi

# For zipalign
PATH=$ANDROID_HOME/build-tools/$build_tools_version:$PATH

if ! test -d "$ANDROID_HOME/platforms/android-$min_api_level"
then
  add_package "android-$min_api_level"
fi

if ! test -d "$ANDROID_HOME/platforms/android-$max_api_level"
then
  add_package "android-$max_api_level"
fi

if test -n "$packages_to_install"
then
  echo y | android update sdk --silent --no-ui --all --filter "$packages_to_install"
fi

which android || { echo "'android' tool not found in your PATH" && exit 1 ; }
which zipalign || { echo "'zipalign' tool is not found in your PATH" && exit 1 ; }
which ant || { echo "'ant' is not found in your PATH" && exit 1 ; }
which git || { echo "'git' is not found in your PATH" && exit 1 ; }
which keytool || { echo "'keytool' is not found in your PATH" && exit 1 ; }
which jarsigner || { echo "'jarsigner' is not found in your PATH" && exit 1 ; }

if uname -s | grep -i "darwin" > /dev/null ; then
  greadlink_path=`which greadlink`
  if [ -n "$greadlink_path" ]; then
    echo "Using greadlink from $greadlink_path"
  else
    echo "Failed to find 'greadlink' tool. Install 'coreutils' package from macports (https://www.macports.org/) or homebrew (http://brew.sh/), and check that the tool is in your PATH"
    exit 1
  fi
fi

# Generate debug.keystore if it doesn't exist
if ! test -f ~/.android/debug.keystore || \
   ! keytool -list -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android
then
  keytool -genkey -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"
fi

if ! $quick_rebuild ; then
  # submodules
  git submodule update --init project/jni/application/openarena/engine
  git submodule update --init project/jni/application/openarena/vm

  # build
  rm project/jni/application/src || true # ignore the error
  ln -s openarena project/jni/application/src

  ./changeAppSettings.sh -a

  android update project -p project

  ./build.sh
else
  ./build.sh -q
fi

echo "OpenArena build succeeded"
