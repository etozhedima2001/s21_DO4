#!/bin/bash

# Скрипт генерирует 5 файлов логов в формате Nginx combined
# Каждый файл содержит записи за один день (от 100 до 1000 записей)
# Формат записи: 
#   $remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent"

# Список кодов состояния HTTP и их значения:
#   200 - OK: Успешный запрос
#   201 - Created: Ресурс создан (после успешного POST/PUT)
#   400 - Bad Request: Неверный синтаксис запроса
#   401 - Unauthorized: Требуется аутентификация
#   403 - Forbidden: Доступ запрещен
#   404 - Not Found: Ресурс не найден
#   500 - Internal Server Error: Ошибка сервера
#   501 - Not Implemented: Метод не поддерживается
#   502 - Bad Gateway: Ошибка шлюза
#   503 - Service Unavailable: Сервис недоступен

# Генерируем логи за последние 5 дней
for days_ago in {4..0}; do
    log_date=$(date -d "today - $days_ago days" "+%Y-%m-%d")
    filename="access_${log_date}.log"
    
    # Случайное количество записей (100-1000)
    entries=$(( RANDOM % 901 + 100 ))
    
    # Генерируем временные метки (сортировка по возрастанию)
    timestamps=($(shuf -i 0-86399 -n "$entries" | sort -n))
    
    echo "Генерация $entries записей для $filename"
    
    for seconds in "${timestamps[@]}"; do
        # Генерация IP (валидный IPv4)
        ip=$(printf "%d.%d.%d.%d" \
            $(( RANDOM % 256 )) $(( RANDOM % 256 )) \
            $(( RANDOM % 256 )) $(( RANDOM % 256 )) )
        
        # Случайный HTTP-код
        http_codes=(200 201 400 401 403 404 500 501 502 503)
        code=${http_codes[$(( RANDOM % 10 ))]}
        
        # Случайный метод
        methods=(GET POST PUT PATCH DELETE)
        method=${methods[$(( RANDOM % 5 ))]}
        
        # Форматирование времени
        timestamp=$(date -d "${log_date} 00:00:00 UTC + ${seconds} seconds" \
            "+%d/%b/%Y:%H:%M:%S %z")
        
        # Генерация URL
        paths=("/" "/index.html" "/about" "/contact" "/products" 
               "/users" "/profile" "/settings" "/api/data" "/images/logo.png")
        path=${paths[$(( RANDOM % 10 ))]}
        
        # Параметры запроса (30% вероятности)
        if (( RANDOM % 100 < 30 )); then
            params=("id" "page" "sort" "filter" "q")
            param_name=${params[$(( RANDOM % 5 ))]}
            param_val=$(( RANDOM % 1000 + 1 ))
            path="${path}?${param_name}=${param_val}"
        fi
        
        # User-Agent
        user_agents=(
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15"
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0"
            "Opera/9.80 (Windows NT 6.0) Presto/2.12.388 Version/12.14"
            "Mozilla/5.0 (Windows NT 10.0; Trident/7.0; rv:11.0) like Gecko"
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.59"
            "Googlebot/2.1 (+http://www.google.com/bot.html)"
            "curl/7.64.1"
        )
        ua=${user_agents[$(( RANDOM % 8 ))]}
        
        # Referer (50% вероятности)
        referers=("-" 
            "http://example.com" 
            "http://google.com/search?q=example"
            "http://yandex.ru/search?text=test"
            "http://github.com"
        )
        referer=${referers[$(( RANDOM % 5 ))]}
        
        # Размер ответа (100-5000 байт)
        bytes=$(( RANDOM % 4901 + 100 ))
        
        # Формирование лог-записи
        echo "${ip} - - [${timestamp}] \"${method} ${path} HTTP/1.1\" ${code} ${bytes} \"${referer}\" \"${ua}\""
    done > "$filename"
done

echo "Логи успешно сгенерированы!"