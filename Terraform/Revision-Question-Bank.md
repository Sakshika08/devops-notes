Most Secure AWS Authentication Method?
IAM Roles with temporary credentials obtained through AWS STS.

What is OIDC?
OpenID Connect allows CI/CD platforms such as GitHub Actions to securely assume AWS IAM Roles without storing AWS access keys.

Do IAM Roles Need Environment Variables?
No. Terraform automatically retrieves temporary credentials when an IAM Role is available.


# Terraform Commands

<br>

## Basic Workflow

<br>

### Initialize Terraform

<br>

```bash
terraform init
```

<br>

Initializes the working directory and downloads required providers and modules.

<br>

---

<br>

### Format Terraform Files

<br>

```bash
terraform fmt
```

<br>

Automatically reformats all configuration files in the current directory according to HashiCorp's recommended style. Terraform prints the names of the files it modified, if any.

<br>

---

<br>

### Validate Configuration

<br>

```bash
terraform validate
```

<br>

Checks whether the Terraform configuration is syntactically valid and internally consistent.

<br>

---

<br>

## Terraform Workspace Commands

<br>

### Create a New Workspace

<br>

```bash
terraform workspace new <name>
```

<br>

Example:

<br>

```bash
terraform workspace new dev
```

<br>

Creates a new workspace named `dev`.

<br>

Terraform creates separate state files for workspaces under:

<br>

```text
terraform.tfstate.d/
```

<br>

---

<br>

### Switch Workspace

<br>

```bash
terraform workspace select dev
```

<br>

Switches the current workspace to `dev`.

<br>

---

<br>

### List Workspaces

<br>

```bash
terraform workspace list
```

<br>

Displays all available workspaces.

<br>

Example:

<br>

```text
default
dev
stage
prod
```

<br>

---

<br>

### Delete Workspace

<br>

```bash
terraform workspace delete dev
```

<br>

Deletes a workspace.

<br>

> Note: You cannot delete the currently selected workspace.

<br>

---

<br>

## Plan and Apply Commands

<br>

### Create Execution Plan

<br>

```bash
terraform plan
```

<br>

Shows what Terraform will create, modify, or destroy without making any actual changes.

<br>

---

<br>

### Save Execution Plan

<br>

```bash
terraform plan -out=tfplan
```

<br>

Saves the execution plan to a file instead of displaying it only on the screen.

<br>

**Why use it?**

<br>

* Review the plan before applying.
* Ensures the exact reviewed plan is applied later.

<br>

---

<br>

### Show Saved Plan

<br>

```bash
terraform show tfplan
```

<br>

Displays the contents of a saved plan file.

<br>

---

<br>

### Apply Changes

<br>

```bash
terraform apply
```

<br>

Creates or updates infrastructure based on the Terraform configuration.

<br>

---

<br>

### Apply Saved Plan

<br>

```bash
terraform apply tfplan
```

<br>

Applies the saved execution plan.

<br>

---

<br>

### Apply Using Variable File

<br>

```bash
terraform apply -var-file=stage.tfvars
```

<br>

Applies the configuration using variables defined in `stage.tfvars`.

<br>

---

<br>

### Apply Without Confirmation

<br>

```bash
terraform apply -auto-approve
```

<br>

Applies changes without asking for confirmation.

<br>

Commonly used in CI/CD pipelines.

<br>

---

<br>

## Output Commands

<br>

### Show Complete State

<br>

```bash
terraform show
```

<br>

Prints the entire state of the current workspace.

<br>

---

<br>

### View Output Values

<br>

```bash
terraform output
```

<br>

Displays the output values defined in the Terraform configuration.

<br>

---

<br>

## Provider Commands

<br>

### Show Providers

<br>

```bash
terraform providers
```

<br>

Displays all providers being used by the current configuration.

<br>

Example:

<br>

```text
provider.aws
provider.kubernetes
provider.helm
```

<br>

---

<br>

### Upgrade Providers

<br>

```bash
terraform init -upgrade
```

<br>

Downloads newer provider versions that satisfy the version constraints.

<br>

---

<br>

## Backend Commands

<br>

### Initialize Backend Configuration

<br>

```bash
terraform init -backend-config=backend.hcl
```

<br>

Initializes Terraform using backend settings stored in a separate file.

<br>

Commonly used with S3 backends.

<br>

---

<br>

## Terraform State Commands

<br>

### List Resources in State

<br>

```bash
terraform state list
```

<br>

Lists all resources and data sources currently tracked in the Terraform state.

<br>

---

<br>

### Show Resource Details

<br>

```bash
terraform state show aws_instance.web
```

<br>

Displays detailed information about a specific resource in the Terraform state.

<br>

---

<br>

### Remove Resource from State

<br>

```bash
terraform state rm aws_instance.web
```

<br>

Removes a resource from Terraform state without deleting the actual infrastructure.

<br>

**Use Case:**

<br>

When Terraform should stop managing a resource, but the resource must remain in AWS.

<br>

---

<br>

### Move/Rename State Entry

<br>

```bash
terraform state mv aws_instance.old aws_instance.new
```

<br>

Moves or renames resources within the Terraform state.

<br>

Commonly used during refactoring.

<br>

---

<br>

### Refresh State

<br>

```bash
terraform refresh
```

<br>

Updates the Terraform state file to match the real infrastructure.

<br>

**Interview Scenario:**

<br>

Someone manually changed an AWS resource outside Terraform.

<br>

---

<br>

## Import Existing Resources

<br>

### Import Existing Infrastructure

<br>

```bash
terraform import aws_instance.web i-1234567890abcdef
```

<br>

Imports an existing resource into Terraform state.

<br>

**Common Interview Scenario:**

<br>

An EC2 instance already exists in AWS and needs to be managed by Terraform.

<br>

---

<br>

## Console

<br>

### Open Terraform Console

<br>

```bash
terraform console
```

<br>

Starts an interactive Terraform shell.

<br>

Example:

<br>

```bash
> var.environment
"dev"
```

<br>

Useful for testing expressions, variables, and functions.

<br>

---

<br>

## State Locking

<br>

### Force Unlock State

<br>

```bash
terraform force-unlock LOCK_ID
```

<br>

Removes a stale state lock.

<br>

**Common Interview Scenario:**

<br>

A Terraform execution was interrupted, leaving the state file locked in DynamoDB.

<br>

---

<br>

## Destroy Infrastructure

<br>

### Destroy All Resources

<br>

```bash
terraform destroy
```

<br>

Destroys all resources managed by Terraform.

<br>

---

<br>

### Destroy Without Confirmation

<br>

```bash
terraform destroy -auto-approve
```

<br>

Destroys infrastructure without prompting for approval.

<br>

Commonly used in automated environments.

<br>

---

<br>

### Destroy a Specific Resource

<br>

```bash
terraform destroy -target=<resource_type>.<resource_name>
```

<br>

Example:

<br>

```bash
terraform destroy -target=aws_instance.web_server
```

<br>

Destroys only the specified resource.

<br>

---

<br>

### Destroy a Resource Inside a Module

<br>

```bash
terraform destroy -target=module.eks.aws_eks_cluster.this
```

<br>

Destroys only the targeted resource within the module.

<br>

---

<br>

### Destroy Multiple Resources

<br>

```bash
terraform destroy \
  -target=aws_instance.web_server \
  -target=aws_security_group.web_sg
```

<br>

Destroys multiple specified resources.

<br>

---

<br>

### Review Targeted Destroy Plan

<br>

```bash
terraform plan -destroy -target=aws_instance.web_server
```

<br>

Shows what Terraform will destroy before executing the actual destroy command.

<br>

> **Note:** Use `-target` cautiously. It is primarily intended for exceptional situations and may result in partial infrastructure changes if dependencies exist.

<br>

---

<br>

## Interview-Favorite Commands

<br>

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

terraform import

terraform output
terraform show

terraform providers

terraform console

terraform force-unlock LOCK_ID

terraform destroy
terraform destroy -auto-approve
terraform destroy -target=aws_instance.web

terraform init -upgrade
```

<br>
