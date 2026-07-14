## Why Infrastructure as Code (IaC)?

**Before IaC:**
Manual server configuration
No version control
Documentation-driven processes
Limited automation
Slow provisioning
More human errors

**Benefits of IaC:**
Automation
Version control
Faster deployments
Consistency
Reduced errors
Key Terraform Concepts

## 1. Provider
Plugin used to interact with cloud platforms (AWS, Azure, GCP).
Defines where Terraform creates resources.

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
EC2 Instance
S3 Bucket
Azure VM
VPC
```hcl
resource "aws_instance" "web" {
  ami           = "ami-xxx"
  instance_type = "t2.micro"
}
```
## 3. Module
Reusable collection of Terraform code. Helps avoid duplication.
Benefits:
Reusability
Modularity
Maintainability
Consistency
Scalability
Versioning

Types:
Root Module
Child Module
Terraform Registry Modules

## 4. Configuration Files
Terraform files use .tf extension.
Common file names:
main.tf
variables.tf
outputs.tf
providers.tf

## 5. Variables
Input Variable: Used to receive values.
```hcl
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
```

Usage:
```hcl
instance_type = var.instance_type
```

Output Variable
Used to expose resource values.
```hcl
output "instance_id" {
  value = aws_instance.web.id
}
```
## 6. Terraform tfvars
**variables.tf** defines variables, while **terraform.tfvars** provides actual values for those variables during deployment.
```hcl
variable "instance_type" {}
```

Apply with custom tfvars:
```hcl
terraform apply -var-file=dev.tfvars
```

Advantages:
Separation of code and configuration
Environment-specific values
Reusability
Team collaboration

## 7. State File
File: ``` terraform.tfstate ```

Purpose:
Tracks current infrastructure state.
Terraform compares state file and code to determine changes.

**Why Important?**
Tracks created resources.
Stores resource IDs/metadata.
Required for terraform plan and terraform apply.

**Problems with Local State**
Sensitive data may be exposed.
Difficult collaboration.
No proper locking.

**Remote Backend** Stores state remotely.

**State Locking**
Prevents multiple users from modifying state simultaneously.
Implemented using DynamoDB.

**Production Standard**
S3 → State Storage
DynamoDB → State Locking

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
AWS S3
Azure Blob Storage
Terraform Cloud

Benefits:
Collaboration
State locking
Security
Backup
Multiple Providers

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
| Function | Purpose |
|----------|----------|
| concat() | Combine lists |
| element() | Get item by index |
| length() | Count elements |
| lookup() | Get value from map |
| join() | Convert list to string |
