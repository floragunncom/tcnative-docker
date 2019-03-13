#!/bin/bash
set -e
rm -rf /output/gen
mkdir -p /output/gen
cd /output/gen
openssl version
cat /usr/include/openssl/opensslv.h | grep OPENSSL_VERSION_TEXT
echo "$NETTY_TCNATIVE_TAG" > "/output/gen/$NETTY_TCNATIVE_TAG"
mkdir -p "/output/gen/openssl-$NETTY_TCNATIVE_TAG"
#mkdir -p "/output/boringssl-$NETTY_TCNATIVE_TAG"
#mkdir -p "/output/libressl-$NETTY_TCNATIVE_TAG"

git clone https://github.com/netty/netty-tcnative || true
cd netty-tcnative
git checkout tags/$NETTY_TCNATIVE_TAG
#sed -i -e 's#^\s*<module>openssl-static</module>\s*$#<!-- removed <module>openssl-static</module>-->#g' pom.xml
#sed -i -e 's#^\s*<module>openssl-dynamic</module>\s*$#<!-- removed <module>openssl-dynamic</module>-->#g' pom.xml
sed -i -e 's#^\s*<module>boringssl-static</module>\s*$#<!-- removed <module>boringssl-static</module>-->#g' pom.xml
sed -i -e 's#^\s*<module>libressl-static</module>\s*$#<!--removed <module>libressl-static</module>-->#g' pom.xml
sed -i -e 's#^\s*<opensslVersion>.*</opensslVersion>\s*$#<opensslVersion>'"$OPENSSL_VERSION"'</opensslVersion>#g' pom.xml
sed -i -e 's#^\s*<opensslSha256>.*</opensslSha256>\s*$#<opensslSha256>'"$OPENSSL_SHA256"'</opensslSha256>#g' pom.xml
sed -i -e 's#www\.us\.apache\.org#archive\.apache\.org#g' pom.xml


cat pom.xml

cat > docker_settings.xml <<EOL
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                      https://maven.apache.org/xsd/settings-1.0.0.xsd">
  <localRepository>/output/repository</localRepository>
</settings>
EOL

mvn -s docker_settings.xml clean package -DskipTests

openssl version
cat /usr/include/openssl/opensslv.h | grep OPENSSL_VERSION_TEXT

cp -av /output/gen/netty-tcnative/openssl-dynamic/target/*x86*.jar "/output/gen/openssl-$NETTY_TCNATIVE_TAG/"
cp -av /output/gen/netty-tcnative/openssl-static/target/*x86*.jar "/output/gen/openssl-$NETTY_TCNATIVE_TAG/"
#mv boringssl-static/target/*.jar /output/boringssl-static
#mv libressl-static/target/*.jar /output/libressl-static