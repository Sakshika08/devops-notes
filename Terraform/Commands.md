# Terraform Commands

## Basic Workflow

### Initialize Terraform

```bash
terraform init
```

Initializes the working directory and downloads required providers and modules.

---

### Format Terraform Files

```bash
terraform fmt
```

Automatically reformats all configuration files in the current directory according to HashiCorp's recommended style. Terraform prints the names of the files it modified, if any.

---

### Validate Configuration

```bash
terraform validate
```

Checks whether the Terraform configuration is syntactically valid and internally consistent.

---

## Terraform Workspace Commands

### Create a New Workspace

```bash
terraform workspace new <name>
```

Example:

```bash
terraform workspace new dev
```

Creates a new workspace named `dev`.


Terraform creates separate state files for workspaces under:

```text
terraform.tfstate.d/
```

---

### Switch Workspace

```bash
terraform workspace select dev
```

Switches the current workspace to `dev`.

---

### List Workspaces

```bash
terraform workspace list
```

Displays all available workspaces.

Example:

```text
default
dev
stage
prod
```

---

### Delete Workspace

```bash
terraform workspace delete dev
```

Deletes a workspace.

> Note: You cannot delete the currently selected workspace.

---

## Plan and Apply Commands

### Create Execution Plan

```bash
terraform plan
```

Shows what Terraform will create, modify, or destroy without making any actual changes.

---

### Save Execution Plan

```bash
terraform plan -out=tfplan
```

Saves the execution plan to a file instead of displaying it only on the screen.

**Why use it?**

* Review the plan before applying.
* Ensures the exact reviewed plan is applied later.

---

### Show Saved Plan

```bash
terraform show tfplan
```

Displays the contents of a saved plan file.

---

### Apply Changes

```bash
terraform apply
```

Creates or updates infrastructure based on the Terraform configuration.

---

### Apply Saved Plan

```bash
terraform apply tfplan
```

Applies the saved execution plan.

---

### Apply Using Variable File

```bash
terraform apply -var-file=stage.tfvars
```

Applies the configuration using variables defined in `stage.tfvars`.

---


### Apply Without Confirmation

```bash
terraform apply -auto-approve
```

Applies changes without asking for confirmation.  
Commonly used in CI/CD pipelines.

---


## Terraform State Commands

### List Resources in State

```bash
terraform state list
```

Lists all resources and data sources currently tracked in the Terraform state.

---

### Show Complete State

```bash
terraform show
```

Prints the entire state of the current workspace.

---

## Output Commands

### Show Complete State

```bash
terraform show
```
Prints the entire state of the current workspace.

---

### View Output Values

```bash
terraform output
```

Displays the output values defined in the Terraform configuration.

---

## Provider Commands

### Show Providers

```bash
terraform providers
```

Displays all providers being used by the current configuration.

Example:

```text
provider.aws
provider.kubernetes
provider.helm
```

---

### Upgrade Providers

```bash
terraform init -upgrade
```

Downloads newer provider versions that satisfy the version constraints.

---

## Backend Commands

### Initialize Backend Configuration

```bash
terraform init -backend-config=backend.hcl
```

Initializes Terraform using backend settings stored in a separate file.

Commonly used with S3 backends.

---


## Terraform State Commands

### List Resources in State

```bash
terraform state list
```

Lists all resources and data sources currently tracked in the Terraform state.

---

### Show Resource Details

```bash
terraform state show aws_instance.web
```

Displays detailed information about a specific resource in the Terraform state.

---

### Remove Resource from State

```bash
terraform state rm aws_instance.web
```

Removes a resource from Terraform state without deleting the actual infrastructure.

**Use Case:**

When Terraform should stop managing a resource, but the resource must remain in AWS.

---

### Move/Rename State Entry

```bash
terraform state mv aws_instance.old aws_instance.new
```

Moves or renames resources within the Terraform state.

Commonly used during refactoring.

---

## State Locking

### Force Unlock State

```bash
terraform force-unlock LOCK_ID
```
Removes a stale state lock.

**Common Interview Scenario:**

A Terraform execution was interrupted, leaving the state file locked in DynamoDB.

---


## Import Existing Resources

### Import Existing Infrastructure

```bash
terraform import aws_instance.web i-1234567890abcdef
```

Imports an existing resource into Terraform state.


**Common Interview Scenario:**

An EC2 instance already exists in AWS and needs to be managed by Terraform.

---

### Refresh State

```bash
terraform -refresh-only
```

Updates the Terraform state file to match the real infrastructure.

**Interview Scenario:**
Someone manually changed an AWS resource outside Terraform.

---

## Console

### Open Terraform Console

```bash
terraform console
```

Starts an interactive Terraform shell.

Example:

```bash
> var.environment
"dev"
```

Useful for testing expressions, variables, and functions.

---

## Destroy Infrastructure

### Destroy All Resources

```bash
terraform destroy
```

Destroys all resources managed by Terraform.

---

### Destroy Without Confirmation

```bash
terraform destroy -auto-approve
```

Destroys infrastructure without prompting for approval.
Commonly used in automated environments.

---

### Destroy a Specific Resource

```bash
terraform destroy -target=<resource_type>.<resource_name>
```

Example:

```bash
terraform destroy -target=aws_instance.web_server
```

Destroys only the specified resource.

---

### Destroy a Resource Inside a Module

```bash
terraform destroy -target=module.eks.aws_eks_cluster.this
```

Destroys only the targeted resource within the module.

---

### Destroy Multiple Resources

```bash
terraform destroy \
  -target=aws_instance.web_server \
  -target=aws_security_group.web_sg
```

Destroys multiple specified resources.

---

### Review Targeted Destroy Plan

```bash
terraform plan -destroy -target=aws_instance.web_server
```

Shows what Terraform will destroy before executing the actual destroy command.

> **Note:** Use `-target` cautiously. It is primarily intended for exceptional situations and may result in partial infrastructure changes if dependencies exist.

---




## Interview-Favorite Commands

```bash
terraform init
terraform fmt
terraform validate

terraform workspace new dev
terraform workspace select dev
terraform workspace list
terraform workspace delete dev

terraform plan
terraform plan -out=tfplan

terraform apply
terraform apply tfplan
terraform apply -var-file=stage.tfvars
terraform apply -auto-approve

terraform state list
terraform state show
terraform state rm
terraform state mv

terraform destroy
terraform destroy -auto-approve
terraform destroy -target=aws_instance.web

terraform import
terraform output
terraform show

terraform providers
terraform console

terraform force-unlock LOCK_ID
terraform init -upgrade
```
