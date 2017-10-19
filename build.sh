#!/bin/bash
set -e
############################################################################################
############################################################################################
OPENSSL_VERSION=1.1.0f
OPENSSL_SHA256=12f746f3f2493b2f39da7ecf63d7ee19c6ac9ec6a4fcd8c229da8a522cb12765
#TC_NATIVE_TAGS=(netty-tcnative-1.1.33.Fork17 netty-tcnative-parent-2.0.0.Final netty-tcnative-parent-2.0.1.Final netty-tcnative-parent-1.1.33.Fork25 netty-tcnative-parent-1.1.33.Fork23)
#TC_NATIVE_TAGS=(netty-tcnative-parent-2.0.2.Final netty-tcnative-parent-2.0.3.Final)
TC_NATIVE_TAGS=(netty-tcnative-parent-2.0.6.Final)

#for every os in OS list there must be subfolder with this name and a Dockerfile in it
OS=(alpine non-fedora fedora)
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
     echo "### RUN $i/$nv for Open SSL $OPENSSL_VERSION ###"
     docker run -e "NETTY_TCNATIVE_TAG=$nv" -e "OPENSSL_VERSION=$OPENSSL_VERSION" -e "OPENSSL_SHA256=$OPENSSL_SHA256" --rm -v "$DIR/$i/binaries:/output" "$i:latest"
     VER=${nv##*-}
     echo "Upload files for $i/$VER"
     #PUT /content/:subject/:repo/:package/:version/:file_path[?publish=0/1][?override=0/1][?explode=0/1]
     #echo curl -T "$DIR/$i/binaries/gen/openssl-$nv/netty-tcnative-$VER-linux-x86_64.jar" -ufloragunncom:$BT_APIKEY "https://api.bintray.com/content/floragunncom/netty-tcnative/natives/$VER/netty-tcnative-openssl-1.0.2-dynamic-$VER-$i-linux-x86_64.jar?override=1"
     curl -T "$DIR/$i/binaries/gen/openssl-$nv/netty-tcnative-$VER-linux-x86_64.jar" -ufloragunncom:$BT_APIKEY "https://api.bintray.com/content/floragunncom/netty-tcnative/natives/$VER/netty-tcnative-openssl-1.0.2-dynamic-$VER-$i-linux-x86_64.jar?override=1"
     curl -T "$DIR/$i/binaries/gen/openssl-$nv/netty-tcnative-openssl-static-$VER-linux-x86_64.jar" -ufloragunncom:$BT_APIKEY "https://api.bintray.com/content/floragunncom/netty-tcnative/natives/$VER/netty-tcnative-openssl-$OPENSSL_VERSION-static-$VER-$i-linux-x86_64.jar?override=1"
     #POST /content/:subject/:repo/:package/:version/publish
     curl -X POST -ufloragunncom:$BT_APIKEY "https://api.bintray.com/content/floragunncom/netty-tcnative/natives/$VER/publish"
   done 
done
echo "All done"
cd $DIR