#!/bin/bash

# --- Arch-AI-Hardener v1.2: Colorful & Automatic ---
# Author: Suditro Pratama

# Definisi Warna
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

score=0
fix_needed=false
log_file="/home/ditr/Arch-AI-Hardener/audit.log"
timestamp=$(date "+%Y-%m-%d %H:%M:%S")

echo -e "${BLUE}--- [ Arch-AI-Hardener: Smart Audit ] ---${NC}"

# 1. Cek Firewall
if sudo ufw status | grep -q "active"; then
    echo -e "[${GREEN}✔${NC}] Firewall Aktif (+40 pts)"
    ((score+=40))
else
    echo -e "[${RED}✘${NC}] Firewall MATI!"
    fix_needed=true
fi

# 2. Cek SSH Port
if sudo ufw status | grep -q "22"; then
    echo -e "[${YELLOW}!${NC}] Port SSH Masih Terbuka! (-20 pts)"
    fix_needed=true
else
    echo -e "[${GREEN}✔${NC}] Port SSH Tertutup (+30 pts)"
    ((score+=30))
fi

# 3. Cek Permission /etc/shadow
if [[ $(stat -c "%a" /etc/shadow) == "600" ]]; then
    echo -e "[${GREEN}✔${NC}] File Shadow Terkunci Aman (+30 pts)"
    ((score+=30))
else
    echo -e "[${RED}✘${NC}] File Shadow Terlalu Terbuka!"
    fix_needed=true
fi

echo -e "${BLUE}---------------------------------------${NC}"
echo -e "SECURITY SCORE ANDA: ${YELLOW}$score / 100${NC}"
echo -e "${BLUE}---------------------------------------${NC}"

# Logging
echo "[$timestamp] Audit Score: $score/100" >> $log_file

# Auto-Fix
if [ "$fix_needed" = true ]; then
    # Jika dijalankan otomatis (non-interaktif), kita gak bisa read -p
    # Tapi untuk sekarang, kita tetap biarkan manual jika dijalankan di terminal
    if [ -t 0 ]; then
        read -p "Sistem belum optimal. Jalankan Auto-Fix? (y/n): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            sudo ufw --force enable > /dev/null
            sudo ufw delete allow 22 > /dev/null
            sudo chmod 600 /etc/shadow
            echo "[$timestamp] AUTO-FIX EXECUTED" >> $log_file
            echo -e "${GREEN}[✔] Perbaikan selesai!${NC}"
        fi
    fi
else
    echo -e "${GREEN}Status: AMAN (Sesuai Standar Suditro)${NC}"
fi
