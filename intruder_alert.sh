#!/bin/bash

TOKEN="8742506481:AAE7RX5PCHI4gfuF0l-YBofOmyZ7hWkS0QA"
ID="7760947776"

# Monitor failed sudo attempts
journalctl -f -t sudo | while read line; do
    if echo "$line" | grep -q "authentication failure"; then
        MESSAGE="⚠️ PERINGATAN KRITIS, BANG! %0A📌 Ada yang coba masukin password SUDO tapi SALAH. %0A🕒 Waktu: $(date '+%Y-%m-%d %H:%M:%S') %0A👀 Cek laptop sekarang!"
        curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d "chat_id=$ID" -d "text=$MESSAGE" > /dev/null
    fi
done
