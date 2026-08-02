Q1: What is a Provider?

A provider is a plugin that enables Terraform to interact with cloud providers and external services through their APIs.

Q2: Is Provider Different from Resource?

Provider

Plugin
Connects Terraform to AWS/Azure/Docker

Resource: Actual infrastructure object

Provider = AWS connection

Resource = EC2 instance

Q3: What Happens During terraform init?
Downloads required providers
Installs provider plugins
Initializes backend
Creates .terraform directory
