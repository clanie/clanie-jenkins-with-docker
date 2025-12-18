# Jenkins with Docker

A Docker setup for running Jenkins with Docker support built-in, allowing Jenkins pipelines to execute Docker commands.

## Overview

This project provides a Jenkins instance running in a Docker container with the ability to control the host's Docker daemon. This enables Jenkins to build Docker images, run containers, and execute Docker-based pipelines.

## Prerequisites

- Docker installed and running on your machine
- Sufficient permissions to run Docker commands
- Bash shell (for running the scripts)

## Features

- Jenkins LTS with JDK 21
- Docker CLI installed in the Jenkins container
- Docker-in-Docker capability via socket mounting
- Automatic Docker socket permissions handling
- Persistent Jenkins home directory using Docker volumes
- Web UI accessible on port 8888
- JNLP agent port exposed on port 50000

## Quick Start

### 1. Build the Image

Build the Jenkins Docker image with Docker support:

```bash
./build.sh
```

This creates the `jenkins-with-docker:lts-jdk21` image with:
- Jenkins LTS with JDK 21 as the base
- Docker CLI tools installed
- Custom entrypoint for Docker socket permissions

### 2. Run Jenkins

Start the Jenkins container:

```bash
./run.sh
```

This will:
1. Remove any existing Jenkins container named `jenkins`
2. Start a new Jenkins container with all necessary configurations

### 3. Access Jenkins

Open your browser and navigate to:
```
http://localhost:8888
```

On first launch, retrieve the initial admin password from the container logs:

```bash
docker logs jenkins
```

Look for a line containing the password, which will look like:
```
*************************************************************
Jenkins initial setup is required. An admin user has been created and a password generated.
Please use the following password to proceed to installation:

<your-password-here>

*************************************************************
```

## Scripts

### build.sh

Builds the Docker image from scratch:
- Uses `--no-cache` to ensure a fresh build
- Tags the image as `jenkins-with-docker:lts-jdk21`

### run.sh

Starts the Jenkins container with:
- **Port 8888**: Web UI (mapped from container port 8080)
- **Port 50000**: JNLP agent connections
- **Volume `jenkins_home`**: Persists Jenkins configuration and data
- **Docker socket mount**: Enables Docker commands in pipelines

### docker-entrypoint.sh

Custom entrypoint script that:
- Detects the Docker socket's group ID
- Creates a matching group in the container
- Adds the Jenkins user to that group
- Ensures Jenkins can access the Docker socket
- Starts Jenkins with proper permissions

## Configuration

### Ports

- **Web UI**: `8888` (host) → `8080` (container)
- **Agent**: `50000` (host) → `50000` (container)

### Volumes

- **jenkins_home**: Docker volume persisting Jenkins configuration, jobs, plugins, and workspace data

### Docker Access

The host's Docker socket (`/var/run/docker.sock`) is mounted into the container, allowing Jenkins to:
- Build Docker images
- Run and manage containers
- Execute Docker Compose commands
- Use Docker in pipeline scripts

## Usage in Jenkins Pipelines

Once running, you can use Docker commands in your Jenkins pipelines:

```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'docker build -t myapp:latest .'
            }
        }
        stage('Test') {
            steps {
                sh 'docker run --rm myapp:latest npm test'
            }
        }
    }
}
```

## Maintenance

### Viewing Logs

```bash
docker logs jenkins
docker logs -f jenkins  # Follow logs in real-time
```

### Stopping Jenkins

```bash
docker stop jenkins
```

### Restarting Jenkins

```bash
docker restart jenkins
```

### Removing Everything

To completely remove the Jenkins container and its data:

```bash
docker rm -f jenkins
docker volume rm jenkins_home
```

## Security Considerations

- The Jenkins container has access to the host's Docker daemon, which is a powerful privilege
- Ensure your Jenkins instance is properly secured with strong passwords
- Consider network isolation if running in production
- Regularly update the base image and rebuild to get security patches

## Troubleshooting

### Docker Permission Issues

If Jenkins can't access Docker, check:
1. The Docker socket is mounted: `docker inspect jenkins | grep docker.sock`
2. Jenkins user has correct permissions: `docker exec jenkins groups jenkins`

### Port Already in Use

If port 8888 is already in use, edit `run.sh` and change `-p 8888:8080` to use a different port.

### Container Won't Start

Check the logs:
```bash
docker logs jenkins
```

## License

This project configuration is provided as-is for setting up Jenkins with Docker support.
