#!/bin/bash

echo "--- [ Arch-AI-Hardener: Smart Audit ] ---"
score=0

# 1. Cek Firewall
if sudo ufw status | grep -q "active"; then
    echo "[✔] Firewall Aktif (+40 pts)"
    ((score+=40))
else
    echo "[✘] Firewall MATI! Bahaya."
fi

# 2. Cek SSH Port
if sudo ufw status | grep -q "22"; then
    echo "[!] Port SSH Masih Terbuka! (-20 pts)"
else
    echo "[✔] Port SSH Tertutup/Stealth Mode (+30 pts)"
    ((score+=30))
fi

# 3. Cek Permission /etc/shadow
if [[ $(stat -c "%a" /etc/shadow) == "600" ]]; then
    echo "[✔] File Shadow Terkunci Aman (+30 pts)"
    ((score+=30))
else
    echo "[✘] File Shadow Terlalu Terbuka!"
fi

echo "---------------------------------------"
echo "SECURITY SCORE ANDA: $score / 100"
echo "---------------------------------------"

if [ $score -eq 100 ]; then
    echo "Status: AMAN (Sesuai Standar Suditro)"
else
    echo "Status: PERLU PERBAIKAN"
fi
