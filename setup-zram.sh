#!/bin/bash
set -e

# ติดตั้ง zram-tools
echo "📦 Installing zram-tools..."
sudo apt update
sudo apt install -y zram-tools

# ตั้งค่า zram: ใช้ 50% ของ RAM (≈ 258GB)
echo "⚙️ Configuring zram..."
sudo tee /etc/default/zramswap > /dev/null <<EOF
ALGO=zstd
PERCENT=50
PRIORITY=32767
EOF

# รีสตาร์ท zram
sudo systemctl restart zramswap
sudo systemctl enable zramswap

# สร้าง fallback swapfile: 128GB (ลดภาระ SSD)
echo "💾 Creating fallback swapfile (128GB)..."
sudo swapoff /swapfile 2>/dev/null || true
sudo rm -f /swapfile
sudo dd if=/dev/zero of=/swapfile bs=1M count=131072 status=progress
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon --priority 100 /swapfile

# เพิ่ม swapfile ใน fstab หากยังไม่มี
grep -q '/swapfile' /etc/fstab || echo '/swapfile none swap sw,pri=100 0 0' | sudo tee -a /etc/fstab

# ตั้ง vm.swappiness ให้ใช้ swap เฉพาะเมื่อจำเป็น
grep -q 'vm.swappiness' /etc/sysctl.conf || echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# แสดงผลลัพธ์
echo ""
echo "✅ Swap setup complete. Current swap devices:"
swapon --show
echo ""
echo "📊 RAM + Swap overview:"
free -h
