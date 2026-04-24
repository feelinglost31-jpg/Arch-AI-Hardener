#!/bin/bash

TOKEN="8742506481:AAE7RX5PCHI4gfuF0l-YBofOmyZ7hWkS0QA"
ID="7760947776"
OFFSET=-1
export LC_ALL=C.UTF-8

# Simpan state log terakhir biar gak spam notif yang sama
LAST_LOG=""

send_menu() {
    local TEXT="🛡️ *SUDITRO COMMAND CENTER V5.5*%0A━━━━━━━━━━━━━━━━━━━━━%0A💻 _ASUS TUF A15 - Watchdog Active_%0A📍 Status: Monitoring Security...%0A━━━━━━━━━━━━━━━━━━━━━"
    local KEYBOARD='{"inline_keyboard":[[{"text":"🌡️ Status","callback_data":"status"},{"text":"📊 Top Proc","callback_data":"top"}],[{"text":"🌐 Network","callback_data":"net"},{"text":"📸 Screenshot","callback_data":"intip"}],[{"text":"⚔️ Audit Sistem","callback_data":"audit"}]]}'
    
    curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
        -d "chat_id=$ID" \
        -d "text=$TEXT" \
        -d "parse_mode=Markdown" \
        -d "reply_markup=$KEYBOARD" > /dev/null
}

echo "🛡️ Watchdog Mode V5.5 Aktif..."

while true; do
    # --- 🕵️ SECURITY WATCHDOG SECTION ---
    # Cek log sistem untuk kegagalan autentikasi (sudo/login/kde)
    CURRENT_LOG=$(journalctl -u systemd-logind.service -u sudo --since "1 minute ago" | grep -i "failed" | tail -n 1)
    
    if [[ -n "$CURRENT_LOG" && "$CURRENT_LOG" != "$LAST_LOG" ]]; then
        LAST_LOG="$CURRENT_LOG"
        MSG="⚠️ *INTRUDER ALERT!*%0A━━━━━━━━━━━━━━━%0A📌 *Detail:* _Percobaan login gagal terdeteksi!_%0A🕒 *Waktu:* $(date '+%H:%M:%S')%0A━━━━━━━━━━━━━━━"
        curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=$MSG" -d "parse_mode=Markdown" > /dev/null
    fi
    # ------------------------------------

    # Cek Updates dari Telegram (Long Polling 10 detik biar gak terlalu lambat respon watchdog)
    UPDATES=$(curl -s --max-time 15 "https://api.telegram.org/bot$TOKEN/getUpdates?offset=$OFFSET&timeout=10")
    
    RESULT=$(echo "$UPDATES" | jq -r '.result[-1] // empty')
    
    if [[ -n "$RESULT" && "$RESULT" != "null" ]]; then
        MESSAGE=$(echo "$RESULT" | jq -r '.message.text // empty')
        CALLBACK=$(echo "$RESULT" | jq -r '.callback_query.data // empty')
        UPDATE_ID=$(echo "$RESULT" | jq -r '.update_id // empty')
        OFFSET=$((UPDATE_ID + 1))

        if [[ "$MESSAGE" == "/start" || "$MESSAGE" == "/menu" ]]; then
            send_menu
        fi

        if [[ -n "$CALLBACK" ]]; then
            case $CALLBACK in
                status)
                    TEMP=$(sensors | grep -E "Tctl|Package" | awk '{print $2}' | head -1 | tr -d '+')
                    RAM=$(free -h | awk '/^Mem:/ {print $3 "/" $2}')
                    RES="🌡️ *CPU:* $TEMP%0A📊 *RAM:* $RAM" ;;
                top)
                    TOP_PROC=$(ps -eo pcpu,comm --sort=-pcpu | head -n 6 | tail -n 5 | sed 's/^[[:space:]]*//' | awk '{printf "🔥 *%.1f%%* -> _%s_\n", $1, $2}')
                    RES="📊 *TOP PROCESSES*%0A$TOP_PROC" ;;
                net)
                    CONNECTIONS=$(ss -tun | grep ESTAB | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | awk '{printf "🌐 *%s* (%s Hits)\n", $2, $1}')
                    [[ -z "$CONNECTIONS" ]] && CONNECTIONS="✅ _Network Secure_"
                    RES="🌐 *NET MONITOR*%0A$CONNECTIONS" ;;
                audit)
                    SKOR_RAW=$(sudo ~/Arch-AI-Hardener/hardener.sh | grep "SCORE AKHIR" | sed 's/\x1b\[[0-9;]*m//g')
                    SKOR=$(echo "$SKOR_RAW" | awk '{print $3}')
                    RES="⚔️ *AUDIT SCORE*%0A📌 Result: *$SKOR / 100*" ;;
                intip)
                    IMG_PATH="/tmp/ss_suditro.png"
                    spectacle -b -n -o "$IMG_PATH" > /dev/null 2>&1
                    sleep 2
                    [[ -f "$IMG_PATH" ]] && curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendPhoto" -F "chat_id=$ID" -F "photo=@$IMG_PATH" -F "caption=📸 Captured" > /dev/null && rm "$IMG_PATH"
                    RES="📸 _Screenshot sent!_" ;;
            esac
            
            [[ "$CALLBACK" != "intip" ]] && curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=$RES" -d "parse_mode=Markdown" > /dev/null
            send_menu
        fi
    fi
    sleep 2
done
