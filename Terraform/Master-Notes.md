# Why Infrastructure as Code (IaC)?

Before the advent of IaC:

- **Manual Server Configuration** – Infrastructure was configured manually.
- **No Version Control** – Changes were difficult to track and audit.
- **Documentation-Driven Processes** – Relied heavily on manual documentation.
- **Limited Automation** – Increased operational effort and human error.
- **Slow Provisioning** – Infrastructure deployment was time-consuming.

## key terminology and concept

## 1. Provider: 
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
      source = "hashicorp/aws"
      version = "~> 3.79"
    }
  }
}

resource "aws_instance" "example" {
  ami = "ami-0123456789abcdef0"
  instance_type = "t2.micro"
}
```
The best way to configure providers depends on your specific needs. If you are only using a single provider, then configuring it in the root module is the simplest option. If you are using multiple providers, or if you want to reuse the same provider configuration in multiple resources, then configuring it in a child module is a good option. And if you want to make sure that a specific provider version is used, then configuring it in the required_providers block is the best option.

### Multiple Providers
You can use multiple providers in one single terraform project. For example,

1. Create a providers.tf file in the root directory of your Terraform project.
2. In the providers.tf file, define the AWS and Azure providers. For example:
```hcl
provider "aws" {
  region = "us-east-1"
}

provider "azurerm" {
  subscription_id = "your-azure-subscription-id"
  client_id = "your-azure-client-id"
  client_secret = "your-azure-client-secret"
  tenant_id = "your-azure-tenant-id"
}
```

3. In your other Terraform configuration files, you can then use the aws and azurerm providers to create resources in AWS and Azure, respectively,
```hcl
resource "aws_instance" "example" {
  ami = "ami-0123456789abcdef0"
  instance_type = "t2.micro"
}

resource "azurerm_virtual_machine" "example" {
  name = "example-vm"
  location = "eastus"
  size = "Standard_A1"
}
```

## 2. Resource
A resource is a specific infrastructure component that you want to create and manage using Terraform. Resources can include virtual machines, databases, storage buckets, network components, and more. Each resource has a type and configuration parameters that you define in your Terraform code.

## 3. Module
A Terraform module is a reusable and self-contained collection of Terraform configuration files that groups related resources together. Modules help organize infrastructure code, improve reusability, and reduce duplication. Terraform provides a root module by default, and additional child modules can be created or sourced from the Terraform Registry.
Benefits of Modules:

- **Reusability:** Use the same infrastructure code across multiple projects and environments.
- **Modularity:** Break complex infrastructure into smaller, manageable components.
- **Maintainability:** Update infrastructure logic in one place.
- **Consistency:** Enforce standardized configurations across deployments.
- **Collaboration:** Teams can work independently on different modules.
- **Versioning:** Modules can be version-controlled and upgraded safely.
- **Abstraction:** Hide implementation details and expose only required inputs and outputs.
- **Scalability:** Supports large and complex infrastructure deployments

Modules can be your own creations or come from the Terraform Registry, which hosts community-contributed modules.

## 4. Configuration File
Terraform uses configuration files (often with a .tf extension) to define the desired infrastructure state. These files specify providers, resources, variables, and other settings. The primary configuration file is usually named main.tf, but you can use multiple configuration files as well.

## 5. Variable 
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

```hcl
output "example_output" {
  description = "An example output variable"
  value       = resource.example_resource.example.id
}
```

You can reference output variables in the root module or in other modules by using the syntax module.module_name.output_name, where module_name is the name of the module containing the output variable.
For example, if you have an output variable named example_output in a module called example_module, you can access it in the root module like this:

```hcl
output "root_output" {
  value = module.example_module.example_output
}
```
This allows you to share data and values between different parts of your Terraform configuration and create more modular and maintainable infrastructure-as-code setups.

## 6. Terraform tfvars
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

## 7. State File 
Terraform maintains a state file (often named terraform.tfstate) that keeps track of the current state of your infrastructure. This file is crucial for Terraform to understand what resources have been created and what changes need to be made during updates.
This file, often named ```terraform.tfstate```, is a JSON or HCL (HashiCorp Configuration Language) formatted

### Advantages of Terraform State File:
**1. Resource Tracking:** The state file keeps track of all the resources managed by Terraform, including their attributes and dependencies. This ensures that Terraform can accurately update or destroy resources when necessary.

**2. Concurrency Control:** Terraform uses the state file to lock resources, preventing multiple users or processes from modifying the same resource simultaneously. This helps avoid conflicts and ensures data consistency.

**3. Plan Calculation:** Terraform uses the state file to calculate and display the difference between the desired configuration (defined in your Terraform code) and the current infrastructure state. This helps you understand what changes Terraform will make before applying them.

**4. Resource Metadata:** The state file stores metadata about each resource, such as unique identifiers, which is crucial for managing resources and understanding their relationships.

### Disadvantages of Storing Terraform State in Version Control Systems (VCS):
**1. Security Risks:** Sensitive information, such as API keys or passwords, may be stored in the state file if it's committed to a VCS. This poses a security risk because VCS repositories are often shared among team members.

**2. Versioning Complexity:** Managing state files in VCS can lead to complex versioning issues, especially when multiple team members are working on the same infrastructure.

### Overcoming Disadvantages with Remote Backends (e.g., S3):
A remote backend stores the Terraform state file outside of your local file system and version control. Using S3 as a remote backend is a popular choice due to its reliability and scalability. Here's how to set it up:

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
Replace ```"your-terraform-state-bucket"``` and ```"path/to/your/terraform.tfstate"``` with your S3 bucket and desired state file path.

**3. DynamoDB Table for State Locking:**
To enable state locking, create a DynamoDB table and provide its name in the dynamodb_table field. This prevents concurrent access issues when multiple users or processes run Terraform.

### State Locking with DynamoDB:
DynamoDB is used for state locking when a remote backend is configured. It ensures that only one user or process can modify the Terraform state at a time. Here's how to create a DynamoDB table and configure it for state locking:

**1. Create a DynamoDB Table:**
You can create a DynamoDB table using the AWS Management Console or AWS CLI. Here's an AWS CLI example:
```aws dynamodb create-table --table-name your-dynamodb-table --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5```

**2.Configure the DynamoDB Table in Terraform Backend Configuration:**
In your Terraform configuration, as shown above, provide the DynamoDB table name in the dynamodb_table field under the backend configuration.

By following these steps, you can securely store your Terraform state in S3 with state locking using DynamoDB, mitigating the disadvantages of storing sensitive information in version control systems and ensuring safe concurrent access to your infrastructure. 

## 8. Plan
A Terraform plan is a preview of changes that Terraform will make to your infrastructure. When you run terraform plan, Terraform analyzes your configuration and current state, then generates a plan detailing what actions it will take during the apply step.

## 9. Apply
The terraform apply command is used to execute the changes specified in the plan. It creates, updates, or destroys resources based on the Terraform configuration.

## 10. Workspace
Workspaces in Terraform are a way to manage multiple environments (e.g., development, staging, production) with separate configurations and state files. Workspaces help keep infrastructure configurations isolated and organized.

## 11. Remote Backend 
A remote backend is a storage location for your Terraform state files that is not stored locally. Popular choices for remote backends include Amazon S3, Azure Blob Storage, or HashiCorp Terraform Cloud. Remote backends enhance collaboration and provide better security and reliability for your state files.

## 12. Multiple Region Implementation in Terraform
You can make use of alias keyword to implement multi region infrastructure setup in terraform
Note: ```provider = aws.us-east-1``` uses the AWS provider alias ```us-east-1``` to create the resource in that specific provider configuration

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

## 13. Conditional Expressions
Conditional expressions in Terraform are used to define conditional logic within your configurations. They allow you to make decisions or set values based on conditions. Conditional expressions are typically used to control whether resources are created or configured based on the evaluation of a condition.

The syntax for a conditional expression in Terraform is:
```hcl
condition ? true_val : false_val
```
**Conditional Resource Creation Example**
```hcl
resource "aws_instance" "example" {
  count = var.create_instance ? 1 : 0

  ami           = "ami-XXXXXXXXXXXXXXXXX"
  instance_type = "t2.micro"
}
```
In this example, the count attribute of the aws_instance resource uses a conditional expression. If the create_instance variable is true, it creates one EC2 instance. If create_instance is false, it creates zero instances, effectively skipping resource creation.

## 14. Built-in Functions
Terraform provides a wide range of built-in functions that you can use within your configuration files (usually written in HashiCorp Configuration Language, or HCL) to manipulate and transform data. These functions help you perform various tasks when defining your infrastructure. Here are some commonly used built-in functions in Terraform:

1. **concat(list1, list2, ...): Combines multiple lists into a single list.**
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

2. **element(list, index): Returns the element at the specified index in a list.**
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

3. **map(key, value): Creates a map from a list of keys and a list of values.**
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

4. **lookup(map, key): Retrieves the value associated with a specific key in a map.**
```hcl
variable "my_map" {
  type    = map(string)
  default = {"name" = "Alice", "age" = "30"}
}

output "value" {
  value = lookup(var.my_map, "name") # Returns "Alice"
}
join(separator, list): Joins the elements of a list into a single string using the specified separator.
variable "my_list" {
  type    = list
  default = ["apple", "banana", "cherry"]
}

output "joined_string" {
  value = join(", ", var.my_list) # Returns "apple, banana, cherry"
}
```
These are just a few examples of the built-in functions available in Terraform. You can find more functions and detailed documentation in the official Terraform documentation, which is regularly updated to include new features and improvements

## 15.Provisioners
A Provisioner is used to execute scripts or commands after a resource is created (or before it's destroyed).

Think of it as: Resource Creation → Provisioner Runs → Additional Configuration

For example:
Create an EC2 instance
SSH into the instance
Install Apache/Nginx
Copy files

All of this can be done using a provisioner.

### Types of Provisioners
**1. file Provisioner:**
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

In this example, the ```file`` provisioner copies the ```localfile.txt``` from the local machine to the ```/path/on/remote/instance/file.txt``` location on the AWS EC2 instance using an SSH connection.


**2. remote-exec Provisioner:**
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

**3. local-exec Provisioner:**

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

