#!/bin/bash

LOG_FILE=/data/gogs-dump.log
DIR_TEMP=/data/temp
DIR_DUMPS=/data/dumps

# 保留最新的5个备份
function keep_some_newest_files(){
    num_save=5
    files_ops="/data/dumps/"
    num_files=$(find /data/dumps/ -maxdepth 1 -type f -name gogs-backup-*.zip -printf "%C@ %p\n" | sort -n | wc -l)
    if test ${num_files} -gt ${num_save};then
        echo "$(date '+%Y-%m-%d %H:%M:%S') total number of files is $num_files." >> $LOG_FILE
        num_ops=$(expr ${num_files} - ${num_save})
        echo "$(date '+%Y-%m-%d %H:%M:%S') $num_ops files are going to be delete." >> $LOG_FILE
        list_ops=$(find /data/dumps/ -maxdepth 1 -type f -name gogs-backup-*.zip -printf "%C@ %p\n" | sort -n | head -n${num_ops} | awk -F '[ ]+' '{print $2}')
        for afile in ${list_ops};do
            echo "$(date '+%Y-%m-%d %H:%M:%S') delete $afile" >> $LOG_FILE
            # 如果文件存在则删除文件
            if [ -f ${afile} ]; then 
            	rm -f ${afile};
            fi
        done
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') total number of files is $num_files." >> $LOG_FILE
        echo "$(date '+%Y-%m-%d %H:%M:%S') 0 files are going to be delete, skipping." >> $LOG_FILE
    fi
}

echo "$(date '+%Y-%m-%d %H:%M:%S') === Backup start ..." >> $LOG_FILE

#创建备份目录
if [ ! -d $DIR_TEMP ];then
    mkdir -p $DIR_TEMP
fi
if [ ! -d $DIR_DUMPS ];then
    mkdir -p $DIR_DUMPS
fi

# 设置仓库下文件的权限，增加所有者的写权限：
echo "$(date '+%Y-%m-%d %H:%M:%S') Adding write permission to /data/git/gogs-repositories/" >> $LOG_FILE
chmod u+w -R /data/git/gogs-repositories/
echo "$(date '+%Y-%m-%d %H:%M:%S') Add write permission ok." >> $LOG_FILE

# 备份文件名，例如：gogs-backup-20180912150913.zip
ARCHIVE_NAME=gogs-backup-$(date +%Y%m%d-%H%M%S).zip

# 设置系统环境变量
export USER=git



# 开始备份
cd /app/gogs
./gogs backup --target $DIR_TEMP --archive-name $ARCHIVE_NAME >> $LOG_FILE

# 获得返回码
status=$?
if [ $status -ne 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') Failed to dump gogs, exit code: $status" >> $LOG_FILE
    # 删除无用的备份文件
    if [ -f $DIR_TEMP/$ARCHIVE_NAME ]; then 
        echo "$(date '+%Y-%m-%d %H:%M:%S') delete dump file: $DIR_TEMP/$ARCHIVE_NAME" >> $LOG_FILE
        rm -f $DIR_TEMP/$ARCHIVE_NAME;
    fi
    echo "$(date '+%Y-%m-%d %H:%M:%S') chown log to root" >> $LOG_FILE
    chown -R git:git /app/gogs/log/
    echo "$(date '+%Y-%m-%d %H:%M:%S') === Backup end." >> $LOG_FILE
    exit $status
fi
echo "$(date '+%Y-%m-%d %H:%M:%S') Success to dump gogs: $DIR_DUMPS/$ARCHIVE_NAME" >> $LOG_FILE
mv $DIR_TEMP/$ARCHIVE_NAME $DIR_DUMPS

# 保留最新的5个备份
keep_some_newest_files

echo "$(date '+%Y-%m-%d %H:%M:%S') chown log to root" >> $LOG_FILE
chown -R git:git /app/gogs/log/

echo "$(date '+%Y-%m-%d %H:%M:%S') === Backup end." >> $LOG_FILE



