#!/bin/bash

TOKEN="8742506481:AAE7RX5PCHI4gfuF0l-YBofOmyZ7hWkS0QA"
ID="7760947776"
OFFSET=-1

echo "🛡️ Suditro Commander Aktif. Menunggu perintah..."

while true; do
    UPDATES=$(curl -s "https://api.telegram.org/bot$TOKEN/getUpdates?offset=$OFFSET&timeout=10")
    MESSAGE=$(echo "$UPDATES" | jq -r '.result[-1].message.text // empty')
    CHAT_ID=$(echo "$UPDATES" | jq -r '.result[-1].message.chat.id // empty')
    UPDATE_ID=$(echo "$UPDATES" | jq -r '.result[-1].update_id // empty')

    if [[ -n "$UPDATE_ID" && "$UPDATE_ID" != "null" ]]; then
        OFFSET=$((UPDATE_ID + 1))

        if [[ "$CHAT_ID" == "$ID" ]]; then
            
            # --- PERINTAH /status ---
            if [[ "$MESSAGE" == "/status" ]]; then
                # AMBIL SUHU Tctl (Ryzen) yang paling akurat
                TEMP=$(sensors | grep "Tctl" | awk '{print $2}' | tr -d '+')
                RAM=$(free -h | awk '/^Mem:/ {print $3 "/" $2}')
                UPTIME=$(uptime -p | sed 's/up //')
                IP_LOCAL=$(ip route get 1.1.1.1 | grep -oP 'src \K\S+' || echo "No IP")
                FAN=$(sensors | grep "cpu_fan" | awk '{print $2 " " $3}')
                
                RESPONSE="💻 *LAPTOP STATUS* %0A🌡️ CPU: $TEMP%0A📊 RAM: $RAM%0A🌀 Fan: $FAN%0A⏱️ Uptime: $UPTIME%0A🌐 IP: $IP_LOCAL"
                curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=$RESPONSE" -d "parse_mode=Markdown" > /dev/null

            # --- PERINTAH /audit ---
            elif [[ "$MESSAGE" == "/audit" ]]; then
                curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=🛡️ _Sabar Bang, Audit lagi jalan..._" -d "parse_mode=Markdown" > /dev/null
                
                # JALANKAN DENGAN SUDO (Pastikan langkah visudo di bawah sudah dilakukan)
                SKOR_SISTEM=$(sudo ~/Arch-AI-Hardener/hardener.sh | grep "SCORE AKHIR" | awk '{print $3}')
                
                RESPONSE="⚔️ *AUDIT SINKRON* ⚔️%0A📌 Score: *$SKOR_SISTEM / 100*%0A✅ Status: Verified"
                curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=$RESPONSE" -d "parse_mode=Markdown" > /dev/null
            fi
        fi
    fi
    sleep 2
done
