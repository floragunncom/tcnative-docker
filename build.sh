#!/bin/bash
set -e
TC_NATIVE_TAGS=(netty-tcnative-parent-2.0.0.Final netty-tcnative-parent-1.1.33.Fork25 netty-tcnative-1.1.33.Fork17)
#for every os in OS list there must be subfolder with this name and Dockerfile in it
OS=(alpine non-fedora fedora)
MAVEN_VERSION=3.5.0
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"
for i in "${OS[@]}"
do
   : 
   cd "$DIR/$i"
   cp -a "$DIR/scripts/compile.sh" .
   echo "### BUILD $i ###"
   docker build --build-arg "MAVEN_VERSION=$MAVEN_VERSION" -t "$i:latest" . > /dev/null
   rm -rf "$DIR/$i/binaries/gen"
   mkdir -p "$DIR/$i/binaries"
   for nv in "${TC_NATIVE_TAGS[@]}"
   do
     : 
     echo "### RUN $i/$nv ###"
     docker run -e "NETTY_TCNATIVE_TAG=$nv" --rm -v "$DIR/$i/binaries:/output" "$i:latest"
     curl -T "$DIR/$i/binaries/gen/netty-tcnative-$nv-linux-x86_64.jar" -ufloragunncom:f6ada084a8e3a79ee07963ca5ab196e261386df9 "https://api.bintray.com/content/floragunncom/netty-tcnative/$i/$nv/nativejar/"
     curl -T "$DIR/$i/binaries/gen/netty-tcnative-openssl-static-$nv-linux-x86_64.jar" -ufloragunncom:f6ada084a8e3a79ee07963ca5ab196e261386df9 "https://api.bintray.com/content/floragunncom/netty-tcnative/$i/$nv/nativejar/"
   done 
done

cd $DIR