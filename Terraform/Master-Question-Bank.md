Q1: What is a Provider?
A provider is a plugin that enables Terraform to interact with cloud providers and external services through their APIs.

Q2: Is Provider Different from Resource?
Provider: Plugin Connects Terraform to AWS/Azure/Docker
Resource: Actual infrastructure object


Q3: What Happens During terraform init?
Downloads required providers
Installs provider plugins
Initializes backend
Creates .terraform directory

Q: What is the difference between Terraform block and Provider block?
The terraform block configures Terraform itself, including Terraform version requirements and provider version constraints. 
The provider block configures the connection to the target platform, such as AWS, Azure, or GCP, including region and authentication settings. 
The terraform block ensures consistency and version compatibility, while the provider block enables Terraform to interact with cloud resources.

Q: How do you make a subnet public in AWS?
A subnet becomes public when it has a route to an Internet Gateway through a route table.
to create a public subnet you need to create a route table first for that subnet to have route table and destination for the route table has to be internet gateway.
and then you need to assiciated this route table to the subent so it become a public subent.

Q: What is the most secure way to authenticate Terraform with AWS?
The most secure way to authenticate Terraform with AWS is by using IAM Roles with temporary credentials instead of long-lived access keys. 
Terraform can assume an IAM Role and obtain temporary credentials from AWS STS, eliminating the need to store AWS access keys and secret keys.

Why IAM Roles?
Benefits
- Temporary credentials
- Automatically rotated
- No hardcoded secrets
- Least privilege access

Q: Do we need to configure AWS credentials as environment variables when using IAM Roles?
No. When using IAM Roles, Terraform can automatically obtain temporary credentials from AWS STS. 
For example, on an EC2 instance with an attached IAM Role, an EKS pod using IRSA, or GitHub Actions using OIDC, there is no need to store or configure AWS Access Keys and Secret Keys as environment variables.

Q: Where is Terraform state stored in AWS?
In production environments, Terraform state is typically stored in an S3 bucket, 
while DynamoDB is used for state locking to prevent multiple users from modifying the same infrastructure simultaneously.

Q: What is the difference between Terraform OSS and HCP Terraform?
Terraform OSS is the open-source Infrastructure as Code engine used to provision and manage infrastructure. 
HCP Terraform is HashiCorp's managed platform that provides additional capabilities such as remote state management, collaboration, governance, policy enforcement, and remote execution of Terraform runs. The actual infrastructure provisioning is still performed by Terraform.

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
### Q Why do we use modules in Terraform?
Answer
Modules improve:
Reusability
Maintainability
Standardization
Code organization
Instead of writing VPC code repeatedly across projects, we create a reusable VPC module and call it wherever needed.

### 4. How do you pass values from one module to another?
Answer
Using outputs from one module and variables in another module.
Example:
```
module "ec2" {
  source        = "./modules/ec2"
  subnet_id     = module.vpc.subnet_id
}
```
Here: ```module.vpc.subnet_id``` comes from the VPC module output and is passed into the EC2 module.

### Q: What happens if you forget to declare a variable in the child module?

**Answer:**

Terraform throws an error because the variable is not defined in that module.

**Example:**

```hcl
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
}
```
But variable "vpc_cidr" {} is missing.

Terraform fails during validation or plan.
