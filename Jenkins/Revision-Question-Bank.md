### Q. Tell me about a challenging CI/CD issue
One challenge I faced was repeated pipeline failures at the SonarQube stage after stricter Quality Gate rules were introduced. Several builds that previously passed started failing, which impacted release timelines.

I reviewed the SonarQube reports and identified that the failures were due to critical vulnerabilities and code quality issues. I worked with developers to understand the findings and prioritize remediation.

We fixed the critical issues, improved code quality practices, and updated our development workflow to address these findings earlier in the SDLC.

After that, pipeline success rates improved and we had fewer production issues related to code quality.

The key lesson was that integrating quality checks early helps prevent problematic code from reaching production.

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



### Q. A Jenkins pipeline is taking 40 minutes to complete, but earlier it used to finish in 10 minutes.

How would you investigate and identify the bottleneck?
✅ Check stage-wise execution time

First determine whether Build, Test, SonarQube, Docker Build, ECR Push, or Deployment is slow.

✅ Check Jenkins agent health

CPU utilization
Memory utilization
Disk utilization

✅ Check workspace cleanup issues

Large workspaces can slow down Git checkout and builds.

✅ Check Docker build performance

Large images
Missing layer caching
Multi-stage build opportunities
Additional points that would make it even stronger

1. Queue Time

Sometimes the pipeline itself is fast, but jobs are waiting in queue.

Not enough executors
Busy agents

2. Recent Changes

Ask:

What changed when the pipeline became slow?

For example:

New test cases added  
New SonarQube rules
Larger Docker image
Additional pipeline stages

3. External Dependencies

Check whether:
SonarQube server is slow
ECR is responding slowly
Kubernetes API server is slow
Artifact repository is slow

4. Build Logs Comparison
Compare:
Old successful run (10 min)
New slow run (40 min)
Stage-by-stage duration comparison often reveals the bottleneck immediately.
