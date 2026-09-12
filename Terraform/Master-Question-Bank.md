## Terraform Fundamentals

### 1. Q. What is Terraform?
Terraform is an Infrastructure as Code (IaC) tool developed by HashiCorp that is used to provision, manage, and automate infrastructure using configuration files. It allows infrastructure to be defined in code and deployed consistently across cloud platforms such as AWS, Azure, and GCP.

### 2. Q. What is Infrastructure as Code (IaC)?
Infrastructure as Code (IaC) is the practice of managing and provisioning infrastructure through code instead of manual processes. Infrastructure configurations are stored in version-controlled files, making deployments repeatable, consistent, and automated.

### 3. Q. What is a Provider?
A provider is a plugin that enables Terraform to interact with cloud providers and external services through their APIs. Providers act as a bridge between Terraform and platforms such as AWS, Azure, GCP, Docker, or Kubernetes.

### 4. Q. Is Provider Different from Resource?
Yes.  
Provider: Plugin that enables Terraform to communicate with a platform.  
Resource: The actual infrastructure object being created or managed.  

Example:
```
provider "aws" {
  region = "ap-south-1"
}
```
Provider connects Terraform to AWS.
```
resource "aws_instance" "web" {
  instance_type = "t2.micro"
}
```
Resource creates an EC2 instance.

5. Q. What happens during terraform init?

Answer:

When terraform init is executed, Terraform:

Downloads required providers  
Installs provider plugins  
Initializes the backend  
Creates the .terraform directory  
Prepares the working directory for Terraform operations  
This command is typically the first command run in a new Terraform project.

### 6. Q. Difference between Terraform block and Provider block?
The terraform block configures Terraform itself, including Terraform version requirements, backend configuration, and provider version constraints.  
The provider block configures how Terraform connects to a specific platform such as AWS, Azure, or GCP, including region and authentication settings.

Example:
```
terraform {
  required_version = ">= 1.0"
}
```

Configures Terraform.
```
provider "aws" {
  region = "ap-south-1"
}
```
Configures AWS connectivity.

In short:

Terraform block → Configures Terraform.
Provider block → Configures cloud/service connectivity.

### 7. Q. Explain Terraform Architecture.
Terraform architecture consists of:

Configuration Files (.tf)
Terraform Core
Provider Plugins
State File (terraform.tfstate)

Flow:
```
Terraform Configuration
           ↓
      Terraform Core
           ↓
     Provider Plugin
           ↓
        Cloud API
           ↓
Infrastructure Resources

State stored in:
terraform.tfstate
```
Terraform Core reads the configuration, determines the required changes, interacts with provider plugins, provisions infrastructure through cloud APIs, and updates the state file to track deployed resources.

### ## Terraform architecture
Terraform architecture consists of Terraform Configuration Files, Terraform Core, Provider Plugins, and the State File. Terraform Core reads the configuration, determines the required changes, interacts with provider plugins like AWS or Azure, provisions infrastructure through cloud APIs, and maintains the infrastructure state in the tfstate file.

A provider acts as a bridge between Terraform and the target platform. Terraform Core uses providers to communicate with cloud APIs and create, update, or delete resources.

---
## Providers & Authentication - Interview Q&A
### Q. Where should provider configuration be kept?
As a best practice, provider configuration should be kept in the root module. Child modules should inherit the provider configuration from the root module. This ensures centralized management and avoids duplicate provider configurations.

Example:
```
provider "aws" {
  region = "ap-south-1"
}
```

### Q. Why is the provider defined in the root module?
Provider configuration is usually defined in the root module because it centralizes authentication and region settings. Child modules can automatically inherit the provider configuration, making modules more reusable and easier to maintain.

Additional Point: If the provider configuration changes, it only needs to be updated in one place instead of multiple modules.

### Q. What is a Provider in Terraform?
A provider is a plugin that allows Terraform to communicate with a specific platform such as AWS, Azure, GCP, or Kubernetes. Terraform Core uses providers to interact with cloud APIs and create, update, or delete resources.

Example:
```
Terraform Core
      ↓
AWS Provider
      ↓
AWS API
      ↓
EC2 Instance
```
### Q. What is the most secure way to authenticate Terraform with AWS?
The most secure method is using IAM Roles with temporary credentials. Terraform can assume an IAM Role and obtain temporary credentials from AWS STS. This eliminates the need to store long-lived access keys and secret keys.



Benefits:  
- No hardcoded credentials
- Automatic credential rotation
- Better security
- Recommended by AWS

## Q. Do we need environment variables when using IAM Roles?
No. When Terraform is running on an AWS resource that already has an IAM Role attached, such as an EC2 instance, EKS worker node, ECS task, or AWS CloudShell, Terraform automatically obtains temporary credentials from the IAM Role.

Example: IAM Role → STS Temporary Credentials → Terraform
No Need for:  
AWS_ACCESS_KEY_ID  
AWS_SECRET_ACCESS_KEY

However, environment variables may still be used when Terraform is running outside AWS, such as on a developer laptop, Jenkins server, or GitHub Actions runner.

### Q. Why should we avoid hardcoded AWS credentials?
Hardcoded credentials create security risks because they can be exposed in source code repositories, shared files, or logs. Using IAM Roles or secret management solutions is a more secure and scalable approach.

Avoid:
```
provider "aws" {
  access_key = "xxxxx"
  secret_key = "xxxxx"
}
```

### Q. Have you used Provider Aliases?
Yes. Provider aliases are used when deploying resources across multiple AWS regions or multiple accounts.

```
provider "aws" {
  alias  = "mumbai"
  region = "ap-south-1"
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}
```
Then: ` provider = aws.mumbai ` OR ` provider = aws.virginia ` to creates resources in the required region.

---

## Variables, Locals & Outputs
### Q. How can variables be passed into Terraform?
Terraform variables can be provided in multiple ways: default values in variable blocks, .tfvars files, command-line options using -var, and environment variables using the TF_VAR_<variable_name> convention. Environment variables are commonly used in CI/CD pipelines and for sensitive values such as passwords or API keys

Example:
` terraform apply -var="environment=dev" `  
` terraform apply -var-file="prod.tfvars" `

### Q. What are Environment Variables?
Environment variables allow Terraform variables to be passed from the operating system or CI/CD pipeline instead of being defined in Terraform files.  
Terraform automatically reads variables prefixed with TF_VAR_.

Example: `export TF_VAR_region="ap-south-1"`
Terraform Variable: ` variable "region" {}  `

Terraform automatically assigns the value to the variable.  
Environment variables are commonly used in Jenkins, GitHub Actions, Azure DevOps, and other CI/CD tools.

### Q. Why use environment variables for secrets?
Environment variables are safer than hardcoding secrets in Terraform code or .tfvars files because secrets are supplied externally at runtime.  

In production environments, secrets are typically injected from:
- AWS Secrets Manager
- HashiCorp Vault
- GitHub Secrets
- Jenkins Credentials
- Azure Key Vault

Environment variables help keep sensitive values out of source code and version control.

### Q. What are Locals?
Locals are reusable values defined within Terraform configurations. They help reduce repetition, improve readability, and centralize commonly used values such as tags, naming conventions, and environment-specific settings.

Example:
```
locals {
  environment = "prod"
}
```

Usage: ` bucket = "app-${local.environment}" `

### Q. Difference between Variables and Locals?
Variables are used to accept input values from users or external sources, whereas locals are used to define reusable internal values within the Terraform configuration.

### Q. When would you choose Locals over Variables?
I use locals when a value is used repeatedly within the Terraform code or is derived from other values.

Examples include:
- Common tags
- Naming conventions
- Environment-specific naming
- Derived values

Variables are used when the value needs to be provided externally, while locals are used for internally reusable values.

### Q. Difference between Variables and Outputs?
Variables are used to pass values into a module, whereas outputs are used to return values from a module.

### Q. What Terraform functions have you used?
I have commonly used lookup for retrieving map values, length for collection size, merge for combining tag maps, and join/split for string manipulation.


### Q. What is state locking?​‌
State locking prevents multiple users from modifying the same Terraform state simultaneously. In AWS, DynamoDB is commonly used for state locking.

### Q. What happens if state locking is not used?
Multiple users could run Terraform simultaneously, leading to race conditions, resource conflicts, and state corruption

---

## 5. State Management
### Q. What is Terraform State?
Terraform State is a file that stores information about the infrastructure managed by Terraform. Terraform uses the state file to track resources, compare the desired configuration with the actual infrastructure, and determine what changes need to be made during a plan or apply operation.

### Q. Where is Terraform state stored in AWS?
In production environments, Terraform state is typically stored in an S3 bucket using a remote backend. DynamoDB is commonly used for state locking to prevent multiple users from modifying the same state file simultaneously.

### Q. Why use S3 and DynamoDB?
S3 is used to store the Terraform state file centrally so that it can be shared across teams and CI/CD pipelines.

DynamoDB is used for state locking to prevent multiple users from performing Terraform operations simultaneously, which helps avoid state corruption and resource conflicts.

### Q. Backend vs Provider?
A Provider is responsible for creating, updating, and managing infrastructure resources.  
A Backend is responsible for storing and managing the Terraform state file.

### Q. How would you migrate local state to S3 backend?
First, I would create an S3 bucket and DynamoDB table for state storage and locking.  
Then I would configure the backend:
```
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "prod/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
  }
}
```
After updating the backend configuration, I would run: ` terraform init `  
Terraform detects the existing local state file and prompts to migrate it to the S3 backend. After confirmation, the state is moved from local storage to S3.

---

## 6. Modules
### Q. Why use modules?
Modules help reduce code duplication, improve reusability, standardize infrastructure, and make Terraform configurations easier to maintain.  
Instead of writing the same infrastructure code repeatedly, a module can be reused across multiple projects.

### Q. Difference between Root Module and Child Module?
The Root Module is the main Terraform configuration being executed.  
A Child Module is called by another module to provide reusable infrastructure components.

### Q. What are Module Inputs and Outputs?
Inputs are variables passed into a module.  
Outputs are values returned from a module for use elsewhere in the configuration.  

### Q. How are values passed into a module?
Values are passed from the parent module using module arguments. (Using outputs from one module and variables in another module.)

Example:
```
module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
}
```
The child module receives the value through: ` variable "vpc_cidr" {} `


### Q. How is module communication achieved?
Modules cannot directly communicate with each other.   
Communication happens through:
- Outputs from one module
- Variables in another module

Example:
```
module "ec2" {
  subnet_id = module.vpc.subnet_id
}
```
The VPC module exposes subnet_id as an output, and the EC2 module receives it as an input variable.

### Q. Explain the flow of your Terraform project.
Answer
User provides values in terraform.tfvars
Root module variables receive the values
Root main.tf calls child modules
Child modules create resources
Child modules return outputs
Root module consumes those outputs if required

Example flow:
```
terraform.tfvars
        ↓
variables.tf
        ↓
main.tf
        ↓
VPC Module
        ↓
Output subnet_id
        ↓
EC2 Module
        ↓
EC2 Created
```
Root module controls the deployment, child modules contain reusable resource code, variables pass data into modules, and outputs pass data out of modules. This makes Terraform code modular, reusable, and maintainable.

### Q. Have you used Terraform Registry Modules?
Yes, I have used Terraform Registry modules such as VPC and EKS modules to reduce development effort and follow community best practices.

### Q. Your organization has 20 projects creating VPCs. How would you avoid duplicating code?
I would create a reusable VPC module and use it across all projects.  
Each project would call the same module and provide environment-specific values through variables.  
This reduces duplication, improves consistency, and makes maintenance easier because changes only need to be made in one place.

---

## 7. Dependency Management
### Q. What is an Implicit Dependency?
An implicit dependency occurs when one resource references an attribute of another resource.

Example:
```
resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id
}
```
Terraform automatically understands that the VPC must be created before the subnet.

### Q. What is an Explicit Dependency?
An explicit dependency is defined using depends_on when Terraform cannot automatically determine the dependency relationship.  
Example: ` depends_on = [aws_internet_gateway.igw] `

### Q. What is depends_on?
depends_on is used to explicitly specify resource dependencies when Terraform cannot infer them automatically.  
It ensures that one resource is created only after another resource has been successfully created.

### Q. When have you used depends_on?
I use depends_on only when Terraform cannot automatically determine the dependency.  
For example, when creating a route table that requires an Internet Gateway to exist first:
```
resource "aws_route_table" "public" {

  depends_on = [
    aws_internet_gateway.igw
  ]
}
```

---
## Lifecycle Policies
## Q: What Terraform lifecycle settings have you used?
I have primarily used create_before_destroy to avoid downtime during resource replacement, prevent_destroy for critical production resources such as databases, and ignore_changes when certain attributes like tags are managed outside Terraform. These lifecycle settings help ensure safer infrastructure changes and prevent accidental disruptions.

Syntax
```
resource "resource_type" "name" {

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false

    ignore_changes = [
      tags
    ]
  }
}
```

### Q. How would you avoid downtime when replacing an EC2 instance?
Use create_before_destroy.

### Q. How would you prevent accidental deletion of a production RDS database?
Use prevent_destroy.

### Q. Another team updates tags manually in AWS and Terraform keeps showing drift. What would you do?
Use ignore_changes on tags.

---

## 9. Resource Creation Techniques
### count vs for_each
I use count for creating multiple identical resources and for_each when resources have unique names or configurations. In most real-world Terraform code, for_each is preferred because resource identities remain stable.

### local
Locals are used to define reusable values within Terraform configurations. They help avoid repetition, improve readability, and centralize commonly used values such as naming conventions, tags, and environment-specific settings.

### Q. for_each vs Dynamic Block
for_each is used to create multiple resources from a map or set, while Dynamic Blocks are used to create multiple nested configuration blocks within a single resource. For example, I would use for_each to create multiple EC2 instances or S3 buckets, and Dynamic Blocks to generate multiple ingress rules inside a Security Group.

---
## Terraform drift
Terraform drift happens when the actual infrastructure differs from the Terraform configuration due to manual changes outside Terraform. First, I run `terraform apply -refresh-only` to update the state with the real infrastructure. If the manual change is intended, I update the Terraform code to match it. If the change is unauthorized, I run `terraform apply` to bring the infrastructure back to the desired state defined in code.

## Q. A developer manually changes an EC2 instance in AWS Console. What happens?
Terraform detects drift during plan/refresh.

---
## Terraform Dependency Management  
Terraform manages dependencies in two ways. Implicit dependencies are automatically detected when one resource references another resource's attribute, such as a subnet using a VPC ID. Explicit dependencies are defined using depends_on when Terraform cannot determine the relationship automatically. As a best practice, I use implicit dependencies whenever possible and use depends_on only when required.


=====================================================================================================


## Q: How do you make a subnet public in AWS?
A subnet becomes public when it has a route to an Internet Gateway through a route table.
to create a public subnet you need to create a route table first for that subnet to have route table and destination for the route table has to be internet gateway.
and then you need to assiciated this route table to the subent so it become a public subent.


## Q: Do we need to configure AWS credentials as environment variables when using IAM Roles?
No. When using IAM Roles, Terraform can automatically obtain temporary credentials from AWS STS. 
For example, on an EC2 instance with an attached IAM Role, an EKS pod using IRSA, or GitHub Actions using OIDC, there is no need to store or configure AWS Access Keys and Secret Keys as environment variables.


## Q. Difference between Root Module and Child Module?  
Root module is the main Terraform configuration being executed. A child module is called from another module to reuse infrastructure code.


## Q. Why is vpc_cidr defined both in the root module and child module?
Answer
Terraform modules have their own scope. Variables declared in the root module are not automatically available inside child modules.
The root module receives the value and passes it to the child module.
```
module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
}
```
The child module must declare: ```variable "vpc_cidr" {}``` to receive that value.

## Q. Can a child module directly access variables from the root module?
Answer
No. A child module can only access values explicitly passed by the parent module.
❌ Not allowed
```
# child module
cidr_block = var.root_vpc_cidr
```
Correct:
```
module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
}
```


### Q: What happens if you forget to declare a variable in the child module?
Terraform throws an error because the variable is not defined in that module.
**Example:**
```hcl
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
}
```
but: `variable "vpc_cidr" {}` is missing.
Terraform fails during validation or plan.


### Q. How is module communication achieved?
Answer
Modules cannot directly communicate with each other.
Communication happens through:
Output from Module A
Variable in Module B
Example: `module.vpc.subnet_id`
and passed into:
```
module "ec2" {
  subnet_id = module.vpc.subnet_id
}
```

## Q. Why use environment variables for secrets if they can still be viewed?  
Environment variables are not fully secure by themselves, but they are safer than hardcoding secrets in Terraform code or tfvars files. In production, secrets are typically injected from Jenkins Credentials, GitHub Secrets, AWS Secrets Manager, or Vault as temporary environment variables, and Terraform variables are marked as sensitive to avoid displaying them in outputs and logs.


## Terraform Taint / Untaint (Deprecated) AND -replace
Earlier, Terraform provided taint and untaint commands to force resource recreation. A tainted resource would be destroyed and recreated during the next apply. However, since Terraform v0.15.2, terraform taint has been deprecated, and the recommended approach is to use terraform apply -replace=<resource>.
