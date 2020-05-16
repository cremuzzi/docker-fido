FROM node:14.2.0-alpine3.11 as api-compiler

ARG GITLAB_SHA=f93e3932

RUN apk add --no-cache \
        curl \
    && curl -fsL https://gitlab.softwarelibre.gob.bo/api/v4/projects/64/repository/archive.tar.gz\?sha\=$GITLAB_SHA -o jacobitus.tar.gz \
    && tar -xf jacobitus.tar.gz \
    && mv jacobitus-$GITLAB_SHA-* jacobitus \
    && npm i -g apidoc \
    && apidoc -i /jacobitus/source/Fido/src/main/java/gob/adsib/fido/server/end_points/ -o /jacobitus/source/Fido/apidoc/

FROM openjdk:8-jdk-alpine3.9 as builder

COPY --from=api-compiler /jacobitus /jacobitus

RUN apk add --no-cache --virtual .build-deps \
        maven \
    && cd /jacobitus/source/FidoModuleAbstract \
    && mvn clean install \
    && cd /jacobitus/source/Fido \
    && mvn clean install \
    && cd /jacobitus/source/FidoMonitor \
    && mvn clean install \
    && mkdir -p /usr/Fido-build \
    && cd /usr/Fido-build \
    && cp /jacobitus/source/Fido/application.properties application.properties \
    && cp /jacobitus/source/Fido/firmadigital_bo.pem firmadigital_bo.pem \
    && cp /jacobitus/source/Fido/target/fido.jar fido.jar \
    && cp /jacobitus/source/FidoMonitor/drivers.json drivers.json \
    && cp /jacobitus/source/FidoMonitor/fido.properties fido.properties \
    && cp /jacobitus/source/FidoMonitor/perfiles_certificado.json perfiles_certificado.json \
    && cp /jacobitus/source/FidoMonitor/target/monitor.jar monitor.jar \
    && cp -r /jacobitus/source/Fido/apidoc/ apidoc/
    #&& sed -i 's/localhost/0.0.0.0/g' source/Fido/src/main/java/gob/bo/agetic/demofi/servidor/ServidorHttp.java \
    #&& sed -i 's~usr\/lib\/x86_64-linux-gnu\/opensc-pkcs11.so~usr/lib/opensc-pkcs11.so~g' /usr/fido/application.properties \

FROM openjdk:8-jre-alpine3.9

LABEL maintainer="Carlos Remuzzi carlosremuzzi@gmail.com"

COPY entrypoint.sh /usr/local/bin/entrypoint
COPY --from=builder /usr/Fido-build /usr/lib/fido

RUN apk add --no-cache \
        ccid \
        opensc \
        pcsc-lite \
        ttf-dejavu

WORKDIR /usr/lib/fido

ENTRYPOINT ["entrypoint"]

CMD ["java","-jar","monitor.jar"]
