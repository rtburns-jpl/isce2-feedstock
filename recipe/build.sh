#!/bin/sh
# XXX Kludge for broken Xfuncproto.h provided by macOS tk conda-forge package
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Workaround https://github.com/conda-forge/tk-feedstock/issues/15
    conda remove -p ${PREFIX} --force --yes tk
    conda install -p ${PREFIX} --force --yes --no-deps xorg-libxt xorg-libxext xorg-libx11
fi

set -xeuo pipefail

MODPATH=$(python3 -c "import os.path; print(os.path.relpath('$SP_DIR', '$PREFIX'))")

# build isce
mkdir $SRC_DIR/build
cd $SRC_DIR/build
cmake $SRC_DIR/isce2 \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DPYTHON_MODULE_DIR=$MODPATH
make -j4 install

# Preserve help directory
# https://github.com/conda/conda/issues/446
touch $SP_DIR/isce2/helper/.keepdir

# Move stack processors to share
# TODO set up cmake to do this automatically
mkdir -p $PREFIX/share/isce2
mv $SRC_DIR/isce2/contrib/stack/* $PREFIX/share/isce2
mv $SRC_DIR/isce2/contrib/timeseries/* $PREFIX/share/isce2
