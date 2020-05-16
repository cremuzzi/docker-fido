FROM node:14.2.0-alpine3.11 as api-compiler

ARG GITLAB_SHA=f93e3932

RUN apk add --no-cache --virtual .build-deps \
        curl \
        maven \
        nodejs \
        npm \
    && apk add --no-cache \
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
