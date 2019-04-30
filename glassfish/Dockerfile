FROM debian:stretch
MAINTAINER Yadickson Soto <yadickson@gmail.com>

ARG GF_VERSION=5.0.1
ARG GF_UID=1234
ARG GF_USER=glassfish

ENV GF_DOMAIN=domain1
ENV GF_BASE=/opt/$GF_UID
ENV GLASSFISH_HOME=$GF_BASE/glassfish

ENV GF_DOMAIN=domain1
ENV GF_ASADMIN=asadmin
ENV GF_DOMAINBASEDIR=$GLASSFISH_HOME/domains
ENV GF_DOMAINDIR=$GF_DOMAINBASEDIR/$GF_DOMAIN
ENV GF_TEMP_PASSFILE=$GF_BASE/.asadminpass

ENV GF_USER_ADMIN=admin
ENV GF_ADMINPASSWORD=adminadmin
ENV GF_MASTERPASSWORD=changeit

ENV PATH=$PATH:$GLASSFISH_HOME/bin

RUN echo "Build glassfish $GF_VERSION"

USER root

COPY start.sh /

RUN echo "deb http://deb.debian.org/debian/ stretch main" > /etc/apt/sources.list \
 && echo "deb http://deb.debian.org/debian/ stretch-updates main" >> /etc/apt/sources.list \
 && echo "deb http://security.debian.org/ stretch/updates main" >> /etc/apt/sources.list

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get upgrade --no-install-recommends -o Dpkg::Options::="--force-confnew" -y \
 && DEBIAN_FRONTEND=noninteractive apt-get install wget unzip screenfetch openjdk-8-jre --no-install-recommends -o Dpkg::Options::="--force-confnew" -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN echo "screenfetch" >> /root/.bashrc

RUN groupadd -g $GF_UID -r $GF_USER \
 && useradd -u $GF_UID -b /opt -d $GF_BASE -m -s /bin/bash -g $GF_USER $GF_USER

USER $GF_USER

ENV JAVA_HOME /usr/lib/jvm/default-java

RUN cd $HOME \
 && wget -c http://download.oracle.com/glassfish/$GF_VERSION/release/glassfish-$GF_VERSION.zip -O glassfish.zip \
 && unzip glassfish.zip -x "glassfish*/glassfish/domains/*" \
 && find . -name '*.bat' -delete \
 && find . -name '*.exe' -delete \
 && rm -f glassfish.zip \
 && ln -s glassfish*/ glassfish

# $GF_ASADMIN set configs.config.server-config.network-config.network-listeners.network-listener.http-listener-1.port=

EXPOSE 8080 8181 4848
VOLUME ["$GF_DOMAINBASEDIR"]
# ENTRYPOINT ["/start.sh"]

# CMD ["$GF_ASADMIN", "start-domain", "--verbose"]

