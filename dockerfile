## This Dockerfile recreates the steps mentioned at: https://ant-media-docs.readthedocs.io/en/latest/Build-From-Source.html
# I copied some steps from the AMS manual and incorporated some extras to set up the environment necessary to compile the project,
# which aren't mentioned at the AMS manual.
FROM ubuntu:20.04

LABEL maintainer="hello@juliusneudecker.com"

WORKDIR /home/ams-build

RUN apt-get update && apt-get upgrade -y

## Build Server from source

# Setup local environment
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata
RUN apt-get install -y git default-jdk maven gpg
ADD ./config/settings.xml ./m2/settings.xml

# Compile Components
RUN git clone https://github.com/ant-media/ant-media-server-parent.git
RUN cd ant-media-server-parent && mvn clean install -Dgpg.skip=true

RUN git clone https://github.com/ant-media/Ant-Media-Server-Common.git
RUN cd Ant-Media-Server-Common && mvn clean install -Dmaven.javadoc.skip=true -Dmaven.test.skip=true -Dgpg.skip=true

RUN git clone https://github.com/ant-media/Ant-Media-Server-Service.git
RUN cd Ant-Media-Server-Service && mvn clean install -Dmaven.javadoc.skip=true -Dmaven.test.skip=true -Dgpg.skip=true

RUN git clone https://github.com/ant-media/red5-plugins.git

ENV GPG_TTY=$(tty)
ADD ./scripts/create-gpg.sh ./create-gpg.sh
RUN chmod +x create-gpg.sh && ./create-gpg.sh && rm create-gpg.sh

RUN cd red5-plugins/tomcat && mvn clean install -Dmaven.javadoc.skip=true -Dmaven.test.skip=true

WORKDIR /home

RUN git clone https://github.com/ant-media/Ant-Media-Server.git

WORKDIR /home/Ant-Media-Server
RUN mvn clean install -Dmaven.javadoc.skip=true -Dmaven.test.skip=true -Dgpg.skip=true && 
RUN chmod +x repackage.sh && ./repackage.sh

# If everthing goes well, a new packaged Ant Media Server(ant-media-server-x.x.x.zip) file will be created in Ant-Media-Server/target directory

## Build Server Image

RUN mkdir /home/ams-dist && cp ./target/ant-media*.zip /home/ams-dist/
WORKDIR /home/ams-dist
ENV AMS_ZIP=${ls}

RUN apt-get install -y libx11-dev \
	&& apt-get install -y wget \
	&& apt-get install -y libcap2

RUN wget https://raw.githubusercontent.com/ant-media/Scripts/master/install_ant-media-server.sh \
    && chmod 755 install_ant-media-server.sh

RUN ./install_ant-media-server.sh ${AMS_ZIP}

## clean up
RUN rm ${AMS_ZIP} && rm install_ant-media-server.sh

WORKDIR /home
RUN rm -rf ./ams-build/Ant-Media-Server-Parent
RUN rm -rf ./ams-build/Ant-Media-Server-Common
RUN rm -rf ./ams-build/Ant-Media-Server-Service
RUN rm -rf ./ams-build/red5-plugins
RUN rm -rf Ant-Media-Server

## Custom config to make it work as expected - experimental
WORKDIR /usr/local/antmedia/
ADD ./config/red5-default.xml ./webapps/red5-default.xml

## Setup container specifics
EXPOSE 9999
EXPOSE 5080

## Setup run config
WORKDIR /home
ADD ./scripts/startup.sh ./startup.sh
RUN chmod +x ./startup.sh

#ENTRYPOINT service antmedia start && bash
#ENTRYPOINT [ "startup.sh", "start" ]
ENTRYPOINT bash