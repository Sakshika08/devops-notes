### EC2 intance all main.ft, output.ft and variable.tf files
**main.tf**
```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
    ami = var.ami_value
    instance_type = var.instance_type_value
    subnet_id = var.subnet_id_value
    associate_public_ip_address = true
}
```
**output.tf**
```hcl
output "public-ip-address" {
  value = aws_instance.example.public_ip
}
```

**variable.tf**
```hcl
variable "ami_value" {
    description = "value for the ami"
}

variable "instance_type_value" {
    description = "value for instance_type"
}

variable "subnet_id_value" {
    description = "value for the subnet_id"
}
```
