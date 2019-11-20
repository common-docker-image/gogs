FROM gogs/gogs:0.11.91

MAINTAINER visionken <visionken2017@qq.com>

#update system timezone & application timezone
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" >> /etc/timezone && \
    apk -U add findutils && \
    echo "30      0       *       *       *       /app/gogs/gogs-dump.sh" >> /var/spool/cron/crontabs/root

COPY gogs-dump.sh /app/gogs/
COPY .gitconfig /data/git/

# Add crond to the dockerfile: https://github.com/gogs/gogs/issues/2597
ENV RUN_CROND=true USER=git
