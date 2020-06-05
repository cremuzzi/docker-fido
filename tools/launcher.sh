#!/usr/bin/env sh

docker run --rm --name fido \
    --device /dev/bus/usb \
    --network host \
    -e DISPLAY \
    -e TZ=America/La_Paz \
    -v $HOME/.Xauthority:/home/fido/.Xauthority \
    fido:80d3b42-jre
