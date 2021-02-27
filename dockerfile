## This Dockerfile recreates the steps mentioned at: https://ant-media-docs.readthedocs.io/en/latest/Build-From-Source.html
# I copied some steps from the AMS manual and incorporated some extras to set up the environment necessary to compile the project,
# which aren't mentioned at the AMS manual.
FROM ubuntu:20.04

LABEL maintainer="hello@juliusneudecker.com"

WORKDIR /home/ams-build

## Build Server from source
# Setup local environment
RUN  apt-get update && apt-get upgrade -y \
    && DEBIAN_FRONTEND="noninteractive" apt-get install tzdata \
    && apt-get install -y tzdata git default-jdk maven
ADD ./config/settings.xml /home/m2/settings.xml

# Compile Components
RUN git clone https://github.com/ant-media/ant-media-server-parent.git \
    && git clone https://github.com/ant-media/Ant-Media-Server-Common.git \
    && git clone https://github.com/ant-media/Ant-Media-Server-Service.git \
    && git clone https://github.com/ant-media/red5-plugins.git

RUN cd ant-media-server-parent && mvn clean install -Dgpg.skip=true
RUN cd Ant-Media-Server-Common && mvn clean install -Dmaven.javadoc.skip=true -Dmaven.test.skip=true -Dgpg.skip=true
RUN cd Ant-Media-Server-Service && mvn clean install -Dmaven.javadoc.skip=true -Dmaven.test.skip=true -Dgpg.skip=true
RUN cd red5-plugins/tomcat && mvn clean install -Dmaven.javadoc.skip=true -Dmaven.test.skip=true -Dgpg.skip=true

WORKDIR /home

RUN git clone https://github.com/ant-media/Ant-Media-Server.git

WORKDIR /home/Ant-Media-Server
RUN mvn clean install -Dmaven.javadoc.skip=true -Dmaven.test.skip=true -Dgpg.skip=true
RUN chmod +x repackage_community.sh && ./repackage_community.sh

## Build Server Image
RUN mkdir /home/ams-dist && cp ./target/ant-media-server-community-*.zip /home/ams-dist/
WORKDIR /home/ams-dist

RUN apt-get install -y libx11-dev \
	&& apt-get install -y wget \
	&& apt-get install -y libcap2

RUN wget https://raw.githubusercontent.com/ant-media/Scripts/master/install_ant-media-server.sh \
    && chmod 755 install_ant-media-server.sh \
    && ./install_ant-media-server.sh -i ant-media-server-*.zip -s false

## clean up
RUN rm ant-media-server-*.zip && rm install_ant-media-server.sh \
    && apt-get autoremove --purge -y git maven

WORKDIR /home
RUN rm -rf ./ams-build/Ant-Media-Server-Parent && \
    rm -rf ./ams-build/Ant-Media-Server-Common && \
    rm -rf ./ams-build/Ant-Media-Server-Service && \
    rm -rf ./ams-build/red5-plugins && \
    rm -rf Ant-Media-Server

## Custom config to make it work as expected - experimental
WORKDIR /usr/local/antmedia/
ADD ./config/red5-default.xml ./webapps/red5-default.xml

## Set some container specifics
VOLUME /usr/local/antmedia/log

EXPOSE 9999
EXPOSE 5080

CMD [ "start", "-m", "standalone" ]
