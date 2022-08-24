#!/usr/bin/env bash

set -e

APP="$1"
VERSION="$2"
DISTFOLDER="$3"

docker build -t apt-deploy:local .
cd deb

cp -r "$DISTFOLDER"/*.deb .

rm -f ./Packages
docker run -it -v "$PWD:/deb" apt-deploy:local bash -c "cd deb && dpkg-scanpackages --multiversion . > Packages"
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
