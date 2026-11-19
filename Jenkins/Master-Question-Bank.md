Scenario 1

Git commit was pushed but Jenkins build did not start.

What would you check?

Answer Flow

✅ Webhook configured?

✅ Webhook delivery status in GitHub

✅ Jenkins reachable from GitHub

✅ Correct repository URL

✅ Jenkins job trigger settings

✅ Jenkins logs

Scenario 2

Pipeline failed during Git checkout.

What would you check first?

Answer

✅ Repository URL

✅ Jenkins credentials

✅ Git token/SSH key validity

✅ Agent internet connectivity

✅ Branch name exists

Scenario 3

SonarQube stage failing.

What would you investigate?

Answer

✅ SonarQube server reachable

✅ Authentication token valid

✅ Sonar Scanner installed

✅ Port 9000 accessible

✅ Quality Gate status

Scenario 4

Docker build succeeds locally but fails in Jenkins.

Check

✅ Docker installed on agent

✅ Jenkins user in docker group

✅ Docker daemon running

✅ Disk space available

✅ Dockerfile path correct

Scenario 5

Docker image built successfully but push to ECR fails.

Check

✅ AWS credentials

✅ IAM permissions

✅ ECR login performed

✅ Repository exists

✅ Correct region

Common permission:

Shell
1
ecr:GetAuthorizationToken
2
ecr:PutImage
3
ecr:UploadLayerPart
Show more lines
Scenario 6

Image pushed to ECR successfully but deployment to EKS fails.

Check

✅ kubectl configured

✅ kubeconfig valid

✅ Cluster reachable

✅ IAM role permission

✅ Namespace exists

✅ Correct image tag

Scenario 7

Pods remain in ImagePullBackOff.

Check

✅ Image name correct

✅ Tag exists in ECR

✅ EKS node IAM role has ECR permissions

✅ Image repository accessible

Scenario 8

Deployment successful but application unavailable.

Check

✅ Pod status

✅ Pod logs

✅ Service configuration

✅ Endpoints populated

✅ Ingress/ALB health checks

✅ Application listening on expected port

Scenario 9

Jenkins build stuck in queue forever.

Check

✅ Available agents

✅ Agent offline?

✅ Executor count

✅ Node label mismatch

✅ Agent resource utilization

Scenario 10

After deployment users report errors. Need immediate recovery.

Answer
Shell
1
kubectl rollout undo deployment/myapp
Show more lines

Then investigate:
✅ New image changes
✅ Logs
✅ ConfigMap changes
✅ Secret modifications
✅ Recent commits

-------------

## 🔥 Q. CI/CD Pipeline Design. Explain Your Multi-Environment Setup (Dev/UAT/Prod).
In my projects, we typically maintain separate environments such as Development, UAT, and Production to ensure changes are properly tested before reaching end users.  
The pipeline starts when developers push code to Git. Jenkins triggers the build process, runs code quality checks, executes unit tests, builds a Docker image, and pushes it to a container registry such as Amazon ECR.
For deployment, environment-specific configurations are managed using Helm values files.
```text
values-dev.yaml
values-uat.yaml
values-prod.yaml
```
The application is usually deployed to the Development environment first, followed by UAT for business validation, and finally Production after approvals.  
Infrastructure for all environments is managed through Terraform to ensure consistency and repeatability.

## 🔥 Q. How Would You Optimize a Pipeline That Takes 25 Minutes to Complete?
I would first identify which stage consumes the most time before optimizing it.
I would review build logs and timing information to determine whether the delay comes from dependency installation, testing, Docker image builds, security scans, or deployment activities.
Common optimizations include enabling dependency caching, parallelizing independent stages, reducing unnecessary test execution, optimizing Docker layers, and reusing build artifacts between stages.
For example, SonarQube scanning, security scanning, and unit testing can often run in parallel instead of sequentially.
I would also review whether all pipeline stages are necessary for every build or whether some stages can be restricted to release branches.

## 🔥 Q. Jenkins Pipeline Failing Randomly. How Would You Debug It?
If a Jenkins pipeline fails intermittently, I would first try to identify whether the issue is related to Jenkins, the build agent, external dependencies, or the application itself.  
I would start by reviewing Jenkins console logs and build history to determine whether the failures occur at the same stage or at random points.  
Next, I would verify build agent health, available CPU, memory, disk space, network connectivity, and workspace issues.  
I would also review integrations such as Git repositories, artifact repositories, SonarQube, Docker registries, cloud services, and deployment targets to identify any temporary connectivity issues.  
If the issue cannot be reproduced consistently, I would compare successful and failed runs to identify environmental differences.

## 🔥 Q. Integrating SonarQube, Trivy, and Slack in Jenkins. Explain the Quality Flow.
In a typical CI/CD pipeline, code first goes through a quality and security validation process before deployment.
After the application is built, Jenkins triggers SonarQube analysis to evaluate code quality, code smells, bugs, security hotspots, and maintainability issues. If the SonarQube Quality Gate passes, the pipeline proceeds to build the Docker image.
Next, Trivy scans the container image for operating system vulnerabilities, package vulnerabilities, and misconfigurations. If critical vulnerabilities are detected, the deployment is blocked.  
Throughout the process, Jenkins sends build notifications, scan results, and deployment status updates to Slack so the team has real-time visibility.   
Only after all quality and security checks pass does the pipeline deploy the application.

## 🔥 Q. How Would You Implement DevOps Practices in a Project That Currently Has Manual Deployments?
If a project relies entirely on manual deployments, I would start by identifying repetitive activities that can be automated.
The first step would be introducing source control using Git and establishing a structured branching strategy.  
Next, I would build a CI/CD pipeline using Jenkins to automate builds, testing, security scanning, and deployments.  
Infrastructure would be managed using Terraform so environments can be created consistently and reproducibly.  
For application deployments, I would containerize applications using Docker and deploy them to Kubernetes using Helm.   
I would also introduce monitoring, logging, alerting, and automated rollback mechanisms to improve operational reliability.  
The migration would happen gradually to avoid disrupting existing delivery processes.  
