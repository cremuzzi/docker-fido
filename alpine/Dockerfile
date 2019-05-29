FROM openjdk:8-jdk-alpine3.9

LABEL maintainer="Carlos Remuzzi carlosremuzzi@gmail.com"

RUN apk add --no-cache --virtual .build-deps \
        curl \
        maven \
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
    && cp source/Fido/application.properties.sample /usr/fido/application.properties \
    && sed -i 's~usr\/lib\/x86_64-linux-gnu\/opensc-pkcs11.so~usr/lib/opensc-pkcs11.so~g' /usr/fido/application.properties \
    && cp source/Fido/adsib.pem /usr/fido/adsib.pem \
    && cp source/Fido/att.pem /usr/fido/att.pem \
    && cp source/Fido/firmadigital_bo.crl.base /usr/fido/firmadigital_bo.crl \
    && mvn install -f source/Fido/pom.xml \
    && cp source/Fido/target/fido.jar /usr/fido/fido.jar \
    && mvn install -f source/FidoMonitor/pom.xml \
    && cp source/FidoMonitor/target/monitor.jar /usr/fido/monitor.jar \
    && mvn install -f source/FidoGUI/pom.xml \
    && cp source/FidoGUI/target/fido_gui.jar /usr/fido/fido_gui.jar \
    && cp -r source/Fido/images /usr/fido/images \
    && cp driver_deb/recursos/creditos.txt /usr/fido/creditos.txt \
    && apk del .build-deps \
    && cd / \
    && rm -rf /jacobitus-v1.0.2

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]

CMD ["java","-jar","/usr/fido/monitor.jar"]
