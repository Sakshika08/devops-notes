### You are deploying a web application on AWS.

Can you explain the difference between an Application Load Balancer (ALB) and a Network Load Balancer (NLB)?

Also tell me:

At which OSI layer does each operate?
When would you choose ALB over NLB?
Give one practical project example for each.  
Answer: ALB (Application Load Balancer) operates at Layer 7 of the OSI model and handles HTTP/HTTPS traffic. It can make routing decisions based on URL path, host headers, query strings, etc.

NLB (Network Load Balancer) operates at Layer 4 and handles TCP, UDP, and TLS traffic. It is designed for ultra-low latency and very high throughput.

I would choose ALB when deploying web applications on EC2, ECS, or EKS where advanced routing features are required, such as:

Path-based routing (/api, /app)
Host-based routing (app.company.com, api.company.com)
SSL/TLS termination

I would choose NLB for performance-sensitive applications requiring high throughput, static IP addresses, or non-HTTP protocols.  
Project Example (NLB): Load balancing TCP traffic for a database or a high-performance messaging application.  
Project Example (ALB): Routing user traffic to multiple microservices running on EKS based on URL paths.

## Suppose you have an application running on EC2 instances behind an ALB.
How does an Auto Scaling Group work?  
Explain:  
- What is an Auto Scaling Group?
- Difference between Scale Out and Scale In.
- What metrics can trigger scaling?
- What happens if one EC2 instance becomes unhealthy?

Answer: Auto Scaling Group helps automatically scale EC2 instances based on demand. Scale-out adds more instances when load increases, while scale-in removes instances when load decreases. Scaling policies can be based on CloudWatch metrics such as CPU utilization, request count, or custom metrics. ASG also performs health checks and automatically replaces unhealthy EC2 instances to maintain application availability and the desired capacity.

## Your application is running on EC2 and needs to access an S3 bucket.

How would you grant the EC2 instance access to S3 securely?

Explain:

Why is storing AWS Access Keys on the EC2 instance a bad practice?
What is an IAM Role?
How do you attach an IAM Role to an EC2 instance?
What happens behind the scenes when the application accesses S3 using the role?  
Answer: Storing AWS access keys on an EC2 instance is a bad practice because long-term credentials can be exposed through configuration files, scripts, logs, or source code repositories. Instead, we use an IAM Role attached to the EC2 instance. An IAM Role is an AWS identity that provides temporary credentials and permissions without requiring hardcoded access keys. We create an IAM Role with the required S3 permissions, create an Instance Profile, and attach it to the EC2 instance. When the application accesses S3, the EC2 instance retrieves temporary credentials from the Instance Metadata Service (IMDS). AWS automatically rotates these credentials, allowing secure access to S3 without storing secrets on the server.

## You have an application running on multiple EC2 instances behind an ALB.

One day users report that the application is slow.

How would you troubleshoot this issue?

Explain:

What would you check first?
Which CloudWatch metrics would you look at?
How would you determine whether the problem is in:
ALB
EC2
Application
Database
What AWS services/tools would you use during troubleshooting?  
Answers:  First, I would identify whether the issue is occurring at the load balancer, EC2, application, or database layer. I would check ALB health checks, Target Response Time, Request Count, and 4XX/5XX errors. Next, I would review EC2 metrics such as CPU utilization, memory usage, disk usage, and network traffic in CloudWatch. If infrastructure looks healthy, I would check application logs in CloudWatch Logs and web server logs. If the application depends on a database, I would review database metrics such as CPU, connections, latency, and slow queries. Tools I would use include CloudWatch, CloudWatch Logs, ALB access logs, EC2 system logs, RDS monitoring, and AWS X-Ray for request tracing.



