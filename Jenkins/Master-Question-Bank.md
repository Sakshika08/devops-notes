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
