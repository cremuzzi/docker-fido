# How to use this image

## Start a Fido instance

```sh
docker run --rm --name fido \
    --device /dev/bus/usb \
    --network host \
    -e DISPLAY \
    -e TZ=America/La_Paz \
    -v $HOME/.Xauthority:/home/fido/.Xauthority \
    cremuzzi/fido
```
