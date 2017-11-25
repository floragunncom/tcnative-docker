#!/bin/bash
set -e
rm -rf /output/gen
mkdir -p /output/gen
cd /output/gen
echo "" > "/output/gen/$(openssl version)"
cat /usr/include/openssl/opensslv.h | grep OPENSSL_VERSION_TEXT > "/output/gen/openssl-header-version.txt"
echo "$NETTY_TCNATIVE_TAG" > "/output/gen/$NETTY_TCNATIVE_TAG"
mkdir -p "/output/gen/libressl-$NETTY_TCNATIVE_TAG"
#mkdir -p "/output/boringssl-$NETTY_TCNATIVE_TAG"
#mkdir -p "/output/libressl-$NETTY_TCNATIVE_TAG"

git clone https://github.com/netty/netty-tcnative || true
cd netty-tcnative
git checkout tags/$NETTY_TCNATIVE_TAG
#sed -i -e 's#^\s*<module>openssl-static</module>\s*$#<!-- removed <module>openssl-static</module>-->#g' pom.xml
#sed -i -e 's#^\s*<module>openssl-dynamic</module>\s*$#<!-- removed <module>openssl-dynamic</module>-->#g' pom.xml
sed -i -e 's#^\s*<module>boringssl-static</module>\s*$#<!-- removed <module>boringssl-static</module>-->#g' pom.xml
sed -i -e 's#^\s*<module>openssl-static</module>\s*$#<!--removed <module>openssl-static</module>-->#g' pom.xml
sed -i -e 's#^\s*<module>openssl-dynamic</module>\s*$#<!--removed <module>openssl-dynamic</module>-->#g' pom.xml
sed -i -e 's#^\s*<libresslVersion>.*</libresslVersion>\s*$#<libresslVersion>'"$LIBRESSL_VERSION"'</libresslVersion>#g' pom.xml
sed -i -e 's#^\s*<libresslSha256>.*</libresslSha256>\s*$#<libresslSha256>'"$LIBRESSL_SHA256"'</libresslSha256>#g' pom.xml
sed -i -e 's#^\s*<aprVersion>.*</aprVersion>\s*$#<aprVersion>1.6.3</aprVersion>#g' pom.xml
sed -i -e 's#^\s*<aprMd5>.*</aprMd5>\s*$#<aprMd5>57c6cc26a31fe420c546ad2234f22db4</aprMd5>#g' pom.xml

cat pom.xml

cat > docker_settings.xml <<EOL
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                      https://maven.apache.org/xsd/settings-1.0.0.xsd">
  <localRepository>/output/repository</localRepository>
</settings>
EOL

mvn -s docker_settings.xml clean package

#'/output/gen/netty-tcnative/libressl-static/target/netty-tcnative-libressl-static-2.0.5.Final-linux-x86_64.jar' -> '/output/gen/libressl-netty-tcnative-parent-2.0.5.Final/netty-tcnative-libressl-static-2.0.5.Final-linux-x86_64.jar'
#'/output/gen/netty-tcnative/libressl-static/target/netty-tcnative-libressl-static-2.0.5.Final-sources.jar' -> '/output/gen/libressl-netty-tcnative-parent-2.0.5.Final/netty-tcnative-libressl-static-2.0.5.Final-sources.jar'
#'/output/gen/netty-tcnative/libressl-static/target/netty-tcnative-libressl-static-2.0.5.Final.jar' -> '/output/gen/libressl-netty-tcnative-parent-2.0.5.Final/netty-tcnative-libressl-static-2.0.5.Final.jar'
#Upload files for non-fedora/2.0.5.Final

#cp -av /output/gen/netty-tcnative/openssl-dynamic/target/*x86*.jar "/output/gen/openssl-$NETTY_TCNATIVE_TAG/"
cp -av /output/gen/netty-tcnative/libressl-static/target/*x86*.jar "/output/gen/libressl-$NETTY_TCNATIVE_TAG/"
#mv boringssl-static/target/*.jar /output/boringssl-static
#mv libressl-static/target/*.jar /output/libressl-static