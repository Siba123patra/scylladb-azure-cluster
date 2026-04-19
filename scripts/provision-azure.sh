#!/usr/bin/env bash
set -euo pipefail
RG="${RG:-scylla-rg}"
LOCATION="${LOCATION:-eastus}"
VM_SIZE="${VM_SIZE:-Standard_L8s_v3}"
NODE_COUNT="${NODE_COUNT:-3}"
echo "=== ScyllaDB Azure Cluster - Infrastructure Setup ==="
az group create --name "$RG" --location "$LOCATION"
az network vnet create --resource-group "$RG" --name scylla-vnet \
  --address-prefix 10.0.0.0/16 --subnet-name scylla-subnet --subnet-prefix 10.0.1.0/24
az network nsg create --resource-group "$RG" --name scylla-nsg
for PORT in 7000 7001 9042 9142 9160 9180 10000; do
  az network nsg rule create --resource-group "$RG" --nsg-name scylla-nsg \
    --name "allow-$PORT" --priority $((200+PORT)) --protocol Tcp \
    --destination-port-ranges "$PORT" --source-address-prefixes 10.0.1.0/24 \
    --access Allow --output none
  echo "  Opened port $PORT"
done
az network nsg rule create --resource-group "$RG" --nsg-name scylla-nsg \
  --name allow-ssh --priority 100 --protocol Tcp \
  --destination-port-ranges 22 --access Allow --output none
az network vnet subnet update --resource-group "$RG" --vnet-name scylla-vnet \
  --name scylla-subnet --network-security-group scylla-nsg --output none
for i in $(seq 1 "$NODE_COUNT"); do
  echo "Creating scylla-node-$i..."
  az vm create --resource-group "$RG" --name "scylla-node-$i" \
    --image "Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest" \
    --size "$VM_SIZE" --vnet-name scylla-vnet --subnet scylla-subnet \
    --nsg scylla-nsg --admin-username azureuser \
    --ssh-key-values ~/.ssh/id_rsa.pub --output table
done
az vm create --resource-group "$RG" --name scylla-monitoring \
  --image "Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest" \
  --size Standard_D4s_v3 --vnet-name scylla-vnet --subnet scylla-subnet \
  --nsg scylla-nsg --admin-username azureuser \
  --ssh-key-values ~/.ssh/id_rsa.pub --output table
echo "Done! Next: ./scripts/install-scylla.sh"
