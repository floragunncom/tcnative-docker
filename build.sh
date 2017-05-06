#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OS=(alpine non-fedora fedora)
cd $DIR
for i in "${OS[@]}"
do
   : 
   cd $DIR/$i
   cp -a $DIR/scripts/compile.sh .
   echo "### BUILD $i ###"
   docker build -t $i:latest . > /dev/null
   rm -rf "$DIR/$i/binaries/gen"
   echo "### RUN $i ###"
   mkdir -p "$DIR/$i/binaries"
   docker run -e "NETTY_TCNATIVE_TAG=netty-tcnative-parent-2.0.0.Final" --rm -v $DIR/$i/binaries:/output "$i:latest"
done

cd $DIR