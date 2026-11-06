## Q. When would you use StatefulSet instead of Deployment?
Answer: I would use StatefulSet for stateful applications such as MySQL, PostgreSQL, MongoDB, Kafka, or Elasticsearch where pods require:

Stable hostname (db-0, db-1)
Stable storage
Ordered startup and shutdown

Deployments are better for stateless applications where pods are interchangeable.


## Q. Why would you use a DaemonSet?
DaemonSets ensure one pod runs on every node.  
Common examples:

FluentBit / Fluentd (log collection)  
Datadog Agent  
Node Exporter  
Security agents  
CNI plugins  
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
Verify current utilization exceeds threshold

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
Kubelet stopped  
Network issue  
Disk pressure  
Memory pressure  
EC2 problem  
 
If necessary: `journalctl -ukubelet`  
A NotReady node usually indicates kubelet, networking, or resource pressure issues.

## Q. Pod stuck in ImagePullBackOff.
Check: ` kubectl describe pod `  
Common causes:  
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
Answer:
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

## suppose if you are installing/upgrading k8s deployment using helm and helm package not installed/failed, how do you troubleshoot?
If a Helm deployment fails, I first check the Helm release status using 1helm status <release-name>`. This tells me whether the release is in a failed, pending-install, or pending-upgrade state.  
Then I review the installation output using `helm install --dry-run --debug`. This helps identify YAML syntax errors, missing values, template rendering issues, or chart configuration problems.  
Next, I check Kubernetes events using `kubectl get events -n <namespace>` to look for scheduling failures, image pull errors, volume mount issues, or resource constraints.  
After that, I inspect the pods using `kubectl describe pod <pod-name> - n namespace` and review application logs with `kubectl logs <pod-name>`. This helps identify runtime issues such as application startup failures, missing ConfigMaps or Secrets, and connectivity problems.  
Finally, I validate the rendered manifests using helm template and verify that the cluster has sufficient CPU, memory, storage, and all required dependencies. Based on the findings, I fix the issue and redeploy the release.

---

