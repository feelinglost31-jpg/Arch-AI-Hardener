#!/bin/bash

TOKEN="8742506481:AAE7RX5PCHI4gfuF0l-YBofOmyZ7hWkS0QA"
ID="7760947776"
OFFSET=-1
export LC_ALL=C.UTF-8

LAST_LOG=""

send_menu() {
    # Ambil status UFW buat indikator di menu
    FW_STATUS=$(sudo ufw status | grep -o "active" || echo "inactive")
    [[ "$FW_STATUS" == "active" ]] && FW_ICON="🛡️" || FW_ICON="🔓"

    local TEXT="🛡️ *SUDITRO COMMAND CENTER V6.0*%0A━━━━━━━━━━━━━━━━━━━━━%0A💻 _ASUS TUF A15 - Lockdown Ready_%0A📍 FW Status: $FW_ICON *$FW_STATUS*%0A━━━━━━━━━━━━━━━━━━━━━"
    
    # Tambah baris tombol LOCKDOWN & UNLOCK
    local KEYBOARD='{"inline_keyboard":[[{"text":"🌡️ Status","callback_data":"status"},{"text":"📊 Top Proc","callback_data":"top"}],[{"text":"🌐 Net","callback_data":"net"},{"text":"📸 SS","callback_data":"intip"}],[{"text":"⚔️ Audit","callback_data":"audit"},{"text":"🔒 LOCKDOWN","callback_data":"panic"}],[{"text":"🔓 UNLOCK","callback_data":"unpanic"}]]}'
    
    curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
        -d "chat_id=$ID" \
        -d "text=$TEXT" \
        -d "parse_mode=Markdown" \
        -d "reply_markup=$KEYBOARD" > /dev/null
}

echo "🔒 Lockdown Mode V6.0 Aktif..."

while true; do
    # --- 🕵️ SECURITY WATCHDOG ---
    CURRENT_LOG=$(journalctl -u systemd-logind.service -u sudo --since "1 minute ago" | grep -i "failed" | tail -n 1)
    if [[ -n "$CURRENT_LOG" && "$CURRENT_LOG" != "$LAST_LOG" ]]; then
        LAST_LOG="$CURRENT_LOG"
        MSG="⚠️ *INTRUDER ALERT!*%0ADetail: _Gagal login terdeteksi!_"
        curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=$MSG" -d "parse_mode=Markdown" > /dev/null
    fi

    # --- 🤖 TELEGRAM HANDLER ---
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
                    RES="🌡️ *CPU:* $TEMP" ;;
                top)
                    TOP_PROC=$(ps -eo pcpu,comm --sort=-pcpu | head -n 4 | tail -n 3 | awk '{printf "🔥 *%.1f%%* %s\n", $1, $2}')
                    RES="📊 *TOP PROC*%0A$TOP_PROC" ;;
                panic)
                    # --- 🔒 AKSI LOCKDOWN ---
                    sudo ufw --force enable > /dev/null
                    sudo ufw default deny incoming > /dev/null
                    RES="🚨 *SYSTEM LOCKDOWN ACTIVE!*%0A_Firewall diaktifkan, semua koneksi luar diblokir!_" ;;
                unpanic)
                    # --- 🔓 BUKA LOCKDOWN ---
                    sudo ufw disable > /dev/null
                    RES="🔓 *SYSTEM UNLOCKED*%0A_Firewall dinonaktifkan._" ;;
                net)
                    CONNS=$(ss -tun | grep ESTAB | wc -l)
                    RES="🌐 *Total Koneksi Aktif:* $CONNS" ;;
                audit)
                    RES="⚔️ _Audit running... Check file hardener.sh_" ;;
                intip)
                    IMG_PATH="/tmp/ss.png"
                    spectacle -b -n -o "$IMG_PATH" > /dev/null 2>&1
                    sleep 2
                    [[ -f "$IMG_PATH" ]] && curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendPhoto" -F "chat_id=$ID" -F "photo=@$IMG_PATH" -F "caption=📸 Screenshot" > /dev/null && rm "$IMG_PATH"
                    RES="📸 _Sent!_" ;;
            esac
            
            [[ "$CALLBACK" != "intip" ]] && curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=$RES" -d "parse_mode=Markdown" > /dev/null
            send_menu
        fi
    fi
    sleep 1
done
