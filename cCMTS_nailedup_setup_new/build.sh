#!/bin/bash

#AtulDOCKER_REPO_NS="containers.cisco.com/odpm/"
DOCKER_REPO_NS=""

BUILD_IMG=vpp-build
VPP_IMG=vpp
VPP_LITE_IMG=vpp-lite

# build the build image
docker build -t ${DOCKER_REPO_NS}${BUILD_IMG} -f Dockerfile.build .

# copy binaries from the build image
rm -rf bin
mkdir bin
docker create --name ${BUILD_IMG}-cont ${DOCKER_REPO_NS}${BUILD_IMG}
docker cp ${BUILD_IMG}-cont:/opt/dev/vpp.tar.gz ./bin
docker cp ${BUILD_IMG}-cont:/opt/dev/vpp-lite.tar.gz ./bin
docker rm ${BUILD_IMG}-cont

# build production images
docker build --build-arg VPP_VERSION=vpp -t ${DOCKER_REPO_NS}${VPP_IMG} .
docker build --build-arg VPP_VERSION=vpp-lite -t ${DOCKER_REPO_NS}${VPP_LITE_IMG} .

# push to registry
#Atuldocker push ${DOCKER_REPO_NS}${VPP_IMG}
#Atuldocker push ${DOCKER_REPO_NS}${VPP_LITE_IMG}
