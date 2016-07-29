#!/bin/sh

set -ex

which android || { echo "'android' tool not found in your PATH" && exit 1 ; }

zipalign_path=`which zipalign`

if [ -n "$zipalign_path" ]; then
  echo "Using zipalign from $zipalign_path"
else
  build_tools_index=`android list sdk --all --extended | grep "build-tools-23\.0\.3" | sed -E 's@id: ([0-9]+) or.+@\1@'`
  if [ -n "$build_tools_index" ]; then
    echo y | android update sdk --no-ui --filter "$build_tools_index"
  else
    echo "Failed to find the package index for build tools."
  fi
fi

which zipalign || { echo "'zipalign' tools is not found in your PATH" && exit 1 ; }

git submodule update --init project/jni/application/openarena/engine
git submodule update --init project/jni/application/openarena/vm

rm project/jni/application/src # ignore the error
ln -s openarena project/jni/application/src

./changeAppSettings.sh -a

android update project -p project

./build.sh

echo "OpenArena build succeeded"
