#!/bin/bash
set -e

echo_green() {
    GREEN_TEXT="\033[32m"
    RESET_TEXT="\033[0m"
    echo -e "${GREEN_TEXT}$1${RESET_TEXT}"
}

# === ตั้งค่าคงที่ ===
AZTEC_VERSION="0.85.0-alpha-testnet.11"
ENV_FILE="/root/aztec-prover/.env"

# === อัปเดตระบบ และติดตั้งทุกอย่างก่อน ===
echo_green ">> [1/5] Updating system..."
sudo apt-get update && sudo apt-get upgrade -y

echo_green ">> [2/5] Installing dependencies..."
sudo apt install -y curl iptables build-essential git wget lz4 jq make gcc nano \
    automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev \
    libleveldb-dev tar clang bsdmainutils ncdu unzip python3 python3-pip \
    python3-venv python3-dev docker-compose

echo_green ">> [3/5] Installing Docker..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo_green ">> [4/5] Installing Aztec CLI..."
yes | bash <(curl -sL https://install.aztec.network)
export PATH=$PATH:/root/.aztec/bin
echo 'export PATH=$PATH:/root/.aztec/bin' >> ~/.bashrc
source ~/.bashrc

# === เตรียม Directory และ Screen ===
mkdir -p /root/aztec-prover/node
chmod 777 -R /root/aztec-prover
cd /root/aztec-prover

# === ดึง Docker image ล่วงหน้า ===
echo_green ">> [5/5] Pulling latest Aztec Docker image v$AZTEC_VERSION..."
docker pull aztecprotocol/aztec:$AZTEC_VERSION

# === เริ่ม aztec testnet (ถ้า CLI ใช้ start ได้อัตโนมัติ) ===
aztec-up alpha-testnet

# === สร้างหรือโหลด .env ===
echo_green ">> Setting up environment..."

if [ ! -f "$ENV_FILE" ]; then
    echo_green ">> Creating .env..."

    read -p "🟢 Sepolia RPC (https://...): " SEPOLIA_RPC
    read -p "🟢 Beacon RPC (https://...): " BEACON_RPC
    read -p "🟢 Private Key (0x...): " PRIVATE_KEY
    read -p "🟢 Wallet Address (0x...): " WALLET_ADDRESS

    cat <<EOF > $ENV_FILE
SEPOLIA_RPC=$SEPOLIA_RPC
BEACON_RPC=$BEACON_RPC
PRIVATE_KEY=$PRIVATE_KEY
WALLET_ADDRESS=$WALLET_ADDRESS
AZTEC_VERSION=$AZTEC_VERSION
EOF
fi

# โหลดค่า .env
set -o allexport
source "$ENV_FILE"
set +o allexport

# === สร้าง docker-compose.yaml ===
echo_green ">> Creating docker-compose.yaml..."

cat <<EOF > docker-compose.yaml
services:
  prover-node:
    image: aztecprotocol/aztec:\${AZTEC_VERSION}
    command:
      - node
      - --no-warnings
      - /usr/src/yarn-project/aztec/dest/bin/index.js
      - start 
      - --prover-node
      - --archiver
      - --network
      - alpha-testnet
    depends_on:
      broker:
        condition: service_started
    environment:
      P2P_FILTER_PEERS_BY_SCORE: "true"
      P2P_SCORE_THRESHOLD: "10"
      P2P_MIN_SCORE_TO_CONNECT: "15"
      P2P_PEER_SCORE_MIN_THRESHOLD: "20"
      P2P_PEER_SCORE_DROP_BELOW: "5"
      P2P_MAX_PEERS: "100"
      P2P_QUERY_FOR_IP: "true"
      DATA_DIRECTORY: /data
      DATA_STORE_MAP_SIZE_KB: "134217728"
      ETHEREUM_HOSTS: "\${SEPOLIA_RPC}"
      L1_CONSENSUS_HOST_URLS: "\${BEACON_RPC}"
      LOG_LEVEL: info
      PROVER_BROKER_HOST: http://broker:8080
      PROVER_PUBLISHER_PRIVATE_KEY: "\${PRIVATE_KEY}"
    ports:
      - "8080:8080"
      - "40400:40400"
      - "40400:40400/udp"
    volumes:
      - /root/aztec-prover/node:/data
    env_file:
      - .env

  agent:
    image: aztecprotocol/aztec:\${AZTEC_VERSION}
    command:
      - node
      - --no-warnings
      - /usr/src/yarn-project/aztec/dest/bin/index.js
      - start
      - --prover-agent
      - --network
      - alpha-testnet
    environment:
      PROVER_AGENT_COUNT: "20"
      PROVER_AGENT_POLL_INTERVAL_MS: "7000"
      PROVER_BROKER_HOST: http://broker:8080
      PROVER_ID: "\${WALLET_ADDRESS}"
    env_file:
      - .env
    pull_policy: always
    restart: unless-stopped

  broker:
    image: aztecprotocol/aztec:\${AZTEC_VERSION}
    command:
      - node
      - --no-warnings
      - /usr/src/yarn-project/aztec/dest/bin/index.js
      - start
      - --prover-broker
      - --network
      - alpha-testnet
    environment:
      DATA_DIRECTORY: /data
      ETHEREUM_HOSTS: "\${SEPOLIA_RPC}"
      LOG_LEVEL: info
    volumes:
      - /root/aztec-prover/node:/data
    env_file:
      - .env
EOF

# === เริ่มระบบใน screen ===
echo_green "✅ Done. 🚀 Starting Aztec Prover Node..."
docker-compose up -d

echo -e "\n✅ ${BOLD}Installation and startup completed!${RESET}"
echo "   - Check logs: docker-compose logs -f"
