# Gokku GitHub Action

A GitHub Action for deploying applications to Gokku servers using either Git push or Docker registry deployment methods.

## Overview

This action provides a simple and powerful way to deploy applications to Gokku servers, similar to how Dokku works but using the Gokku platform. It supports two deployment strategies:

- **Git Deploy**: Direct git push to the Gokku server
- **Registry Deploy**: Deploy pre-built Docker images from a registry

## Features

- Support for both Git and Docker registry deployments
- SSH key authentication
- Configurable branch deployment
- Docker-based action for consistent execution
- Simple configuration with minimal setup

## Usage

### Git Deploy

Deploy directly from your repository to the Gokku server:

```yaml
name: Deploy to Gokku

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to Gokku
        uses: thadeu/gokku-gh-action@v1
        with:
          server: ${{ secrets.GOKKU_SERVER }}
          user: ${{ secrets.GOKKU_USER }}
          app_name: api
          ssh_key: ${{ secrets.GOKKU_SSH_KEY }}
          deploy_type: 'git'
          branch: 'main'
```

### Registry Deploy

Build and push a Docker image, then deploy it to Gokku:

```yaml
name: Deploy to Gokku

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build and Push
        run: |
          docker build -t ghcr.io/${{ github.repository }}:${{ github.sha }} .
          docker push ghcr.io/${{ github.repository }}:${{ github.sha }}

      - name: Deploy to Gokku
        uses: thadeu/gokku-gh-action@v1
        with:
          server: ${{ secrets.GOKKU_SERVER }}
          user: ${{ secrets.GOKKU_USER }}
          app_name: api
          ssh_key: ${{ secrets.GOKKU_SSH_KEY }}
          deploy_type: 'registry'
          image: ghcr.io/${{ github.repository }}:${{ github.sha }}
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `server` | Gokku server IP/hostname | Yes | - |
| `user` | SSH user | Yes | `ubuntu` |
| `app_name` | App name on Gokku | Yes | - |
| `branch` | Branch to deploy | No | `main` |
| `ssh_key` | SSH private key | Yes | - |
| `deploy_type` | Deploy type: `git` or `registry` | No | `git` |
| `image` | Docker image (only for registry deploy) | No | - |

## Required Secrets

Configure the following secrets in your repository settings:

- `GOKKU_SERVER`: Your Gokku server IP address or hostname
- `GOKKU_USER`: SSH username for the Gokku server
- `GOKKU_SSH_KEY`: Private SSH key for authentication

## Deployment Flow

### Git Deploy Flow
1. GitHub Actions triggers on push
2. Action connects to Gokku server via SSH
3. Git repository is pushed to `/opt/gokku/repos/APP_NAME.git`
4. Gokku automatically deploys the application

### Registry Deploy Flow
1. GitHub Actions triggers on push
2. Docker image is built and pushed to registry
3. Action connects to Gokku server via SSH
4. `gokku.yml` is updated with the new image reference
5. Gokku deploys the application using the new image

## Requirements

- Gokku server with SSH access
- SSH key configured for authentication
- For registry deploy: Docker registry access

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

For issues and questions, please open an issue on the [GitHub repository](https://github.com/thadeu/gokku-gh-action).
