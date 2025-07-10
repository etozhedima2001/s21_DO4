#!/bin/bash

if [ $# -ne 1 ] ; then
    echo "Ошибка: аргументов должно быть 1" >&2
    echo -e "1 - Сортировка по коду ответа\n2 - Сортировка по уникальным IP\n3 - Запросы с ошибками\n4 - Сортировка по уникальным IP с ошибками"
    exit 1
fi

if [[ $1 -lt 1 || $1 -gt 4 ]]; then
    echo "Ошибка: аргумент команды не найден"
    echo -e "1 - Сортировка по коду ответа\n2 - Сортировка по уникальным IP\n3 - Запросы с ошибками\n4 - Сортировка по уникальным IP с ошибками"
    exit 1
fi

sort_status() {
    awk '{print $3, $0}' ../04/access* | sort -n | cut -d' ' -f2- 
}

uniq_ip() {
    awk '{print $1}' ../04/access* | sort -u
}

error_status() {
    awk '$3 ~ /^[45][0-9]{2}$/' ../04/access*
}

uniq_ip_error_status() {
    awk '$3 ~ /^[45][0-9]{2}$/' ../04/access*.log| sort -u
}

case "$1" in
    "1")
    sort_status
    ;;
    "2")
    uniq_ip
    ;;
    "3")
    error_status
    ;;
    "4")
    uniq_ip_error_status
    ;;
esac