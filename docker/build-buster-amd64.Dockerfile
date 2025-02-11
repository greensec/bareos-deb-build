FROM debian:buster-slim

ADD assets/dpkg_nodoc /etc/dpkg/dpkg.cfg.d/90_nodoc
ADD assets/dpkg_nolocale /etc/dpkg/dpkg.cfg.d/90_nolocale
ADD assets/apt_nocache /etc/apt/apt.conf.d/90_nocache
ADD assets/apt_mindeps /etc/apt/apt.conf.d/90_mindeps

ARG DEBIAN_FRONTEND=noninteractive

# default dependencies
RUN	set -e \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends wget ca-certificates gnupg quilt ccache distcc  \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* /var/tmp/* /var/log/*

# install package deps
RUN set -e \
    && echo "deb-src http://archive.debian.org/debian buster main" >/etc/apt/sources.list.d/buster-source.list \
    && echo "deb http://debian-archive.at.mirror.anexia.com/debian buster-backports main" >/etc/apt/sources.list.d/buster-backports.list \
    && echo "deb-src http://security.debian.org/debian-security/ buster/updates main contrib non-free" >>/etc/apt/sources.list.d/buster-source.list \
    && echo "deb http://download.bareos.org/current/Debian_11 /" > /etc/apt/sources.list.d/bareos.list \
    && echo "deb-src http://download.bareos.org/current/Debian_11 /" >> /etc/apt/sources.list.d/bareos.list \
    && wget -O- https://download.bareos.org/current/Debian_11/Release.key | apt-key add - \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y git git-buildpackage librados-dev \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y -t buster-backports cmake libarchive13 \
    && DEBIAN_FRONTEND=noninteractive apt-get build-dep -y bareos \
    && DEBIAN_FRONTEND=noninteractive apt-get build-dep -y python-bareos \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* /var/tmp/* /var/log/*
