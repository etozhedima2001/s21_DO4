#!/bin/bash

#Сборка всех логов из part04
cat ../04/access* > all_logs.log

goaccess all_logs.log \
    --log-format=COMBINED \
    --date-format=%d/%b/%Y \
    --time-format=%H:%M:%S \
    -o dashboard.html

echo -e "Выберите браузер для открытия логов\n1 - Firefox\n2 - Google Chrome\n3 - Chromium\n4 - Brave\n5 - Очистить логи"
read -e browser

case "$browser" in
    "1")
    firefox dashboard.html
    ;;
    "2")
    google-chrome dashboard.html
    ;;
    "3")
    chromium dashboard.html
    ;;
    "4")
    brave-browser dashboard.html
    ;;
    "5")
    rm all_logs.log dashboard.html
    ;;
    *)
    echo "Not valid command"
    ;;
esac