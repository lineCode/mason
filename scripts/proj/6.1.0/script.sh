#!/usr/bin/env bash

MASON_NAME=proj
MASON_VERSION=6.1.0
MASON_LIB_FILE=lib/libproj.a
GRID_VERSION="1.6"

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://download.osgeo.org/proj/proj-${MASON_VERSION}.tar.gz \
        6a5162cf81b3e82df02d54fc491a28c65594218d

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    curl --retry 3 -f -# -L https://download.osgeo.org/proj/proj-datumgrid-${GRID_VERSION}.zip -o proj-datumgrid-${GRID_VERSION}.zip
    cd data
    unzip -o ../proj-datumgrid-${GRID_VERSION}.zip
    cd ../
    # note CFLAGS overrides defaults (-g -O2) so we need to add optimization flags back
    export CFLAGS="${CFLAGS} -O3 -DNDEBUG"
    ./configure --prefix=${MASON_PREFIX} \
    --without-mutex ${MASON_HOST_ARG} \
    --with-jni=no \
    --enable-static \
    --disable-shared \
    --disable-dependency-tracking

    make -j${MASON_CONCURRENCY}
    make install
}

function mason_cflags {
    echo -I${MASON_PREFIX}/include
}

function mason_ldflags {
    echo "-lproj"
}

function mason_clean {
    make clean
}

mason_run "$@"
