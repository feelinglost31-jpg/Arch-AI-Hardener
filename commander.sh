#!/bin/bash

TOKEN="8742506481:AAE7RX5PCHI4gfuF0l-YBofOmyZ7hWkS0QA"
ID="7760947776"
OFFSET=-1

# Pastikan bot pakai standar UTF-8 supaya tidak error locale
export LC_ALL=C.UTF-8

echo "🛡️ Suditro Commander VISION V2 Aktif. Menunggu perintah..."

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
                TEMP=$(sensors | grep "Tctl" | awk '{print $2}' | tr -d '+')
                RAM=$(free -h | awk '/^Mem:/ {print $3 "/" $2}')
                RESPONSE="💻 *LAPTOP STATUS*%0A🌡️ CPU: $TEMP%0A📊 RAM: $RAM"
                curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=$RESPONSE" -d "parse_mode=Markdown" > /dev/null

            # --- PERINTAH /audit ---
            elif [[ "$MESSAGE" == "/audit" ]]; then
                curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=🛡️ _Sabar Bang, Audit lagi jalan..._" -d "parse_mode=Markdown" > /dev/null
                SKOR_SISTEM=$(sudo ~/Arch-AI-Hardener/hardener.sh | grep "SCORE AKHIR" | awk '{print $3}')
                RESPONSE="⚔️ *AUDIT SINKRON* ⚔️%0A📌 Score: *$SKOR_SISTEM / 100*"
                curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=$RESPONSE" -d "parse_mode=Markdown" > /dev/null

            # --- PERINTAH /intip (VERSI FIXED KDE) ---
            elif [[ "$MESSAGE" == "/intip" ]]; then
                IMG_PATH="/tmp/ss_suditro.png"
                
                # Ambil screenshot secara silent
                spectacle -b -n -o "$IMG_PATH" > /dev/null 2>&1
                
                # Tunggu sebentar biar file selesai ditulis
                sleep 1.5
                
                if [ -f "$IMG_PATH" ]; then
                    curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendPhoto" \
                         -F "chat_id=$ID" \
                         -F "photo=@$IMG_PATH" \
                         -F "caption=📸 Kondisi layar ASUS TUF Abang" > /dev/null
                    rm "$IMG_PATH"
                else
                    curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=❌ Gagal ambil gambar, Bang!" > /dev/null
                fi
            fi
        fi
    fi
    sleep 2
done
