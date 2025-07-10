#!/bin/bash

echo -e "создано файлов в /home"
grep '/home' $1 | wc -l
echo "каталогов:"
grep 'Папка: /home' $1 | wc -l
echo "файлов:"
grep 'Файл: /home' $1 | wc -l
echo ""

echo -e "создано файлов в /tmp"
grep '/tmp' $1 | wc -l
echo "каталогов:"
grep 'Папка: /tmp' $1 | wc -l
echo "файлов:"
grep 'Файл: /tmp' $1 | wc -l
echo ""

echo -e "создано файлов в /var"
grep '/var' $1 | wc -l
echo "каталогов:"
grep 'Папка: /var' $1 | wc -l
echo "файлов:"
grep 'Файл: /var' $1 | wc -l
echo ""

echo -e "создано файлов в /opt"
grep '/opt' $1 | wc -l
echo "каталогов:"
grep 'Папка: /opt' $1 | wc -l
echo "файлов:"
grep 'Файл: /opt' $1 | wc -l
echo ""

echo -e "создано файлов в /srv"
grep '/srv' $1 | wc -l
echo "каталогов:"
grep 'Папка: /srv' $1 | wc -l
echo "файлов:"
grep 'Файл: /srv' $1 | wc -l
echo ""

echo "Всего файлов было создано:"
grep -E '/home|/tmp|/var|/opt|/srv' $1 | grep -v 'Время начала|Время окончания|Общее время работы' | wc -l
echo "Всего каталогов:"
grep 'Папка:' $1 | wc -l