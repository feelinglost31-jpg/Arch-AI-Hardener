#!/bin/bash

TOKEN="8742506481:AAE7RX5PCHI4gfuF0l-YBofOmyZ7hWkS0QA"
ID="7760947776"
OFFSET=-1
export LC_ALL=C.UTF-8

echo "🛡️ Suditro Commander: THE COMPLETE EDITION Aktif..."

while true; do
    UPDATES=$(curl -s "https://api.telegram.org/bot$TOKEN/getUpdates?offset=$OFFSET&timeout=10")
    MESSAGE=$(echo "$UPDATES" | jq -r '.result[-1].message.text // empty')
    CHAT_ID=$(echo "$UPDATES" | jq -r '.result[-1].message.chat.id // empty')
    UPDATE_ID=$(echo "$UPDATES" | jq -r '.result[-1].update_id // empty')

    if [[ -n "$UPDATE_ID" && "$UPDATE_ID" != "null" ]]; then
        OFFSET=$((UPDATE_ID + 1))

        if [[ "$CHAT_ID" == "$ID" ]]; then
            
            # --- 🌡️ FITUR /status (KEMBALI HADIR) ---
            if [[ "$MESSAGE" == "/status" ]]; then
                TEMP=$(sensors | grep "Tctl" | awk '{print $2}' | tr -d '+')
                RAM=$(free -h | awk '/^Mem:/ {print $3 "/" $2}')
                RESPONSE="💻 *LAPTOP STATUS*%0A━━━━━━━━━━━━━━━%0A🌡️ *CPU:* $TEMP%0A📊 *RAM:* $RAM%0A━━━━━━━━━━━━━━━"
                curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=$RESPONSE" -d "parse_mode=Markdown" > /dev/null

            # --- 📊 FITUR /top ---
            elif [[ "$MESSAGE" == "/top" ]]; then
                TOP_PROC=$(top -b -n 1 | head -n 12 | tail -n 5 | awk '{printf "🔥 *%s%%* -> _%s_\n", $9, $12}')
                RESPONSE="📊 *RESOURCE MONITOR*%0A━━━━━━━━━━━━━━━%0A$TOP_PROC%0A━━━━━━━━━━━━━━━"
                curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=$RESPONSE" -d "parse_mode=Markdown" > /dev/null

            # --- 🌐 FITUR /netstat ---
            elif [[ "$MESSAGE" == "/netstat" ]]; then
                CONNECTIONS=$(ss -tun | grep ESTAB | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | awk '{printf "🌐 *%s* (%s Hits)\n", $2, $1}')
                [[ -z "$CONNECTIONS" ]] && CONNECTIONS="✅ *Status:* _Secure_"
                RESPONSE="🌐 *NETWORK MONITOR*%0A━━━━━━━━━━━━━━━%0A$CONNECTIONS%0A━━━━━━━━━━━━━━━"
                curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=$RESPONSE" -d "parse_mode=Markdown" > /dev/null

            # --- 🛡️ FITUR /audit (FIX VALIDASI) ---
            elif [[ "$MESSAGE" == "/audit" ]]; then
                curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=🛡️ _Sabar Bang, Audit lagi jalan..._" -d "parse_mode=Markdown" > /dev/null
                # Kita ambil angka doang biar gak error gara-gara warna terminal
                SKOR_RAW=$(sudo ~/Arch-AI-Hardener/hardener.sh | grep "SCORE AKHIR" | sed 's/\x1b\[[0-9;]*m//g')
                SKOR_SISTEM=$(echo "$SKOR_RAW" | awk '{print $3}')
                RESPONSE="⚔️ *AUDIT RESULT*%0A━━━━━━━━━━━━━━━%0A📌 Score: *$SKOR_SISTEM / 100*%0A━━━━━━━━━━━━━━━"
                curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=$RESPONSE" -d "parse_mode=Markdown" > /dev/null

            # --- 📸 FITUR /intip ---
            elif [[ "$MESSAGE" == "/intip" ]]; then
                IMG_PATH="/tmp/ss_suditro.png"
                spectacle -b -n -o "$IMG_PATH" > /dev/null 2>&1
                sleep 1.5
                [[ -f "$IMG_PATH" ]] && curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendPhoto" -F "chat_id=$ID" -F "photo=@$IMG_PATH" -F "caption=📸 Layar ASUS TUF" > /dev/null && rm "$IMG_PATH"
            fi
        fi
    fi
    sleep 2
done
