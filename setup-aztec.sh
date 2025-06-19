#!/bin/bash

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

echo "[1/8] Updating system packages..."
sudo apt-get update -y && sudo apt-get upgrade -y

echo "[2/8] Installing essential tools..."
sudo apt-get install -y \
  curl iptables build-essential git wget lz4 jq make gcc nano \
  automake autoconf tmux htop nvme-cli libgbm1 pkg-config \
  libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip \
  docker-compose libleveldb-dev acl

echo "[3/8] Installing Docker..."
sudo apt-get install -y \
  docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin

echo "[4/8] Installing Aztec CLI (non-interactive)..."
curl -sL https://install.aztec.network | bash

echo "[5/8] Adding Aztec to PATH (if not already)..."
# ใช้ grep แบบปลอดภัย ไม่ใช้ range
if ! grep -Fq '/root/.aztec/bin' ~/.bashrc; then
  echo 'export PATH=$PATH:/root/.aztec/bin' >> ~/.bashrc
fi

# ป้องกัน shell non-interactive ใน .bashrc
if ! grep -Fq 'if [[ $- != *i* ]]' ~/.bashrc; then
  sed -i '1i\
if [[ $- != *i* ]]; then\n  return\nfi\n' ~/.bashrc
fi

# โหลด PATH ใน shell ปัจจุบันโดยตรง
export PATH="$PATH:/root/.aztec/bin"

echo "[6/8] Bootstrapping Aztec alpha-testnet..."
aztec-up alpha-testnet || true

echo "[7/8] Creating prover node folders..."
for i in {1..4}; do
  mkdir -p /root/aztec-prover/node$i
done

echo "[8/8] Setting folder permissions..."
chmod -R 777 /root/aztec-prover
setfacl -R -m u::rwx,g::rwx,o::rwx /root/aztec-prover
find /root/aztec-prover -type d -exec setfacl -d -m u::rwx,g::rwx,o::rwx {} \;

echo "✅ Aztec setup complete and prover folders ready!"
