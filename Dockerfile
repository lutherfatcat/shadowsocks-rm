FROM centos:7
MAINTAINER LUTHER LIU<lutherfatcat@gmail.com>

ENV NODE_ID=0                     \
    DNS_1=1.0.0.1                 \
    DNS_2=8.8.8.8                 \
    API_INTERFACE=legendsockssr   \
    MYSQL_HOST=remotehost         \
    MYSQL_PORT=3306               \
    MYSQL_USER=docker             \
    MYSQL_PASS=mypasswd           \
    MYSQL_DB=whmcs                \
    TRANSFER_MUL=1.0              \
    SS_TABLE=user                 \
    REDIRECT=github.com           \
    FAST_OPEN=false

COPY . /root/shadowsocks-rm
COPY /root/shadowsocks-rm/centos/* /root/
WORKDIR /root/shadowsocks-rm


RUN  apk --no-cache add \
                        supervisor \
                        grub2 \
                        wget \
                        net-tools \
                        python-setuptools \
                        git \
                        python-pip \
                        php \
                        php-pear \
                        ntpdate \
                        dsniff \
                        libnetpacket-perl \
                        nginx                                && \
     apk --no-cache add --virtual .build-deps \
                        tar \
                        make \
                        gettext \
                        py3-pip \
                        autoconf \
                        automake \
                        build-base \
                        linux-headers                        && \
     cp /usr/bin/envsubst /usr/local/bin/                    && \
     pip install --upgrade pip                               && \
     pip install cymysql                                     && \
     rm -f /etc/localtime                                    && \
     ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime  && \
     rm -rf ~/.cache && touch /etc/hosts.deny                && \
     apk del --purge .build-deps

CMD chmod +x /root/killcx.pl && mkdir /root/logs                            && \
    envsubst < apiconfig.py > userapiconfig.py                              && \
    echo -e "${DNS_1}\n${DNS_2}\n" > dns.conf                               && \
    iptables-restore < /root/firewall.rules                                 && \
    mv /root/root /var/spool/cron/root                                      && \
    sed -i -e s#ss_table#${SS_TABLE}#g /root/shadowsocks-rm/db_transfer.py  && \
    iptables-restore < /root/firewall.rules                                 && \
    echo "files = supervisord.d/*.conf" >> /etc/supervisord.conf            && \
    cp /root/shadowsocks.conf /etc/supervisord.d/                           && \
    YES | cp -f /root/sysctl.conf /etc/                                     && \
    systemctl enable supervisord && service supervisord start
