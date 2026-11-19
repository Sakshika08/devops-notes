## 🔥 Q. What Happens Internally When You Run `docker run`?
When I run a `docker run` command, Docker first checks whether the required image is available locally. If it's not present, Docker pulls the image from the configured container registry such as Docker Hub or Amazon ECR.  
Once the image is available, Docker creates a writable container layer on top of the image, allocates networking, assigns a container ID, and sets up isolation using Linux namespaces and cgroups.  
Docker then executes the container's ENTRYPOINT and CMD instructions, starts the main application process, and attaches logs and networking to the container.  
From that point, the container runs until the main process exits or the container is stopped.  


## 🔥 Q. Difference Between CMD and ENTRYPOINT.
Both CMD and ENTRYPOINT specify what runs when a container starts, but they serve different purposes.  
ENTRYPOINT defines the main executable that should always run inside the container.  
CMD provides default arguments for the executable and can be easily overridden when running the container.  
**example:**
```dockerfile
ENTRYPOINT ["python"]
CMD ["app.py"]
```
When the container starts, Docker executes: python app.py  
If I run: docker run my-image test.py   
Docker executes: python test.py  
In real-world applications, I typically use ENTRYPOINT for the application executable and CMD for default runtime parameters.


## 🔥 Q. Which Docker Base Image Did You Use for Your Application and Why?
In most projects, I prefer lightweight base images such as Alpine-based images or official language-specific images like Python, Node.js, or OpenJDK images.
For example, for Python applications I commonly use: `FROM python:3.12-alpine` or `FROM python:3.12-slim`  
I prefer smaller images because they reduce image size, improve build and deployment speed, lower storage consumption, and reduce the attack surface.  
For production environments, Distroless images are also a good option because they contain only the application runtime and minimal operating system components.  

## 🔥 Q. How Do You Secure Container Images Before Deployment?
Before deploying container images, I ensure they go through multiple security checks as part of the CI/CD pipeline.  
I start by using trusted and minimal base images to reduce unnecessary packages and attack surface.  
Next, I perform vulnerability scanning using tools such as Trivy or Grype. If critical vulnerabilities are detected, the deployment is blocked until they are resolved.  
I avoid running containers as the root user, remove unnecessary packages and dependencies, and keep images updated with the latest security patches.  
Images are stored in secure registries such as Amazon ECR with image scanning enabled, and access is controlled through IAM permissions.  
I also ensure secrets are never baked into container images and are instead retrieved from Kubernetes Secrets, AWS Secrets Manager, or HashiCorp Vault.
