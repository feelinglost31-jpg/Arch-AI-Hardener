#!/bin/bash

TOKEN="8742506481:AAE7RX5PCHI4gfuF0l-YBofOmyZ7hWkS0QA"
ID="7760947776"
OFFSET=-1

echo "COMMANDER AKTIF. Menunggu perintah /status..."

while true; do
    UPDATES=$(curl -s "https://api.telegram.org/bot$TOKEN/getUpdates?offset=$OFFSET&timeout=10")
    
    MESSAGE=$(echo "$UPDATES" | jq -r '.result[-1].message.text // empty')
    CHAT_ID=$(echo "$UPDATES" | jq -r '.result[-1].message.chat.id // empty')
    UPDATE_ID=$(echo "$UPDATES" | jq -r '.result[-1].update_id // empty')

    if [[ -n "$UPDATE_ID" && "$UPDATE_ID" != "null" ]]; then
        OFFSET=$((UPDATE_ID + 1))

        if [[ "$CHAT_ID" == "$ID" && "$MESSAGE" == "/status" ]]; then
            TEMP=$(sensors | grep -E 'Tctl|Package id 0|temp1' | head -n 1 | awk '{print $2}' | tr -d '+')
            RAM=$(free -h | awk '/^Mem:/ {print $3 "/" $2}')
            UPTIME=$(uptime -p | sed 's/up //')
            IP_LOCAL=$(ip route get 1.1.1.1 | grep -oP 'src \K\S+' || echo "No IP")

            RESPONSE="⚔️ *SUDITRO GUARD REPORT* ⚔️%0A%0A🌡️ *CPU Temp:* $TEMP%0A📊 *RAM Usage:* $RAM%0A⏱️ *Uptime:* $UPTIME%0A🌐 *IP Local:* $IP_LOCAL%0A%0A🛡️ _Status: Secure_"
            
            curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=$RESPONSE" -d "parse_mode=Markdown" > /dev/null
        fi
    fi
    sleep 2
done
