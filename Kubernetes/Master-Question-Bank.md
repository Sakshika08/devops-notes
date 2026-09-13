## 1.Q. When would you use StatefulSet instead of Deployment?

Answer: I would use StatefulSet for stateful applications such as MySQL, PostgreSQL, MongoDB, Kafka, or Elasticsearch where pods require:

Stable hostname (db-0, db-1)
Stable storage
Ordered startup and shutdown

Deployments are better for stateless applications where pods are interchangeable.


## Q. Why would you use a DaemonSet?

Answer: DaemonSets ensure one pod runs on every node.

Common examples:

FluentBit / Fluentd (log collection)
Datadog Agent
Node Exporter
Security agents
CNI plugins

If a new node is added, Kubernetes automatically schedules the DaemonSet pod.


## Q. HPA is configured but pods are not scaling. What will you check?

Answer:

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
