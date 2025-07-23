#!/bin/bash
set -e

echo "📦 Installing zram-tools..."
sudo apt update
sudo apt install -y zram-tools

echo "⚙️ Configuring zram..."
sudo tee /etc/default/zramswap > /dev/null <<EOF
ALGO=zstd
PERCENT=50
PRIORITY=32767
EOF

echo "🔄 Restarting zramswap..."
sudo systemctl restart zramswap
sudo systemctl enable zramswap

# ❌ Remove swapfile completely
if grep -q '/swapfile' /etc/fstab; then
    echo "🧹 Removing existing swapfile..."
    sudo swapoff /swapfile || true
    sudo rm -f /swapfile
    sudo sed -i '/\/swapfile/d' /etc/fstab
fi

# 🧠 Lower swappiness to avoid unnecessary swap
grep -q 'vm.swappiness' /etc/sysctl.conf || echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
sudo sysctl -w vm.swappiness=10

# 📊 Show current memory and swap usage
echo ""
echo "✅ zram-only setup complete."
echo "Current swap devices:"
swapon --show
echo ""
echo "Memory overview:"
free -h
