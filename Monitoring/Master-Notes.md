# Prometheus Basics

## What is Prometheus?  
Prometheus is an open-source monitoring and alerting system used to collect, store, query, and monitor metrics from applications, servers, containers, and Kubernetes clusters.  
Prometheus stores data as time-series information and allows querying using PromQL.

### Key Features

- Time-Series Database (TSDB)
- Pull-based monitoring
- Powerful query language (PromQL)
- Multi-dimensional data model
- Alerting support
- Service discovery support
- Kubernetes-native monitoring
- Highly scalable

---

## Why Do We Need Monitoring?

Without monitoring:  
- Server failures go unnoticed
- Applications can be unavailable
- Performance issues remain undetected
- Resource exhaustion can cause outages

Monitoring helps identify:  
- CPU bottlenecks
- Memory leaks
- Disk utilization issues
- Application errors
- Service failures

---

# Prometheus Architecture

```text
Application / Server
          │
          ▼
     Exporter
(Node Exporter)
          │
          ▼
     Prometheus
          │
 ┌────────┼────────┐
 ▼        ▼        ▼
Grafana AlertMgr Storage
```

## Components

### Exporters  
Exporters expose metrics in a Prometheus-compatible format.  
Examples:

- Node Exporter
- Blackbox Exporter
- JMX Exporter
- MySQL Exporter
- PostgreSQL Exporter
- Kubernetes State Metrics

---

### Prometheus Server
Responsible for:
- Scraping targets
- Storing metrics
- Running PromQL queries
- Generating alerts

---

### Grafana
Responsible for:
- Visualization
- Dashboards
- Reporting
- Alerting

---

### Alertmanager
Responsible for:
- Sending alerts
- Alert grouping
- Alert routing
- Alert suppression

Supports:

- Email
- Slack
- Microsoft Teams
- PagerDuty

---

# Metrics

## What is a Metric?

A metric is a measurable value representing the state of a system at a particular point in time.

Examples:

```text
CPU Usage
Memory Usage
Disk Usage
Network Traffic
Pod Count
HTTP Requests
```

Real examples:

```text
node_cpu_seconds_total

node_memory_MemAvailable_bytes

http_requests_total
```

---

## Time-Series Data

Prometheus stores metrics as time-series.

Example:

```text
Time      CPU Usage

10:00        25
10:01        30
10:02        35
10:03        28
```

Prometheus stores:

```text
Metric Name
Labels
Timestamp
Value
```

Example:

```text
node_cpu_usage{instance="server1"} 35
```

---

# Labels

## What are Labels?

Labels are key-value pairs attached to metrics.

They help identify and filter data.

Example:

```text
up{job="node-exporter",instance="server1"} 1
```

### Labels

```text
job=node-exporter

instance=server1
```

---

## Why Are Labels Important?

Labels enable:

### Filtering

```promql
up{job="node-exporter"}
```

### Grouping

```promql
sum by(job)(up)
```

### Aggregation

```promql
avg by(instance)(cpu_usage)
```

---

## Interview Question

### What are Labels in Prometheus?

Labels are key-value pairs attached to metrics that provide dimensional information used for filtering, grouping, and aggregation.

---

# Targets

## What is a Target?

A target is an endpoint (application, server, container, or service) from which Prometheus collects metrics.
Examples:
Prometheus server itself
Node Exporter on an EC2 instance
Kubernetes API Server
MySQL Exporter
Redis Exporter

```text
localhost:9090

10.0.0.15:9100

192.168.1.10:8080
```

Prometheus periodically contacts these endpoints and collects metrics.
How to Check Targets
Prometheus UI: Status → Target Health → Query: up → Output:
1 = Target is healthy and being scraped
0 = Target is down or scrape failed

---

## Target Example

```text
Prometheus
      │
      ▼
10.0.0.15:9100
```

Here,

```text
10.0.0.15:9100
```

is the target.

---

# Scraping

## What is Scraping?

Scraping is the process by which Prometheus pulls metrics from a target's /metrics endpoint at regular intervals.
Prometheus periodically sends HTTP requests to targets.

Example:

```text
Prometheus
     │
 GET /metrics
     │
     ▼
Node Exporter
```
Node Exporter responds:
```
CPU = 25%
Memory = 60%
Disk = 45%
```
Prometheus stores these values in its database.

---

## Scrape Interval

Default:

```yaml
scrape_interval: 15s
```

Meaning: Prometheus will collect metrics every 15 seconds.

---

## Interview Question


---

# Exporters

## What is an Exporter?

An exporter collects metrics from a system and exposes them in Prometheus format.
Prometheus cannot directly understand every technology. Prometheus understands metrics only in a specific format.
Most operating systems and applications don't expose metrics in that format by default.
Exporters bridge this gap.

---

## Common Exporters

### Node Exporter

Monitors:
```text
CPU
Memory
Disk
Network
Filesystem
Load Average
```

---

### Blackbox Exporter

Monitors:

```text
HTTP
HTTPS
TCP
DNS
ICMP
```

---

### MySQL Exporter

Monitors:

```text
Connections
Queries
Replication
Performance
```

---

### JMX Exporter

Monitors Java applications.

---

## Interview Question

### What is Node Exporter?
Node Exporter is a Prometheus exporter that exposes Linux operating system metrics such as CPU, memory, disk, filesystem, and network statistics.

### How Does Service Discovery Work?
Instead of manually adding every target IP address, Prometheus can automatically discover targets IP addresses and ports (like Kubernetes pods, AWS EC2 instances, or Consul nodes) by querying infrastructure APIs to update the list of scrape targets dynamically.
```text
Prometheus
      ↓
AWS API
      ↓
Discovers:
EC2-1
EC2-2
EC2-3
```

Prometheus begins scraping them automatically.

Interview Answer:
Service discovery automatically finds targets from platforms like Kubernetes, AWS EC2, Docker, or Consul so Prometheus can scrape them without manually updating configurations.

---

# Prometheus Data Model

Structure:

```text
metric_name{labels} value
```

Example:

```text
up{job="prometheus"} 1
```

Breakdown:

Metric Name:

```text
up
```

Label:

```text
job="prometheus"
```

Value:

```text
1
```

Meaning:

```text
Target is healthy
```

---

# Pull Model

## How Prometheus Collects Data
Prometheus uses a pull architecture.
Prometheus initiates the connection.
```text
Prometheus ----> Target
```

Prometheus requests data from targets.

---

## Benefits

- Better service discovery
- Centralized monitoring
- Easy troubleshooting
- Simple architecture

---

## Pull vs Push

### Pull

```text
Prometheus --> Target
```

Advantages:

- Health checking
- Better visibility
- Simpler management

---

### Push

```text
Application --> Monitoring Tool
```

Examples:

- CloudWatch
- Splunk Forwarders

---

# PromQL

## What is PromQL?

PromQL (Prometheus Query Language) is used to query Prometheus metrics.

Similar to SQL for databases.

---

## First Query

```promql
up
```

Output:

```text
up{job="prometheus"} 1
```

Meaning:

Target is healthy.

---

## Count Targets

```promql
count(up)
```

---

## Sum

```promql
sum(up)
```

---

## Average

```promql
avg(up)
```

---

## Rate

```promql
rate(http_requests_total[5m])
```

Calculates per-second increase of a counter.

---

## CPU Utilization

```promql
100 -
(avg by(instance)
(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

---

## Memory Usage %

```promql
100 *
(
1 -
(node_memory_MemAvailable_bytes
/
node_memory_MemTotal_bytes)
)
```

---

## Top 5 CPU Consumers

```promql
topk(5,
100-(avg by(instance)
(rate(node_cpu_seconds_total{mode="idle"}[5m]))*100)
)
```

---

## Interview Question

### What is PromQL?

PromQL is Prometheus Query Language used to filter, aggregate, and analyze time-series metrics stored in Prometheus.

---

# Grafana

## What is Grafana?

Grafana is an open-source visualization platform used to display monitoring data.
Grafana does not store metrics itself.
```
Node Exporter
      ↓
Prometheus Scrapes
      ↓
Metrics Stored
      ↓
Grafana Executes PromQL
      ↓
Displays Dashboard
```
Example:
Grafana panel query: `process_resident_memory_bytes` Grafana sends that query to Prometheus.  
Prometheus returns: `114028544` Grafana converts that into a graph.

It reads metrics from data sources such as:

- Prometheus
- Loki
- Elasticsearch
- CloudWatch
- InfluxDB

---

# Grafana Components
## Data Sources

A system from which Grafana retrieves data.

Example:

```text
Prometheus
```

Connection:

```text
Grafana
     │
     ▼
Prometheus
```

---

## Dashboards

A dashboard is a collection of visualizations.

Example:

```text
Infrastructure Dashboard

├── CPU Usage
├── Memory Usage
├── Disk Usage
└── Network Usage
```

---

## Panels

A panel is a single visualization or graph within a dashboard.

Examples:

- Graph
- Gauge
- Table
- Pie Chart
- Heat Map

Grafana doesn't store monitoring data. It connects to Prometheus as a data source, executes PromQL queries, retrieves metrics, and displays them in dashboards and graphs

## Complete End-to-End Flow

```
EC2 Server
     │
     ▼
Node Exporter
(exposes metrics)
     │
     ▼
http://server:9100/metrics
     │
     ▼
Prometheus
(scrapes every 15s)
     │
     ▼
Time-Series Database
(metric + labels + timestamp + value)
     │
     ▼
Grafana
(PromQL Queries)
     │
     ▼
Dashboards & Alerts
```

---

# Variables

## What are Variables?

Variables make dashboards dynamic.

Example:

```text
server1
server2
server3
```

Instead of creating multiple dashboards.

Use:

```text
$instance
```

---

## Benefits

- Reusable dashboards
- Easier filtering
- Dynamic visualization

---

# Grafana Alerts

## What are Alerts?

Alerts notify teams when thresholds are breached.

Example:

```text
CPU > 80%
```

Actions:

- Email
- Slack
- Teams
- PagerDuty

---

# Alertmanager

## What is Alertmanager?

Alertmanager manages alerts generated by Prometheus.

Workflow:

```text
Prometheus
      │
      ▼
Alertmanager
      │
      ▼
Email / Slack / Teams
```

---

## Features

- Alert grouping
- Alert routing
- Deduplication
- Silence alerts
- Escalations

---

# Kubernetes Monitoring

## Why Kubernetes Monitoring?

In Kubernetes environments we need visibility into:

- Nodes
- Pods
- Deployments
- StatefulSets
- Services
- Ingresses

---

# kube-prometheus-stack

## What is kube-prometheus-stack?

A Helm package that installs:

```text
Prometheus
Grafana
Alertmanager
Node Exporter
kube-state-metrics
Prometheus Operator
```

Installation:

```bash
helm install monitoring prometheus-community/kube-prometheus-stack
```

---

# Prometheus Operator

## What is Prometheus Operator?

Prometheus Operator automates:

- Deployment
- Configuration
- Scaling
- Upgrades

of Prometheus inside Kubernetes.

---

# ServiceMonitor

## What is ServiceMonitor?

Custom Resource Definition (CRD) used by Prometheus Operator.

Defines which Kubernetes Services should be scraped.

Example:

```text
Service
    │
    ▼
ServiceMonitor
    │
    ▼
Prometheus
```

---

## Why ServiceMonitor?

Without ServiceMonitor:

```text
Manual target configuration
```

With ServiceMonitor:

```text
Automatic discovery
```

---

# PodMonitor

## What is PodMonitor?

Used when Prometheus needs to scrape pods directly.

Flow:

```text
Pod
  │
  ▼
PodMonitor
  │
  ▼
Prometheus
```

---

## ServiceMonitor vs PodMonitor

### ServiceMonitor

Monitors:

```text
Services
```

Example:

```text
Frontend Service
Backend Service
```

---

### PodMonitor

Monitors:

```text
Individual Pods
```

Example:

```text
nginx-pod
api-pod
```

---

# Important Interview Questions

## What is Prometheus?

An open-source monitoring and alerting system that stores metrics as time-series data.

---

## Why is Prometheus called a Time-Series Database?
Time series: A metric stored over time.
Because it stores:

```text
Metric
Timestamp
Value
```

over time.

---

## What is a Metric?

A measurable value representing the state of a system.

---

## What are Labels?

Key-value pairs attached to metrics used for filtering and aggregation.

---

## What is Scraping?

The process of collecting metrics from targets.

---

## What is an Exporter?

A tool that exposes metrics in Prometheus-compatible format.

---

## What is PromQL?

A query language used to query, aggregate, and analyze Prometheus metrics.

---

## Why is Grafana used with Prometheus?

Prometheus stores metrics.

Grafana visualizes metrics through dashboards and alerts.

---

## What is Alertmanager?

Alertmanager handles alerts generated by Prometheus and sends notifications through multiple channels.

---

## What is ServiceMonitor?

A Kubernetes CRD used by Prometheus Operator to automatically discover and scrape Kubernetes Services.

---

## What is PodMonitor?

A Kubernetes CRD used by Prometheus Operator to scrape metrics directly from Pods.

---

## What is kube-prometheus-stack?

A Helm-based monitoring stack that installs Prometheus, Grafana, Alertmanager, Node Exporter, kube-state-metrics, and Prometheus Operator in Kubernetes.

---

## Push vs Pull
### Pull
Prometheus --> Target  

Advantages:

Target health checking
Better scalability
Simpler configuration

### Push
Application --> Monitoring Tool

Examples:
CloudWatch
Datadog Agent

---

# Service Discovery vs ServiceMonitor
## Service Discovery 
Service Discovery is Prometheus's mechanism for automatically finding targets that expose metrics.
Without Service Discovery Problem:  
New servers require manual updates
Scaling is difficult
Kubernetes pods change IPs frequently

With Service Discovery  
Prometheus automatically discovers targets.
Example:
```
scrape_configs:
  - job_name: kubernetes-pods
    kubernetes_sd_configs:
      - role: pod
```
Prometheus continuously asks Kubernetes: Show me all pods exposing metrics and automatically updates targets.

## ServiceMonitor
ServiceMonitor is a Kubernetes Custom Resource (CRD) created by the Prometheus Operator.  
It defines:
Which Service should be monitored  
Which port should be scraped  
How frequently it should be scraped  

Example ServiceMonitor:
```
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: my-app-monitor
spec:
  selector:
    matchLabels:
      app: my-app

  endpoints:
  - port: http
    interval: 30s
```
Meaning: 
Find Service with label app=my-app
Scrape every 30 seconds

ServiceMonitor is a Kubernetes Custom Resource provided by Prometheus Operator that defines how Prometheus should discover and scrape Kubernetes Services.
