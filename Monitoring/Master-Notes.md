# Prometheus Basics

## What is Prometheus?

Prometheus is an open-source monitoring and alerting system that collects, stores, and queries metrics as time-series data.

### Key Features

- Time-series database (TSDB)
- Pull-based monitoring
- PromQL query language
- Alerting support through Alertmanager
- Service discovery integration
- Multi-dimensional data model using labels

---

## Why Do We Need Prometheus?

Without monitoring:

- Server failures go unnoticed
- High CPU or memory usage is not detected early
- Application outages impact users

Prometheus helps monitor:

- Infrastructure
- Applications
- Containers
- Kubernetes clusters

---

## Prometheus Architecture

```text
Application/Server
        │
        ▼
Exporter
(Node Exporter)
        │
        ▼
Prometheus
        │
   ┌────┴────┐
   ▼         ▼
Grafana   Alertmanager
`
