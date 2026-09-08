Q: What is the difference between copy and template in Ansible?

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

