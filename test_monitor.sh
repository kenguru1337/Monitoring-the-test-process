#!/bin/bash

LOG_FILE="/var/log/monitoring.log"
STATE_FILE="/var/run/test_monitor.pid"
PROCESS_NAME="test"
MONITOR_URL="https://test.com/monitoring/test/api"

timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Проверка, запущен ли процесс
PID=$(pgrep -x "$PROCESS_NAME")

if [[ -n "$PID" ]]; then
    # Отправка запроса на сервер мониторинга
    if ! curl -fsS --max-time 5 "$MONITOR_URL" >/dev/null 2>&1; then
        echo "$(timestamp) - Ошибка: Сервер мониторинга недоступен" >> "$LOG_FILE"
    fi

    # Проверка на перезапуск процесса
    if [[ -f "$STATE_FILE" ]]; then
        LAST_PID=$(cat "$STATE_FILE")
        if [[ "$PID" != "$LAST_PID" ]]; then
            echo "$(timestamp) - Процесс '$PROCESS_NAME' был перезапущен (PID: $PID)" >> "$LOG_FILE"
        fi
    fi
    echo "$PID" > "$STATE_FILE"
fi
