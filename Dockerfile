
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
    zip \
    vim \
    npm \
    g++ \
    gcc \
    file \
    swig \
    wget \
    time \
    make \
    curl \
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
    java-propose-classpath \
    && apt-get clean

RUN npm cache clean -f && \
    npm install -g n && \
    n stable && \
    /bin/bash && \
    node -v

RUN npm install -g npm@9.6.4 &&\
    /bin/bash && \
    npm -v

WORKDIR /home

RUN git clone -b openwrt-19.07 --recursive https://github.com/openwrt/openwrt.git

WORKDIR /home/openwrt

RUN ./scripts/feeds update -a \
    && ./scripts/feeds install -a \
    && rm -rf feeds/packages/net/nginx package/feeds/packages/nginx

RUN echo "src-git oui https://github.com/jorislee/oui.git" >> feeds.conf.default \
    && ./scripts/feeds update oui \
    && ./scripts/feeds install -a oui

COPY ./HLK-7628N.dts ./target/linux/ramips/dts/HLK-7628N.dts

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
    echo "CONFIG_PACKAGE_oui-rpc-core=y" >> .config && \
    echo "CONFIG_PACKAGE_oui-ui-core=y" >> .config && \
    echo "CONFIG_OUI_USE_HOST_NODE=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-core=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-net=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-net-cdc-eem=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-net-cdc-ether=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-net-cdc-mbim=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-net-cdc-ncm=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-net-cdc-subset=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-net-qmi-wwan=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-net-rndis=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-serial=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-serial-ipw=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-serial-garmin=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-serial-option=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-serial-qualcomm=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-serial-wwan=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-ohci=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-uhci=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb2=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-usb-wdm=y" >> .config && \
    echo "CONFIG_PACKAGE_kmod-mii=y" >> .config && \
    echo "CONFIG_PACKAGE_wwan=y" >> .config && \
    echo "CONFIG_PACKAGE_chat=y" >> .config && \
    echo "CONFIG_PACKAGE_ppp=y" >> .config && \
    echo "CONFIG_PACKAGE_uqmi=y" >> .config && \
    echo "CONFIG_PACKAGE_umbim=y" >> .config && \
    echo "CONFIG_PACKAGE_comgt=y" >> .config && \
    echo "CONFIG_PACKAGE_comgt-ncm=y" >> .config && \
    echo "CONFIG_PACKAGE_usb-modeswitch=y" >> .config && \
    echo "CONFIG_PACKAGE_qmi-utils=y" >> .config && \
    echo "CONFIG_PACKAGE_usbutils=y" >> .config && \
    sed -i 's/^[ \t]*//g' .config && \
    make defconfig

RUN make download -j8 \
    && make -j1 V=w \
    && tar -jxvf ./bin/targets/ramips/mt76x8/openwrt-toolchain-ramips-mt76x8_gcc-7.5.0_musl.Linux-x86_64.tar.bz2 -C /opt/ \
    && tar -Jxvf ./bin/targets/ramips/mt76x8/openwrt-imagebuilder-ramips-mt76x8.Linux-x86_64.tar.xz -C /home/ \
    && mkdir -p /opt/Kernel-mt76x8 \
    && mv ./build_dir/target-mipsel_24kc_musl/linux-ramips_mt76x8/linux-4.14.275/ /opt/Kernel-mt76x8 \
    && cd /home && rm -rf ./openwrt

ENV ARCH=mips
ENV CROSS_COMPILE=/opt/openwrt-toolchain-ramips-mt76x8_gcc-7.5.0_musl.Linux-x86_64/toolchain-mipsel_24kc_gcc-7.5.0_musl/bin/mipsel-openwrt-linux-
ENV STAGING_DIR=/opt/openwrt-toolchain-ramips-mt76x8_gcc-7.5.0_musl.Linux-x86_64/toolchain-mipsel_24kc_gcc-7.5.0_musl/bin

WORKDIR /home/openwrt-imagebuilder-ramips-mt76x8.Linux-x86_64

RUN make image PROFILE="hilink_hlk-7628n" PACKAGES="wget vim bash"

WORKDIR /home

CMD [ "/bin/bash" ]
