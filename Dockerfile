FROM gogs/gogs:0.11.91

MAINTAINER visionken <visionken2017@qq.com>

#update system timezone & application timezone
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" >> /etc/timezone && \
    apk --no-cache add findutils && \
    echo "30      0       *       *       *       /app/gogs/gogs-dump.sh" >> /var/spool/cron/crontabs/root

COPY gogs-dump.sh /app/gogs/
COPY .gitconfig /data/git/

# Add crond to the dockerfile: https://github.com/gogs/gogs/issues/2597
ENV RUN_CROND=true USER=git

# add openjdk
RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV PATH $PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin

ENV JAVA_VERSION 8u222
ENV JAVA_ALPINE_VERSION 8.222.10-r0

RUN set -x \
	&& apk --no-cache add openjdk8="$JAVA_ALPINE_VERSION" \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ]