```bash
https://github.com/Pay2earn/aztec-prover.git
cd /root/aztec-prover
```

```bash
chmod +x setup-aztec.sh
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
docker ps -a
```

```bash
docker compose down -v --remove-orphans && sudo rm -rf /root/aztec-prover/node{1,2,3,4} && sudo rm -f /root/aztec-prover/.env
```
