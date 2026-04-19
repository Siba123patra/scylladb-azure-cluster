#!/usr/bin/env bash
set -euo pipefail
SCYLLA_VERSION="${SCYLLA_VERSION:-6.1}"
sudo apt-get install -y apt-transport-https gnupg curl
curl -o /tmp/scylladb.gpg \
  "https://downloads.scylladb.com/deb/debian/scylladb-${SCYLLA_VERSION}/scylladb.gpg"
sudo mv /tmp/scylladb.gpg /etc/apt/keyrings/scylladb.gpg
echo "deb [signed-by=/etc/apt/keyrings/scylladb.gpg] \
  https://downloads.scylladb.com/deb/debian/scylladb-${SCYLLA_VERSION} \
  jammy scylladb-${SCYLLA_VERSION}" | sudo tee /etc/apt/sources.list.d/scylladb.list
sudo apt-get update && sudo apt-get install -y scylla
sudo scylla_setup --no-raid-setup --nic eth0 --setup-nic-and-disks
sudo cp configs/scylla.yaml /etc/scylla/scylla.yaml
echo "Edit /etc/scylla/scylla.yaml with this node IP and seed IPs"
echo "Then: sudo systemctl enable --now scylla-server && nodetool status"
