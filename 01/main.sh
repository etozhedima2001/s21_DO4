#!/bin/bash

if [[ $# -ne 6 ]]; then
    echo "Ошибка: аргументов должно быть 6" >&2
    exit 1
fi

log_file="file_log.txt"
path="$1"
num_folders="$2"
folder_chars="$3"
num_files="$4"
file_params="$5"
file_size_kb="${6%kb}"
current_date=$(date '+%d%m%y')

validate_parameters() {
    if [[ ! "$path" =~ ^/ ]]; then
        echo "Ошибка: Параметр 1 должен быть абсолютным путем" >&2
        exit 1
    fi
    if ! [[ "$num_folders" =~ ^[0-9]+$ && "$num_files" =~ ^[0-9]+$ ]]; then
        echo "Ошибка: Параметр 2 и 4 должны быть положительными целыми числами" >&2
        exit 1
    fi
    if [[ ! "$folder_chars" =~ ^[a-z]{1,7}$ ]]; then
        echo "Ошибка: Параметр 3 не должен превышать 7 знаков" >&2
        exit 1
    fi
    IFS='.' read -r file_name_part file_ext_part <<< "$file_params"
    if [[ -z "$file_name_part" || -z "$file_ext_part" ]]; then
        echo "Ошибка: Параметр 5 должен быть в формате 'name.ext'." >&2
        exit 1
    fi
    if [[ "${#file_name_part}" -lt 1 || "${#file_name_part}" -gt 7 ]]; then
        echo "Ошибка: Часть названия в параметре 5 не должен превышать 7 знаков" >&2
        exit 1
    fi
    if [[ "${#file_ext_part}" -lt 1 || "${#file_ext_part}" -gt 3 ]]; then
        echo "Ошибка: Часть формата в параметре 5 не должен превышать 3 знаков" >&2
        exit 1
    fi
    if [[ ! "$file_size_kb" =~ ^[0-9]+$ || "$file_size_kb" -gt 100 || "$file_size_kb" -le 0 ]]; then
        echo "Ошибка: Параметр 6 не должен превышать 100kb" >&2
        exit 1
    fi
}

generate_part() {
    local chars=$1 min_len=$2 target_len=$3
    local part=""
    for ((i=0; i<${#chars}; i++)); do
        part+="${chars:$i:1}"
    done
    while [[ ${#part} -lt $target_len ]]; do
        part+="${chars: -1}"
    done
    echo "$part"
}

create_entities() {
    local folder_chars=$1 num_folders=$2 file_name_part=$3 file_ext_part=$4 num_files=$5 file_size=$6
    local folder_part=$(generate_part "$folder_chars" ${#folder_chars} 4)
    local last_folder_char="${folder_chars: -1}"
    local ext_part=$(generate_part "$file_ext_part" ${#file_ext_part} ${#file_ext_part})

    for ((i=1; i<=num_folders; i++)); do
        local current_folder_part="${folder_part}$(printf "%${i}s" | tr ' ' "$last_folder_char")"
        local folder_name="${current_folder_part}_${current_date}"
        local folder_path="${path}/${folder_name}"
        mkdir -p "$folder_path"
        echo "$folder_path $(date '+%Y-%m-%d %H:%M:%S')" >> "$log_file"

        local file_part=$(generate_part "$file_name_part" ${#file_name_part} 4)
        local last_file_char="${file_name_part: -1}"

        for ((j=1; j<=num_files; j++)); do
            local current_file_part="${file_part}$(printf "%${j}s" | tr ' ' "$last_file_char")"
            local file_name="${current_file_part}_${current_date}.${ext_part}"
            local file_path="${folder_path}/${file_name}"
            dd if=/dev/zero of="$file_path" bs=1K count="$file_size" status=none
            echo "$file_path $(date '+%Y-%m-%d %H:%M:%S') ${file_size}K" >> "$log_file"

            if (( $(df / | awk 'NR==2 {print $4}') < 1048576 )); then
                echo "Ошибка: В системе меньше 1GB свободного места. Остановка" >&2
                exit 1
            fi
        done
    done
}

validate_parameters
create_entities "$folder_chars" "$num_folders" "$file_name_part" "$file_ext_part" "$num_files" "$file_size_kb"

echo "Скрипт успешно заверешен"