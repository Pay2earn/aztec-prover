```bash
git clone https://github.com/Pay2earn/aztec-prover.git
cd /root/aztec-prover
```

```bash
chmod +x setup-aztec.sh
chmod +x setup-zram.sh
chmod +x prove
```

```bash
screen -S aztec
```

```bash
nano docker-compose.yaml
```

```bash
sudo ./setup-aztec.sh
```

```bash
docker compose up -d
```

```bash
docker compose logs -f
```

```bash
rm -rf docker-compose.yaml
```

```bash
docker ps -a
```

```bash
docker compose down -v --remove-orphans && sudo rm -rf /root/aztec-prover/node{1,2,3,4,5,6,7,8} && sudo rm -f /root/aztec-prover/.env
```
