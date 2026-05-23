# DevOps Todo App

## Project Overview

This is a Flask Todo web application created for the DevOps take-home assignment.

The app includes:

- Flask web UI
- PostgreSQL database
- Docker containerization
- Docker Compose local setup
- Bash deployment script
- GitHub Actions CI/CD pipeline
- AWS EC2 deployment approach
- `/health` endpoint for deployment validation

---

## Architecture Diagram

```text
Developer
   |
   | git push to main
   v
GitHub Repository
   |
   v
GitHub Actions CI/CD
   |
   | lint
   | unit test
   | integration test
   | docker build
   | docker push
   v
GitHub Container Registry
   |
   | SSH to EC2
   v
AWS EC2 Ubuntu Server
   |
   | bootstrap.sh
   | docker pull latest image
   | stop old container
   | run new container
   v
Flask Todo App Container
   |
   | DATABASE_URL
   v
PostgreSQL Database
```

---

## Platform Chosen and Why

I chose **AWS EC2** because I already have an AWS free-tier account.

For this assignment, EC2 is useful because it clearly demonstrates:

- Server provisioning understanding
- Docker deployment on Linux
- SSH-based deployment automation
- Bash scripting using `bootstrap.sh`
- Security group and public URL configuration
- CI/CD deployment from GitHub Actions to AWS

I used **GitHub Container Registry** for Docker images because it integrates directly with GitHub Actions and avoids storing registry credentials in the repository.

---

## How to Run Locally

### Prerequisites

Install:

- Docker
- Docker Compose
- Git

### Start app and database

```bash
docker compose up --build
```

This starts:

- Flask app on port `8080`
- PostgreSQL on port `5432`

Open:

```text
http://localhost:8080
```

Health check:

```bash
curl http://localhost:8080/health
```

Expected response:

```json
{
  "status": "healthy"
}
```

Stop containers:

```bash
docker compose down
```

---

## Dockerfile Explanation

The Dockerfile uses a **multi-stage build**.

The first stage installs Python dependencies.

The second stage copies only the installed dependencies and app code.

To keep the image small:

- Used `python:3.12-slim`
- Used `pip install --no-cache-dir`
- Used `.dockerignore`
- Copied only required files
- Avoided unnecessary build tools in final image

The container runs as a **non-root user**:

```dockerfile
USER appuser
```

This improves security because the application process does not run as root inside the container.

---

## docker-compose Explanation

The `docker-compose.yml` file runs the app and PostgreSQL locally with one command.

It includes:

- `app` service
- `db` service
- PostgreSQL environment variables
- Persistent database volume
- Database health check
- App dependency on healthy database

This helps developers test the full app locally before deployment.

---

## bootstrap.sh Explanation

The `bootstrap.sh` script is used for EC2 deployment.

It does the following:

1. Uses strict error handling:

```bash
set -euo pipefail
```

2. Checks whether Docker is installed.

3. Installs Docker on Ubuntu if missing.

4. Pulls the latest Docker image from GHCR.

5. Checks whether the old container already exists.

6. Stops and removes the old container.

7. Starts the new container with environment variables.

8. Runs a health check on:

```text
http://localhost:8080/health
```

### Idempotency

The script is idempotent because running it multiple times does not create duplicate containers.

It removes the old container before starting a new one.

---

## CI/CD Pipeline Explanation

The GitHub Actions workflow is located at:

```text
.github/workflows/ci-cd.yml
```

It runs on every push to the `main` branch.

Pipeline steps:

1. Checkout source code
2. Install Python dependencies
3. Run lint using `flake8`
4. Run unit tests using `pytest`
5. Build Docker image
6. Tag image with:
   - Git SHA
   - latest
7. Push image to GitHub Container Registry
8. Run integration test
9. SSH into AWS EC2
10. Copy and run `bootstrap.sh`
11. Check public `/health` endpoint

If any command fails, the pipeline fails loudly.

---

## Secrets Management

No secrets are stored in the repository.

GitHub Actions secrets used:

```text
EC2_HOST
EC2_USER
EC2_SSH_KEY
DATABASE_URL
```

These values are stored in:

```text
GitHub Repo -> Settings -> Secrets and variables -> Actions
```

---

## Production Improvements

If this were production, I would improve the setup as follows:

### 1. Managed Database

I would use Amazon RDS PostgreSQL instead of manually managing PostgreSQL.

Benefits:

- Automated backups
- Point-in-time recovery
- High availability
- Easier patching
- Better monitoring

### 2. Private Database Access

The database should not be publicly accessible.

Only the application should connect to it through private networking.

### 3. Load Balancer

I would place an Application Load Balancer in front of the EC2 instances.

Benefits:

- Better traffic distribution
- HTTPS termination
- Health checks
- Zero-downtime deployment support

### 4. Auto Scaling

I would use an Auto Scaling Group so the app can scale based on load.

Scaling metrics:

- CPU usage
- Memory usage
- Request count

### 5. Rollback Strategy

The image is tagged with Git SHA, so rollback can be done by redeploying a previous known-good image.

In production, I would automate rollback when the post-deploy health check fails.

### 6. Monitoring and Alerts

I would add monitoring for:

- CPU
- Memory
- Disk usage
- Container restarts
- HTTP 5xx errors
- Response latency
- Database connections

Tools:

- CloudWatch
- Prometheus
- Grafana

### 7. Centralized Logging

I would send logs to a centralized system like CloudWatch Logs or ELK.

This makes debugging easier.

### 8. Security Scanning

I would scan Docker images before deployment using tools like:

- Trivy
- Docker Scout
- Grype

### 9. Infrastructure as Code

I would use Terraform to manage AWS resources.

Terraform would create:

- VPC
- EC2
- Security groups
- RDS
- IAM roles
- Load balancer

### 10. Branch Protection

I would protect the `main` branch.

Rules:

- Pull request required
- CI must pass
- No direct push to main
- Approval required

### 11. Environment Separation

I would create separate environments:

```text
dev
staging
production
```

Each environment should have separate secrets and database.

### 12. Database Migration Tool

I would use Alembic or Flask-Migrate instead of creating tables automatically in app startup.

This makes schema changes safer.

---

## AI Usage

I used AI assistance to prepare the initial structure, Dockerfile, GitHub Actions workflow, bootstrap script, and README draft.

I verified the output by reviewing:

- Dockerfile multi-stage build
- Non-root container user
- docker-compose app and PostgreSQL setup
- bootstrap script idempotency
- GitHub Actions CI/CD steps
- Health check endpoint
- Secrets not committed to repo

I understand the code and can explain each file during the interview.

---

## Submission

```text
GitHub Repo Link:
ADD_GITHUB_REPO_LINK

Live URL:
http://ADD_EC2_PUBLIC_IP:8080

Video Walkthrough Link:
ADD_LOOM_LINK
```
