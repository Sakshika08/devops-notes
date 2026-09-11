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
  
# Key Terraform Concepts

**Terraform Block**  
The terraform block manages your Terraform settings, including provider versions and the version of Terraform itself.

## 1. Provider
Plugin used to interact with cloud platforms (AWS, Azure, GCP). Defines where Terraform creates resources.

Example:
```hcl
provider "aws" {
  region = "us-east-1"
}
```

**Provider Configuration Methods**
1. Root Module (most common)
2. Child Module
3. required_providers block (version control)

Example:
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.79"
    }
  }
}
```
## 2. Resource
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

## 3. Module
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

## 5. Variables
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

## 6. Terraform tfvars
**variables.tf** defines variables, while **terraform.tfvars** provides actual values for those variables during deployment.
```variable "instance_type" {}```

Apply with custom tfvars:
``` terraform apply -var-file=dev.tfvars ```

Advantages:
- Separation of code and configuration
- Environment-specific values
- Reusability
- Team collaboration

## 7. State File
File: ``` terraform.tfstate ```

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

## 8. Plan
Command: ``` terraform plan ```

Purpose:
Preview changes before deployment.  
Shows create/update/delete actions.

## 9. Apply
Command: ```terraform apply```
Purpose: Executes changes defined in the plan.

## 10. Workspace
Used to manage multiple environments.

Examples:
Dev
Test
Prod

Commands:
```
terraform workspace list
terraform workspace new dev
terraform workspace select dev
```

## 11. Remote Backend
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

## 12. Multi-Region Deployment
Use provider alias to deploy resources in multiple AWS regions.  
Define multiple providers with alias.  
Specify provider in resource using provider = aws.alias_name.  

Remember: Alias = Same cloud, different regions.

```
provider "aws" {
  alias = "east"
}

provider "aws" {
  alias = "west"
}
```

## 13. Conditional Expression
**Syntax:** ```condition ? true_value : false_value```

**Common Use:** ```count = var.create_instance ? 1 : 0```

Remember: Used to create/skip resources based on a condition.

Important Built-in Functions
| Function  | Purpose  |
|---------- |---------- |
| concat()  | Combine lists  |
| element() | Get item by index  |
| length()  | Count elements  |
| lookup()  | Get value from map  |
| join()    | Convert list to string  |

## 14. Provisioner 
Executes scripts/commands after resource creation (or before destruction).

###Types

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

**terraform import** brings an existing unmanaged resource into Terraform state for the first time, whereas   
**terraform plan/apply -refresh-only** synchronizes Terraform state with the current state of resources that are already being managed by Terraform.


