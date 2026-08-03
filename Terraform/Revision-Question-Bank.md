Most Secure AWS Authentication Method?
IAM Roles with temporary credentials obtained through AWS STS.

What is OIDC?
OpenID Connect allows CI/CD platforms such as GitHub Actions to securely assume AWS IAM Roles without storing AWS access keys.

Do IAM Roles Need Environment Variables?
No. Terraform automatically retrieves temporary credentials when an IAM Role is available.
