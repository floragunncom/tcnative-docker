#!/bin/bash
set -e
############################################################################################
############################################################################################
LIBRESSL_VERSION=2.5.5
LIBRESSL_SHA256=e57f5e3d5842a81fe9351b6e817fcaf0a749ca4ef35a91465edba9e071dce7c4
#TC_NATIVE_TAGS=(netty-tcnative-1.1.33.Fork17 netty-tcnative-parent-2.0.0.Final netty-tcnative-parent-2.0.1.Final netty-tcnative-parent-1.1.33.Fork25 netty-tcnative-parent-1.1.33.Fork23)
#TC_NATIVE_TAGS=(netty-tcnative-parent-2.0.2.Final netty-tcnative-parent-2.0.3.Final)
TC_NATIVE_TAGS=(netty-tcnative-parent-2.0.5.Final)

#for every os in OS list there must be subfolder with this name and a Dockerfile in it
OS=(non-fedora fedora alpine)
MAVEN_VERSION=3.5.0
############################################################################################
############################################################################################
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILDLOG="$DIR/build.log"
#DATE=`date +%Y-%m-%d:%H:%M:%S`
#echo "Start $DATE"
rm -f "$BUILDLOG"
cd "$DIR"
for i in "${OS[@]}"
do
   : 
   cd "$DIR/$i"
   cp -a "$DIR/scripts/compile.sh" .
   echo "### BUILD $i ###"
   docker build --build-arg "MAVEN_VERSION=$MAVEN_VERSION" -t "$i:latest" . >> "$BUILDLOG" 2>&1
   mkdir -p "$DIR/$i/binaries"
   for nv in "${TC_NATIVE_TAGS[@]}"
   do
     : 
     echo "### RUN $i/$nv for Open SSL $LIBRESSL_VERSION ###"
     docker run -e "NETTY_TCNATIVE_TAG=$nv" -e "LIBRESSL_VERSION=$LIBRESSL_VERSION" -e "LIBRESSL_SHA256=$LIBRESSL_SHA256" --rm -v "$DIR/$i/binaries:/output" "$i:latest"
     VER=${nv##*-}
     echo "Upload files for $i/$VER"
     #PUT /content/:subject/:repo/:package/:version/:file_path[?publish=0/1][?override=0/1][?explode=0/1]
     #echo curl -T "$DIR/$i/binaries/gen/openssl-$nv/netty-tcnative-$VER-linux-x86_64.jar" -ufloragunncom:$BT_APIKEY "https://api.bintray.com/content/floragunncom/netty-tcnative/natives/$VER/netty-tcnative-openssl-1.0.2-dynamic-$VER-$i-linux-x86_64.jar?override=1"
     #curl -T "$DIR/$i/binaries/gen/openssl-$nv/netty-tcnative-$VER-linux-x86_64.jar" -ufloragunncom:$BT_APIKEY "https://api.bintray.com/content/floragunncom/netty-tcnative/natives/$VER/netty-tcnative-libressl-$LIBRESSL_VERSION-dynamic-$VER-$i-linux-x86_64.jar?override=1"
     curl -T "$DIR/$i/binaries/gen/libressl-$nv/netty-tcnative-libressl-static-$VER-linux-x86_64.jar" -ufloragunncom:$BT_APIKEY "https://api.bintray.com/content/floragunncom/netty-tcnative/natives/$VER/netty-tcnative-libressl-$LIBRESSL_VERSION-static-$VER-$i-linux-x86_64.jar?override=1"
     #POST /content/:subject/:repo/:package/:version/publish

     #do not publish yet
     #curl -X POST -ufloragunncom:$BT_APIKEY "https://api.bintray.com/content/floragunncom/netty-tcnative/natives/$VER/publish"
   done 
done
echo "All done"
cd $DIR