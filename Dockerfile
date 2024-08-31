ARG PLATFORM=${BUILDPLATFORM:-linux/amd64}
ARG DISTRO=rockylinux
ARG ELVER=8
ARG PHPVER=8.0
ARG PHPXPASSREPO=https://github.com/zeriyoshi/php-xpass.git
ARG PHPXPASSBRANCH=hotfix_autoconf

FROM --platform=${PLATFORM} ${DISTRO}:${ELVER}

ARG ELVER
ARG PHPVER
ARG PHPXPASSREPO
ARG PHPXPASSBRANCH

RUN dnf install -y "https://rpms.remirepo.net/enterprise/remi-release-${ELVER}.rpm" \
 && dnf config-manager --disable -y "epel" "remi-modular" "remi-safe" \
 && dnf --enablerepo=remi-modular module enable -y "php:remi-${PHPVER}" \
 && dnf --enablerepo=epel,remi,remi-modular install -y "php" "php-devel" \
 && dnf install -y "python3-pip" "perl-open" "git" \
 && (dnf install -y "perl-FindBin" || true) \
 && pip3 install "passlib" \
 && git clone --depth=1 --branch="v4.4.36" "https://github.com/besser82/libxcrypt.git" "/libxcrypt" \
 && cd "/libxcrypt" \
 &&   ./autogen.sh \
 &&   ./configure --with-pkgconfigdir="/usr/lib64/pkgconfig" --libdir="/usr/lib64" \
 &&   make -j"$(nproc)" \
 &&   make install \
 && cd - \
 && git clone --depth=1 --branch="${PHPXPASSBRANCH}" "${PHPXPASSREPO}" "/php-xpass" 

COPY "xpasstest.sh" "/usr/local/bin/xpasstest"

CMD [ "/usr/local/bin/xpasstest" ]
