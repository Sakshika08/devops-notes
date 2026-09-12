## Why Infrastructure as Code (IaC)?

**Before IaC:**
- Manual server configuration
- No version control
- Documentation-driven processes
- Limited automation
- Slow provisioning
- More human errors

**Benefits of IaC:**
- Automation
- Version control
- Faster deployments
- Consistency
- Reduced errors

Terraform is HashiCorp's Infrastructure as Code tool used to provision and manage infrastructure through declarative configuration files.
  
---
## Terraform Architecture

Terraform architecture as 4 main components:  
```
Developer
    |
Terraform Configuration (.tf files)
    |
Terraform Core
    |
Provider Plugins (AWS, Azure, GCP, Kubernetes)
    |
Target Infrastructure Resources
```
erraform Core Responsibilities
Reads Terraform code
Creates execution plan
Maintains state
Resolves dependencies
Communicates with providers

Terraform Core does not directly create resources.

---
## Terraform Workflow
```
Write Code
    |
terraform init
    |
Download Providers
    |
terraform plan
    |
Show Changes
    |
terraform apply
    |
Create Resources
    |
Update State File
```
terraform init
Downloads providers
Installs plugins
Initializes backend
Creates .terraform directory
Creates .terraform.lock.hcl

---

## Terraform Graph
Terraform builds a dependency graph before execution and determines the correct creation and destruction order.
Example:
```
VPC
 ↓
Subnet
 ↓
EC2
```
---

## Provider
Plugin used to interact with cloud platforms (AWS, Azure, GCP). Defines where Terraform creates resources.

Example:
```hcl
provider "aws" {
  region = "us-east-1"
}
```

### Provider Configuration Methods
- Root Module (Most Common)
- Child Module Provider Passing
- required_providers Block

### Multi Region Deployment
Use provider alias to deploy resources in multiple AWS regions.  
Define multiple providers with alias.  
Specify provider in resource using provider = aws.alias_name.  

```
provider "aws" {
  alias = "east"
}

provider "aws" {
  alias = "west"
}
```
Remember: Alias = Same Cloud + Different Region

---
### Provider Authentication

Production Best Practice:
- IAM Roles
- Temporary Credentials
- No hardcoded keys

Avoid:  
AWS_ACCESS_KEY_ID  
AWS_SECRET_ACCESS_KEY

---

## Terraform Block
Used to configure Terraform itself.  
Responsibilities:  
- Terraform version
- Provider versions
- Backend configuration

Example:
```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```
**~> Operator:** Allows compatible updates while preventing breaking version upgrades.

---
## Resource
Actual infrastructure component managed by Terraform.
Examples:
- EC2 Instance
- S3 Bucket
- Azure (VM, VNET)
- VPC
  
```hcl
resource "aws_instance" "web" {
  ami           = "ami-xxx"
  instance_type = "t2.micro"
}
```
---
## Data Sources
Used to read existing infrastructure without creating it.  
Example: ` data "aws_ami" "ubuntu" {} `

Common Uses:
- Latest AMI lookup
- Existing VPC lookup
- Existing Subnet lookup

Memory Trick:
Data Source = Read Existing Resource
Resource = Create/Manage Resource

---

## Module
Reusable collection of Terraform code. Helps avoid duplication.  
Benefits:
- Reusability
- Modularity
- Maintainability
- Consistency
- Scalability
- Versioning

Types:
- Root Module = Main Terraform configuration being executed.
- Child Module = Reusable module called from another module.
- Terraform Registry Modules

Input = Variable passed into a module.  
Output = Value returned from a module.  
Source = Location of module (local path, Git, Registry).  

Modules = Reusability + Standardization + Less Duplication

---

## 4. Configuration Files
Terraform files use .tf extension.
Common file names:
main.tf  
variables.tf  
outputs.tf  
providers.tf  

## Variables
**Input Variable:** Used to receive values.
```hcl
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
```

Usage: ```instance_type = var.instance_type```

**Output Variable**: Used to expose resource values.
```hcl
output "instance_id" {
  value = aws_instance.web.id
}
```

**Terraform Environment Variables** 
Use TF_VAR_<variable_name> to pass variable values from the shell or CI/CD pipeline without storing them in Terraform code. Commonly used for environment-specific values and secrets.  

Environment variables are used to externalize application configuration such as URLs, ports, credentials, and environment-specific settings, avoiding hardcoding and improving portability across environments.

---

## Terraform tfvars
**variables.tf** defines variables, while **terraform.tfvars** provides actual values for those variables during deployment.
```variable "instance_type" {}```

Apply with custom tfvars:
``` terraform apply -var-file=dev.tfvars ```

Advantages:
- Separation of code and configuration
- Environment-specific values
- Reusability
- Team collaboration

---
## Sensitive Variables (sensitive = true)
Purpose: Used to prevent sensitive values from being displayed in Terraform output, plan, and logs.
```
variable "db_password" {
  type      = string
  sensitive = true
}
```

sensitive = true hides secrets from Terraform output and logs, but secrets should still be stored in a dedicated secret management solution and the Terraform state must be secured.

---

## State File
File: ``` terraform.tfstate ```

Terraform compares:  
` Desired State (.tf files) ` VS ` Current State (terraform.tfstate) `
and generates an execution plan.

Purpose:
- Tracks current infrastructure state.  
- Maps Terraform resources to real-world resources.
- Terraform compares the state file with the configuration code to determine what needs to be created, updated, or destroyed.


**Why Important?**
- Tracks created resources.
- Stores resource IDs/metadata.
- Required for terraform plan and terraform apply.

**Problems with Local State**
- Sensitive data may be exposed.
- Difficult collaboration.
- No proper locking.

**Remote Backend** Stores state remotely.

**State Locking**
Prevents multiple users from modifying state simultaneously.
Implemented using DynamoDB.

**Production Standard**
- S3 → State Storage
- DynamoDB → State Locking

## Plan
Command: ``` terraform plan ```

Purpose:
Preview changes before deployment.  
Shows create/update/delete actions.

## Apply
Command: ```terraform apply```
Purpose: Executes changes defined in the plan.

## Workspace

Used to manage multiple environments with separate state files.

Example:
dev
test
prod

Same Terraform code
Different state file per workspace

Common Commands:
terraform workspace list
terraform workspace new dev
terraform workspace select dev

---

## Remote Backend
Stores state remotely instead of locally.

Examples:
- AWS S3
- Azure Blob Storage
- Terraform Cloud

Benefits:
- Collaboration
- State locking
- Security
- Backup
- Multiple Providers

---

## Conditional Expression
**Syntax:** ```condition ? true_value : false_value```

**Common Use:** ```count = var.create_instance ? 1 : 0```

Remember: Used to create/skip resources based on a condition.

Important Built-in Functions
| Function  | Purpose  |
|---------- |---------- |
| merge()   | Combines multiple maps into one  |
| split()   | Splits a string into a list.  |
| length()  | Count elements  |
| lookup()  | Get value from map  |
| join()    | Convert list to string  |

---

## Provisioner 
Executes scripts/commands after resource creation (or before destruction).

### Types

**local-exec**
Runs on Terraform machine.

Example: Run shell command, create log file.
```
  provisioner "local-exec" {
    command = "echo Instance Created"
  }
```

**remote-exec**
Runs on target server (EC2/VM).

Example: Install packages, configure server.
```
provisioner "remote-exec" {
  inline = [
    "sudo yum update -y",
    "sudo yum install nginx -y"
  ]
}
```

**file**
Copies files from local machine to remote server.
```
provisioner "file" {
  source      = "app.conf"
  destination = "/tmp/app.conf"
}
```

**Quick Memory Trick**
LRF
- Local-exec → Local machine
- Remote-exec → Remote server
- File → File transfer

---
## Terraform Import
- Used for unmanaged resources
- Brings existing resource into state
- Does not create resource
- Existing EC2 instance

- Common command: `terraform import`

**Import Workflow:**
1. Create import block
2. Generate configuration
3. Review generated code
4. Run terraform import
5. Verify with terraform plan

## Terraform Refresh-Only
- Detects infrastructure drift
- Updates state only
- Does not change infrastructure
- 
- Commands:
  terraform plan -refresh-only
  terraform apply -refresh-only

Terraform drift occurs when the actual infrastructure differs from the Terraform state or configuration due to manual changes outside Terraform. To detect it, I run terraform plan or terraform apply -refresh-only. If the manual change is valid, I update the Terraform code to match the resource. If the change is unauthorized, I run terraform apply straight after terraform apply -refresh-only command to bring the infrastructure back to the desired state defined in code.

## One-Line Interview Answer

**terraform import** brings an existing unmanaged resource into Terraform state for the first time  
**Drift** = Existing managed resource changed outside Terraform  
**terraform plan/apply -refresh-only** synchronizes Terraform state with the current state of resources that are already being managed by Terraform.

---
## Lifecycle Meta-Arguments
Used to control resource creation, update, and deletion behavior.

### create_before_destroy
Creates new resource first, then deletes old resource.

### prevent_destroy
Prevents accidental deletion of critical resources.

### ignore_changes
Terraform ignores changes to selected attributes.

### replace_triggered_by
Recreates resource when another resource changes.

---
## Terraform Dependency Management
Implicit Dependency = Terraform detects automatically through resource references.   
Explicit Dependency = Manually defined using depends_on.    
depends_on = Used only when Terraform cannot infer the dependency.   
Best Practice = Prefer implicit dependency over explicit dependency.   

---
## count vs for_each
### count
- Uses numeric index
- Best for identical resources
- Uses count.index

### for_each
- Uses keys
- Best for unique resources
- Uses each.key and each.value

Preferred:
for_each because resource tracking is more stable.

---
## locals
Reusable internal values  
Accessed using local.<name>  
Commonly used for tags, naming standards, and repeated values  

These three topics are asked very frequently in Terraform interviews.

---

## Dynamic Blocks

Dynamic blocks are used to generate repeated nested blocks dynamically instead of writing the same configuration multiple times.

**Common Uses:**
- Security Group Rules (Ingress/Egress)
- Load Balancer Rules
- Route Tables
- IAM Policy Statements
- Any repeated nested block

**Syntax:**
```hcl
dynamic "<block_name>" {
  for_each = <collection>

  content {
    ...
  }
}
```

Dynamic Block Loop for nested blocks inside a resource.
for_each = Loop for creating multiple resources.

---

## Taint / Untaint (Deprecated)

terraform taint aws_instance.web  - Marks resource for recreation on next apply. 

terraform untaint aws_instance.web - Removes taint mark.

Deprecated since Terraform v0.15.2.

Modern replacement: terraform apply -replace="aws_instance.web"  



