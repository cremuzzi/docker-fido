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
    #&& cp source/Fido/adsib.pem /usr/fido/adsib.pem \
    #&& cp source/Fido/att.pem /usr/fido/att.pem \
    #&& cp source/Fido/firmadigital_bo.crl.base /usr/fido/firmadigital_bo.crl \

FROM openjdk:8-jre-alpine3.9

LABEL maintainer="Carlos Remuzzi carlosremuzzi@gmail.com"

COPY entrypoint.sh /usr/local/bin/entrypoint
COPY --from=builder /usr/Fido-build /usr/lib/fido

RUN apk add --no-cache \
        ccid \
        opensc \
        pcsc-lite \
        ttf-dejavu \
    && curl -fsL https://gitlab.softwarelibre.gob.bo/adsib/jacobitus/-/archive/v1.0.2/jacobitus-v1.0.2.tar.gz -o jacobitus.tar.gz \
    && tar -xf jacobitus.tar.gz \
    && mkdir /usr/fido/ \
    && rm jacobitus.tar.gz \
    && cd jacobitus-v1.0.2 \
    && sed -i 's/localhost/0.0.0.0/g' source/Fido/src/main/java/gob/bo/agetic/demofi/servidor/ServidorHttp.java \
    && cp source/Fido/application.properties.sample /usr/fido/application.properties \
    && sed -i 's~usr\/lib\/x86_64-linux-gnu\/opensc-pkcs11.so~usr/lib/opensc-pkcs11.so~g' /usr/fido/application.properties \
    && cp source/Fido/adsib.pem /usr/fido/adsib.pem \
    && cp source/Fido/att.pem /usr/fido/att.pem \
    && cp source/Fido/firmadigital_bo.crl.base /usr/fido/firmadigital_bo.crl \
    && npm i apidoc -g \
    && apidoc -i source/Fido/src/main/java/com/adsib/fido/server/end_points/ -o source/Fido/apidoc/ \
    && mvn install -f source/Fido/pom.xml \
    && cp source/Fido/target/fido.jar /usr/fido/fido.jar \
    && mvn install -f source/FidoMonitor/pom.xml \
    && cp source/FidoMonitor/target/monitor.jar /usr/fido/monitor.jar \
    && mvn install -f source/FidoGUI/pom.xml \
    && cp source/FidoGUI/target/fido_gui.jar /usr/fido/fido_gui.jar \
    && cp -r source/Fido/images /usr/fido/images \
    && cp -r source/Fido/apidoc /usr/fido/apidoc \
    && cp driver_deb/recursos/creditos.txt /usr/fido/creditos.txt \
    && apk del .build-deps \
    && cd / \
    && rm -rf /jacobitus-v1.0.2 \
    && rm -rf /usr/lib/node_modules

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]

CMD ["java","-jar","/usr/fido/monitor.jar"]
