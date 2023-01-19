#!/usr/bin/env bash

set -e

APP="$1"
VERSION="$2"
DISTFOLDER="$3"

docker build -t apt-deploy:local .

cat _redirects | grep 'https' | awk '{print $2}' | while read link; do
	curl -L -o "pool/main/$(basename "$link")" "$link"
done

ls "$DISTFOLDER" | grep '.deb' | while read file; do
	echo "/pool/main/${file} https://github.com/dustinblackman/${APP}/releases/download/v${VERSION}/${file} 302" >>_redirects
done

cp -r "$DISTFOLDER"/*.deb ./pool/main/

rm -rf all-packages dists
docker run -it -v "$PWD:/project" apt-deploy:local bash -c "cd project && dpkg-scanpackages --multiversion ./pool/ > all-packages"
cat all-packages | grep 'Architecture:' | awk -F ': ' '{print $2}' | sort | uniq | while read arch; do
	mkdir -p "dists/stable/main/binary-${arch}"
	docker run -t -v "$PWD:/project" apt-deploy:local bash -c "cd project && dpkg-scanpackages --arch ${arch} pool/ > dists/stable/main/binary-${arch}/Packages"
	gzip -k -f "dists/stable/main/binary-${arch}/Packages"
done
rm -f all-packages

docker run -it -v "$PWD:/project" apt-deploy:local bash -c "cd project && apt-ftparchive release . > dists/stable/Release"
gpg --default-key "6A34CFEE77FE8257C3BB92FE24C3FC5D6987904B" -abs -o - Release >dists/stable/Release.gpg
gpg --default-key "6A34CFEE77FE8257C3BB92FE24C3FC5D6987904B" --clearsign -o - Release >dists/stable/InRelease

git add .
git commit -m "add $APP $VERSION"
git push
