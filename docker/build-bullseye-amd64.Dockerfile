FROM debian:bullseye-slim

ADD assets/dpkg_nodoc /etc/dpkg/dpkg.cfg.d/90_nodoc
ADD assets/dpkg_nolocale /etc/dpkg/dpkg.cfg.d/90_nolocale
ADD assets/apt_nocache /etc/apt/apt.conf.d/90_nocache
ADD assets/apt_mindeps /etc/apt/apt.conf.d/90_mindeps

ARG DEBIAN_FRONTEND=noninteractive

# default dependencies
RUN	set -e \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends wget ca-certificates gnupg quilt ccache distcc dpkg-cross \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* /var/tmp/* /var/log/*

# install package deps
RUN set -e \
    && echo "deb-src http://deb.debian.org/debian bullseye main" >/etc/apt/sources.list.d/bullseye-source.list \
    && echo "deb http://http.debian.net/debian bullseye-backports main" >/etc/apt/sources.list.d/bullseye-backports.list \
    && echo "deb http://download.bareos.org/current/Debian_11 /" > /etc/apt/sources.list.d/bareos.list \
    && echo "deb-src http://download.bareos.org/current/Debian_11 /" >> /etc/apt/sources.list.d/bareos.list \
    && wget -O- "https://download.bareos.org/current/Debian_11/Release.key" | apt-key add - \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y git git-buildpackage cmake \
    && DEBIAN_FRONTEND=noninteractive apt-get build-dep -y bareos \
    && DEBIAN_FRONTEND=noninteractive apt-get build-dep -y python-bareos \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* /var/tmp/* /var/log/*
