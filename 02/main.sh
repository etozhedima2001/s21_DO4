#!/bin/bash

if [ $# -ne 3 ] ; then
    echo "Ошибка: аргументов должно быть 3" >&2
    echo "Параметр 1 — список букв английского алфавита, используемый в названии папок (не более 7 знаков)."
    echo "Параметр 2 — список букв английского алфавита, используемый в имени файла и расширении (не более 7 знаков для имени, не более 3 знаков для расширения)." 
    echo "Параметр 3 — размер файла (в Мегабайтах, но не более 100)."
    exit 1
fi

folder_chars="$1"
file_params="$2"
file_size_mb="${3%Mb}"
start_time=$(date +%s)
start_readable=$(date "+%d-%m-%Y %H:%M:%S")
log_file="script_log_$(date +%d%m%y_%H%M%S).log"
touch "$log_file"

validate_parameters() {
    if [[ ! "$folder_chars" =~ ^[a-z]{1,7}$ ]]; then
        echo "Ошибка: Параметр 1 не должен превышать 7 знаков"
        exit 1
    fi
    IFS='.' read -r file_name_part file_ext_part <<< "$file_params"
    if [[ -z "$file_name_part" || -z "file_ext_part" ]]; then
        echo "Ошибка: Параметр 2 должен быть в формате 'name.ext'" >&2
        exit 1
    fi
    if [[ "${#file_name_part}" -lt 1 || "${#file_name_part}" -gt 7 ]]; then
        echo "Ошибка: Часть названия в параметре 2 не должен превышать 7 знаков" >&2
        exit 1
    fi
    if [[ "${#file_ext_part}" -lt 1 || "${#file_ext_part}" -gt 3 ]]; then
        echo "Ошибка: Часть формата в параметре 2 не должен превышать 3 знаков" >&2
        exit 1
    fi
    if [[ ! "$file_size_mb" =~ ^[0-9]+$ || "$file_size_mb" -gt 100 || "$file_size_mb" -le 0 ]]; then
        echo "Ошибка: Параметр 3 не должен превышать 100Mb" >&2
        exit 1
    fi
}

check_reverse_order() {
    input="$1"
    reversed=$(echo "$1" | rev)
    if [[ "$input" == "$reversed" ]]; then
        echo "Ошибка: порядок символов в параметре должен сохраняться (обратный порядок недопустим)" >&2
        exit 1
    fi
}

create_random_name() {
    chars="$1"
    while :; do
        shuffled=$(echo "$chars" | fold -w1 | shuf | tr -d '\n')
        name="${shuffled}${shuffled}${shuffled}"
        name=$(echo "$name" | fold -w1 | shuf | tr -d '\n')
        name=${name:0:$((RANDOM % 3 + 5))}_$(date +%d%m%y)

        valid=true
        for ((k=0; k<${#chars}; k++)); do
            [[ "$name" == *"${chars:k:1}"* ]] || valid=false
        done
        $valid && echo "$name" && return
    done
}

validate_parameters
check_reverse_order "$folder_chars"
excluded_paths=(/bin /sbin /usr/bin /usr/sbin /lib /lib64)
possible_dirs=(/home /tmp /var /opt /srv)

get_random_dir() {
    while :; do
        base_dir="${possible_dirs[$RANDOM % ${#possible_dirs[@]}]}"
        [[ -d "$base_dir" ]] || continue
        for exclude in "${excluded_paths[@]}"; do
            [[ "$base_dir" == "$exclude"* ]] && continue 2
        done
        echo "$base_dir"
        return
    done
}

# if grep -q -E "bin/sbin" <<< "$path"; then
#     echo "Ошибка: скрипт не может запускаться в директориях bin/sbin" >&2
#     exit 1
# fi

for ((i=0; i<100; i++)); do
    free_gb=$(df --output=avail -BG / | tail -1 | grep -o '[0-9]\+')
    if (( free_gb <= 1 )); then
        echo "Мало свободного места (<1GB). Остановка." >> "$log_file"
        break
    fi

    base_dir=$(get_random_dir)
    folder_name=$(create_random_name "$folder_chars")
    full_folder_path="$base_dir/$folder_name"
    sudo mkdir -p "$full_folder_path"
    echo "Папка: $full_folder_path | Дата: $(date "+%d-%m-%Y %H:%M:%S")" >> "$log_file"

    files_count=$((RANDOM % 10 + 1))
    for ((j=0; j<files_count; j++)); do
        file_base=$(create_random_name "$file_name_part")
        file_name="$file_base.$file_ext_part"
        file_path="$full_folder_path/$file_name"
        sudo dd if=/dev/urandom of="$file_path" bs=1M count=$file_size_mb status=none
        echo "Файл: $file_path | Размер: ${file_size_mb}MB | Дата: $(date "+%d-%m-%Y %H:%M:%S")" >> "$log_file"
    done

done

end_time=$(date +%s)
end_readable=$(date "+%d-%m-%Y %H:%M:%S")
elapsed=$((end_time - start_time))

{
    echo "Время начала: $start_readable"
    echo "Время окончания: $end_readable"
    echo "Общее время работы: ${elapsed} секунд"
} >> "$log_file"

cat "$log_file"
