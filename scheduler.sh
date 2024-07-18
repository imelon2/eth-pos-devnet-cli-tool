#!/bin/bash
# .env 파일의 경로 설정
env_file=".env"

# 파일 존재 여부 확인
if [ -f "$env_file" ]; then
    source "$env_file"
else
    echo "Error: $env_file does not exist."
    exit 1
fi


TIMESTAMP=`date +%Y/%m/%d-%H:%M`
LOG_PATH=scheduler.log

echo "===============[$TIMESTAMP| => restart geth]=================" >> $LOG_PATH
docker compose stop geth && docker compose restart geth --no-deps 




# crontab -e
# 0 8 * * 1 ./scheduler.sh
# 분 시 일 월 요

# crontab -l
