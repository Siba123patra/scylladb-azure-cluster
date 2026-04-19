#!/usr/bin/env bash
set -euo pipefail
sudo apt-get install -y sasl2-bin libsasl2-modules-ldap
sudo sed -i 's/START=no/START=yes/' /etc/default/saslauthd
sudo sed -i 's/MECHANISMS=.*/MECHANISMS="ldap"/' /etc/default/saslauthd
sudo cp configs/saslauthd.conf /etc/saslauthd.conf
sudo usermod -aG sasl scylla
sudo systemctl enable --now saslauthd && sudo systemctl restart saslauthd
echo "Test with: testsaslauthd -u <username> -p <password>"
echo "Then: sudo systemctl restart scylla-server"
