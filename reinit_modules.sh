#!/bin/sh

git config -f .git/config --remove-section submodule.project/jni/application/openarena/vm
git config -f .git/config --remove-section submodule.project/jni/application/openarena/engine

# git add .gitmodules

# git commit -m "[update submodules]: remove submodules"

# rm -rf ./project/jni/application/openarena/engine
# rm -rf ./project/jni/application/openarena/vm

# git submodule add https://github.com/dd00/openarena-vm ./project/jni/application/openarena/vm
# git submodule add https://github.com/dd00/openarena-vm ./project/jni/application/openarena/engine

# git add .gitmodules
# git commit -m "[update submodules]: add submodules"
