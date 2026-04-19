#!/usr/bin/env bash
set -euo pipefail
SCYLLA_VERSION="${SCYLLA_VERSION:-6.1}"
sudo apt-get update && sudo apt-get install -y docker.io docker-compose git
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
git clone https://github.com/scylladb/scylla-monitoring.git
cd scylla-monitoring
cp ../configs/scylla_servers.yml prometheus/scylla_servers.yml
./start-all.sh -s "$SCYLLA_VERSION"
MONITOR_IP=$(hostname -I | awk '{print $1}')
echo "Grafana    : http://$MONITOR_IP:3000  (admin/admin - change immediately!)"
echo "Prometheus : http://$MONITOR_IP:9090"
