#!/bin/bash

# Konfigurasi Bot
TOKEN="8742506481:AAE7RX5PCHI4gfuF0l-YBofOmyZ7hWkS0QA"
ID="7760947776"
OFFSET=-1
export LC_ALL=C.UTF-8

echo "🛡️ Suditro Commander V4.0 (Ultimate Edition) Aktif..."

while true; do
    UPDATES=$(curl -s "https://api.telegram.org/bot$TOKEN/getUpdates?offset=$OFFSET&timeout=10")
    MESSAGE=$(echo "$UPDATES" | jq -r '.result[-1].message.text // empty')
    CHAT_ID=$(echo "$UPDATES" | jq -r '.result[-1].message.chat.id // empty')
    UPDATE_ID=$(echo "$UPDATES" | jq -r '.result[-1].update_id // empty')

    if [[ -n "$UPDATE_ID" && "$UPDATE_ID" != "null" ]]; then
        OFFSET=$((UPDATE_ID + 1))

        if [[ "$CHAT_ID" == "$ID" ]]; then
            
            # --- 🌡️ /status (SYSTEM HEALTH) ---
            if [[ "$MESSAGE" == "/status" ]]; then
                TEMP=$(sensors | grep "Tctl" | awk '{print $2}' | tr -d '+')
                RAM=$(free -h | awk '/^Mem:/ {print $3 "/" $2}')
                RESPONSE="💻 *LAPTOP STATUS*%0A━━━━━━━━━━━━━━━%0A🌡️ *CPU Temp:* $TEMP%0A📊 *Memory:* $RAM%0A━━━━━━━━━━━━━━━"
                curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=$RESPONSE" -d "parse_mode=Markdown" > /dev/null

            # --- 📊 /top (RELIABLE PROCESS MONITOR) ---
            elif [[ "$MESSAGE" == "/top" ]]; then
                # Coba metode 1: top (Batch Mode)
                TOP_PROC=$(top -b -n 1 | head -n 12 | tail -n 5 | awk '{printf "🔥 *%s%%* -> _%s_\n", $9, $12}')
                
                # Cek jika output aneh (kolom geser), pakai Metode 2: ps
                if [[ "$TOP_PROC" == *"%"* || -z "$TOP_PROC" ]]; then
                    TOP_PROC=$(ps -eo pcpu,comm --sort=-pcpu | head -n 6 | tail -n 5 | sed 's/^[[:space:]]*//' | awk '{printf "🔥 *%s%%* -> _%s_\n", $1, $2}')
                fi

                RESPONSE="📊 *RESOURCE MONITOR*%0A━━━━━━━━━━━━━━━%0A$TOP_PROC%0A━━━━━━━━━━━━━━━"
                curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=$RESPONSE" -d "parse_mode=Markdown" > /dev/null

            # --- 🌐 /netstat (CYBER SECURITY) ---
            elif [[ "$MESSAGE" == "/netstat" ]]; then
                CONNECTIONS=$(ss -tun | grep ESTAB | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | awk '{printf "🌐 *%s* (%s Hits)\n", $2, $1}')
                [[ -z "$CONNECTIONS" ]] && CONNECTIONS="✅ *Status:* _Secure / No External Link_"
                RESPONSE="🌐 *NETWORK MONITOR*%0A━━━━━━━━━━━━━━━%0A$CONNECTIONS%0A━━━━━━━━━━━━━━━"
                curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=$RESPONSE" -d "parse_mode=Markdown" > /dev/null

            # --- 🛡️ /audit (FIXED VALIDATION) ---
            elif [[ "$MESSAGE" == "/audit" ]]; then
                curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=🛡️ _Sabar Bang, Audit lagi jalan..._" -d "parse_mode=Markdown" > /dev/null
                # Bersihkan kode warna ANSI agar angka skor bisa diambil dengan benar
                SKOR_RAW=$(sudo ~/Arch-AI-Hardener/hardener.sh | grep "SCORE AKHIR" | sed 's/\x1b\[[0-9;]*m//g')
                SKOR_SISTEM=$(echo "$SKOR_RAW" | awk '{print $3}')
                RESPONSE="⚔️ *AUDIT RESULT*%0A━━━━━━━━━━━━━━━%0A📌 Score: *$SKOR_SISTEM / 100*%0A━━━━━━━━━━━━━━━"
                curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=$RESPONSE" -d "parse_mode=Markdown" > /dev/null

            # --- 📸 /intip (STEALTH SCREENSHOT) ---
            elif [[ "$MESSAGE" == "/intip" ]]; then
                IMG_PATH="/tmp/ss_suditro.png"
                spectacle -b -n -o "$IMG_PATH" > /dev/null 2>&1
                sleep 2
                if [[ -f "$IMG_PATH" ]]; then
                    curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendPhoto" -F "chat_id=$ID" -F "photo=@$IMG_PATH" -F "caption=📸 Kondisi Layar ASUS TUF" > /dev/null
                    rm "$IMG_PATH"
                fi
            fi
        fi
    fi
    sleep 2
done
