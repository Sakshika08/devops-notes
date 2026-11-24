## Why did you use Ansible?
We used Ansible for configuration management and server automation. Instead of manually logging into multiple Linux servers and performing the same steps repeatedly, we automated those tasks using Ansible playbooks. This helped ensure consistency, reduced human errors, and saved time during deployments and server provisioning.

## Tasks I performed using Ansible
We primarily used Ansible for configuration management and server automation. I created and executed playbooks for package installation, service management, configuration file deployment using templates, Docker and Nginx setup, user management, and patching activities. We also integrated Ansible with Jenkins to automate configuration and operational tasks during releases, ensuring consistent configurations across multiple Linux servers.

### 1. Package Installation
I used Ansible to automate package installation across multiple Linux servers, ensuring all servers had the required software versions.
```
- name: Install packages
  yum:
    name:
      - docker
      - git
      - unzip
    state: present
```

### 2. Service Management
We used Ansible to manage services such as Docker, Nginx, and application services across environments.
```
service:
  name: docker
  state: started
  enabled: yes
```

## 3. Configuration File Deployment
I used templates to deploy environment-specific configuration files while keeping a single reusable template.
```
template:
  src: app.conf.j2
  dest: /etc/app/app.conf
```

## 4. User and Permission Management
We automated user creation, SSH key deployment, and permission management on Linux servers.
```
user:
  name: appuser
  state: present
```

## 6. Patch Management
Ansible was used for regular OS patching and package updates across multiple servers.
```
- name: Update packages
  yum:
    name: "*"
    state: latest
```

## Q. Explain Ansible Architecture.
Control Node = Machine where Ansible is installed.  
Managed Nodes = Target servers managed by Ansible.  
Inventory = List of managed hosts.  
Playbook = YAML file containing automation tasks.  
Modules = Units of work executed on managed nodes.  
SSH = Communication method between control node and managed nodes.  

Ansible works on a Control Node → connects to Managed Nodes via SSH → executes modules defined in Playbooks against hosts from Inventory.

## 2. Variables in Ansible
Variables allow us to make playbooks reusable and avoid hardcoded values.
```
vars:
  app_name: nginx

tasks:
  - name: Install package
    yum:
      name: "{{ app_name }}"
      state: present
```

## 3. Facts & Gather Facts
`ansible all -m setup`  
What are Facts?  
Facts are system information about managed hosts.  
Facts are automatically gathered system variables that can be used for conditional logic and dynamic configurations.
Examples:  
- OS
- IP address
- Hostname
- CPU
- Memory

Example:  
```
{{ ansible_hostname }}
{{ ansible_os_family }}
{{ ansible_default_ipv4.address }}
```

## Tags
Tags allow us to execute only specific tasks from a playbook instead of running the entire playbook.
```
tasks:
  - name: Install nginx
    yum:
      name: nginx
      state: present
    tags: install
```
Run: `ansible-playbook site.yml --tags install `

## Register
Register captures the output of a task and stores it in a variable for later use.
```
- name: Check uptime
  command: uptime
  register: uptime_output

- debug:
    var: uptime_output.stdout
```
## Become
`become_user: yes` or `become: root`  
Become is used for privilege escalation, similar to sudo in Linux.

## Include vs Import
Both import_tasks and include_tasks are used to split large playbooks into smaller task files, improving reusability and maintainability.  
The main difference is when Ansible loads the task file:  
**import_tasks** is static. Ansible reads and imports the task file during playbook parsing, before execution starts.
Use when tasks are always required.  
**include_tasks** is dynamic. Ansible loads the task file (at runtime) only when execution reaches that statement, allowing conditional and runtime decisions.  
Use when tasks need to be loaded conditionally 
```
---
- hosts: web
  become: yes
  tasks:
    - import_tasks: common.yml
```
With import_tasks, Ansible reads common.yml before execution begins and adds those tasks to the playbook.


```
tasks:
  - include_tasks: common.yml
```
With include_tasks, Ansible loads common.yml only when that task is encountered during execution.


**Why does it matter?**  
Because include_tasks can be conditional.  
Ansible decides at runtime whether to load the file.  
With import_tasks, the file is loaded regardless because parsing happens before execution.
```
- include_tasks: install.yml
  when: ansible_os_family == "RedHat"
```

**What gets loaded?**
The file being loaded is typically a task file, not a complete playbook.  
A complete playbook containing hosts: and tasks: cannot be used with import_tasks or include_tasks.  
For complete playbooks, use: `- import_playbook: web.yml`

Note>> A playbook can import another playbook using import_playbook. There is no include_playbook module. Dynamic inclusion is supported for tasks and roles using include_tasks and include_role, but complete playbooks are imported statically using import_playbook.

import_playbook:	Import an entire playbook  
import_tasks:	Import a task file (static)  
include_tasks:	Include a task file (dynamic)  
import_role:	Import a role (static)  
include_role:	Include a role (dynamic  

```
---
- hosts: web

  tasks:

    - name: Always run common tasks
      import_tasks: common.yml

    - name: Run Docker tasks only if needed
      include_tasks: docker.yml
      when: install_docker

    - name: Run Kubernetes tasks only in prod
      include_tasks: k8s.yml
      when: env == "prod"

```

## Blocks
Blocks are used to group tasks and implement error handling using block, rescue, and always sections.  
If a task inside the block fails, execution moves to the rescue section where corrective actions such as rollback, logging, or notifications can be performed. The always section runs regardless of success or failure, similar to a finally block in programming.  
```
block:
  - name: Install package
    yum:
      name: nginx
      state: present

rescue:
  - debug:
      msg: "Installation failed"
always:
  - debug:
      msg: "Block Completed"
```

## Dynamic Inventory
In AWS environments, Ansible Dynamic Inventory uses the AWS EC2 API to discover instances dynamically instead of relying on a manually maintained inventory file. Instances are typically grouped using EC2 tags such as Role=web, Role=db, or Environment=prod. During inventory refresh, Ansible queries AWS, reads these tags, and automatically places servers into the appropriate inventory groups. As a result, newly created EC2 instances are discovered and grouped automatically without manual inventory updates.
```
plugin: amazon.aws.aws_ec2

keyed_groups:
  - prefix: role
    key: tags.Role

  - prefix: env
    key: tags.Environment
```

In enterprise environments, inventory discovery is often automated through **Ansible Tower inventory syncs** or triggered from provisioning workflows such as Terraform, Jenkins, or AWS EventBridge.

## CI/CD Integration
We commonly use Ansible in CI/CD pipelines for configuration management, server automation, patching activities, and post-deployment tasks.
    Jenkins  
        ↓
Ansible Playbook  
        ↓
Configuration Updates  
        ↓
Service Management  
        ↓
Validation Checks  

## Q: What is the difference between copy and template in Ansible?
The copy module transfers a file to the target server exactly as it is, without modifying its contents. 
The template module processes a Jinja2 (.j2) template first, replacing variables and expressions with actual values, and then copies the rendered file to the target server.  
For example, if I need the same configuration file on multiple servers but with different hostnames, IPs, or environment-specific values, I would use the template module. If the file content is static and does not require variable substitution, I would use the copy module.

template = renders Jinja2 variables before copying; copy = copies the file as-is.


What is a Handler?  
A handler is a task that runs only when notified by a changed task, typically used for service restart or reload operations.

```
---
- hosts: web
  become: yes

  tasks:
    - name: Install nginx
      yum:
        name: nginx
        state: present
        
    - name: Deploy Nginx config
      template:
        src: nginx.conf.j2
        dest: /etc/nginx/nginx.conf
      notify: Restart Nginx

  handlers:
    - name: Restart Nginx
      service:
        name: nginx
        state: restarted
```

---

**What is Inventory?**    
Inventory is a file that contains the list of servers Ansible manages, either as individual hosts or grouped hosts.

**What is a Playbook?**    
A playbook is a YAML file that defines a sequence of tasks to be executed on managed hosts.

**What is a Role?**   
A role is a reusable and modular way to organize Ansible content such as tasks, handlers, templates, variables, and files.

**What is a Handler?**   
A handler is a task that runs only when notified by a changed task, commonly used to restart or reload services.

**What is a Template?**  
A template is a Jinja2-based file that renders variables dynamically before being copied to the target host.

**What is Ansible Vault?**  
Ansible Vault is used to encrypt and securely store sensitive data such as passwords, tokens, and API keys.

**Indempotency**: if we run a playbook to insatll httpd package twice, ansible won’t do anything the second time becouse the “state” is already recahed.

## If an Ansible playbook execution fails,how do you trobleshoot?
If an Ansible playbook execution fails, I first check the exact error message in the playbook output using increased verbosity: ` ansible-playbook playbook.yml -vvv `  
This provides detailed information about the failed task, module, and target host.  

Next, I identify the task that failed and verify its parameters, variables, and syntax. If required, I validate the playbook syntax using: ` ansible-playbook playbook.yml --syntax-check `  

Then, I check inventory and connectivity to the target hosts: ` ansible all -m ping `  
This helps determine whether SSH access or authentication is causing the issue.  
If the failure is related to variables, I verify that all required variables are defined and have the correct values. I also review inventory files, group variables, and host variables.  
For module-specific failures, I check the target server logs and validate prerequisites such as package repositories, permissions, disk space, network connectivity, or service availability.  
Finally, I rerun the playbook after fixing the issue and verify that all tasks complete successfully.

---
-m = Module to run
-a = Arguments for that module
`ansible all -m ping`   
Run ad-hoc command:  `ansible web -m command -a "uptime"`    
`ansible all -m setup` → Collects system information about hosts.  
`ansible web -m yum -a "name=nginx state=present"`  → Installs nginx on RHEL/CentOS.  
`ansible web -m service -a "name=nginx state=started"` → Starts nginx service.  
`ansible-playbook site.yml --check` → Shows what changes would occur without making them.  
`ansible-playbook site.yml --diff` → Displays file/config changes.  
`ansible-playbook -i inventory.ini site.yml` → Uses specified inventory file.  
`ansible-playbook site.yml --limit web` → Runs only on web hosts.  
`ansible-vault encrypt secrets.yml` → Encrypts sensitive files.  

