## ⚡ Quick Start

* Clone repo
```bash
git clone https://github.com/Pay2earn/aztec-prover.git
cd aztec-prover
```
* Make the Script Executable
```bash
chmod +x aztec.sh
```
* Open a screen to run it in background
```bash
screen -S aztec
```
* Run with sudo
```bash
sudo ./aztec.sh
```

## ▶️ Start the Node
```bash
docker compose up -d
```
## ⏹ Stop the Node
```bash
docker compose down
```

## 🔄 Reset Node Completely

To stop and remove your Aztec node along with all related data:

```bash
docker compose down -v --remove-orphans && \
sudo rm -rf /root/aztec-prover/node && \
sudo rm -f /root/aztec-prover/.env
```
This will completely wipe your node’s state and storage, allowing you to start fresh.

## 📊 Checking Node Status
```bash
cd /root/aztec-prover
```
```bash
docker ps -a
```
```bash
docker compose logs -f
```
Specific Service Logs
```bash
docker compose logs -f agent
```
```bash
docker compose logs -f broker
```
```bash
docker compose logs -f prover-node
```

## ⚙️ Modify Configuration
To change node config or service arguments:
```bash
nano docker-compose.yaml
```
To edit your .env file:
```bash
nano /root/aztec-prover/.env
```

## 🧠 Tips
To detach from screen session: Ctrl+A then D

To reconnect to the screen: screen -r aztec

You can run multiple agents by increasing PROVER_AGENT_COUNT in docker-compose.yaml

