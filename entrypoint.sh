#!/bin/bash

set -e

# Parameters
SERVER="$1"
USER="$2"
APP_NAME="$3"
SSH_KEY="$4"
DEPLOY_TYPE="$5"
BRANCH="$6"
IMAGE="$7"

# Validate required parameters
if [ -z "$SERVER" ] || [ -z "$USER" ] || [ -z "$APP_NAME" ] || [ -z "$SSH_KEY" ]; then
    echo "Error: Missing required parameters"
    exit 1
fi

SSH_PATH="$HOME/.ssh"

echo "Setting up SSH..."
mkdir -p ~/.ssh
echo "$SSH_KEY" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa

eval "$(ssh-agent)"
ssh-add ~/.ssh/id_rsa
ssh-keyscan -H $SERVER >> ~/.ssh/known_hosts

if [ "$DEPLOY_TYPE" = "registry" ]; then
    if [ -z "$IMAGE" ]; then
        echo "Error: Image parameter is required for registry deploy"
        exit 1
    fi
    
    echo "Deploying registry image: $IMAGE"
    
    ssh -i ~/.ssh/id_rsa $USER@$SERVER "
        sed -i 's|image:.*|image: \"$IMAGE\"|' /opt/gokku/apps/$APP_NAME/gokku.yml
        gokku deploy -a $APP_NAME
    "
else
    echo "Deploying via git push"
    
    # Remove existing production remote if it exists
    git remote remove production 2>/dev/null || true
    
    git remote add production $USER@$SERVER:/opt/gokku/repos/$APP_NAME.git
    
    echo "Checking out branch: $BRANCH"
    git checkout "$BRANCH"
    
    echo "Pushing to production..."
    git push production "$BRANCH"
    
    echo "Deploy completed successfully"
fi