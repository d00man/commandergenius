#!/bin/sh

git config -f .git/config --remove-section submodule.project/jni/application/openarena/vm
git config -f .git/config --remove-section submodule.project/jni/application/openarena/engine

git config -f .gitmodules --remove-section submodule.project/jni/application/openarena/vm
git config -f .gitmodules --remove-section submodule.project/jni/application/openarena/engine

git add .
git commit -m "[update submodules]: remove submodules"

git rm --cached project/jni/application/openarena/engine
git rm --cached project/jni/application/openarena/vm

rm -rf ./project/jni/application/openarena/engine
rm -rf ./project/jni/application/openarena/vm

git submodule add https://github.com/dd00/openarena-vm ./project/jni/application/openarena/vm
git submodule add https://github.com/dd00/openarena-engine ./project/jni/application/openarena/engine

git add .
git commit -m "[update submodules]: add submodules"
