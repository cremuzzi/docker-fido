FROM openjdk:8-jre-stretch

LABEL maintainer="Carlos Remuzzi carlosremuzzi@gmail.com"

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
       libusb-1.0 \
    && curl -fsL https://firmadigital.bo/herramientas/descargas/v1.0.2/adsib-jacobitus-fido_1.0.2_amd64_usuario_para_debian.tar.gz -o jacobitus.tar.gz \
    && tar -xf jacobitus.tar.gz \
    && cd fido_install \
    && sed -i 's/sudo\ //g' instalar_fido.sh \
    && sed -i 's/read\ temp//g' instalar_fido.sh \
    && sh instalar_fido.sh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && cd ../  \
    && rm -rf fido_install \
    && rm jacobitus.tar.gz

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]

CMD ["java","-jar","/usr/fido/monitor.jar"]
