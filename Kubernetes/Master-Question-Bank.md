## Q. When would you use StatefulSet instead of Deployment?
I would use StatefulSet for stateful applications such as MySQL, PostgreSQL, MongoDB, Kafka, or Elasticsearch where pods require:
- Stable hostname (db-0, db-1)
- Stable storage
- Ordered startup and shutdown
Deployments are better for stateless applications where pods are interchangeable.

## Q. Why would you use a DaemonSet?
DaemonSets ensure one pod runs on every node.  
Common examples:
- FluentBit / Fluentd (log collection)  
- Datadog Agent  
- Node Exporter  
- Security agents  
- CNI plugins  
If a new node is added, Kubernetes automatically schedules the DaemonSet pod.

## Q. HPA is configured but pods are not scaling. What will you check?
Check HPA status: `kubectl get hpa`   
Verify metrix server:  kubectl top pods  
Confirm cpu/memory request exists:  
```
resources:
  requests:
    cpu: 100m
```
Verify current utilization exceeds threshold.  
HPA depends on Metrics Server and resource requests. Without them scaling won't happen.  

## Q. Pods are healthy but cannot communicate. What could be wrong?  
Check: `kubectle get network policy `  
Possible reasons:  
Ingress denied  
Egress denied  
Namespace restrictions    
Incorrect pod labels  
If connectivity suddenly breaks while pods and services look healthy, I would check NetworkPolicies first.

## Q. Node becomes NotReady. What do you do?
Check: `kubectl get nodes` and `kubetl describe node <node-name>`  
Investigate:  
- Kubelet stopped  
- Network issue  
- Disk pressure  
- Memory pressure  
- EC2 problem  
If necessary: `journalctl -ukubelet`  
A NotReady node usually indicates kubelet, networking, or resource pressure issues.

## Q. Pod stuck in ImagePullBackOff.
Check: ` kubectl describe pod `  
Check Common causes visible in event section:  
Wrong image name  
Wrong tag  
Registry unavailable  
Authentication issue  
Missing imagePullSecret  
ImagePullBackOff means Kubernetes cannot pull the container image.

## 7. ErrImagePull vs ImagePullBackOff
ErrImagePull: Initial image pull failure  
ImagePullBackOff: Kubernetes retries with backoff  
ErrImagePull occurs first; repeated failures transition to ImagePullBackOff. 

## Q. PVC remains Pending.
Check: `kubectl describe pvc `  
Possible causes:  
No matching StorageClass  
No PV available  
Provisioner issue  
Wrong access mode  

## Q. Difference between OOMKilled and Evicted?
OOMKilled: Container exceeded memory limit  
Evicted:  
- Node under pressure
- Node memory exhausted
- Disk pressure

## Q. How do you force workloads onto specific nodes?
Options: 
- NodeSelector
- NodeAffinity
- Taints/Tolerations

## Q. A node suddenly crashes. What happens?
Node stops reporting to control plane.  
Node marked NotReady.  
Pods on that node become unavailable.  
Deployment/ReplicaSet detects missing replicas.  
Scheduler places replacement pods on healthy nodes.  
Service starts routing to new healthy pods.  
Kubernetes provides self-healing by recreating lost pods on healthy nodes when a node fails.

## How do you find which deployment is using a specific env varible in k8s?
command: 
If you know the env var name, find all deployments using it: ` kubectl get deploy -A -o yaml | grep -B5 -A5 "ENV_VAR_NAME" ' 

If the env var comes from a ConfigMap or Secret:  
` kubectl get deploy -A -o yaml | grep my-configmap `   
` kubectl get deploy -A -o yaml | grep my-secret ` 
 
To check a specific deployment: ` kubectl describe deployment <deployment-name> -n <namespace> | grep -A5 -B5 ENV_VAR_NAME `

## How do you perform node maintaince in k8s?
During node maintenance, I first cordon the node to prevent new pod scheduling. Then I drain the node using kubectl drain --ignore-daemonsets, which safely evicts workloads and reschedules them on other nodes. After performing the required maintenance such as patching or rebooting, I verify the node is back in the Ready state and finally uncordon it so Kubernetes can schedule workloads on it again.  
Commands:  
```
kubectl cordon <node>                                             →   node-1   Ready,SchedulingDisabled
kubectl drain <node> --ignore-daemonsets --delete-emptydir-data  --force
kubectl uncordon <node>  
```
- ignore-daemonsets → DaemonSet pods remain running.
- delete-emptydir-data → allows pods using emptyDir volumes to be evicted.
- force → required for some unmanaged pods.

## How to upgrade Kubernates cluster in prod:
Before upgrading an EKS cluster, I first review the Kubernetes and EKS release notes for any breaking changes and use EKS Upgrade Insights to evaluate the cluster's upgrade readiness. I also test the upgrade in a lower environment for 1-2 weeks because Kubernetes upgrades cannot be rolled back. Additionally, I verify version compatibility between the control plane, worker nodes, kubelet, Cluster Autoscaler, Helm charts, and monitoring tools such as Prometheus.  
Once the prerequisites are validated, I upgrade the EKS control plane using aws eks update-cluster-version. The control plane upgrade is managed by AWS and does not impact running workloads.  
After the control plane upgrade is complete, I upgrade the managed node groups using aws eks update-nodegroup-version. EKS performs a rolling replacement of worker nodes, safely drains workloads, reschedules pods onto new nodes, and terminates the old nodes.   
During the upgrade, if required, I can cordon specific nodes for controlled workload movement and closely monitor application health.  
Finally, I validate the upgrade by checking node versions and workload health using kubectl get nodes and kubectl get pods -A, ensuring all applications are running successfully on the upgraded cluster.

1. Upgrade the EKS Control Plane
`aws eks update-cluster-version --name <cluster-name> --kubernetes-version 1.31 `
Monitor:  `aws eks describe-update --name <cluster-name> --update-id <update-id>`

3. Upgrade Managed Node Groups: EKS automatically, launches new nodes with the target version, Drains old nodes, Moves workloads and Terminates old nodes
   `aws eks update-nodegroup-version --cluster-name <cluster-name>  --nodegroup-name <nodegroup-name>`
5. Verify
```
kubectl get nodes
kubectl get pods -A
kubectl get nodes -o wide
```
Best Practice (Important) → Always upgrade step-by-step (N → N+1)

---
# HELM
---
## suppose if you are installing/upgrading k8s deployment using helm and helm package not installed/failed, how do you troubleshoot?
If a Helm deployment fails, I first check the Helm release status using 1helm status <release-name>`. This tells me whether the release is in a failed, pending-install, or pending-upgrade state.  
Then I review the installation output using `helm install --dry-run --debug`. This helps identify YAML syntax errors, missing values, template rendering issues, or chart configuration problems.  
Next, I check Kubernetes events using `kubectl get events -n <namespace>` to look for scheduling failures, image pull errors, volume mount issues, or resource constraints.  
After that, I inspect the pods using `kubectl describe pod <pod-name> - n namespace` and review application logs with `kubectl logs <pod-name>`. This helps identify runtime issues such as application startup failures, missing ConfigMaps or Secrets, and connectivity problems.  
Finally, I validate the rendered manifests using helm template and verify that the cluster has sufficient CPU, memory, storage, and all required dependencies. Based on the findings, I fix the issue and redeploy the release.

---

## 🔥 Q. How do you check what values are currently used by a Helm release?
` helm get values <release-name> `  
To see all values including defaults: ` helm get values <release-name> --all `  
This helps verify whether the expected configuration was deployed.

---
## 🔥 Q. How do you see the Kubernetes manifests generated by a Helm release?
` helm get manifest <release-name> `
Useful for:
- Verifying rendered resources
- Troubleshooting templates
- Checking actual deployed configuration

---
## 🔥 Q. How do you verify what changed between two Helm upgrades?
` helm history <release-name> `
Review revision history and compare changes.
In many environments, we also use: ` helm diff upgrade `
before upgrading to preview changes.

**Strong Line:**
Before upgrading, I prefer using `helm diff` to understand exactly what resources will change.

---
## 🔥 Q. What is `helm lint` and when do you use it?
` helm lint <chart> `
Used before deployment to validate:
- YAML syntax
- Template issues
- Chart structure
- Missing values
- Common chart mistakes

It helps catch chart-level issues before deployment.

---
## 🔥 Q. How do you uninstall a Helm release?
` helm uninstall <release-name> `
Verify removal:
```bash
helm list
kubectl get all
```
This removes Kubernetes resources managed by that Helm release.

---

## 🔥 Q. Difference between `helm template` and `helm install`?
### helm template
` helm template my-app . `
- Renders Kubernetes manifests locally
- Does not connect to Kubernetes
- Does not deploy resources

### helm install
` helm install my-app . `  
- Renders templates
- Creates resources in the cluster
- Creates a Helm release

**One-Liner:**
`helm template` generates manifests, while `helm install` generates and deploys them.

---
## 🔥 Q. What is the difference between a Helm Chart and a Helm Release?
### Helm Chart
A chart is a package containing Kubernetes templates and configuration.
Example: nginx-chart

### Helm Release
A release is a deployed instance of a chart.  
Example:
dev-nginx  
prod-nginx  
One chart can be installed multiple times, creating multiple releases.

**One-Liner:**
A Chart is the blueprint, and a Release is the running instance of that chart.

---
## 🔥 Q. What is `Chart.yaml`?
`Chart.yaml` contains metadata about the Helm chart.  
Example:
```yaml
apiVersion: v2
name: my-app
version: 1.0.0
appVersion: 2.0
```
---
## 🔥 Q. How do you pass values during Helm deployment?
Using a values file: ` helm install my-app . -f values.yaml `
Or directly from CLI:  
```bash
helm install my-app . \
  --set image.tag=v2
```
Useful for environment-specific configuration.

---
## 🔥 Q. Multiple environments (Dev/UAT/Prod) use the same chart. How do you manage it?
Use separate values files:
```text
values-dev.yaml
values-uat.yaml
values-prod.yaml
```
Deploy: `helm install my-app . -f values-prod.yaml `  
This allows reuse of the same chart while maintaining environment-specific configurations.

---
## 🔥 Q. What are Helm Hooks?
Helm Hooks allow execution of tasks before or after lifecycle events.

Common use cases:
- Database migrations
- Backups
- Validation jobs
- Cleanup tasks

Common hooks:
```yaml
pre-install
post-install
pre-upgrade
post-upgrade
pre-delete
post-delete
```
---
## 🔥 Q. Deployment gets stuck during Helm upgrade. What will you check first?
Check release status:

```bash
helm status <release>
```

Then inspect Kubernetes resources:

```bash
kubectl get pods
kubectl describe pod <pod>
kubectl logs <pod>
```

Most common causes:

- Readiness probe failures
- CrashLoopBackOff
- ImagePullBackOff
- Pending pods
- Insufficient resources

**Golden Line:**

A Helm upgrade is usually stuck because Kubernetes resources are not becoming Ready.

---

## 🔥 Q. Image updated in values.yaml but old image is still running. Why?



First verify upgrade history:

```bash
helm history <release>
```

Then check deployed image:

```bash
kubectl describe pod <pod>
```

Verify:

- Correct image tag
- imagePullPolicy
- Rollout status
- New pods creation

Most common causes:

- Upgrade was not executed
- Same tag reused (latest)
- Cached image used
- Rollout not triggered

**Best Practice:**

Avoid using:

```yaml
image: myapp:latest
```

Prefer:

```yaml
image: myapp:v1.2.0
```

---

## 🔥 Q. How do you list all Helm releases in a cluster?



```bash
helm list -A
```

This displays releases across all namespaces.

Useful for:

- Release discovery
- Troubleshooting
- Audits

---

## 🔥 Q. Helm install fails. How do you troubleshoot?



Check release status:

```bash
helm status <release-name>
```

Validate chart:

```bash
helm lint .
```

Render manifests:

```bash
helm template .
```

Run dry-run:

```bash
helm install my-app . --dry-run --debug
```

Common causes:

- YAML syntax errors
- Missing values
- Invalid templates
- Kubernetes API incompatibility

**Strong Closing Line:**

I start with `helm lint` and `--dry-run --debug` to isolate chart-level issues before investigating cluster-side problems.

---

## 🔥 Q. Helm upgrade failed in production. How would you troubleshoot?



Check release status:

```bash
helm status <release>
```

Review release history:

```bash
helm history <release>
```

Inspect Kubernetes resources:

```bash
kubectl get pods
kubectl describe pod <pod>
kubectl logs <pod>
```

Verify:

- Invalid values.yaml
- Wrong image version
- Probe failures
- Missing Secret/ConfigMap
- Resource constraints

If service impact is high:

```bash
helm rollback <release> <revision>
```

**Strong Closing Line:**

I first determine whether the issue is chart-related, Kubernetes-related, or application-related, and perform rollback if business impact is significant.

---

## 🔥 Q. Release is showing `pending-upgrade`. What will you do?
Check release status:

```bash
helm status <release>
```

Check release history:

```bash
helm history <release>
```

Inspect deployment rollout:

```bash
kubectl rollout status deployment/<deployment-name>
```

Common causes:

- Interrupted upgrade
- Timeout
- New pods failing readiness checks
- CrashLoopBackOff
- Resource shortage

Rollback if necessary:

```bash
helm rollback <release> <revision>
```

---

## 🔥 Q. Values.yaml changed but application still uses old configuration. Why?
Verify deployed values:

```bash
helm get values <release>
```

Check release history:

```bash
helm history <release>
```

Inspect deployment:

```bash
kubectl describe deployment <deployment-name>
```

Verify:

- Upgrade was executed
- Correct values file used
- ConfigMap mounted correctly
- Application reloads config

If required:

```bash
kubectl rollout restart deployment <deployment-name>
```

Common causes:

- Upgrade not executed
- Wrong values file
- ConfigMap changes not picked up

---

## 🔥 Q. How do you upgrade an existing Helm release?
Review changes:

```bash
helm diff upgrade
```

Perform upgrade:

```bash
helm upgrade <release-name> <chart> -f values.yaml
```

Validate:

```bash
helm status <release-name>
kubectl rollout status deployment/<deployment-name>
```

Monitor:

- Pods
- Application logs
- Metrics
- Health checks

Rollback if required.

---

## 🔥 Q. What if Helm rollback also fails?

Check release history:

```bash
helm history <release>
```

Investigate:

- Previous image deleted from registry
- Database schema incompatibility
- Missing Secrets
- Invalid configuration

Possible actions:

- Redeploy last stable image
- Restore missing configuration
- Recover dependencies
- Coordinate with application team

**Senior-Level Point:**

Helm rollback restores Kubernetes resources, but it does not automatically revert database schema changes.

---

## 🔥 Q. How do you troubleshoot a Helm chart before deployment?
Validate chart:

```bash
helm lint .
```

Render manifests:

```bash
helm template .
```

Perform dry run:

```bash
helm install my-app . \
--dry-run \
--debug
```

Verify:

- Manifests
- Image tags
- Resource settings
- ConfigMaps
- Secret references
- Environment variables

**One-Liner:**

I always lint, template, and perform a dry run before deploying a chart to production.

---

## 🔥 Q. What is `--atomic` in Helm?
```bash
helm upgrade --install my-app chart/ --atomic
```

Behavior:
- Upgrade starts
- Deployment validation happens
- If deployment fails, Helm automatically rolls back
- Previous working revision gets restored

**Interview One-Liner:**

The `--atomic` flag makes deployments safer because Helm automatically rolls back failed upgrades.

---
## 🔥 Q. Helm status shows deployed, but no pods exist. What would you check?
Inspect rendered resources:

```bash
helm get manifest <release>
```

Check resources:

```bash
kubectl get all
```

Verify:

- Deployment exists
- Replica count
- Namespace
- Selectors
- Template conditions

Common causes:

- Wrong values
- Disabled templates
- Namespace mismatch
- Replica count set to zero

**Strong Closing Line:**

If Helm shows deployed but no pods exist, I verify whether the chart actually created a Deployment and whether replicas were successfully scheduled.

