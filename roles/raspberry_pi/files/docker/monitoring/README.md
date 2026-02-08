# Raspberry Pi Monitoring Stack (Docker)

## Overview

This repository contains a lightweight but powerful **monitoring and logging stack** designed to run on a Raspberry Pi using Docker Compose.  
It provides **metrics, logs, and dashboards** for both the host system and running containers.

The stack is well suited for:
- Raspberry Pi homelabs
- Low-power ARM systems
- Single-node Docker environments
- Configuration managed via Ansible

### Included components

- **Prometheus** – metrics storage and querying
- **Grafana** – dashboards and visualization
- **cAdvisor** – container-level metrics
- **Node Exporter** – host-level system metrics
- **Loki** – log aggregation
- **Alloy** – log and telemetry collection (Grafana Agent successor)

---

## Architecture

At a high level:

- **Node Exporter** exposes host metrics (CPU, memory, disk, network)
- **cAdvisor** exposes container metrics
- **Prometheus** scrapes metrics from Node Exporter and cAdvisor
- **Alloy** collects:
  - Docker container logs
  - System logs (journald)
- **Loki** stores logs received from Alloy
- **Grafana** visualizes metrics (Prometheus) and logs (Loki)

```
Node Exporter ─┐
               ├──> Prometheus ───> Grafana
cAdvisor  ─────┘

Docker / System Logs ──> Alloy ───> Loki ───> Grafana
```

---

## Services

### Prometheus
Prometheus scrapes metrics from Node Exporter and cAdvisor and stores them locally.

- Configuration: `prometheus/prometheus.yml`
- Data directory: `prometheus/data`
- Scrape targets use Docker service names

### Grafana
Grafana provides dashboards for metrics and logs.

- URL: `http://<host-ip>:3000`
- Default credentials: `admin / admin`
- Environment variables: `grafana/.env`
- Provisioning:
  - Datasources: `grafana/provisioning/datasources`
  - Dashboards: `grafana/provisioning/dashboards`

### cAdvisor
cAdvisor exposes container-level metrics such as CPU, memory, filesystem, and network usage.

- Runs in privileged mode
- Reads Docker and host filesystem metadata
- Scraped by Prometheus

### Node Exporter
Node Exporter exposes hardware and OS metrics for the Raspberry Pi host.

- CPU, memory, disk, filesystem, network
- Uses custom mount paths suitable for Docker

### Loki
Loki is a log aggregation system optimized for Grafana.

- Receives logs from Alloy
- Stores logs locally (single-node setup)
- Version is pinned due to Docker issues in newer releases

### Alloy
Alloy is Grafana’s unified collector (successor to Grafana Agent).

In this stack, Alloy:
- Discovers Docker containers via the Docker socket
- Collects container logs
- Collects system logs from `journald`
- Ships logs to Loki
- Exposes a local debug/UI endpoint

---

## Setup

### Prepare data directories

Create persistent data directories and set correct ownership:

```bash
mkdir -p prometheus/data grafana/data alloy/data && \
sudo chown -R 472:472 grafana/ && \
sudo chown -R 65534:65534 prometheus/
```

### Start the stack

```bash
docker compose up -d
```

---

## Exposed Ports

| Port  | Service     | Description              |
|------:|-------------|--------------------------|
| 3000  | Grafana     | Web UI                   |
| 3100  | Loki        | Loki API                 |
| 12345 | Alloy       | Alloy debug / UI         |

Prometheus, Node Exporter, and cAdvisor are **internal only** and not exposed on the host.
