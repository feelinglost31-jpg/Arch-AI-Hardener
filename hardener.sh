#!/bin/bash

# --- Arch-AI-Hardener: Smart Audit, Auto-Fix & Logger ---
# Author: Suditro Pratama
# Path: ~/Arch-AI-Hardener/audit.log

score=0
fix_needed=false
log_file="audit.log"
timestamp=$(date "+%Y-%m-%d %H:%M:%S")

echo "--- [ Arch-AI-Hardener: Smart Audit ] ---"

# 1. Cek Firewall
if sudo ufw status | grep -q "active"; then
    echo "[✔] Firewall Aktif (+40 pts)"
    ((score+=40))
else
    echo "[✘] Firewall MATI!"
    fix_needed=true
fi

# 2. Cek SSH Port
if sudo ufw status | grep -q "22"; then
    echo "[!] Port SSH Masih Terbuka! (-20 pts)"
    fix_needed=true
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
    fix_needed=true
fi

echo "---------------------------------------"
echo "SECURITY SCORE ANDA: $score / 100"
echo "---------------------------------------"

# --- LOGGING SYSTEM (The Chronicler) ---
echo "[$timestamp] Audit Score: $score/100" >> $log_file

# --- LOGIKA AUTO-FIX ---
if [ "$fix_needed" = true ]; then
    read -p "Sistem belum optimal. Jalankan Auto-Fix sekarang? (y/n): " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        echo "[+] Menjalankan Auto-Fix..."
        sudo ufw --force enable > /dev/null
        sudo ufw delete allow 22 > /dev/null
        sudo chmod 600 /etc/shadow
        echo "[$timestamp] AUTO-FIX EXECUTED" >> $log_file
        echo "[✔] Perbaikan selesai! Jalankan audit lagi."
    else
        echo "[$timestamp] AUTO-FIX REJECTED BY USER" >> $log_file
        echo "[!] Perbaikan dibatalkan."
    fi
else
    echo "Status: AMAN (Sesuai Standar Suditro)"
fi
