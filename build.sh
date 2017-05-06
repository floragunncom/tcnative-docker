#!/bin/bash
set -e
TC_NATIVE_TAGS=(netty-tcnative-parent-2.0.0.Final netty-tcnative-parent-1.1.33.Fork25)
# netty-tcnative-1.1.33.Fork17)
#for every os in OS list there must be subfolder with this name and Dockerfile in it
OS=(alpine non-fedora fedora)
OS=(non-fedora fedora)
MAVEN_VERSION=3.5.0
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILDLOG="$DIR/build.log"
DATE=`date +%Y-%m-%d:%H:%M:%S`
echo $DATE
rm -rf "$BUILDLOG"
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
     echo "### RUN $i/$nv ###"
     docker run -e "NETTY_TCNATIVE_TAG=$nv" --rm -v "$DIR/$i/binaries:/output" "$i:latest" >> "$BUILDLOG" 2>&1
     VER=${nv##*-}
     echo "Upload files for $VER and $DATE"
     curl -T "$DIR/$i/binaries/gen/openssl-$nv/netty-tcnative-$VER-linux-x86_64.jar" -ufloragunncom:$BT_APIKEY "https://api.bintray.com/content/floragunncom/netty-tcnative/$i/$nv-$DATE/nativejar-$i-$VER-$DATE/"
     curl -T "$DIR/$i/binaries/gen/openssl-$nv/netty-tcnative-openssl-static-$VER-linux-x86_64.jar" -ufloragunncom:$BT_APIKEY "https://api.bintray.com/content/floragunncom/netty-tcnative/$i/$nv-$DATE/nativejar-$i-$VER-$DATE/"
     curl -X POST -ufloragunncom:$BT_APIKEY "https://api.bintray.com/content/floragunncom/netty-tcnative/$i/$nv-$DATE/publish"
   done 
done
echo "All done"
cd $DIR