# eksctl
eksctl is a command-line tool that simplifies the creation and management of EKS clusters on AWS. Instead of manually creating all AWS resources, a single command can provision an entire Kubernetes cluster.

## Key Uses of eksctl
**Create EKS Clusters**  
eksctl create cluster --name my-cluster --region ap-south-1

**Delete EKS Clusters**  
eksctl delete cluster --name my-cluster

**Manage Node Groups**

Create node groups
Scale node groups
Delete node groups

**Create Fargate Profiles** Run pods without managing EC2 worker nodes

### Relationship with Other Tools
## Relationship with Other Tools

| Tool | Purpose |
|------|---------|
| `kubectl` | Manage Kubernetes resources such as Pods, Deployments, Services, ConfigMaps, and Secrets |
| `eksctl` | Create, manage, upgrade, and delete Amazon EKS clusters and node groups |
| `aws cli` | Manage AWS services and resources in general |
| `terraform` | Provision and manage AWS and EKS infrastructure using Infrastructure as Code (IaC) |

### Important Note
> [!IMPORTANT]
> `eksctl` is an AWS-specific CLI tool for provisioning and managing Amazon EKS clusters. Once the cluster is created, `kubectl` is used to deploy and manage Kubernetes workloads inside the cluster.
> **Note:** `eksctl` is used for managing Amazon EKS clusters, whereas `kubectl` is used for managing Kubernetes resources inside the cluster.
In real-world environments, `eksctl` is often used for quick cluster provisioning, while Terraform is preferred for production-grade Infrastructure as Code.

### Q: Can you create Kubernetes deployments using eksctl?
 No. eksctl manages the EKS infrastructure (cluster, node groups, Fargate profiles, IAM roles). Kubernetes resources such as Deployments, Services, ConfigMaps, and Ingresses are managed using kubectl.

# AWS EKS - Core Objects

An Amazon EKS cluster consists of multiple components that work together to run Kubernetes workloads on AWS.

## EKS Cluster

The EKS Cluster is the central Kubernetes environment managed by AWS. It includes the Kubernetes control plane and integrates with AWS services such as VPC, EC2, IAM, and Fargate.

## EKS Control Plane

- Contains Kubernetes master components.
- Includes:
  - `kube-apiserver`
  - `etcd`
  - `kube-controller-manager`
  - `kube-scheduler`
- Fully managed by AWS.
- Responsible for managing the overall state of the cluster.

## Worker Nodes & Node Groups

- A group of EC2 instances that run application workloads.
- Worker nodes join the EKS cluster and register with the control plane.
- Can be self-managed or AWS-managed node groups.
- Host Kubernetes components such as:
  - `kubelet`
  - `kube-proxy`
  - Container runtime

## Fargate Profiles (Serverless)

- Run Kubernetes pods without managing EC2 instances.
- AWS automatically provisions and manages compute resources.
- Ideal for serverless container workloads.
- Charges are based on consumed CPU and memory resources.

## VPC (Virtual Private Cloud)

- Provides networking for the EKS cluster.
- Enables secure communication between cluster components.
- Controls:
  - Subnets
  - Route Tables
  - Security Groups
  - Network ACLs
- Ensures production-grade network isolation and security.

## Component Overview

| Component         | Purpose |
|-------------------|---------|
| EKS Control Plane | Manages the Kubernetes cluster |
| Worker Nodes      | Run application workloads |
| Fargate Profiles  | Serverless execution of Kubernetes pods |
| VPC               | Provides networking and security |

> [!IMPORTANT]
> Every EKS cluster requires a Control Plane and VPC. Workloads can run either on EC2-based Worker Nodes, Fargate, or a combination of both.

### When would you choose EKS Fargate over Managed Node Groups?"
"I would choose Fargate when I want serverless Kubernetes without managing EC2 worker nodes, especially for smaller, variable, or operationally simple workloads. For large, predictable, always-running production applications, EKS Managed Node Groups are often preferred because they provide more control and can be more cost-effective."

The practical mindset is:  
Always-running production apps → Managed Nodes (often with Cluster Autoscaler/Karpenter)
Short-lived, unpredictable, or small workloads → Fargate
Cost optimization at scale → Managed Nodes generally win
Operational simplicity → Fargate wins

---

# EKS Cluster - Core Objects
## EKS Control Plane
The EKS Control Plane is the managed Kubernetes control layer provided by AWS.

### Key Points
1. Each EKS cluster has its own dedicated Kubernetes control plane.
2. Control plane infrastructure is **not shared** across clusters or AWS accounts.
3. The control plane consists of:
   - At least **2 API Server nodes**
   - At least **3 etcd nodes**
4. These components are distributed across **3 Availability Zones within an AWS Region** for high availability.
5. Amazon EKS automatically detects unhealthy control plane instances and replaces them when required.
6. AWS manages all control plane components, including:
   - `kube-apiserver`
   - `etcd`
   - `kube-controller-manager`
   - `kube-scheduler`

> [!NOTE]
> The EKS Control Plane runs in an AWS-managed environment and is highly available across multiple Availability Zones.

---

## Worker Nodes & Node Groups

Worker Nodes are EC2 instances that run Kubernetes workloads.

### Key Points

1. In Kubernetes, worker machines are called **Nodes**.
2. In EKS, nodes are typically EC2 instances running in your AWS account.
3. Worker nodes communicate with the EKS Control Plane through the cluster API endpoint.
4. Applications, Pods, and containers run on worker nodes.
5. A Node Group is a collection of worker nodes managed together.

### Node Group Characteristics

All instances within a node group:

- Use the same EC2 instance type
- Run the same Amazon Machine Image (AMI)
- Use the same EKS worker node IAM role
- Are typically managed by an Auto Scaling Group

---
## Fargate Profiles

AWS Fargate is a serverless compute engine for containers that allows you to run Kubernetes Pods without managing EC2 instances.

### Key Points

1. AWS Fargate provides on-demand, right-sized compute capacity for containers.
2. With Fargate, there is no need to provision, configure, or scale EC2 instances for running container workloads.
3. Each Pod running on Fargate has its own isolation boundary.
4. Fargate Pods do not share:
   - Kernel
   - CPU resources
   - Memory resources
   - Elastic Network Interfaces (ENIs)
5. AWS uses Fargate controllers to identify Pods matching a Fargate Profile and schedule them on Fargate infrastructure.

> [!NOTE]
> Fargate is ideal when you want to focus on applications rather than managing worker nodes.

---

## VPC (Virtual Private Cloud)
Amazon EKS uses Amazon VPC networking to provide secure communication and isolation for cluster resources.

### Key Points

1. EKS uses AWS VPC networking policies to restrict traffic within a cluster.
2. Control plane components communicate securely within the cluster's network boundaries.
3. Control plane components from one EKS cluster cannot communicate with or access another cluster unless explicitly authorized.
4. Cross-account and cross-cluster communication is restricted and controlled through AWS and Kubernetes security mechanisms.
5. The secure and highly available VPC architecture makes EKS suitable for production workloads.

### VPC Components Commonly Used in EKS

- VPC
- Public Subnets
- Private Subnets
- Route Tables
- Internet Gateway
- NAT Gateway
- Security Groups
- Network ACLs

> [!IMPORTANT]
> Every EKS cluster runs inside a VPC. The VPC provides networking, security, traffic isolation, and connectivity for worker nodes, Pods, and the EKS control plane.
