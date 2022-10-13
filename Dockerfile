
FROM sioiot/ci_openwrt_docker:mt7628

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai


RUN apt-get update && \
    apt-get install -y \
    npm \
    vim

RUN npm cache clean -f && \
    npm install -g n && \
    n stable && \
    /bin/bash

RUN npm install -g npm@8.19.2 &&\
    /bin/bash

WORKDIR /home/openwrt

RUN echo "src-git oui https://github.com/jorislee/oui.git" >> feeds.conf.default

RUN ./scripts/feeds update -a
RUN ./scripts/feeds install -a -p oui

RUN rm -rf ./feeds/oui/nginx ./package/feeds/oui/nginx
RUN rm -rf ./feeds/packages/net/nginx ./package/feeds/packages/nginx

COPY ./HLK-7628N.dts target/linux/ramips/dts/HLK-7628N.dts


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

RUN make V=s