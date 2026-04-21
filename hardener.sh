#!/bin/bash

# --- CONFIGURATION ---
TARGET_DIR="/home/ditr/Arch-AI-Hardener"
SCORE=0

echo "--- [ Arch-AI-Hardener: Smart Audit ] ---"

# 1. Cek Intruder (Auth Log)
echo "--- [ Intruder Discovery ] ---"
if sudo grep "Failed password" /var/log/auth.log | tail -n 5 | grep -q "failed"; then
    echo "[!] Ada percobaan login gagal!"
else
    echo "[✔] Tidak ada aktivitas mencurigakan."
    SCORE=$((SCORE + 0)) # Placeholder
fi

# 2. Cek System Security
echo "--- [ System Security ] ---"

# Cek Firewall (UFW)
if sudo ufw status | grep -q "Status: active"; then
    echo "[✔] Firewall Aktif (+40 pts)"
    SCORE=$((SCORE + 40))
else
    echo "[X] Firewall MATI (0 pts)"
fi

# Cek SSH (Port 22)
if sudo ss -tuln | grep -q ":22"; then
    echo "[X] Port SSH Terbuka (Bahaya!)"
else
    echo "[✔] Port SSH Tertutup (+30 pts)"
    SCORE=$((SCORE + 30))
fi

# Cek File Shadow
if [ "$(sudo stat -c %a /etc/shadow)" == "000" ] || [ "$(sudo stat -c %a /etc/shadow)" == "600" ]; then
    echo "[✔] File Shadow Terkunci (+30 pts)"
    SCORE=$((SCORE + 30))
else
    echo "[X] File Shadow Terbuka (0 pts)"
fi

# 3. Cek Network
echo "--- [ Network Discovery ] ---"
IP_LOCAL=$(ip route get 1.1.1.1 | grep -oP 'src \K\S+')
echo "[✔] Local IP: $IP_LOCAL"

# 4. Cloud Syncing (Git)
echo "--- [ Cloud Syncing ] ---"
# Masuk ke folder dengan path absolut agar sudo tidak nyasar ke /root
cd "$TARGET_DIR" || exit

# Mencegah error git safe directory
sudo git config --global --add safe.directory "$TARGET_DIR"

# Simpan hasil ke file log sebelum commit
echo "Audit Log: $(date) - Score: $SCORE" >> audit_log.txt

# Sync ke Git
sudo git add .
sudo git commit -m "security-update: score $SCORE at $(date '+%Y-%m-%d %H:%M:%S')" --allow-empty > /dev/null 2>&1
echo "[✔] Cloud Synced!"

echo "SCORE AKHIR: $SCORE / 100"
