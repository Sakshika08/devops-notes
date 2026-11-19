### You are deploying a web application on AWS. Can you explain the difference between an Application Load Balancer (ALB) and a Network Load Balancer (NLB)?
 Answer: ALB (Application Load Balancer) operates at Layer 7 of the OSI model and handles HTTP/HTTPS traffic. It can make routing decisions based on URL path, host headers, query strings, etc.  
NLB (Network Load Balancer) operates at Layer 4 and handles TCP, UDP, and TLS traffic. It is designed for ultra-low latency and very high throughput.  
I would choose ALB when deploying web applications on EC2, ECS, or EKS where advanced routing features are required, such as:  
Path-based routing (/api, /app)  
Host-based routing (app.company.com, api.company.com)   
SSL/TLS termination  

I would choose NLB for performance-sensitive applications requiring high throughput, static IP addresses, or non-HTTP protocols.  
Project Example (NLB): Load balancing TCP traffic for a database or a high-performance messaging application.  
Project Example (ALB): Routing user traffic to multiple microservices running on EKS based on URL paths.

## Suppose you have an application running on EC2 instances behind an ALB. How does an Auto Scaling Group work?  
Explain: What is an Auto Scaling Group?, Difference between Scale Out and Scale In?  
What metrics can trigger scaling? What happens if one EC2 instance becomes unhealthy?  
**Answer:** Auto Scaling Group helps automatically scale EC2 instances based on demand. Scale-out adds more instances when load increases, while scale-in removes instances when load decreases. Scaling policies can be based on CloudWatch metrics such as CPU utilization, request count, or custom metrics. ASG also performs health checks and automatically replaces unhealthy EC2 instances to maintain application availability and the desired capacity.

## Your application is running on EC2 and needs to access an S3 bucket.
Why is storing AWS Access Keys on the EC2 instance a bad practice?  
How do you attach an IAM Role to an EC2 instance?  
What happens behind the scenes when the application accesses S3 using the role?    
Answer: Storing AWS access keys on an EC2 instance is a bad practice because long-term credentials can be exposed through configuration files, scripts, logs, or source code repositories. Instead, we use an IAM Role attached to the EC2 instance. An IAM Role is an AWS identity that provides temporary credentials and permissions without requiring hardcoded access keys. We create an IAM Role with the required S3 permissions, create an Instance Profile, and attach it to the EC2 instance. When the application accesses S3, the EC2 instance retrieves temporary credentials from the Instance Metadata Service (IMDS). AWS automatically rotates these credentials, allowing secure access to S3 without storing secrets on the server.

## 🔥 Q. How do you provide access to an S3 bucket?
Access to an S3 bucket can be provided using IAM policies, bucket policies, or IAM roles depending on the use case.  
If an application or user needs access, I first identify the required permissions such as read-only access (`s3:GetObject`) or read-write access (`s3:GetObject`, `s3:PutObject`).  
For users and applications within the same AWS account, I generally prefer IAM roles or IAM policies following the principle of least privilege.  
If cross-account access is required, I would use a bucket policy to explicitly allow access from the external AWS account.  
Finally, I validate access using AWS CLI commands or application testing to ensure the required permissions are working correctly.

## You have an application running on multiple EC2 instances behind an ALB. One day users report that the application is slow. How would you troubleshoot this issue?
 Answers:  First, I would identify whether the issue is occurring at the load balancer, EC2, application, or database layer. I would check ALB health checks, Target Response Time, Request Count, and 4XX/5XX errors. Next, I would review EC2 metrics such as CPU utilization, memory usage, disk usage, and network traffic in CloudWatch. If infrastructure looks healthy, I would check application logs in CloudWatch Logs and web server logs. If the application depends on a database, I would review database metrics such as CPU, connections, latency, and slow queries. Tools I would use include CloudWatch, CloudWatch Logs, ALB access logs, EC2 system logs, RDS monitoring, and AWS X-Ray for request tracing.

## Application needs to communicate with EC2 in a private subnet behind Multi-AZ Load Balancer.
I would place the EC2 instances in private subnets across multiple Availability Zones and expose them through an Application Load Balancer.  
Application → ALB → Target Group → Private EC2 Instances  
The application communicates through the ALB which allows traffic from internet, while the EC2 instances remain private and protected from direct internet access and allow traffic only from ALB Security Group

## 🔥 Q. Application hosted in S3. Users are in multiple regions. How would you reduce latency?
I would place Amazon CloudFront in front of the S3 bucket. CloudFront acts as a global CDN and caches static content at edge locations around the world. This allows users to receive content from the nearest edge location instead of accessing the S3 bucket directly, which significantly reduces latency and improves response times.  
If the application supports user uploads or region-specific data access, I would consider using S3 Cross-Region Replication to replicate data closer to users. I can also combine this with Route 53 latency-based routing so users are directed to the nearest available AWS region.  
For security, I would use Origin Access Control (OAC) to ensure users access the application through CloudFront rather than directly accessing the S3 bucket.  
For workloads involving large file uploads, I would also consider enabling S3 Transfer Acceleration, which uses the CloudFront edge network to speed up uploads from geographically distant users.

## 🔥 Q. An application is experiencing high latency. What troubleshooting steps would you take?
If users report high latency in an application, I first try to identify whether the bottleneck is in the application, infrastructure, network, load balancer, or database layer.  
I would start by reviewing monitoring dashboards such as CloudWatch, Prometheus, or Grafana to check response times, error rates, request volume, CPU utilization, memory usage, and network metrics.  
Next, I would review application logs to identify slow requests, exceptions, timeout errors, or dependency failures. If distributed tracing is available through tools like AWS X-Ray, I would use it to determine exactly where requests are spending most of their time.  
I would then verify the health of backend components such as databases, caches, and external APIs. In many real-world cases, latency is caused by slow database queries, exhausted connection pools, or delays from third-party services.  
If the application is running on Kubernetes, I would also check pod resource utilization, HPA activity, pod restarts, and node health to determine whether resource constraints are affecting performance.  
Additionally, I would review load balancer metrics, network latency, and infrastructure health to identify any bottlenecks outside the application itself.  
Once the root cause is identified, I would take the appropriate corrective action such as scaling resources, optimizing database queries, increasing application replicas, fine-tuning caching, or resolving infrastructure issues.

## 🔥 Q. Explain EC2, NAT Gateway, and NACL Together in an AWS Architecture.
EC2 provides compute, NAT Gateway enables secure outbound internet access for private resources, and NACLs provide subnet-level traffic filtering.

## 🔥 Q. What Are the Different Amazon EBS Volume Types?
Amazon EBS provides different storage types based on performance and workload requirements.
The most commonly used volumes are GP3 and GP2, which are SSD-based General Purpose volumes suitable for most applications.
For high-performance workloads requiring very low latency and high IOPS, Provisioned IOPS volumes such as IO1 and IO2 are used.
For large sequential workloads such as log processing, data warehousing, and big data analytics, Throughput Optimized HDD (ST1) can be used.
For infrequently accessed workloads where cost is more important than performance, Cold HDD (SC1) is available.  
- GP3 → General-purpose SSD (most commonly used)
- GP2 → Older general-purpose SSD
- IO1 / IO2 → High-performance SSD with provisioned IOPS
- ST1 → Throughput-optimized HDD
- SC1 → Cold HDD for infrequently accessed data
For most production workloads today, GP3 is preferred because it provides better performance and lower cost compared to GP2.

## 🔥 Q. What Are the Components and Routing Policies in Route 53?
Amazon Route 53 is AWS's DNS service used to route users to applications and AWS resources.  
The main components include hosted zones, DNS records, health checks, and routing policies.  
A Hosted Zone stores DNS records for a domain, while records such as A, CNAME, Alias, and MX define how traffic is routed.  
Route 53 supports multiple routing policies depending on the use case.

**Common Routing Policies:**  
- Simple Routing → Single resource
- Weighted Routing → Distribute traffic by percentage
- Latency-Based Routing → Route users to the nearest region
- Failover Routing → Disaster recovery and high availability
- Geolocation Routing → Route based on user location
- Geoproximity Routing → Route based on geographic proximity
- Multi-Value Answer Routing → Return multiple healthy endpoints
For example, in a multi-region application, I would use Latency-Based Routing to ensure users are routed to the nearest AWS region for better performance.

## 🔥 Q. How Do You Reduce Cloud Costs Without Affecting Availability?
I start by identifying underutilized resources and then optimize them without compromising reliability or performance.  
Some common approaches I have used include rightsizing EC2 instances, removing unused EBS volumes and snapshots, scheduling non-production resources to shut down outside business hours, and using Auto Scaling so resources match actual demand.  
For steady-state workloads, I would use Savings Plans or Reserved Instances to reduce compute costs. For fault-tolerant workloads, I would leverage Spot Instances where appropriate.  
I also use tools such as AWS Cost Explorer, Trusted Advisor, and AWS Compute Optimizer to identify optimization opportunities.  
Throughout the process, I monitor application performance to ensure availability and user experience are not impacted.

## 🔥 Q. What is UAT?
UAT stands for User Acceptance Testing.  
It is the phase where business users, clients, or stakeholders validate that the application meets business requirements before it is released to production.  
After development and system testing are completed, the application is deployed to a UAT environment that closely resembles production. End users then execute business scenarios and validate functionality.  
Only after successful UAT sign-off is the application promoted to production.  

**Typical Environment Flow:**

```text
Development
      ↓
QA / Testing
      ↓
UAT
      ↓
Production
```
