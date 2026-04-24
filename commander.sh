#!/bin/bash

TOKEN="8742506481:AAE7RX5PCHI4gfuF0l-YBofOmyZ7hWkS0QA"
ID="7760947776"
OFFSET=-1
export LC_ALL=C.UTF-8

# Fungsi untuk mengirim Dashboard (Menu Tombol)
send_menu() {
    local TEXT="🛡️ *SUDITRO COMMAND CENTER V5.0*%0A━━━━━━━━━━━━━━━━━━━━━%0A💻 _ASUS TUF A15 Gaming Center_%0A📍 Lokasi: Bengkulu, Indonesia%0A━━━━━━━━━━━━━━━━━━━━━%0A*Pilih aksi di bawah ini:* "
    local KEYBOARD='{"inline_keyboard":[[{"text":"🌡️ Status","callback_data":"status"},{"text":"📊 Top Proc","callback_data":"top"}],[{"text":"🌐 Network","callback_data":"net"},{"text":"📸 Screenshot","callback_data":"intip"}],[{"text":"⚔️ Audit Sistem","callback_data":"audit"}]]}'
    
    curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
        -d "chat_id=$ID" \
        -d "text=$TEXT" \
        -d "parse_mode=Markdown" \
        -d "reply_markup=$KEYBOARD" > /dev/null
}

echo "🚀 Dashboard Edition V5.0 Aktif..."

while true; do
    UPDATES=$(curl -s --max-time 25 "https://api.telegram.org/bot$TOKEN/getUpdates?offset=$OFFSET&timeout=20")
    
    # Ambil pesan teks biasa (/start atau menu)
    MESSAGE=$(echo "$UPDATES" | jq -r '.result[-1].message.text // empty')
    
    # Ambil data dari klik tombol (callback_data)
    CALLBACK=$(echo "$UPDATES" | jq -r '.result[-1].callback_query.data // empty')
    UPDATE_ID=$(echo "$UPDATES" | jq -r '.result[-1].update_id // empty')

    if [[ -n "$UPDATE_ID" && "$UPDATE_ID" != "null" ]]; then
        OFFSET=$((UPDATE_ID + 1))
        
        # JIKA USER KETIK /start ATAU /menu
        if [[ "$MESSAGE" == "/start" || "$MESSAGE" == "/menu" ]]; then
            send_menu
        fi

        # JIKA USER KLIK TOMBOL (CALLBACK)
        if [[ -n "$CALLBACK" ]]; then
            case $CALLBACK in
                status)
                    TEMP=$(sensors | grep -E "Tctl|Package" | awk '{print $2}' | head -1 | tr -d '+')
                    RAM=$(free -h | awk '/^Mem:/ {print $3 "/" $2}')
                    RES="🌡️ *CPU:* $TEMP%0A📊 *RAM:* $RAM"
                    ;;
                top)
                    TOP_PROC=$(ps -eo pcpu,comm --sort=-pcpu | head -n 6 | tail -n 5 | sed 's/^[[:space:]]*//' | awk '{printf "🔥 *%.1f%%* -> _%s_\n", $1, $2}')
                    RES="📊 *TOP PROCESSES*%0A━━━━━━━━━━━━━%0A$TOP_PROC"
                    ;;
                net)
                    CONNECTIONS=$(ss -tun | grep ESTAB | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | awk '{printf "🌐 *%s* (%s Hits)\n", $2, $1}')
                    [[ -z "$CONNECTIONS" ]] && CONNECTIONS="✅ _Network Secure_"
                    RES="🌐 *NET MONITOR*%0A━━━━━━━━━━━━━%0A$CONNECTIONS"
                    ;;
                audit)
                    curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=🛡️ _Audit running..._" > /dev/null
                    SKOR_RAW=$(sudo ~/Arch-AI-Hardener/hardener.sh | grep "SCORE AKHIR" | sed 's/\x1b\[[0-9;]*m//g')
                    SKOR=$(echo "$SKOR_RAW" | awk '{print $3}')
                    RES="⚔️ *AUDIT SCORE*%0A📌 Result: *$SKOR / 100*"
                    ;;
                intip)
                    IMG_PATH="/tmp/ss_suditro.png"
                    spectacle -b -n -o "$IMG_PATH" > /dev/null 2>&1
                    sleep 2
                    [[ -f "$IMG_PATH" ]] && curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendPhoto" -F "chat_id=$ID" -F "photo=@$IMG_PATH" -F "caption=📸 Captured" > /dev/null && rm "$IMG_PATH"
                    RES="📸 _Screenshot sent!_"
                    ;;
            esac
            
            # Kirim balasan hasil tombolnya
            if [[ "$CALLBACK" != "intip" ]]; then
                curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=$RES" -d "parse_mode=Markdown" > /dev/null
            fi
            # Munculkan menu lagi biar gak usah ngetik ulang
            send_menu
        fi
    fi
    sleep 2
done
