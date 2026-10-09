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
