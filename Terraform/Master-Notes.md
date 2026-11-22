# Terraform

## Why Infrastructure as Code (IaC)?
Before the advent of IaC:
- Manual Server Configuration 
- Changes were difficult to track and audit.
- Increased operational effort and human error.
- Infrastructure deployment was time-consuming.

## Terraform
Terraform is Infrastructure as Code (IaC) tool that allows us to define, provision, and manage infrastructure using declarative configuration files instead of manually creating resources through the cloud console. It helps automate infrastructure management in a consistent, repeatable, and version-controlled manner across cloud providers such as AWS, Azure, and GCP.

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
**1. Terraform Configuration:** These are the .tf files where you define infrastructure as code.  

**2. Terraform Core**
Terraform Core is the brain of Terraform.  
Responsibilities:  
* Reads .tf files  
* Creates execution plan
* Maintains state file
* Finds resource dependencies
* Communicates with providers

Commands acting through Terraform Core:  
```
terraform init
terraform plan
terraform apply
terraform destroy
```
terraform init initializes the working directory, downloads the required provider plugins, configures the backend, and creates the .terraform.lock.hcl file to lock provider versions.

### 3. Provider Plugins
A Provider is a plugin that enables Terraform to communicate with a target platform by calling its APIs and managing infrastructure resources.

Examples:  
AWS → hashicorp/aws  
Azure → hashicorp/azurerm  
Kubernetes → hashicorp/kubernetes  

```
provider "aws" {
  region = "ap-south-1"
}
```

### 4. State File
Terraform stores the current infrastructure state in: ` terraform.tfstate `

Purpose:  
* Tracks created resources
* Maps Terraform resources to real resources
* Helps Terraform detect changes

Example: ` terraform plan `
Terraform compares: `Desired State (.tf files)`  VS `Current State (tfstate)` and generates the execution plan.

### Terraform Workflow
```
Write Code
    |
terraform init → Download Providers
    |
terraform plan → Show Changes
    |
terraform apply →  Create Resources
    |
Update State File
```
---

## The ```terraform``` block
**Responsibilities**
- Specifies required Terraform version  
- Specifies required providers  
- Defines backend configuration  
- Controls Terraform behavior  

```
terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }
}

```
```source``` - Tells Terraform where to download the provider from.  
```version``` - Specifies which provider versions are allowed.  
```~>``` operator is called the pessimistic version constraint. It allows Terraform to use newer compatible versions while preventing upgrades that might introduce breaking changes.  
For example, The string ~> 5.92 means your configuration supports any version of the provider with a major version of 5 and a minor version greater than or equal to 92.

>> Note: required_providers tells Terraform which provider plugin to download, while the provider block configures how Terraform connects to and uses that provider.
---

## Provider
### Provider Authentication Methods (AWS)
The most secure way to authenticate Terraform with AWS is by using IAM Roles with temporary credentials instead of long-lived access keys. Terraform can assume an IAM Role and obtain temporary credentials from AWS STS, eliminating the need to store AWS access keys and secret keys.
Avoid hardcoded in code:  
AWS_ACCESS_KEY_ID or AWS_SECRET_ACCESS_KEY  

### Multiple Providers
Terraform can use multiple providers within the same project to manage resources across different platforms.
Examples:  
- aws → AWS
- azurerm → Azure
- kubernetes → Kubernetes

Example:
```hcl
provider "aws" {
  region = "ap-south-1"
}
provider "kubernetes" {
  config_path = "~/.kube/config"
}
```
Terraform can then create and manage resources across both AWS and Kubernetes from a single configuration.

### Different Ways to Configure Providers in Terraform
#### In the Root Module (Most common)
Provider configuration is typically defined in the root module and inherited by child modules.
 ```hcl
provider "aws" {
  region = "us-east-1"
}
resource "aws_instance" "example" {
  ami           = "ami-0123456789abcdef0"
  instance_type = "t2.micro"
}
```
Eg. azurerm - for Azure

#### Passing a Provider Configuration from the Root Module to a Child Module
A child module can use a specific provider configuration passed from the root module. This is commonly used for multi-region or multi-account deployments.
```hcl
provider "aws" {
  alias  = "us-west-2"
  region = "us-west-2"
}

module "aws_vpc" {
  source = "./aws_vpc"
  providers = {
    aws = aws.us-west-2
  }
}
```
Best Practice:  
Define provider configurations in the root module and allow child modules to inherit them. Use provider aliases when multiple regions or accounts are involved.
#### Provider Aliases
Provider aliases are used to create multiple provider configurations, which is commonly required for multi-region or multi-account deployments.
`alias` is a Terraform identifier (any name) used to distinguish multiple provider configurations, while `region` specifies the actual AWS region where resources will be created.
```hcl
provider "aws" {
  alias  = "mumbai"
  region = "ap-south-1"
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami = "ami-0123456789abcdef0"
  instance_type = "t2.micro"
  provider = aws.mumbai
}

resource "aws_instance" "example2" {
  ami = "ami-0123456789abcdef0"
  instance_type = "t2.micro"
  provider = aws.virginia
}
```
---
## Data sources
Data sources are used to fetch information about existing resources from a cloud provider instead of creating new resources.
They help avoid hardcoded values and keep Terraform configurations dynamic.  
Example: Fetching the latest AWS AMI instead of hardcoding an AMI ID.

**Key Point:** Data sources read existing information, while resources create and manage infrastructure.  
main.tf
```
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}
```
In this example, the ```data.aws_ami.ubuntu``` data source loads an AMI for the most recent Ubuntu Noble Numbat release in the region configured for your provider.

---
# Module
A Terraform module is a reusable and self-contained collection of Terraform configuration files that groups related resources together. Modules help organize infrastructure code, improve reusability, and reduce duplication.  
Modules can be your own creations or come from the Terraform Registry, which hosts community-contributed modules.  

Terraform provides a root module by default, and additional child modules can be created or sourced from the Terraform Registry.  

## Types of Modules
The root module is the main Terraform configuration that we execute using terraform apply. It typically contains provider configuration and calls reusable child modules.  
Child modules contain reusable infrastructure code such as VPC, EC2, or EKS configurations, which can be called from the root module multiple times.
### 1. Root Module
The Terraform configuration in the current working directory.  
```
project/
├── main.tf
├── variables.tf
├── outputs.tf
├──terraform.tfvars
```
Every Terraform project has one root module.

### 2. Child Module
A module called by another module.
```
module "vpc" {
  source = "./modules/vpc"
}
```

Example structure:  
```
project/
├── main.tf
└── modules/
    └── vpc/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Module Components
### Inputs (variables.tf)
Used to pass values into the module.

### Resource
A resource is a specific infrastructure component that you want to create and manage using Terraform. Each resource has a type and configuration parameters that you define in your Terraform code.  
main.tf
```
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  tags = {
    Name = "learn-terraform"
  }
}
```
The first line of a resource block declares a resource type and resource name. 
The tags argument sets the EC2 instance's name. 

### Outputs (outputs.tf)
Return values from modules

### Calling a Module
```
module "ec2" {
  source        = "./modules/ec2"
  instance_type = "t3.micro"
}
```

### Module Sources
**Local Module**: ` source = "./modules/ec2" `

**Git Repository**: ` source = "git::https://github.com/company/ec2-module.git" `

**Terraform Registry**: ` source = "terraform-aws-modules/vpc/aws" `

---
## locals
Locals allow storing values that are reused multiple times within a Terraform configuration.  
Example  
```
locals {
  environment = "dev"
}
```
use:
```
resource "aws_s3_bucket" "bucket" {
  bucket = "myapp-${local.environment}"
}
```
Output: myapp-dev

### Multiple Locals
```
locals {
  env         = "prod"
  project     = "ecommerce"
  common_tags = {
    Environment = local.env
    Project     = local.project
  }
}
```
Use ` tags = local.common_tags `

### Why Use Locals?
Without locals: ` Environment = "prod" ` repeated everywhere.  
With locals: ` Environment = local.env ` Change once, reflected everywhere.

### Variables vs Locals
```
Variables                        Locals
Input from user                Internal values
Can change during execution    Defined inside code
var.name                       local.name
```

---
## Variable 
Variables in Terraform are placeholders for values that can be passed into your configurations. They make your code more flexible and reusable by allowing you to define values outside of your code and pass them in when you apply the Terraform configuration.

**Input Variables**
Input variables are used to parameterize Terraform configurations by accepting values from outside the code. They can be defined in both root modules and child modules. Each module has its own variable scope, and values must be explicitly passed from the root module to child modules.

**variables.tf**
```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
```
Use the variable in your configuration:
```hcl
resource "aws_instance" "example" {
  instance_type = var.instance_type
}
```
Variables are referenced using: `var.instance_type`

**Output Variables**
Output variables are used to return values from a module so they can be used elsewhere in the Terraform configuration.  
outputs.tf
```hcl
output "example_output" {
  description = "An example output variable"
  value       = resource.example_resource.example.id
}
```

Access an output from another module: `module.module_name.output_name`
Example: `module.ec2.instance_id`
Output variables help share data between modules and make Terraform configurations more modular and reusable.

### Terraform tfvars
`.tfvars` files are used to store values for input variables outside the Terraform code. This makes configurations reusable, environment-specific, and easier to manage.  
**Benefits:**
- Separates configuration from code
- Supports Dev, Test, and Prod environments
- Reduces code changes across environments
- Helps teams manage environment-specific values

**Example:**
```
# variables.tf
variable "instance_type" {}

# terraform.tfvars
instance_type = "t3.micro"
```
Use a specific tfvars file: ` terraform apply -var-file=dev.tfvars`  
**Common Files:**  
dev.tfvars   
test.tfvars  
prod.tfvars  
**Key Point:** The same Terraform code can be reused across multiple environments by supplying different `.tfvars` files.

### Environment Variables in Terraform
Environment variables allow Terraform variables to be provided from the operating system or CI/CD pipeline instead of hardcoding values in `.tfvars` files.  
Example: ` export TF_VAR_region="ap-south-1" `

Terraform variable: `variable "region" {}`  
Terraform automatically maps:
```text
TF_VAR_region
      ↓
var.region
```
**Key Point:** Any environment variable prefixed with `TF_VAR_` is automatically assigned to the corresponding Terraform variable.

#### they are used in CI/CD Pipelines
Jenkins/GitHub Actions/Azure DevOps can pass values dynamically.
```
export TF_VAR_environment="prod"
terraform apply
```
**Different Values Per Environment**  
   export TF_VAR_environment="dev"  
   export TF_VAR_environment="prod"  
Same code, different deployment.

---
## Sensitive Variables (sensitive = true)
Purpose: Used to prevent sensitive values from being displayed in Terraform output, plan, and logs.
```
variable "db_password" {
  type      = string
  sensitive = true
}
```

### What Happens?
Without: ` db_password = "Password123" `  
Terraform may display: ` db_password = Password123 `

With: ` sensitive = true `
Terraform displays: ` db_password = (sensitive value) `

### What It Protects
- Terraform plan output
- Terraform apply output
- Terraform outputs
- CI/CD console logs

### What It Does NOT Protect
- Does not encrypt the value
- Does not remove it from Terraform state
- Does not replace a secret management solution

### Production Best Practice
Store secrets in:
- AWS Secrets Manager
- HashiCorp Vault
- Azure Key Vault

Then use: sensitive = true

Example:
```
data "aws_secretsmanager_secret_version" "db" {
  secret_id = "prod/db-password"
}

variable "db_password" {
  sensitive = true
}
```
The password comes from AWS Secrets Manager, but Terraform may still use that value during planning and applying.  
Key point: Secret Manager protects where the secret is stored; sensitive = true protects where the secret is displayed.

### Variable Management
Variable Management allows Terraform Cloud workspaces to securely store Terraform variables and environment variables, including sensitive values such as passwords, tokens, and cloud credentials, without storing them in code.

---
## State Management 
### Why Not Store State in Git?
Terraform state may contain:
- Resource IDs
- IP Addresses
- Database Endpoints
- Sensitive Information
It also changes frequently and can lead to merge conflicts.

### Remote Backends (e.g., S3):
A remote backend stores the Terraform state file outside of your local file system and version control. Using S3 as a remote backend is a popular choice due to its reliability and scalability. 
Benefits:
- Centralized state
- Team collaboration
- Versioning
- Backup and recovery

Here's how to set it up:
**1. Create an S3 Bucket:** Create an S3 bucket in your AWS account to store the Terraform state. Ensure that the appropriate IAM permissions are set up.

**2. Configure Remote Backend in Terraform:**
```
# In your Terraform configuration file (e.g., main.tf), define the remote backend.
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "path/to/your/terraform.tfstate"
    region         = "us-east-1" # Change to your desired region
    encrypt        = true
    dynamodb_table = "your-dynamodb-table"
  }
}
```

**3. DynamoDB Table for State Locking:**
To enable state locking, create a DynamoDB table and provide its name in the dynamodb_table field. This prevents concurrent access issues when multiple users or processes run Terraform.

### State Locking with DynamoDB:
DynamoDB is used for state locking to prevent multiple users from modifying the same state file simultaneously.  
Benefits:
- Prevents concurrent applies
- Prevents state corruption
- Prevents race conditions

### Remote Runs
Remote Runs execute Terraform plans and applies inside Terraform Cloud instead of on a user's local machine, providing consistency, centralized auditing, and secure credential management.

---
## Workspace
Workspaces in Terraform are a way to manage multiple environments (e.g., development, staging, production) with separate configurations and state files. Workspaces help keep infrastructure configurations isolated and organized.


## Conditional Expressions
Conditional expressions allow Terraform to make decisions based on conditions, such as creating resources only in specific environments or assigning different values based on environment settings.  
Think of it exactly like an if-else statement in programming

The syntax for a conditional expression in Terraform is: ` condition ? true_val : false_val `
**Conditional Resource Creation Example**
```hcl
resource "aws_instance" "example" {
  count = var.create_instance ? 1 : 0

  ami           = "ami-XXXXXXXXXXXXXXXXX"
  instance_type = "t2.micro"
}
```
In this example, the count attribute of the aws_instance resource uses a conditional expression. If the create_instance variable is true, it creates one EC2 instance. If create_instance is false, it creates zero instances, effectively skipping resource creation.
```
instance_type = var.environment == "prod" ? "t3.large" : "t3.micro"
Prod → t3.large, Dev  → t3.micro
```

## Built-in Functions
Terraform provides a wide range of built-in functions that you can use within your configuration files (usually written in HashiCorp Configuration Language, HCL) to manipulate and transform data. These functions help you perform various tasks when defining your infrastructure.

**1. lookup()**: Used to retrieve a value from a map using a key.
```
variable "instance_type" {
  default = {
    dev  = "t2.micro"
    prod = "t2.large"
  }
}

output "type" {
  value = lookup(var.instance_type, "dev")
}
```
Output: t2.micro  
Use Case: Selecting environment-specific values.

**2. element(list, index):** Returns the element at the specified index in a list.
```hcl
variable "my_list" {
  type    = list
  default = ["apple", "banana", "cherry"]
}

output "selected_element" {
  value = element(var.my_list, 1) # Returns "banana"
}
length(list): Returns the number of elements in a list.
variable "my_list" {
  type    = list
  default = ["apple", "banana", "cherry"]
}

output "list_length" {
  value = length(var.my_list) # Returns 3
}
```

count = length(var.instances)  
length() returns the number of items in a collection and is commonly used with count.

**3.merge()**  
Combines multiple maps into one.  
```
locals {
  common_tags = {
    Project = "Ecommerce"
  }

  env_tags = {
    Environment = "Prod"
  }
}

output "tags" {
  value = merge(local.common_tags, local.env_tags)
}
```
Output:
```
{
  Project     = "Ecommerce"
  Environment = "Prod"
}
```
Use Case: Combining common and environment-specific tags.


**4. lookup(map, key): Retrieves the value associated with a specific key in a map.**
```hcl
variable "my_map" {
  type    = map(string)
  default = {"name" = "Alice", "age" = "30"}
}

output "value" {
  value = lookup(var.my_map, "name") # Returns "Alice"
}
join(separator, list):  # Joins the elements of a list into a single string using the specified separator.
variable "my_list" {
  type    = list
  default = ["apple", "banana", "cherry"]
}

output "joined_string" {
  value = join(", ", var.my_list) # Returns "apple, banana, cherry"
}
```
**5. split()**  
Splits a string into a list.
` split(",", "dev,test,prod") `

OutPut: ` ["dev","test","prod"] `


#### Rarely asked

**1. concat(list1, list2, ...): Combines multiple lists into a single list.**
```hcl
variable "list1" {
  type    = list
  default = ["a", "b"]
}

variable "list2" {
  type    = list
  default = ["c", "d"]
}

output "combined_list" {
  value = concat(var.list1, var.list2)
}
```
**2. map(key, value): Creates a map from a list of keys and a list of values.**
```hcl
variable "keys" {
  type    = list
  default = ["name", "age"]
}

variable "values" {
  type    = list
  default = ["Alice", 30]
}

output "my_map" {
  value = map(var.keys, var.values) # Returns {"name" = "Alice", "age" = 30}
}
```

These are just a few examples of the built-in functions available in Terraform. You can find more functions and detailed documentation in the official Terraform documentation, which is regularly updated to include new features and improvements

# Provisioners
Provisioners are used to execute commands after resource creation. (or before it's destroyed).   
For example:
Create an EC2 instance  
SSH into the instance  
Install Apache/Nginx  
Copy files  
Note: HashiCorp generally recommends configuration management tools such as Ansible or cloud-init over provisioners.

## Types of Provisioners
### 1. file Provisioner ( `Terraform → Copy file → EC2` )
The file provisioner is used to copy files or directories from the local machine to a remote machine. This is useful for deploying configuration files, scripts, or other assets to a provisioned instance.

Example:
```
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}

provisioner "file" {
  source      = "local/path/to/localfile.txt"
  destination = "/path/on/remote/instance/file.txt"
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
  }
}
```
**Use case:**  
Copy scripts  
Copy application files  
Copy configuration files  

### 2. remote-exec Provisioner  
The remote-exec provisioner is used to run scripts or commands on a remote machine over SSH or WinRM connections. It's often used to configure or install software on provisioned instances.  
Example:
```
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}

provisioner "remote-exec" {
  inline = [
    "sudo yum update -y",
    "sudo yum install -y httpd",
    "sudo systemctl start httpd",
  ]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host        = aws_instance.example.public_ip
  }
}
```
In this example, the ```remote-exec``` provisioner connects to the AWS EC2 instance using SSH and runs a series of commands to update the package repositories, install Apache HTTP Server, and start the HTTP server.  
Runs commands inside the created server `Terraform → SSH → EC2 → Run commands`  
**Use case:**
Install packages  
Edit config files    
Start services  
Configure EC2 after creation  

### 3. local-exec Provisioner  
The local-exec provisioner is used to run scripts or commands locally on the machine where Terraform is executed. It is useful for tasks that don't require remote execution, such as initializing a local database or configuring local resources.

Example:
```
resource "null_resource" "example" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "echo 'This is a local command'"
  }
}
```

In this example, a ```null_resource``` is used with a ```local-exec``` provisioner to run a simple local command that echoes a message to the console whenever Terraform is applied or refreshed. The ```timestamp()``` function ensures it runs each time.  
This command runs on:  
Your laptop   
Jenkins agent  
GitHub Actions runner  
Any machine running Terraform  
NOT on EC2.  

---
# Terraform Import
Terraform Import allows Terraform to start managing an existing resource without recreating it.
Use When: Existing EC2, S3 bucket and/or IAM Role
  
## Terraform Import (Bring Existing Resources Under Terraform Management)
### Step 1: Create Import Block
In your Terraform configuration:
```hcl
import {
  id = "resource-id"
  to = aws_instance.example
}
```

### Step 2: Generate Terraform Configuration
` terraform plan --generate-config-out=generated_resource.tf `  
→ Terraform generates configuration code for the imported resource.

### Step 3: Review Generated Configuration
Terraform creates: ` generated_resource.tf `  
Review the generated code and move it into your preferred Terraform files such as:
```text
main.tf
ec2.tf
s3.tf
```

### Step 4: Import Resource into State
`terraform import aws_instance.example i-0123456789abcdef0 ` → This links the existing AWS resource with Terraform state.


### Step 5: Verify Import
```bash
terraform plan
```
Expected output:
```text
No changes. Your infrastructure matches the configuration.
```
This confirms the resource is successfully imported and Terraform state is synchronized.

---
# Terraform Drift
Terraform drift occurs when actual infrastructure differs from the Terraform configuration due to changes made outside Terraform.  
Example:  
```text
Terraform Code (.tf) : t2.micro
Terraform State      : t2.micro
Actual AWS Resource  : t3.micro
```

### Drift Detection
#### Option 1 (Recommended): Audit & Alerting
- CloudTrail records infrastructure changes
- EventBridge detects changes
- Lambda validates the change
- Alert if the change was made by a non-Terraform IAM role

Benefits:
- Near real-time detection
- Better governance
- No scheduled Terraform jobs required

#### Option 2: Scheduled Drift Checks
Run periodically using: Jenkins, GitHub Actions or Cron Jobs

Detect drift: ` terraform plan `  
Updates state only: ` terraform apply -refresh-only `

### Resolving Drift
#### Keep the Manual Change
`terraform apply -refresh-only` 
→ Update the Terraform state to match the actual infrastructure. Then manually update the Terraform code to match the infrastructure.

#### Revert the Manual Change
```bash
terraform plan
terraform apply
```
→ Terraform updates the infrastructure to match the code.

## What Refresh Does
**Queries Cloud APIs:** Checks actual resource configuration from cloud providers  
**Detects Drift:** Identifies changes made outside Terraform.  
**Updates State Only:**  Refresh updates `terraform.tfstate ` only. It does **not** modify cloud resources.    
**Requires Existing State:** Refresh only works for resources already managed by Terraform. It cannot discover new resources.

---

### Key Point
```text
Drift = Terraform Code ≠ Actual Infrastructure

Detect  → terraform plan -refresh-only
Refresh → terraform apply -refresh-only

Keep Change?   → Update Code
Remove Change? → terraform apply
```
---

## Import vs Refresh-Only

### terraform import
* Bring an existing resource under Terraform management.
* Resource is not currently present in Terraform state.

Example: A coworker manually created an S3 bucket. Terraform must start managing it.

### terraform plan -refresh-only
* Detect drift in resources already managed by Terraform.

Example: An EC2 instance exists in Terraform state but Someone manually changes its configuration in AWS.

---

# Terraform Lifecycle Meta-Argument
lifecycle is used inside a Terraform resource block to control how Terraform creates, updates, or destroys resources.

### 1. create_before_destroy
Creates the new resource first, then deletes the old one. Prevents downtime during replacement.
```
resource "aws_instance" "web" {
  ami           = "ami-123456"
  instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
  }
}
```

### 2. prevent_destroy
**How do you protect a production database from accidental deletion?**  

`prevent_destroy` Prevents accidental deletion of critical resources.  
```
resource "aws_db_instance" "prod_db" {

  lifecycle {
    prevent_destroy = true
  }
}
```
If someone runs: ` terraform destroy ` Terraform will throw an error instead of deleting the database.  
Useful for Production DBs, S3 buckets, EKS clusters.

### 3. ignore_changes
**Q: Terraform keeps trying to revert tags modified by another team. How do you stop it?**

`ignore_changes` Tells Terraform to ignore changes to specific attributes.  
```
resource "aws_instance" "web" {
  ami = "ami-123456"

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
```
Example:  
Terraform creates VM with tags.  
Someone manually updates tags in AWS Console.  
terraform plan will not show changes.  
✅ Useful when another team/tool manages certain attributes.  

### 4. replace_triggered_by
replace_triggered_by forces a resource replacement when the referenced resource or value changes.
```
resource "aws_instance" "web" {

  lifecycle {
    replace_triggered_by = [
      aws_launch_template.app
    ]
  }
}
```
If the Launch Template changes, the EC2 instance is recreated automatically.  
✅ Useful for immutable infrastructure.

---
# Terraform Dependency (OR Terraform Graph)
Terraform automatically determines the order in which resources should be created, modified, or destroyed based on their relationships.

## 1. Implicit Dependency (Most Common)
An implicit dependency is created automatically when one resource references another resource's attribute. Terraform determines the correct execution order without any manual configuration.
Example
```
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
}
```
Here ` vpc_id = aws_vpc.main.id ` creates the dependency automatically. so Terraform knows the VPC must be created before the subnet.

## 2. Explicit Dependency
Explicit dependencies are defined using `depends_on` when Terraform cannot automatically determine the relationship between resources.  
Example:
```
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_instance" "web" {
  ami           = "ami-123456"
  instance_type = "t2.micro"

  depends_on = [aws_vpc.main]
}
```
Even though the EC2 instance does not reference the VPC directly, Terraform will create the VPC first.

### depends_on Syntax
Resource Dependency: ` depends_on = [aws_vpc.main] `

### Multiple Dependencies
```
depends_on = [
  aws_vpc.main,
  aws_security_group.web
]
```

### Module Dependency
```
module "ec2" {
  source = "./modules/ec2"

  depends_on = [module.vpc]
}
```

#### When Do We Use depends_on?
Use it only when Terraform cannot infer the dependency.  
Examples:  
✅ IAM Role before EKS Cluster  
✅ VPC before Route Configuration  
✅ Module-to-Module Dependency  
✅ Resource depends on another resource operationally but not through an attribute reference  

---

## count
count is used when we need multiple instances of the same resource. Resources are indexed numerically using count.index.  
Example
```
resource "aws_instance" "web" {
  count         = 3
  ami           = "ami-123456"
  instance_type = "t2.micro"
}
```
Creates: aws_instance.web[0], aws_instance.web[1] and aws_instance.web[2]  

Accessing Count Index: ` Name = "server-${count.index}" `  
When to Use?  
Multiple identical resources  
Fixed number of VMs  
Fixed number of S3 buckets  

**Limitation**  
If one item is removed from the middle, Terraform may recreate resources because indexing changes.

---

## for_each
for_each is preferred when resources need unique names or configurations. It uses keys instead of numeric indexes, making resource management more stable than count.  
Example  
```
resource "aws_s3_bucket" "bucket" {
  for_each = toset(["dev", "test", "prod"])

  bucket = "company-${each.key}"
}
```

Creates: company-dev, company-test and company-prod

### Using Map
```
variable "instances" {
  default = {
    web = "t2.micro"
    app = "t2.small"
  }
}

resource "aws_instance" "server" {
  for_each = var.instances

  instance_type = each.value
}
```

Here:  
each.key   → web/app  
each.value → t2.micro/t2.small  


### Why Prefer for_each?

Suppose: ["dev","test","prod"]  
Become: ["dev","prod"]  

With count, indexing changes and resources may be recreated.  
With for_each, keys remain stable: [dev pro] Only test gets removed.  

---

## Terraform Dynamic Blocks 
Dynamic blocks are used to generate repeated nested blocks dynamically instead of writing the same configuration multiple times.

Dynamic Block Example:
```
variable "ports" {
  default = [22, 80, 443]
}

resource "aws_security_group" "web" {

  dynamic "ingress" {
    for_each = var.ports

    content {
      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"
    }
  }
}
```

Terraform automatically creates:
```
ingress {
  from_port = 22
}

ingress {
  from_port = 80
}

ingress {
  from_port = 443
}
```

Syntax
```
dynamic "<block_name>" {

  for_each = <collection>

  content {
    ...
  }
}
```

### When Do We Use Dynamic Blocks?
Security Group Rules: Ingress and Egress  
Load Balancer Rules   
Route Tables  
IAM Policy Statements  
Any Repeated Nested Block  


### Difference between for_each and Dynamic Blocks
for_each is used to create multiple resources, while dynamic blocks are used to create multiple nested configuration blocks inside a resource. Dynamic blocks help reduce repetitive code when configuring structures such as security group ingress or egress rules.

---

# Terraform Taint / Untaint (Deprecated)
`terraform taint aws_instance.web` → Marks a resource for recreation during the next `terraform apply`.  
`terraform untaint aws_instance.web` → Removes the taint mark.

### Recommended Replacement
```bash
terraform apply -replace="aws_instance.web"
```
→ Force recreation of a resource even if there are no configuration changes. And is the modern replacement for `terraform taint`.

### Why Was Taint Deprecated?  
Since Terraform v0.15.2, HashiCorp recommends: ` terraform apply -replace="aws_instance.web" `
Instead of ` terraform taint aws_instance.web` and  ` terraform apply `  
Because -replace shows the replacement directly in the plan and apply workflow, making changes safer and easier to review.

**Modern Approach:** ` Terraform apply -replace="aws_instance.web" ` 

---
## Policy Enforcement
Policy Enforcement allows organizations to define governance rules that Terraform deployments must satisfy before they can be applied. Common policies enforce approved regions, mandatory tagging, security standards, and cost controls.
