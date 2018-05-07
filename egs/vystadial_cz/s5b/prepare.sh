#!/bin/bash
set -ue

GIT_ROOT_PATH=`git rev-parse --show-toplevel`
tools_dir=$GIT_ROOT_PATH/tools
src_dir=$GIT_ROOT_PATH/src
make_parallel=$(grep -c ^processor /proc/cpuinfo)
srilm_path=/mnt/data/tools/srilm.tgz  # TODO wiki#11 - replace srilm by kenlm and mitlm

source ./utils/parse_options.sh

echo "Removed file signalling that the dependencies are prepared"
rm -f PREPARED

pushd $tools_dir
    cp $srilm_path srilm.tgz
    ./install_srilm.sh &
    install_srilm_pid=$!
    make -j $make_parallel
    wait $install_srilm_pid
popd # $tools_dir

pushd $src_dir
    ./configure --shared
    make depend -j $make_parallel
    make -j $make_parallel
popd # $src_dir

date >> PREPARED
git rev-parse HEAD >> PREPARED
git status -bsuno >> PREPARED
