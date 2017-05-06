#!/bin/bash
set -e
rm -rf /output/gen
mkdir -p /output/gen

echo "" > "/output/gen/$(openssl version)"
cat /usr/include/openssl/opensslv.h | grep OPENSSL_VERSION_TEXT > "/output/gen/openssl-header-version.txt"
echo $NETTY_TCNATIVE_TAG > "/output/gen/$NETTY_TCNATIVE_TAG"
mkdir -p "/output/gen/openssl-dynamic-$NETTY_TCNATIVE_TAG"
mkdir -p "/output/gen/openssl-static-$NETTY_TCNATIVE_TAG"
#mkdir -p /output/boringssl-static
#mkdir -p /output/libressl-static

git clone https://github.com/netty/netty-tcnative
cd netty-tcnative
git checkout tags/$NETTY_TCNATIVE_TAG
#sed -i -e 's#<module>openssl-static</module>#<!--<module>openssl-static</module>-->#g' pom.xml
#sed -i -e 's#<module>openssl-dynamic</module>#<!--<module>openssl-dynamic</module>-->#g' pom.xml
sed -i -e 's#<module>boringssl-static</module>#<!--<module>boringssl-static</module>-->#g' pom.xml
sed -i -e 's#<module>libressl-static</module>#<!--<module>libressl-static</module>-->#g' pom.xml
sed -i -e 's#<opensslVersion>1.0.2j</opensslVersion>#<opensslVersion>1.0.2k</opensslVersion>#g' pom.xml
sed -i -e 's#<opensslSha256>e7aff292be21c259c6af26469c7a9b3ba26e9abaaffd325e3dccc9785256c431</opensslSha256>#<opensslSha256>6b3977c61f2aedf0f96367dcfb5c6e578cf37e7b8d913b4ecb6643c3cb88d8c0</opensslSha256>#g' pom.xml

cat > docker_settings.xml <<EOL
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                      https://maven.apache.org/xsd/settings-1.0.0.xsd">
  <localRepository>/output/repository</localRepository>
</settings>
EOL

mvn -s docker_settings.xml clean package

mv openssl-static/target/*.jar /output/gen/openssl-static-$NETTY_TCNATIVE_TAG
mv openssl-dynamic/target/*.jar /output/gen/openssl-dynamic-$NETTY_TCNATIVE_TAG
#mv boringssl-static/target/*.jar /output/boringssl-static
#mv libressl-static/target/*.jar /output/libressl-static