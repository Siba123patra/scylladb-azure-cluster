# ScyllaDB Cluster on Azure Cloud

![ScyllaDB](https://img.shields.io/badge/ScyllaDB-6.x-blue)
![Azure](https://img.shields.io/badge/Microsoft_Azure-Cloud-0078D4)
![LDAP](https://img.shields.io/badge/Auth-LDAP-green)
![Grafana](https://img.shields.io/badge/Monitoring-Grafana-F46800)
![License](https://img.shields.io/badge/License-MIT-yellow)

> Production-ready ScyllaDB cluster on Microsoft Azure with LDAP authentication,
> Grafana + Prometheus monitoring, and TTL-enabled data management.

## Architecture

```
+-------------------------------------------------------------+
|                   Azure Virtual Network (10.0.0.0/16)       |
|  +-------------+  +-------------+  +-------------+         |
|  | ScyllaDB    |  | ScyllaDB    |  | ScyllaDB    |         |
|  |  Node 1     +--+  Node 2     +--+  Node 3     |         |
|  | 10.0.1.4   |  | 10.0.1.5   |  | 10.0.1.6   |         |
|  +------+------+  +-------------+  +------+------+         |
|         |                                 |                 |
|  +------+------+              +-----------+----------+      |
|  | LDAP Server |              |  Monitoring VM        |     |
|  |(Azure AD DS)|              |  Prometheus + Grafana |     |
|  +-------------+              +----------------------+      |
+-------------------------------------------------------------+
```

## Quick Start

```bash
git clone https://github.com/YOUR_USERNAME/scylladb-azure-cluster.git
cd scylladb-azure-cluster
chmod +x scripts/*.sh
./scripts/provision-azure.sh    # Step 1: Azure infrastructure
./scripts/install-scylla.sh     # Step 2: ScyllaDB on each node
./scripts/setup-ldap.sh         # Step 3: LDAP authentication
./scripts/start-monitoring.sh   # Step 4: Grafana + Prometheus
```

## Prerequisites

- Azure subscription (Owner or Contributor role)
- Azure CLI v2.50+
- ScyllaDB Enterprise license (required for LDAP)
- SSH key pair at ~/.ssh/id_rsa.pub
- LDAP server (Azure AD DS or OpenLDAP VM)

## Project Structure

```
scylladb-azure-cluster/
├── configs/
│   ├── scylla.yaml            # ScyllaDB cluster config
│   ├── saslauthd.conf         # LDAP authentication config
│   └── scylla_servers.yml     # Prometheus scrape targets
├── scripts/
│   ├── provision-azure.sh     # Azure infra provisioning
│   ├── install-scylla.sh      # ScyllaDB installation
│   ├── setup-ldap.sh          # LDAP / saslauthd setup
│   └── start-monitoring.sh    # Grafana + Prometheus stack
├── docs/
│   └── ttl-examples.cql       # TTL configuration examples
├── LICENSE
└── README.md
```

## Azure Infrastructure

See scripts/provision-azure.sh for the full setup.

| Port     | Purpose                    |
|----------|----------------------------|
| 7000     | Inter-node gossip          |
| 7001     | Inter-node gossip (TLS)    |
| 9042     | CQL client                 |
| 9142     | CQL client (TLS)           |
| 9180     | Prometheus metrics         |
| 3000     | Grafana dashboard          |

## ScyllaDB Installation

See scripts/install-scylla.sh and configs/scylla.yaml.

## LDAP Authentication

See scripts/setup-ldap.sh and configs/saslauthd.conf.

Key settings in scylla.yaml:

```yaml
authenticator: com.scylladb.auth.SaslauthdAuthenticator
authorizer: CassandraAuthorizer
```

## Grafana Monitoring

See scripts/start-monitoring.sh and configs/scylla_servers.yml.
Access Grafana at http://<monitoring-vm-ip>:3000 (default: admin/admin).

## TTL Configuration

See docs/ttl-examples.cql.

```sql
CREATE TABLE myapp.events (
  event_id UUID PRIMARY KEY,
  payload  TEXT
) WITH default_time_to_live = 2592000
   AND compaction = {
     'class': 'TimeWindowCompactionStrategy',
     'compaction_window_unit': 'DAYS',
     'compaction_window_size': 1
   };
```

## Security Checklist

- [ ] Enable client-to-node TLS
- [ ] Enable node-to-node TLS
- [ ] Remove default cassandra superuser
- [ ] Store LDAP credentials in Azure Key Vault
- [ ] Enable audit logging
- [ ] Enable Microsoft Defender for Cloud

## Troubleshooting

| Problem                  | Resolution                                          |
|--------------------------|-----------------------------------------------------|
| Node fails to join       | Check seed IPs; verify NSG ports 7000/7001          |
| LDAP login fails         | Run testsaslauthd -u user -p pass; check bind DN    |
| Grafana no data          | Verify port 9180 open; check scylla_servers.yml     |
| TTL not expiring         | Check gc_grace_seconds < TTL; run manual compaction |
| High tombstone latency   | Switch to TWCS; run nodetool compact                |

## References

- ScyllaDB Docs: https://docs.scylladb.com
- Scylla Monitoring Stack: https://github.com/scylladb/scylla-monitoring
- LDAP Auth Enterprise: https://docs.scylladb.com/enterprise/operating-scylla/security/ldap-authorization
- TTL in ScyllaDB: https://docs.scylladb.com/using-scylla/expiring-data
- Azure VM Sizing: https://learn.microsoft.com/azure/virtual-machines/sizes

## License

MIT - see LICENSE
