#!/bin/bash

# Konfigurasi Bot
TOKEN="8742506481:AAE7RX5PCHI4gfuF0l-YBofOmyZ7hWkS0QA"
ID="7760947776"
OFFSET=-1
export LC_ALL=C.UTF-8

echo "❄️ Suditro Commander V4.1.1 (Fixed Edition) Aktif..."
echo "🛡️ Monitoring ASUS TUF - Mode Hemat Daya"

while true; do
    # LONG POLLING: Nunggu di server Telegram (CPU Aman)
    UPDATES=$(curl -s --max-time 25 "https://api.telegram.org/bot$TOKEN/getUpdates?offset=$OFFSET&timeout=20")
    
    RESULT=$(echo "$UPDATES" | jq -r '.result[-1] // empty')
    
    if [[ -n "$RESULT" && "$RESULT" != "null" ]]; then
        MESSAGE=$(echo "$RESULT" | jq -r '.message.text // empty')
        CHAT_ID=$(echo "$RESULT" | jq -r '.message.chat.id // empty')
        UPDATE_ID=$(echo "$RESULT" | jq -r '.update_id // empty')
        OFFSET=$((UPDATE_ID + 1))

        if [[ "$CHAT_ID" == "$ID" ]]; then
            
            # --- 🌡️ /status ---
            if [[ "$MESSAGE" == "/status" ]]; then
                TEMP=$(sensors | grep -E "Tctl|Package" | awk '{print $2}' | head -1 | tr -d '+')
                RAM=$(free -h | awk '/^Mem:/ {print $3 "/" $2}')
                RESPONSE="💻 *SYSTEM HEALTH*%0A━━━━━━━━━━━━━━━%0A🌡️ *CPU:* $TEMP%0A📊 *RAM:* $RAM"
                curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=$RESPONSE" -d "parse_mode=Markdown" > /dev/null

            # --- 📊 /top ---
            elif [[ "$MESSAGE" == "/top" ]]; then
                TOP_PROC=$(ps -eo pcpu,comm --sort=-pcpu | head -n 6 | tail -n 5 | sed 's/^[[:space:]]*//' | awk '{printf "🔥 *%.1f%%* -> _%s_\n", $1, $2}')
                RESPONSE="📊 *RESOURCE MONITOR*%0A━━━━━━━━━━━━━━━%0A$TOP_PROC"
                curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=$RESPONSE" -d "parse_mode=Markdown" > /dev/null

            # --- 🌐 /netstat ---
            elif [[ "$MESSAGE" == "/netstat" ]]; then
                CONNECTIONS=$(ss -tun | grep ESTAB | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | awk '{printf "🌐 *%s* (%s Hits)\n", $2, $1}')
                [[ -z "$CONNECTIONS" ]] && CONNECTIONS="✅ *Status:* _Secure_"
                RESPONSE="🌐 *NETWORK MONITOR*%0A━━━━━━━━━━━━━━━%0A$CONNECTIONS"
                curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=$RESPONSE" -d "parse_mode=Markdown" > /dev/null

            # --- 🛡️ /audit ---
            elif [[ "$MESSAGE" == "/audit" ]]; then
                curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=🛡️ _Audit running..._" -d "parse_mode=Markdown" > /dev/null
                SKOR_RAW=$(sudo ~/Arch-AI-Hardener/hardener.sh | grep "SCORE AKHIR" | sed 's/\x1b\[[0-9;]*m//g')
                SKOR_SISTEM=$(echo "$SKOR_RAW" | awk '{print $3}')
                RESPONSE="⚔️ *AUDIT RESULT*%0A━━━━━━━━━━━━━━━%0A📌 Score: *$SKOR_SISTEM / 100*"
                curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=$RESPONSE" -d "parse_mode=Markdown" > /dev/null

            # --- 📸 /intip ---
            elif [[ "$MESSAGE" == "/intip" ]]; then
                IMG_PATH="/tmp/ss_suditro.png"
                spectacle -b -n -o "$IMG_PATH" > /dev/null 2>&1
                sleep 2
                if [[ -f "$IMG_PATH" ]]; then
                    curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendPhoto" -F "chat_id=$ID" -F "photo=@$IMG_PATH" -F "caption=📸 Layar Laptop" > /dev/null
                    rm "$IMG_PATH"
                fi
            fi
        fi
    fi
    # Jeda 3 detik (Penting buat nurunin suhu)
    sleep 3
done
