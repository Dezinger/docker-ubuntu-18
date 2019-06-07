FROM golang as configurability
MAINTAINER brian.wilkinson@1and1.co.uk
WORKDIR /go/src/github.com/1and1internet/configurability
RUN git clone https://github.com/1and1internet/configurability.git . \
	&& make main \
	&& echo "configurator successfully built"

FROM ubuntu:bionic
MAINTAINER brian.wilkinson@1and1.co.uk
ARG DEBIAN_FRONTEND=noninteractive
COPY files/ /
COPY --from=configurability /go/src/github.com/1and1internet/configurability/bin/configurator /usr/bin/configurator
RUN \
  apt-get -y update && apt-get -y upgrade && \
  apt-get -o Dpkg::Options::=--force-confdef -y install \
  supervisor curl netcat wget telnet \
  vim mc bzip2 ssmtp locales python-pip cron && \
  locale-gen en_GB.utf8 en_US.utf8 es_ES.utf8 de_DE.UTF-8 ru_RU.UTF-8 && \
  mkdir --mode 777 -p /var/log/supervisor && \
  chmod -R 777 /var/run /etc/ssmtp /etc/passwd /etc/group && \
  mkdir --mode 777 -p /tmp/sockets && \
  chmod -R 755 /init /hooks && \
  apt-get remove -y binutils* build-essential bzip2 cpp* dbus dirmngr fakeroot \
  				 file g++* gcc-7* gnupg* gpg-* krb5-locales libalgorithm* && \
  apt-get -y clean && \
  rm -rf /var/lib/apt/lists/* && \
  sed -i '/^root.*/d' /etc/shadow
ENV \
  SUPERVISORD_EXIT_ON_FATAL=1 \
  LC_ALL=ru_RU.UTF-8 \
  LANG=ru_RU.UTF-8 \
  LANGUAGE=ru_RU.UTF-8 \
  SMTP_USER="" \
  SMTP_PASS="" \
  SMTP_DOMAIN="" \
  SMTP_RELAYHOST=""
ENTRYPOINT ["/bin/bash", "-e", "/init/entrypoint"]
CMD ["/init/supervisord"]
