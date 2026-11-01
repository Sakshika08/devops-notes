
# Jenkins
Open-source CI/CD automation server  
Automates Build → Test → Deploy  
Pipeline as Code using Jenkinsfile  
Declarative (preferred) vs Scripted (flexible)  

## End-to-End Flow
Git Push → Webhook → Jenkins → Build → Test → SonarQube → Docker Image → ECR → Helm → Kubernetes → Monitoring

Build Once → Test Once → Deploy Many   
CI proves code is deployable. CD delivers it safely.  

---
# Controller vs Agent
## Controller
Schedules Jobs
Stores Pipeline State
Stores Credentials
Stores Build History
Orchestrates

## Agent
Runs Build
Runs Tests
Runs Deployments
Has Workspace

Controller Assigns Work and Agent Executes

Never run heavy builds on controller.

---
# Executors
Executor = job slot, not machine  
Controls concurrency    
1 agent + 2 executors = 2 parallel jobs  
Best Practice  
Controller = 0 executors  
Kubernetes agents = usually 1 executor/pod  

More Executors ≠ More Capacity  
More Executors + Same Hardware = Resource Contention

Isolation > Parallelism

## Kubernetes Agents 
Problem with Traditional VM running the agent/executor:  
Idle Resources  
Manual Management  
Scaling Problems  

**Kubernetes Agents** 
Controller → K8s Plugin → Pod Created → Build Runs → Pod Deleted

Benefits:  
Dynamic scaling  
Isolation  
Lower cost  
Ephemeral builds  

Scale Jenkins by adding Pods, not Executors.

---
## Workspace vs Pipeline State  
#### Workspace  
Agent: Stores files, code, artifacts

#### Pipeline State
Controller: Stores stage Completed, re3sume information  

Workspace stores files; Controller stores state.

---
## Build Queue
Pipeline Starts → Controller Searches Agent → Free Executor?  
                                                ├─ YES → Run  
                                                └─ NO → Queue  
Job waits when:  
Busy Executors  
Agent Offline  
Label Mismatch  
Resources Unavailable  

Queue protects Jenkins from overload.

---
## Pipeline Lifecycle
Trigger → Pipeline Initialized → Agent Allocated → Stages → Post → Results Stored

---
# Jenkins Restart
## Controller Restart
Controller Restarts
↓
Loads Pipeline State
↓
Agents Reconnect
↓
Pipeline Resumes

## Agent Restart
Agent Crashes
↓
Execution Stops
↓
Workspace Lost
↓
Stage Fails  

Controller restart interrupts orchestration. Agent restart interrupts execution.

---
# Shared Libraries
Problem:
Team A: Build Logic  
Team B: Same Build Logic  
Team C: Same Build Logic  
Resulting in Duplication and Maintenance Headache

**Solution:** 
Shared Libraries → Reusable pipeline code/ functions → Reduce duplication → Thin Jenkinsfiles  → Same everywhere   

Thin Jenkinsfile + Shared Library = Production standard

<img width="467" height="581" alt="image" src="https://github.com/user-attachments/assets/4b8385cb-7533-4ae2-9bf5-e98dbb4ca542" />

I would use Jenkins shared libraries to centralize common pipeline logic.
Reusable pipeline steps such as build, test, security scans, and deployment would be written once in the shared library and exposed as reusable functions.
Each team's Jenkinsfile would remain lightweight and focus only on team-specific configuration, such as parameters or environment details, while reusing common logic from the shared library.
The shared library would be versioned to allow controlled updates, ensuring changes do not break existing pipelines.

---
# Multibranch Pipelines
Repository
├─ Main
├─ Feature-A
├─ Feature-B
└─ PR

Jenkins Automatically Discovers Everything: Branches and Pull Requests 
Branch Appears → Jenkins Detects → Pipeline Runs  
Multibranch pipelines scale repository growth automatically.

Feature Branch: Validate Code Alone  
PR: Validate With Latest Main  (Build, Test, Scan, no deploy)
Main: Validation + Deploy  
PR = Untrusted, Main = Trusted   
Gold: PR validation reduces integration risk.

---
## Artifact Strategy

Artifact:
- Docker Image
- JAR
- WAR
- Binary

Not Artifact: Source Code

**Flow:** Build once → Version the Artifact → Store → Promote → Deploy Everywhere  
**Never:** Rebuild for production

If you rebuild for prod, you're deploying something you never tested.

---
# Matrix Builds

Keep:

Same pipeline  
Multiple combinations 
Parallel execution  

Example:
Java:   
8   
11  
17  

OS:  
Linux  
Windows

Result = 6 executions

Gold line: Matrix builds increase validation coverage without duplicating pipelines.

# Fail-Fast vs Fail-Safe
Fail Fast:  
Build failure    
Unit test failure    
Docker build failure    
“Anything that makes the artifact invalid must stop immediately"

Fail Safe:  
Sonar warning   
Optional reports  
Non-blocking scans  

Gold: Not every failure should block the pipeline.

---
# Pipeline Safety
## Approval Stages
Pause Pipeline → Persist State → Release Executor → Wait For Human Approval → Allocate Executor → Continue  

Used for:
- Production Deployments  
- Terraform Apply  
- Database Migrations

```
stage('Approve Production') {
  steps{
    timeout(time: 10, unit: 'MINUTES' ) {
	    input message: 'Deploy to production'
	  }
  }
}
```
Must have:  
RBAC  
Timeout  
Audit trail

Danger: Too Many Approvals Slows Delivery  
Approval should reduce risk, not slow delivery

---
## retry
```
stage('Test') {
  steps {
    retry(2) {
	  sh "run-test.sh"
	}
  }
}
```
Use for:
- Network failures  
- API hiccups  
- Git clone issues  
- Timeouts while downloading dependencies

Not for:   Code bugs or Test failures  

--
## timeout
Timeouts protect executors and CI capacity by preventing jobs from hanging indefinitely and blocking limited build resources.
```
stage('Build') {
  steps {
    timeout(time: 10, unit: 'MINUTES') {
	    sh 'buil.sh'
	  }
  }
}
```
---
## catchError
Is used when you want the stage to be marked as FAILED but the overall pipeline should continue executing for non blocking or optional steps.
```
stage('Quality scan') {
  stapes {
    catchError(buildResult: 'SUCCESS', sttageREsult: 'FAILURE') {
	  sh 'sonar-scan.sh'
	}
  }
}

```
Used for: Sonar or Optional scans

---
# Parallel vs Sequential
## Parallel
Unit tests  
Linting  
Security scans  
```
stage('Parallel Tests') {
  parallel {
    stage('Unit test') {
	  steps {
	    echo 'Running unit test'
	  }
	}
	stage('Integration test') {
	  steps {
	    echo "Running integration test"
	  }
	}
  }
}
```
--- 
## Sequential
Build → Test  
Package → Deploy

Dependency decides sequencing. 

---
## disableConcurrentBuilds()
Prevents multiple runs of same pipeline from modifying same resources.

---
## post Block
Runs even on failure.  

Used for:
Cleanup  
Notifications  
Reporting  

---
# CI vs CD
## CI
Build  
Test  
Scan  
Create artifact  

## CD
Promote artifact  
Deploy  
Rollback  

CI proves correctness. CD manages risk.

---
# agent any vs agent none

## agent any
Executor allocated for entire pipeline  
Can unnecessarily hold executor 

## agent none
No executor until stage requests one    
Better resource utilization  
Useful for approval stages  

Gold line: agent none prevents executors from being blocked during waits and approvals.

---
# Conditions 
## Branch
Deploy only from main
```
stage('Deploy') {
  when {
    branch 'main'
  }
  steps{
    echo " Deploying to production "
  }
}
```

## Environment
Prod requires approval

## Status
Deploy only if CI passed

## Custom
Tag/Parameter based  
Pipeline-level conditions > shell if/else

---
# Jenkins Parameters
Common:
- String  
- Choice  
- Boolean  
- Password  

Use case: Deploy same artifact to Dev/Staging/Prod
```
pipeline {
    agent any

    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'staging', 'prod'],
            description: 'Select environment'
        )
    }

    stages {
        stage('Deploy') {
            steps {
                echo "Deploying to ${params.ENVIRONMENT}"
```

---
# Security
Credentials → Credentials Store → withCredentials() → Temporary Access

Never:
Hardcode secrets  
Print secrets  

Least Privilege: 
Pipeline needs deploy access → Give Deploy access only  
Not Admin access

**RBAC**
Controls:
Pipeline modification

Deploy permissions:
- Who Can Deploy
- Who Can Change Pipelines
- Who Can View Credentials

Credential access

---
## Rollback Strategy
Immutable artifacts  
Previous image tag  
Helm rollback  
kubectl rollout undo  

---
## Troubleshooting
### Mental Model
Failure
↓
Which Bucket?

**Bucket:**    
Controller
Agent
Pipeline
External System

**Debug Order:**  
Logs
↓
Agent (Agent Offline)
↓
Conditions (Disk Full, OOM or Bad Credentials)
↓
External Dependencies (Git Down or ECR down)

**Classify first. Debug second.** 

---
### Q. Scaling Jenkins From: 5 Developers to 50 Developers  
Do:
Controller = Orchestration Only
Add More Agents  
Use Kubernetes Agents  
Use Parallel Stages  
Use Shared Libraries  
Use Multibranch Pipelines  

Avoid:
Heavy Controller  
Long Pipelines  
Manual Agent Management  

**Scale execution horizontally, not the controller vertically.**

---
# Common Failures
## Jenkins Slowdown Causes
Build history accumulation  
Logs accumulation    
Artifact accumulation  
Too many plugins  
Controller overload  

## Controller
UI slow   
Queues  
Scheduling issues  

## Agent
Offline  
Disk full  
OOM  
Docker missing  

## Pipeline
Wrong conditions  
Wrong variables  

## External
Git unavailable  
ECR unavailable  
Cloud API issue  

---
# Debug Order
Pipeline logs  
Agent status  
Conditions  
External dependencies  

---
# Production Deployment Failure
Stabilize  
Rollback if required  
Find failed stage  
Check logs  
Fix root cause  
Prevent recurrence  

---
# Jenkins Stability
Main causes:
Controller overload  
Plugin problems  
Resource exhaustion  
Poor pipeline design  

Monitor:
CPU  
Memory  
Disk  

---
## Backup & Recovery
Backup:  
JENKINS_HOME

Contains:
Jobs  
Credentials  
Plugins  
Build history  

If controller lost:

Restore JENKINS_HOME
Reconnect agents

---
# Interview Gold Lines
Controller orchestrates, agents execute.  
Executors control parallelism, not capacity.  
Isolation > Parallelism.  
Workspace stores files; controller stores state.  
CI proves code is deployable; CD delivers it safely.  
Build once, deploy many.  
PR pipelines validate; main pipelines deliver.  
Approval rights must be stricter than execution rights.  
Pipelines fail on agents more often than on Jenkins.  
Scale agents, not controller workload.
Stabilize → Debug → Prevent.  
Metrics first, logs second.  

---
