#!/bin/sh

git submodule update --init project/jni/application/openarena/engine
git submodule update --init project/jni/application/openarena/vm

rm project/jni/application/src # ignore the error
ln -s openarena project/jni/application/src

./changeAppSettings.sh -a

android update project -p project

./build.sh
