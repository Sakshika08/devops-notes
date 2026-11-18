# devops-notes

This repository contains my learning notes, revision notes, interview preparation material, troubleshooting guides, and real-world DevOps scenarios.


most modern DevOps environments commonly use **Python 3.x (typically 3.9, 3.10, 3.11, or newer)** depending on the organization.

### java -version  
openjdk version "17.0

### Check linux OS Version
cat /etc/os-release  
output:  
NAME="Ubuntu"  
VERSION="22.04.4 LTS"

### bash, version: 
5.1.16


Jenkins LTS: 2.568.3   
Terraform: 1.16.1 (latest stable release)   
EKS Standard Support Versions: 1.34, 1.35, 1.36; Extended Support: 1.31, 1.32, 1.33  

What I'd say in your interviews  
We use Jenkins 2.x LTS for CI/CD, Terraform 1.x for infrastructure provisioning, and Amazon EKS for Kubernetes workloads. The clusters I've worked with are generally in the Kubernetes 1.3x range.

## Log Monitoring Automation (Support Role Friendly)

One process I automated was application log monitoring.

Support engineers were manually reviewing logs during incidents to identify failures and exceptions.

I developed a script that automatically scanned log files, identified critical errors, generated summaries, and sent alerts when predefined thresholds were exceeded.

This reduced the time required to detect issues and helped the team respond to incidents more quickly.
```
#!/bin/bash

LOG_FILE="/var/log/app.log"
THRESHOLD=5

ERROR_COUNT=$(grep -i "ERROR" "$LOG_FILE" | wc -l)

echo "===== Log Summary ====="
echo "Total Errors: $ERROR_COUNT"

grep -i "ERROR" "$LOG_FILE" | tail -5

if [ "$ERROR_COUNT" -gt "$THRESHOLD" ]; then
    echo "ALERT: High number of errors detected"
fi
```

## 🔥 Q. Please explain your day-to-day activities as a DevOps Engineer.
In my current role, my day typically starts with reviewing monitoring dashboards, alerts, and overnight incidents to ensure all applications and infrastructure are healthy.  
A significant part of my work involves managing and monitoring AWS resources such as EC2, EKS, ALB, IAM, and S3. I regularly review CloudWatch, Grafana, and Prometheus dashboards to identify performance issues, resource bottlenecks, or any critical alerts.  
I also support application deployments by maintaining CI/CD pipelines using Jenkins and GitHub Actions. This includes reviewing build failures, troubleshooting deployment issues, and ensuring releases are deployed successfully across environments.  
For containerized workloads, I manage Kubernetes clusters and perform activities such as deployments, scaling, troubleshooting pod issues, and Helm-based application upgrades.  
I work with Terraform to provision and maintain infrastructure as code, ensuring infrastructure changes are version-controlled and repeatable.  
Another important part of my role is troubleshooting. This may include investigating application issues, Kubernetes problems, AWS infrastructure issues, CI/CD failures, or performance-related incidents.  
I also collaborate closely with development teams by supporting deployments, managing environment configurations, handling Secrets and access controls, and helping resolve operational challenges.  
Throughout the day, I continuously monitor alerts, incidents, and production health to ensure system reliability and minimize downtime. 

---

## Author
Sakshi Kale
