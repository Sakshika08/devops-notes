## Why did you use Ansible?
We used Ansible for configuration management and server automation. Instead of manually logging into multiple Linux servers and performing the same steps repeatedly, we automated those tasks using Ansible playbooks. This helped ensure consistency, reduced human errors, and saved time during deployments and server provisioning.

## Tasks I performed using Ansible
We primarily used Ansible for configuration management and server automation. I created and executed playbooks for package installation, service management, application deployment, configuration file deployment using templates, Docker and Nginx setup, user management, and patching activities. We also integrated Ansible with Jenkins, where Jenkins triggered Ansible playbooks during deployments to ensure consistent configurations across multiple Linux servers. This reduced manual effort and helped maintain standardization across environments.

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

## 4. Application Deployment
After Jenkins built the application, Ansible was used to deploy the artifact to target servers and restart the service.
```
copy:
  src: app.jar
  dest: /opt/app/
```
## 5. User and Permission Management
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
Answer:  
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
```
import_tasks: common.yml
include_tasks: common.yml
```
Difference:

import_tasks → static, loaded before execution.
include_tasks → dynamic, loaded during execution.

For interviews: import_tasks is static, include_tasks is dynamic.

## Blocks
Blocks are used to group tasks and implement error handling using block, rescue, and always sections.
```
block:
  - name: Install package
    yum:
      name: nginx
      state: present

rescue:
  - debug:
      msg: "Installation failed"
```

## Dynamic Inventory
For AWS: aws_ec2.yml  
Instead of manually maintaining inventory:
```
[web]
10.1.1.10
10.1.1.11
```
Ansible can automatically discover EC2 instances.

In cloud environments we generally use Dynamic Inventory so newly created EC2 instances are automatically discovered.

## CI/CD Integration
We commonly use Ansible in CI/CD pipelines for application deployment, configuration management, and post-deployment tasks.
```
GitHub/Jenkins
        ↓
Ansible Playbook
        ↓
Deploy Application
        ↓
Restart Service
```

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

What is Inventory?  
Inventory is a file that contains the list of servers Ansible manages, either as individual hosts or grouped hosts.

What is a Playbook?  
A playbook is a YAML file that defines a sequence of tasks to be executed on managed hosts.

What is a Role?   
A role is a reusable and modular way to organize Ansible content such as tasks, handlers, templates, variables, and files.

What is a Handler?   
A handler is a task that runs only when notified by a changed task, commonly used to restart or reload services.

What is a Template?  
A template is a Jinja2-based file that renders variables dynamically before being copied to the target host.

What is Ansible Vault?  
Ansible Vault is used to encrypt and securely store sensitive data such as passwords, tokens, and API keys.

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

