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
