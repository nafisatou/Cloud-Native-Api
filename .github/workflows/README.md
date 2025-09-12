# GitHub Actions Workflows

## sync-repositories.yml

This workflow automatically:

1. **Syncs changes** from GitHub to your local Gitea instance
2. **Builds and tests** the Rust API application
3. **Validates code quality** with rustfmt and clippy
4. **Creates Docker images** for deployment

### Required Secrets

To enable Gitea synchronization, add these secrets to your GitHub repository:

- `GITEA_REPO_URL`: Your Gitea repository URL (e.g., `http://admin1:admin123@gitea.local:3000/admin1/cloud-native-api.git`)
- `GITEA_USERNAME`: Your Gitea username (`admin1`)
- `GITEA_TOKEN`: Your Gitea access token or password (`admin123`)

### Workflow Triggers

- **Push events** on `main`, `develop`, and `gitea-setup` branches
- **Pull requests** targeting the `main` branch

### Jobs

1. **sync-to-gitea**: Pushes changes to your local Gitea instance
2. **build-and-test**: Validates Rust code and builds Docker image
3. **deploy-notification**: Provides deployment status updates

This ensures your local development environment stays in sync with your GitHub repository automatically.
