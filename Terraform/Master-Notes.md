# Why Infrastructure as Code (IaC)?

Before the advent of IaC:

- **Manual Server Configuration** – Infrastructure was configured manually.
- **No Version Control** – Changes were difficult to track and audit.
- **Documentation-Driven Processes** – Relied heavily on manual documentation.
- **Limited Automation** – Increased operational effort and human error.
- **Slow Provisioning** – Infrastructure deployment was time-consuming.

## key terminology and concept

### Provider: 
A provider is a plugin for Terraform that defines and manages resources for a specific cloud or infrastructure platform. Examples of providers include AWS, Azure, Google Cloud, and many others. You configure providers in your Terraform code to interact with the desired infrastructure platform.

**Different Ways to Configure Providers in Terraform**
#### In the Root Module
This is the most common way to configure providers. The provider configuration block is placed in the root module of the Terraform configuration. This makes the provider configuration available to all the resources in the configuration.

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

#### In a child module
You can also configure providers in a child module. This is useful if you want to reuse the same provider configuration in multiple resources.
```hcl
module "aws_vpc" {
  source = "./aws_vpc"
  providers = {
    aws = aws.us-west-2
  }
}

resource "aws_instance" "example" {
  ami = "ami-0123456789abcdef0"
  instance_type = "t2.micro"
  depends_on = [module.aws_vpc]
}
```
#### In the required_providers block
You can also configure providers in the required_providers block. This is useful if you want to make sure that a specific provider version is used.
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.0, < 3.0"
    }
  }
}

resource "aws_instance" "example" {
  ami = "ami-0123456789abcdef0"
  instance_type = "t2.micro"
}
```
The best way to configure providers depends on your specific needs. If you are only using a single provider, then configuring it in the root module is the simplest option. If you are using multiple providers, or if you want to reuse the same provider configuration in multiple resources, then configuring it in a child module is a good option. And if you want to make sure that a specific provider version is used, then configuring it in the required_providers block is the best option.

### Resource
A resource is a specific infrastructure component that you want to create and manage using Terraform. Resources can include virtual machines, databases, storage buckets, network components, and more. Each resource has a type and configuration parameters that you define in your Terraform code.

### Module
A module is a reusable and encapsulated unit of Terraform code. Modules allow you to package infrastructure configurations, making it easier to maintain, share, and reuse them across different parts of your infrastructure. Modules can be your own creations or come from the Terraform Registry, which hosts community-contributed modules.

### Configuration File
Terraform uses configuration files (often with a .tf extension) to define the desired infrastructure state. These files specify providers, resources, variables, and other settings. The primary configuration file is usually named main.tf, but you can use multiple configuration files as well.

### Variable 
Variables in Terraform are placeholders for values that can be passed into your configurations. They make your code more flexible and reusable by allowing you to define values outside of your code and pass them in when you apply the Terraform configuration.

**Input Variables**
Input variables are used to parameterize your Terraform configurations. They allow you to pass values into your modules or configurations from the outside. Input variables can be defined within a module or at the root level of your configuration. Here's how you define an input variable:
```hcl
variable "example_var" {
  description = "An example input variable"
  type        = string
  default     = "default_value"
}
```
You can then use the input variable within your module or configuration like this:
```hcl
resource "example_resource" "example" {
  name = var.example_var
  # other resource configurations
}
```
You reference the input variable using var.example_var.

**Output Variables**
Output variables allow you to expose values from your module or configuration, making them available for use in other parts of your Terraform setup. Here's how you define an output variable:
``hcl
output "example_output" {
  description = "An example output variable"
  value       = resource.example_resource.example.id
}
```
You can reference output variables in the root module or in other modules by using the syntax module.module_name.output_name, where module_name is the name of the module containing the output variable.

For example, if you have an output variable named example_output in a module called example_module, you can access it in the root module like this:
``hcl
output "root_output" {
  value = module.example_module.example_output
}
```
This allows you to share data and values between different parts of your Terraform configuration and create more modular and maintainable infrastructure-as-code setups.

### Terraform tfvars
Separation of Configuration from Code: Keep variable values outside .tf files, making code reusable and easier to manage across environments.
Sensitive Information: Can store secrets like passwords, API keys, and credentials, but it is recommended to use secret management solutions (Vault, AWS Secrets Manager, etc.) instead.
Reusability: Use the same Terraform code with different variable values for multiple environments (Dev, Test, Prod).
Collaboration: Team members can maintain their own .tfvars files without modifying the main Terraform code, reducing conflicts.
```hcl
# variables.tf
variable "instance_type" {}

# terraform.tfvars
instance_type = "t3.micro"
```
Here's how you typically use .tfvars files
- Define your input variables in your Terraform code (e.g., in a variables.tf file).
- Create one or more .tfvars files, each containing specific values for those input variables.
- When running Terraform commands (e.g., terraform apply, terraform plan), you can specify which .tfvars file(s) to use with the -var-file option:
```hcl
terraform apply -var-file=dev.tfvars
```
.tfvars files help keep infrastructure code flexible, reusable, and environment-specific.

### State File 
Terraform maintains a state file (often named terraform.tfstate) that keeps track of the current state of your infrastructure. This file is crucial for Terraform to understand what resources have been created and what changes need to be made during updates.

### Plan
A Terraform plan is a preview of changes that Terraform will make to your infrastructure. When you run terraform plan, Terraform analyzes your configuration and current state, then generates a plan detailing what actions it will take during the apply step.

### Apply
The terraform apply command is used to execute the changes specified in the plan. It creates, updates, or destroys resources based on the Terraform configuration.

### Workspace
Workspaces in Terraform are a way to manage multiple environments (e.g., development, staging, production) with separate configurations and state files. Workspaces help keep infrastructure configurations isolated and organized.

### Remote Backend 
A remote backend is a storage location for your Terraform state files that is not stored locally. Popular choices for remote backends include Amazon S3, Azure Blob Storage, or HashiCorp Terraform Cloud. Remote backends enhance collaboration and provide better security and reliability for your state files.

### Multiple Region Implementation in Terraform
You can make use of alias keyword to implement multi region infrastructure setup in terraform
```hcl
provider "aws" {
  alias = "us-east-1"
  region = "us-east-1"
}

provider "aws" {
  alias = "us-west-2"
  region = "us-west-2"
}

resource "aws_instance" "example" {
  ami = "ami-0123456789abcdef0"
  instance_type = "t2.micro"
  provider = "aws.us-east-1"
}

resource "aws_instance" "example2" {
  ami = "ami-0123456789abcdef0"
  instance_type = "t2.micro"
  provider = "aws.us-west-2"
}
```
