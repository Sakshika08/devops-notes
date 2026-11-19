## 🔥 Q. Explain the complete request flow from a browser to a Kubernetes pod.
When a user enters a URL in the browser, the browser first performs DNS resolution to obtain the IP address of the application. The request then reaches the Load Balancer, which forwards the request to the Kubernetes Ingress Controller.
The Ingress Controller evaluates the host and path rules defined in the Ingress resource and routes the request to the appropriate Kubernetes Service. The Service then forwards the request to one of the healthy backend Pods based on its label selectors.  
The application running inside the Pod processes the request and sends the response back through the same path to the user.

## 🔥 Q. How does Kubernetes Service Discovery work?
Kubernetes Service Discovery allows applications to communicate without knowing Pod IP addresses.
When a Service is created, Kubernetes automatically creates a DNS entry through CoreDNS. Applications can use the Service name instead of hardcoded IP addresses.
For example, if a Service named `backend-service` exists, frontend applications can access it using: http://backend-service

## 🔥 Q. Explain ConfigMaps and Secrets. How do you manage them across environments?
ConfigMaps and Secrets are used to separate configuration from application code.
ConfigMaps store non-sensitive configuration such as API URLs, feature flags, and application settings.  
Secrets store sensitive data such as passwords, API keys, and database credentials.  
Across environments like Dev, UAT, and Production, I typically maintain separate ConfigMaps and Secrets for each environment while using the same application image.  
When deploying with Helm, environment-specific values are usually managed through separate values files such as:
```text
values-dev.yaml
values-uat.yaml
values-prod.yaml
```

## 🔥 Q. What is CNI (Container Network Interface)? Which CNI plugin have you used, and how did you implement it?
CNI is the networking layer responsible for providing network connectivity between Pods and external networks.  
In Amazon EKS, I have worked with AWS VPC CNI. It assigns VPC IP addresses directly to Pods, allowing Pods to communicate within the VPC without additional overlay networking.  
Implementation is usually handled automatically during EKS cluster creation, but I verify that the AWS VPC CNI plugin is healthy and correctly configured.  
Other commonly used CNI plugins include Calico, Flannel, and Cilium.

## 🔥 Q. How do you implement RBAC in Kubernetes?
RBAC is used to control what actions users or services can perform within a Kubernetes cluster.  
I usually create Roles or ClusterRoles to define permissions and then bind them to users, groups, or Service Accounts using RoleBindings or ClusterRoleBindings.  
For example, a developer may be allowed to view Pods and logs but not delete resources.
This follows the principle of least privilege and prevents unnecessary access to critical resources.

## 🔥 Q. Two applications (frontend/backend) are running in different Pods. How would you ensure the frontend starts only after the backend becomes available?
Instead of relying on startup order, I would make the frontend check whether the backend service is available before becoming ready.  
The preferred approach is to use Kubernetes Readiness Probes so that traffic is sent only after the backend is healthy.  
If startup dependency is mandatory, I can also use an Init Container that continuously checks backend availability before starting the frontend application.

## 🔥 Q. We mostly follow Blue-Green deployment. How do you divert traffic from Blue to Green?
In Blue-Green deployments, both environments run simultaneously.  
Initially, the Service routes traffic to the Blue environment. After validating the Green environment, I update the Service selector or Load Balancer target configuration to point to Green.  
Once verification is complete, all production traffic is routed to Green while Blue remains available for rollback if needed.


## 🔥 Q. Centralized monitoring for multi-cluster Kubernetes. What toolchain would you use?
For multi-cluster monitoring, I would use Prometheus for metrics collection, Grafana for visualization, and Alertmanager for alerting.  
Logs can be centralized using Fluent Bit or Fluentd and stored in Elasticsearch, OpenSearch, or Loki.
For tracing, I would use Jaeger or OpenTelemetry.
This provides centralized visibility into cluster health, workloads, logs, and application performance across multiple environments.  

---

## 🔥 Q. You have three nodes, and one node is not receiving traffic. How would you troubleshoot it?
If one node is not receiving traffic, I first check whether application Pods are actually scheduled on that node.  
Then I verify node health, readiness status, taints, labels, and resource availability.  
I also check Service endpoints to ensure Pods running on that node are included, and verify Ingress and Load Balancer configurations.  
If the node has networking issues, I investigate kube-proxy, CNI plugin status, routing rules, and security group configurations.

## 🔥 Q. Suppose there are two Pods running in different namespaces. What DNS name would you use so that one Pod can communicate with the other?
If the Pods communicate through a Service, I would use the fully qualified Kubernetes DNS name:   
` <service-name>.<namespace>.svc.cluster.local `  
Example: ` backend-service.dev.svc.cluster.local `  
This allows applications in any namespace to communicate without relying on Pod IP addresses.

## 🔥 Q. How do you secure container images before deployment?
Before deploying container images, I perform vulnerability scanning using tools such as Trivy.
I also use minimal base images such as Alpine or Distroless images, avoid running containers as root, and remove unnecessary packages. Images are stored in trusted registries such as Amazon ECR with image scanning enabled.
In CI/CD pipelines, image scans are integrated before deployment, and critical vulnerabilities block the release.

---
## 🔥 Q. How do you manage secrets in production?
In production, I avoid storing secrets directly in code, Git repositories, or configuration files.  
I use AWS Secrets Manager, Applications retrieve secrets securely at runtime, and access is controlled through IAM roles and RBAC policies.  
Secrets are rotated regularly, audited, and encrypted both at rest and in transit.

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
Before upgrading an EKS cluster, I first review the Kubernetes and EKS release notes for any breaking changes and use EKS Upgrade Insights to evaluate the cluster's upgrade readiness. 
Then I verify version compatibility between the control plane, worker nodes, kubelet, Cluster Autoscaler, Helm charts, and monitoring tools such as Prometheus. I also test the upgrade in a lower environment for 1-2 weeks because Kubernetes upgrades cannot be rolled back.   
Once the prerequisites are validated, I upgrade the EKS control plane using aws eks update-cluster-version. The control plane upgrade is managed by AWS and does not impact running workloads.  
After the control plane upgrade is complete, I upgrade the managed node groups using aws eks update-nodegroup-version. EKS performs a rolling replacement of worker nodes, safely drains workloads, reschedules pods onto new nodes, and terminates the old nodes.   
During the upgrade, if required, I can cordon specific nodes for controlled workload movement andcontinuously monitor node status, pod health, and application availability.
Finally, I validate the upgrade by checking node versions and workload health ensuring all applications are running successfully on the upgraded cluster.

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
## 🔥 Q. During peak traffic, if the Ingress Controller fails to route requests efficiently, how would you diagnose and scale it?
If the Ingress Controller starts struggling during peak traffic, I would first determine whether the issue is related to the controller itself, backend services, or infrastructure resources.  
I would start by checking the Ingress Controller pods, logs, and resource utilization to see if CPU or memory exhaustion is causing request delays or dropped connections.  
Next, I would review Ingress Controller metrics such as request count, response latency, error rates, and pod restarts. I would also verify that the backend services and application pods are healthy and able to handle incoming traffic.  
If the controller pods are reaching resource limits, I would increase CPU and memory allocations or scale the Ingress Controller horizontally by increasing the replica count. In production environments, I would typically configure an HPA (Horizontal Pod Autoscaler) so that the controller scales automatically based on load.  
I would also review the Ingress configuration for inefficient routing rules, rate limiting policies, SSL termination overhead, or any misconfigurations that might affect performance during high traffic.  
Finally, I would monitor the system after scaling to ensure that request latency, throughput, and error rates return to acceptable levels.

---


