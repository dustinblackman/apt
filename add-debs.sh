#!/usr/bin/env bash

set -e

APP="$1"
VERSION="$2"
DISTFOLDER="$3"

docker build -t apt-deploy:local .

cat _redirects | grep 'https' | awk '{print $2}' | while read link; do
	curl -L -o "deb/files/$(basename "$link")" "$link"
done

ls "$DISTFOLDER" | grep '.deb' | while read file; do
	echo "/deb/files/${file} https://github.com/dustinblackman/${APP}/releases/download/v${VERSION}/${file} 302" >>_redirects
done

cd deb
cp -r "$DISTFOLDER"/*.deb ./files/

rm -f ./Packages
docker run -it -v "$PWD:/deb" apt-deploy:local bash -c "cd deb && dpkg-scanpackages --multiversion ./files > Packages"
gzip -k -f Packages

rm -f ./Release
docker run -it -v "$PWD:/deb" apt-deploy:local bash -c "cd deb && apt-ftparchive release . > Release"

rm -f ./Release.gpg
gpg --default-key "6A34CFEE77FE8257C3BB92FE24C3FC5D6987904B" -abs -o - Release >Release.gpg

rm -f ./InRelease
gpg --default-key "6A34CFEE77FE8257C3BB92FE24C3FC5D6987904B" --clearsign -o - Release >InRelease

git add .
git commit -m "add $APP $VERSION"
git push
