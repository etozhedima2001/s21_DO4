#!/bin/bash

TARGET_DIRS=("/home" "/tmp" "/var" "/opt" "/srv")

if [ $# -ne 1 ] ; then
    echo "Ошибка: аргументов должно быть 1" >&2
    echo -e "Выберите следующие команды:\n1-чистка системы по лог файлу\n2-чистка системы по дате и времени создания\n3-чистка системы по маске имени  "
    exit 1
fi

logfile_reader() {
    read -e -p "Введите путь до логов: " log_path

    if [[ ! -f "$log_path" ]]; then
        echo "Ошибка: логфайл не найден"
        exit 1
    fi

    if [[ ! "$log_path" == *.log ]]; then
        echo "Ошибка: файл не является логами"
        exit 1
    fi

    count=0

    while IFS= read -r line; do
        if [[ "$line" == Папка:* ]]; then
            folder_path=$(echo "$line" | awk -F'[:|]' '{gsub(/^ +| +$/, "", $2); print $2}')
            echo $folder_path  #изменить на rm -rf
            ((count++))
        fi
    done < "$log_path"

    echo "Найдено $count каталогов"

    echo -e "\nУдалить найденные объекты? [y/N]"
    read -r confirm

    if [[ "$confirm" == "y" || "$confirm" == "Y" || "$confirm" == "yes" ]]; then
        echo "Удаление..."
            while IFS= read -r line; do
            if [[ "$line" == Папка:* ]]; then
                folder_path=$(echo "$line" | awk -F'[:|]' '{gsub(/^ +| +$/, "", $2); print $2}')
                sudo rm -rf $folder_path
            fi
    done < "$log_path"
        echo "Удаление завершено"
    else
        echo "Удаление отменено"
    fi
}

uptime_reader() {
    echo -e "Введите интервал времени по данному примеру\n2025-06-18 14:01:00 2025-06-18 14:02:00"
    read -p ">> " interval
    start_time=$(echo "$interval" | awk '{print $1 " " $2}')
    end_time=$(echo "$interval" | awk '{print $3 " " $4}')
    start_ts=$(date -d "$start_time" +%s 2>/dev/null)
    end_ts=$(date -d "$end_time" +%s 2>/dev/null)

    if [[ -z "$start_ts" || -z "$end_ts" ]]; then
        echo "Ошибка: некорректный ввод, убедитесь, что вы указали обе даты"
        exit 1
    fi

    if (( end_ts < start_ts )); then
    echo "Ошибка: время окончания интервала должно быть позже начала"
    exit 1
    fi

    echo -e "\nИщем файлы, изменённые в интервале:\nС $start_time по $end_time\n"

    #TARGET_DIRS=("/home" "/tmp" "/var" "/opt" "/srv")
    touch files_to_delete.txt
    results_file="files_to_delete.txt"

    for  dir in "${TARGET_DIRS[@]}"; do
        echo "Поиск в каталоге: $dir"

        # sudo find "$dir" -type f \
        #     -newermt "$start_time" ! -newermt "$end_time" \
        #     ! -name "*.log" \
        #     -print 2>/dev/null >> "$results_file"

        # sudo find "$dir" -depth -type d \
        # -newermt "$start_time" ! -newermt "$end_time" \
        # ! -path "$dir" \
        # ! -path "*/DO4*" \
        # -print 2>/dev/null >> "$results_file"
        sudo find "$dir" -type d -path '*DO4*' -prune -false -o \
            -type f -newermt "$start_time" ! -newermt "$end_time" \
            ! -name "*.log" -print 2>/dev/null >> "$results_file"

        sudo find "$dir" -type d -path '*DO4*' -prune -false -o \
            -depth -type d -newermt "$start_time" ! -newermt "$end_time" \
            ! -path "$dir" -print 2>/dev/null >> "$results_file"

    done

    echo -e "\nНайдено $(wc -l < "$results_file") объектов для удаления"
    echo -e "\nСписок найденных объектов находится в файле $results_file"

    echo -e "\nУдалить найденные объекты? [y/N]"
    read -r confirm

    if [[ "$confirm" == "y" || "$confirm" == "Y" || "$confirm" == "yes" ]]; then
        echo "Удаление..."
        sudo xargs rm -rf "$results_file"
        echo "Удаление завершено"
    else
        echo "Удаление отменено"
    fi

    rm -f "$results_file"
}

mask_name() {
    #read -p "Введите символы, использованные в названии каталогов:" folder_chars
    #read -p "Введите символы, использованные в названии файлах:" file_chars
    read -p "Введите время создания файлов в виде DDMMYY:" file_date
    
    #pattern_folder="$(echo $folder_chars | sed 's/./[&]/g')_[${file_date}]"
    #pattern_file="$(echo $file_chars | sed 's/./[&]/g')_[${file_date}]"
    pattern_date="*${file_date}*"
    #echo "Используем маски: Папки: $pattern_folder, Файлы: $pattern_file"

    found=()

    for dir in "${TARGET_DIRS[@]}"; do
        echo "Поиск в каталоге: $dir"
        while IFS= read -r path; do
            found+=("$path")
        done < <(find "$dir" \( -type f -o -type d \) -name "*$pattern_date" 2>/dev/null)
    done

    for f in "${found[@]}"; do
        echo "$f"
    done

    echo -e "\nНайдено ${#found[@]} объектов для удаления"
    if [ ${#found[@]} -eq 0 ]; then
        echo "Объектов, подходящих под такую дату не найдены"
        exit 1
    fi

    echo -e "\nУдалить найденные объекты? [y/N]"
    read -r confirm

    if [[ "$confirm" =~ ^[yY](es)?$ ]]; then
        echo "Удаление..."
        for f in "${found[@]}"; do
            sudo rm -rf "$f"
        done
        echo "Удаление завершено"
    else
        echo "Удаление отменено"
    fi
}

case "$1" in
    "1")
    logfile_reader
    ;;
    "2")
    uptime_reader
    ;;
    "3")
    mask_name
    ;;
    *)
    echo "not found command"
    ;;
esac