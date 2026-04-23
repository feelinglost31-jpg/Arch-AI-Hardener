#!/bin/bash

TOKEN="8742506481:AAE7RX5PCHI4gfuF0l-YBofOmyZ7hWkS0QA"
ID="7760947776"
OFFSET=-1
export LC_ALL=C.UTF-8

echo "🛡️ Suditro Commander V3.2 (Aesthetic Edition) Aktif..."

while true; do
    UPDATES=$(curl -s "https://api.telegram.org/bot$TOKEN/getUpdates?offset=$OFFSET&timeout=10")
    MESSAGE=$(echo "$UPDATES" | jq -r '.result[-1].message.text // empty')
    CHAT_ID=$(echo "$UPDATES" | jq -r '.result[-1].message.chat.id // empty')
    UPDATE_ID=$(echo "$UPDATES" | jq -r '.result[-1].update_id // empty')

    if [[ -n "$UPDATE_ID" && "$UPDATE_ID" != "null" ]]; then
        OFFSET=$((UPDATE_ID + 1))

        if [[ "$CHAT_ID" == "$ID" ]]; then
            
            # --- 📊 FITUR /top (RESOURCE MONITOR) ---
            if [[ "$MESSAGE" == "/top" ]]; then
                TOP_PROC=$(top -b -n 1 | head -n 12 | tail -n 5 | awk '{printf "🔥 *%s%%* -> _%s_\n", $9, $12}')
                RESPONSE="📊 *RESOURCE MONITOR*%0A━━━━━━━━━━━━━━━%0A$TOP_PROC%0A━━━━━━━━━━━━━━━%0A⚡ _ASUS TUF Performance_"
                curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=$RESPONSE" -d "parse_mode=Markdown" > /dev/null

            # --- 🌐 FITUR /netstat (NETWORK SCANNER) ---
            elif [[ "$MESSAGE" == "/netstat" ]]; then
                CONNECTIONS=$(ss -tun | grep ESTAB | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | awk '{printf "🌐 *%s* (%s Hits)\n", $2, $1}')
                if [[ -z "$CONNECTIONS" ]]; then
                    RESPONSE="🌐 *NETWORK SHIELD*%0A━━━━━━━━━━━━━━━%0A✅ *Status:* _Secure / No Outside Link_%0A━━━━━━━━━━━━━━━"
                else
                    RESPONSE="🌐 *INTRUSION DETECTOR*%0A━━━━━━━━━━━━━━━%0A$CONNECTIONS%0A━━━━━━━━━━━━━━━%0A⚠️ _Monitoring Active..._"
                fi
                curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=$RESPONSE" -d "parse_mode=Markdown" > /dev/null

            # --- 📸 FITUR /intip ---
            elif [[ "$MESSAGE" == "/intip" ]]; then
                IMG_PATH="/tmp/ss_suditro.png"
                spectacle -b -n -o "$IMG_PATH" > /dev/null 2>&1
                sleep 1.5
                if [ -f "$IMG_PATH" ]; then
                    curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendPhoto" -F "chat_id=$ID" -F "photo=@$IMG_PATH" -F "caption=📸 Layar saat ini." > /dev/null
                    rm "$IMG_PATH"
                fi

            # --- 🛡️ FITUR /audit ---
            elif [[ "$MESSAGE" == "/audit" ]]; then
                SKOR_SISTEM=$(sudo ~/Arch-AI-Hardener/hardener.sh | grep "SCORE AKHIR" | awk '{print $3}')
                RESPONSE="⚔️ *AUDIT SINKRON*%0A📌 Score: *$SKOR_SISTEM / 100*"
                curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=$RESPONSE" -d "parse_mode=Markdown" > /dev/null
            fi
        fi
    fi
    sleep 2
done
