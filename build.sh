#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
mkdir -p "$DIR/logs"
#set -e
############################################################################################
######################  MATRIX  #################################
OPENSSL_VERSIONS=(1.0.2q 1.1.0j 1.1.1a)
TC_NATIVE_TAGS=(netty-tcnative-parent-2.0.7.Final netty-tcnative-parent-2.0.15.Final)
OS=(non-fedora fedora) #alpine?
############################################################################################
############################################################################################
MAVEN_VERSION=3.5.0

for i in "${OS[@]}"
do
	echo "#### BUILD Docker container for $i in $DIR ####"
	ls -la "$DIR"
	cd "$DIR/$i"
	cp -a "$DIR/scripts/compile.sh" .
	docker build --build-arg "MAVEN_VERSION=$MAVEN_VERSION" -t "$i:latest" . > /dev/null 2>&1
	mkdir -p "$DIR/$i/binaries"

	for OPENSSL_VERSION in "${OPENSSL_VERSIONS[@]}"
	do
		for nv in "${TC_NATIVE_TAGS[@]}"
		do
			BUILDLOG="$DIR/logs/run-$i-$nv-$OPENSSL_VERSION.log"
			echo "  -- >RUN $i/$nv for Open SSL $OPENSSL_VERSION "
			docker run -e "NETTY_TCNATIVE_TAG=$nv" -e "OPENSSL_VERSION=$OPENSSL_VERSION" -e "OPENSSL_SHA256=$OPENSSL_SHA256" --rm -v "$DIR/$i/binaries:/output" "$i:latest" > "$BUILDLOG" 2>&1
			VER=${nv##*-}
			echo "    Upload files for $i/$VER"
			ls -la "$DIR/$i/binaries/gen/openssl-$nv"
			curl -T "$DIR/$i/binaries/gen/openssl-$nv/netty-tcnative-$VER-linux-x86_64.jar" -ufloragunncom:$BT_APIKEY "https://api.bintray.com/content/floragunncom/netty-tcnative/natives/$VER/netty-tcnative-openssl-$OPENSSL_VERSION-dynamic-$VER-$i-linux-x86_64.jar?override=1"
			echo ""
			curl -T "$DIR/$i/binaries/gen/openssl-$nv/netty-tcnative-openssl-static-$VER-linux-x86_64.jar" -ufloragunncom:$BT_APIKEY "https://api.bintray.com/content/floragunncom/netty-tcnative/natives/$VER/netty-tcnative-openssl-$OPENSSL_VERSION-static-$VER-$i-linux-x86_64.jar?override=1"
			echo ""
			curl -X POST -ufloragunncom:$BT_APIKEY "https://api.bintray.com/content/floragunncom/netty-tcnative/natives/$VER/publish"
		    echo ""
			echo ""
			echo ""
		done 
	done
done
echo "All done"
cd "$DIR"