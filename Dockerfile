FROM ubuntu:24.04

ENV DEBIAN_FRONTEND noninteractive
ENV STEAM_USER anonymous
ENV USE_SRCDS true
ENV APPID=232250
ENV APPDIR=/home/steamsrv/tf2
ENV APP_SERVER_PORT 27015
ENV APP_GAME_NAME tf
ENV APP_SERVER_MAXPLAYERS 24
ENV APP_SERVER_MAP ctf_2fort
ENV APP_SERVER_NAME Team Fortress 2 Dedicated Server
ENV APP_SERVER_CONTACT user@example.com
ENV APP_SERVER_REGION -1

# Install dependencies
RUN dpkg --add-architecture i386
RUN apt-get update                      &&      \
    apt-get upgrade -y                     &&      \
    apt-get install -y                          \
        curl                                    \
	libc6:i386				\
	libstdc++6:i386				\
	lib32z1					\
	libcurl3-gnutls:i386

RUN useradd                             \
        -d /home/steamsrv               \
        -m                              \
        -s /bin/bash                    \
        steamsrv

RUN mkdir -p /scripts
ADD InstallAppID /scripts/InstallAppID
ADD run_srcds_server /scripts/run_srcds_server
ADD StartServer /scripts/StartServer

USER steamsrv
# Download and extract SteamCMD
RUN mkdir -p /home/steamsrv/steamcmd            &&\
    cd /home/steamsrv/steamcmd                          &&\
    curl -s http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar -vxz &&\
    mkdir -p /home/steamsrv/.steam/sdk32		&&\
    mkdir -p /home/steamsrv/.steam/sdk64		&&\
    ln -s /home/steamsrv/steamcmd/linux32/steamclient.so /home/steamsrv/.steam/sdk32/steamclient.so && \
    ln -s /home/steamsrv/steamcmd/linux64/steamclient.so /home/steamsrv/.steam/sdk64/steamclient.so
	

WORKDIR /home/steamsrv

RUN /home/steamsrv/steamcmd/steamcmd.sh +login anonymous +quit


ADD server.cfg /tmp/server.cfg

EXPOSE ${APP_SERVER_PORT}
EXPOSE ${APP_SERVER_PORT}/udp

USER steamsrv

CMD /scripts/StartServer