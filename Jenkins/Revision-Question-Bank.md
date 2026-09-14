
1. Jenkins job stuck in queue

What to check?

Free executors?
Agent available?
Label mismatch?
Agent offline?

Interview line:

First I check controller health, then agent availability, then label/configuration issues.

2. Agent Offline

Possible causes

Network issue
Agent process crashed
K8s agent pod terminated
Disk full / OOM
Configuration issue
3. Pipeline failed

Debug order

Pipeline logs
Agent status
Pipeline conditions
External dependencies

This debugging framework can answer many questions.

4. Production Deployment Failed

Expected answer

Stabilize system
Rollback if required
Find failed stage
Check logs
Fix root cause
Prevent recurrence

Gold line:

Stabilize → Debug → Prevent

5. PR Pipeline Accidentally Deployed to Production

Very common senior-level question.

Root causes:

Missing branch condition
CI/CD mixed together
Incorrect branch detection

Prevention:

Deploy only from main
Separate CI/CD
Approval gates
RBAC
6. Password Printed in Jenkins Logs

Expected answer:

Treat as security incident
Rotate credential immediately
Use Credentials Store
Remove echo statements
Audit access
7. Jenkins UI Slow

Check:

Controller overloaded
Disk full
Memory issue
Too many plugins
Large build history
8. Wrong Image Deployed

Expected answer:

Never use latest
Use commit SHA/build number tags
Validate deployment parameters
Follow artifact immutability

9. Deployment Succeeded but App Not Working

Debug:
```
kubectl get pods
kubectl describe pod
kubectl logs
check env/secrets
check probes
check resources
```
Agent is offline. What do you do?
"If an agent is offline, I first verify whether the problem is connectivity, agent failure, resource exhaustion, or configuration related. I check if the agent machine or Kubernetes pod is running, verify connectivity to the Jenkins controller, review agent logs, and check CPU, memory, and disk usage. Once the root cause is identified, I restore the agent and confirm it reconnects before re-running the pipeline."
