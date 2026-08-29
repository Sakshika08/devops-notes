
## IAM User
→ Permanent identity with long-term credentials.

IAM Role
→ Temporary identity with permissions that can be assumed.

AssumeRole
→ Obtain temporary credentials for a role using AWS STS.

Cross-Account Access
→ Use IAM Roles to securely access resources in another AWS account.

Least Privilege
→ Grant only the minimum permissions necessary to perform a task.

## Design a Scalable Web Application on AWS (Interview Ready)
To design a scalable and highly available web application on AWS, I would create a VPC with public and private subnets across multiple Availability Zones. Route 53 would route user requests to an Application Load Balancer (ALB) in the public subnet. The ALB would distribute traffic to EC2 instances or EKS pods running in private subnets, managed by Auto Scaling Groups (ASG) or HPA for scalability. Data would be stored in RDS Multi-AZ (or DynamoDB), with ElastiCache (Redis) used for caching and S3 for static content. A NAT Gateway would provide outbound internet access for private resources. Monitoring would be done using CloudWatch, Prometheus, and Grafana, while security would be enforced using IAM Roles, Security Groups, private subnets, and least-privilege access.

## AWS Lambda 
Serverless compute service

Trigger → S3, API Gateway, EventBridge, SQS, SNS

Scaling → Automatic

Billing → Per request and execution duration

Max Execution Time → 15 Minutes

Security → IAM Execution Role

Common Use Cases → Automation, APIs, Log Processing, CI/CD, Event-Driven Workloads

Key Benefit → Run code without managing servers

### Difference between SNS and SQS?
SNS is a publish-subscribe messaging service that follows a push model, where messages are automatically delivered to subscribers such as Email, SMS, Lambda, or SQS. SQS is a message queue service that follows a pull model, where messages are stored in a queue until consumers retrieve and process them. SNS is mainly used for notifications and fan-out messaging, whereas SQS is used to decouple applications and enable reliable asynchronous processing.
