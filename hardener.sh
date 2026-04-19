#!/bin/bash
# --- Arch-AI-Hardener v1.5: Intruder Alert ---
# Author: Suditro Pratama

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' 

score=0
fix_needed=false
log_file="/home/ditr/Arch-AI-Hardener/audit.log"
timestamp=$(date "+%Y-%m-%d %H:%M:%S")

echo -e "${BLUE}--- [ Arch-AI-Hardener: Smart Audit ] ---${NC}"

# --- MODUL 1: INTRUDER ALERT (NEW!) ---
echo -e "${BLUE}--- [ Intruder Discovery ] ---${NC}"
# Cek percobaan login gagal dalam 24 jam terakhir
failed_attempts=$(journalctl --since "24h ago" | grep -i "failed password" | wc -l)

if [ "$failed_attempts" -gt 0 ]; then
    echo -e "[${RED}⚠${NC}] WASPADA: Ada ${RED}$failed_attempts${NC} percobaan login gagal dlm 24 jam!"
    # Ambil 3 IP terakhir yang mencoba menyerang
    journalctl --since "24h ago" | grep -i "failed password" | awk '{print $NF}' | tail -n 3 > /tmp/intruders.txt
    echo -e "[${RED}!${NC}] IP Terakhir: $(cat /tmp/intruders.txt | tr '\n' ' ')"
else
    echo -e "[${GREEN}✔${NC}] Tidak ada aktivitas mencurigakan."
fi

# --- MODUL 2: SYSTEM AUDIT ---
echo -e "${BLUE}--- [ System Security ] ---${NC}"
if sudo ufw status | grep -q "active"; then
    echo -e "[${GREEN}✔${NC}] Firewall Aktif (+40 pts)"; ((score+=40))
else
    echo -e "[${RED}✘${NC}] Firewall MATI!"; fix_needed=true
fi

if sudo ufw status | grep -q "22"; then
    echo -e "[${YELLOW}!${NC}] Port SSH Terbuka! (-20 pts)"; fix_needed=true
else
    echo -e "[${GREEN}✔${NC}] Port SSH Tertutup (+30 pts)"; ((score+=30))
fi

if [[ $(stat -c "%a" /etc/shadow) == "600" ]]; then
    echo -e "[${GREEN}✔${NC}] File Shadow Terkunci (+30 pts)"; ((score+=30))
else
    echo -e "[${RED}✘${NC}] Shadow File Terbuka!"; fix_needed=true
fi

# --- MODUL 3: NETWORK ---
echo -e "${BLUE}--- [ Network Discovery ] ---${NC}"
interface=$(nmcli -t -f DEVICE,STATE device | grep ":connected" | cut -d: -f1 | head -n1)
if [ -z "$interface" ]; then
    ip_addr="127.0.0.1"
else
    ip_addr=$(ip addr show $interface | grep "inet " | awk '{print $2}' | cut -d/ -f1)
    echo -e "[${GREEN}✔${NC}] Local IP: $ip_addr"
fi

# --- MODUL 4: LOGGING & SYNC ---
echo "[$timestamp] Score: $score/100 | Failed Logs: $failed_attempts | IP: $ip_addr" >> $log_file

echo -e "${BLUE}--- [ Cloud Syncing ] ---${NC}"
cd ~/Arch-AI-Hardener
if [[ -n $(git status -s) ]]; then
    git add .
    git commit -m "security-update: score $score, failed: $failed_attempts at $timestamp"
    git push origin main > /dev/null 2>&1
    echo -e "[${GREEN}✔${NC}] Cloud Synced!"
fi
echo -e "SCORE AKHIR: ${YELLOW}$score / 100${NC}"
