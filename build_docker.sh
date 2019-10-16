#!/bin/bash

set -e
set -u
set -o pipefail

ver=$1
labelversion=$2
tmpdir=$(mktemp -d)

git clone https://github.com/pndni/fsl_ants_nipype_container $tmpdir
pushd $tmpdir

git checkout $ver

lv=""
if [ $labelversion == 1 ]
then
    lv="--build-arg ver=$ver"
fi

docker build \
       --build-arg revision=$ver \
       --build-arg builddate="$(date --rfc-3339=seconds)" \
       $lv \
       -t pndni/fsl_ants_nipype_container:$ver .

popd
rm -rf $tmpdir

docker push pndni/fsl_ants_nipype_container:$ver
