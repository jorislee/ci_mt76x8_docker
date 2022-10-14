
#ubuntu
FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV GIT_SSL_NO_VERIFY=1
ENV FORCE_UNSAFE_CONFIGURE=1

#RUN sed -i s:/archive.ubuntu.com:/mirrors.tuna.tsinghua.edu.cn/ubuntu:g /etc/apt/sources.list
#RUN apt-get clean

RUN apt-get -y update --fix-missing && \
    apt-get install -y \
    ecj \
    git \
    vim \
    npm \
    g++ \
    gcc \
    file \
    swig \
    wget \
    time \
    make \
    cmake \
    gawk \
    unzip \
    rsync \
    ccache \
    fastjar \
    gettext \
    xsltproc \
    apt-utils \
    libssl-dev \
    libelf-dev \
    zlib1g-dev \
    subversion \
    build-essential \
    libncurses5-dev \
    libncursesw5-dev \
    python \
    python3 \
    python3-dev \
    python2.7-dev \
    python3-setuptools \
    python-distutils-extra \
    java-propose-classpath

RUN npm -v

RUN npm cache clean -f && \
    npm install -g n && \
    n stable && \
    /bin/bash && \
    node -v

RUN npm install -g npm@8.19.2 &&\
    /bin/bash && \
    npm -v

WORKDIR /home

RUN git clone -b openwrt-21.02 --recursive https://github.com/openwrt/openwrt.git

WORKDIR /home/openwrt

RUN ./scripts/feeds update -a && ./scripts/feeds install -a

RUN echo "src-git oui https://github.com/jorislee/oui.git" >> feeds.conf.default

RUN ./scripts/feeds update -a && ./scripts/feeds install -a -p oui

RUN rm -rf ./feeds/oui/nginx-19.07 ./package/feeds/oui/nginx-19.07
RUN rm -rf ./feeds/packages/net/nginx ./package/feeds/packages/nginx

COPY ./HLK-7628N.dts ./target/linux/ramips/dts/mt7628an_hilink_hlk-7628n.dts

RUN rm -f .config* && touch .config && \
    echo "CONFIG_HOST_OS_LINUX=y" >> .config && \
    echo "CONFIG_TARGET_ramips=y" >> .config && \
    echo "CONFIG_TARGET_ramips_mt76x8=y" >> .config && \
    echo "CONFIG_TARGET_ramips_mt76x8_DEVICE_hilink_hlk-7628n=y" >> .config && \
    echo "CONFIG_TARGET_ROOTFS_INITRAMFS=y" >> .config && \
    echo "CONFIG_SDK=y" >> .config && \
    echo "CONFIG_MAKE_TOOLCHAIN=y" >> .config && \
    echo "CONFIG_IB=y" >> .config && \
    echo "CONFIG_PACKAGE_vim=y" >> .config && \
    echo "CONFIG_PACKAGE_bash=y" >> .config && \
    echo "CONFIG_PACKAGE_wget=y" >> .config && \
    echo "CONFIG_PACKAGE_ethtool=y" >> .config && \
    echo "CONFIG_PACKAGE_oui-app-home=y" >> .config && \
    echo "CONFIG_PACKAGE_oui-app-layout=y" >> .config && \
    echo "CONFIG_PACKAGE_oui-app-login=y" >> .config && \
    echo "CONFIG_PACKAGE_oui-app-stations=y" >> .config && \
    echo "CONFIG_PACKAGE_oui-app-system=y" >> .config && \
    echo "CONFIG_PACKAGE_oui-app-upgrade=y" >> .config && \
    echo "CONFIG_PACKAGE_oui-app-user=y" >> .config && \
    echo "CONFIG_PACKAGE_oui-rpc-core=y" >> .config && \
    echo "CONFIG_PACKAGE_oui-ui-core=y" >> .config && \
    echo "CONFIG_OUI_USE_HOST_NODE=y" >> .config && \
    sed -i 's/^[ \t]*//g' .config

RUN make defconfig

RUN make download -j8

RUN make -j1 V=s

CMD [ "/bin/bash" ]
