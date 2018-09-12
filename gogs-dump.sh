#!/bin/bash

LOG_FILE=/data/dumps/gogs-dump.log

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


# 设置仓库下文件的权限，增加所有者的写权限：
chmod u+w -R /data/git/gogs-repositories/

# 备份文件名，例如：gogs-backup-20180912150913.zip
ARCHIVE_NAME=gogs-backup-$(date +%Y%m%d-%H%M%S).zip

# 设置系统环境变量
export USER=git

# 开始备份
cd /app/gogs

./gogs backup --target /data/dumps --archive-name $ARCHIVE_NAME >> $LOG_FILE
# 获得返回码
status=$?
if [ $status -ne 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') Failed to dump gogs, exit code: $status" >> $LOG_FILE
    # 删除无用的备份文件
    if [ -f /data/dumps/$ARCHIVE_NAME ]; then 
        echo "$(date '+%Y-%m-%d %H:%M:%S') delete dump file: /data/dumps/$ARCHIVE_NAME" >> $LOG_FILE
        rm -f /data/dumps/$ARCHIVE_NAME;
    fi
    exit $status
fi
echo "$(date '+%Y-%m-%d %H:%M:%S') Success to dump gogs: $ARCHIVE_NAME" >> $LOG_FILE

# 保留最新的5个备份
keep_some_newest_files




