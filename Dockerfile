FROM --platform=linux/amd64 debian:bullseye-slim

RUN apt-get update && apt-get install -y local-apt-repository dpkg-dev
