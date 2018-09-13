# prong/gogs



这是 [gogs](https://gogs.io/) 的 docker 自定义镜像，官方镜像 [gogs/gogs](https://hub.docker.com/r/gogs/gogs/)。

在官方的基础上做了如下变更：

- 将时区从UTC改为中国上海；
- 增加自动备份功能，每日0点30分开始全量备份，保留最新的5个备份文件。
  - 备份文件例子：

    - 容器内：/data/dumps/gogs-backup-20180912-230801.zip
  - 备份日志：
    - 容器内：/data/dumps/gogs-dump.log

> 你可以结合 `rsync` + `inotify`，将备份文件实时复制到备份服务器上。



## 使用说明

```shell
# Pull image from Docker Hub.
$ docker pull prong/gogs:0.11.53

# Create local directory for volume.
$ mkdir -p /var/gogs

# Use `docker run` for the first time.
$ docker run --name=gogs -p 10022:22 -p 10080:3000 -v /var/gogs:/data -d prong/gogs:0.11.53

# Use `docker start` if you have stopped it.
$ docker start gogs
```

更多帮助请参考[官方文档](https://github.com/gogs/gogs/tree/master/docker)。

