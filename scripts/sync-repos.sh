#!/bin/bash

# Dual Repository Sync Script
# Pushes changes to both GitHub and Gitea with proper commit messages

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not in a git repository!"
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
print_status "Current branch: $CURRENT_BRANCH"

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    print_warning "You have uncommitted changes. Please commit them first."
    git status --short
    exit 1
fi

# Check if we have remotes configured
if ! git remote get-url origin > /dev/null 2>&1; then
    print_error "No 'origin' remote configured!"
    exit 1
fi

if ! git remote get-url github > /dev/null 2>&1; then
    print_warning "No 'github' remote configured. Adding it..."
    git remote add github git@github.com:nafisatou/Cloud-Native-Api.git
fi

# Function to push to a remote with error handling
push_to_remote() {
    local remote=$1
    local branch=$2
    
    print_status "Pushing to $remote..."
    
    if git push "$remote" "$branch"; then
        print_success "Successfully pushed to $remote"
        return 0
    else
        print_error "Failed to push to $remote"
        return 1
    fi
}

# Push to GitHub
print_status "=== Pushing to GitHub ==="
if push_to_remote "github" "$CURRENT_BRANCH"; then
    GITHUB_SUCCESS=true
else
    GITHUB_SUCCESS=false
fi

# Push to Gitea (origin)
print_status "=== Pushing to Gitea ==="
if push_to_remote "origin" "$CURRENT_BRANCH"; then
    GITEA_SUCCESS=true
else
    GITEA_SUCCESS=false
fi

# Summary
echo
print_status "=== SYNC SUMMARY ==="
if [ "$GITHUB_SUCCESS" = true ]; then
    print_success "✓ GitHub sync completed"
else
    print_error "✗ GitHub sync failed"
fi

if [ "$GITEA_SUCCESS" = true ]; then
    print_success "✓ Gitea sync completed"
else
    print_error "✗ Gitea sync failed"
fi

# Exit with error if any push failed
if [ "$GITHUB_SUCCESS" = false ] || [ "$GITEA_SUCCESS" = false ]; then
    exit 1
fi

print_success "All repositories synchronized successfully!"
