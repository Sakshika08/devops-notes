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

## Author
Sakshi Kale
