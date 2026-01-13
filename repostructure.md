# Repository Structure

## Complete File Layout

```
ee-onbase-deployment-automation-rhel9/
├── Makefile                          # Build automation (REQUIRED)
├── execution-environment.yml         # EE definition (REQUIRED)
├── requirements.yml                  # Ansible collections (REQUIRED)
├── requirements.txt                  # Python dependencies (REQUIRED)
├── bindep.txt                        # System packages (REQUIRED)
├── git-credential-environment        # Git credential helper (REQUIRED)
├── gitconfig                         # Git configuration (REQUIRED)
├── hylandgov-chain.pem              # SSL certificate chain (REQUIRED)
├── .dockerignore                    # Docker ignore file (RECOMMENDED)
├── README.md                         # Documentation (RECOMMENDED)
├── deploy-ee.sh                     # Deployment script (OPTIONAL)
├── venv/                            # Python virtual environment (GENERATED)
└── context/                         # Build context (GENERATED)
```

---

## File Descriptions

### Core Configuration Files (Required)

#### 1. **Makefile**
- **Purpose**: Automates build, test, and save operations
- **Key Features**:
  - Build with token validation
  - Comprehensive verification
  - Image save with compression
  - Interactive shell access
- **Usage**: `make build`, `make verify`, `make save`

#### 2. **execution-environment.yml**
- **Purpose**: Defines the EE structure and build process
- **Contains**:
  - Base image configuration
  - Dependencies references
  - Additional build steps
  - Tool installations (AWS CLI, kubectl, terraform)
- **Key Sections**:
  - `images`: Base image from Red Hat
  - `dependencies`: Links to requirements files
  - `additional_build_steps`: Custom installation commands

#### 3. **requirements.yml**
- **Purpose**: Specifies Ansible collections to install
- **Collections Included**:
  - amazon.aws
  - community.aws
  - awx.awx
  - ansible.controller
  - community.general
  - netapp.ontap
  - kubernetes.core

#### 4. **requirements.txt**
- **Purpose**: Defines Python package dependencies
- **Packages Included**:
  - kubernetes >= 12.0.0
  - boto3 >= 1.28.0
  - botocore >= 1.31.0
  - urllib3 >= 1.26.0
  - jmespath >= 1.0.0
  - PyYAML >= 6.0
  - snowflake-snowpark-python

#### 5. **bindep.txt**
- **Purpose**: Lists system-level package dependencies
- **Packages**:
  - python3-ldap
  - python3-psutil
  - python3-pyodbc
  - terraform
  - git, curl, unzip

#### 6. **git-credential-environment**
- **Purpose**: Credential helper for Git operations
- **Function**: Reads credentials from environment variables
- **Must be executable**: `chmod +x git-credential-environment`

#### 7. **gitconfig**
- **Purpose**: Git configuration for the container
- **Sets**: Credential helper to use environment variables

#### 8. **hylandgov-chain.pem**
- **Purpose**: SSL certificate chain for internal services
- **Usage**: Installed to system trust store during build

---

### Recommended Files

#### 9. **.dockerignore**
```
# Python
venv/
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
*.egg-info/
dist/
build/

# Build artifacts
context/
*.tar
*.tar.gz

# Git
.git/
.gitignore

# IDE
.vscode/
.idea/
*.swp
*.swo

# Logs
*.log

# OS
.DS_Store
Thumbs.db
```

#### 10. **README.md**
Should include:
- Project description
- Prerequisites
- Quick start guide
- Link to full documentation
- Support contacts

---

### Optional Helper Scripts

#### 11. **deploy-ee.sh**
- **Purpose**: Automated deployment script
- **Features**:
  - Prerequisite checking
  - Environment setup
  - Automated build process
  - Verification steps

---

### Generated Directories

#### **venv/** (Generated)
- Python virtual environment
- Created by: `python3 -m venv venv`
- **Do not commit to Git**
- Add to `.gitignore`

#### **context/** (Generated)
- Build context created by ansible-builder
- Contains: Containerfile, dependencies
- **Do not commit to Git**
- Cleaned by: `make clean`

---

## File Permissions

Set correct permissions before building:

```bash
# Make Git credential helper executable
chmod +x git-credential-environment

# Optional: Make deployment script executable
chmod +x deploy-ee.sh

# Verify permissions
ls -la git-credential-environment
```

---

## Environment Variables Required

### During Build

```bash
# Required for Ansible Galaxy collections
export ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_TOKEN="your_token_here"
```

### During Runtime (Optional)

```bash
# For Git operations in the EE
export GIT_USERNAME="your_git_username"
export GIT_PASSWORD="your_git_password_or_token"
```

---

## Version Control Best Practices

### What to Commit

✅ **DO commit:**
- All core configuration files
- Makefile
- Documentation files
- Certificate files (if not sensitive)
- Helper scripts

❌ **DO NOT commit:**
- `venv/` directory
- `context/` directory
- `*.tar` and `*.tar.gz` files
- Token files or credentials
- Build artifacts

### Recommended .gitignore

```gitignore
# Python
venv/
__pycache__/
*.pyc
*.egg-info/

# Build artifacts
context/
*.tar
*.tar.gz

# Secrets
*.token
.env
secrets/

# IDE
.vscode/
.idea/

# OS
.DS_Store
```

---

## Customization Guide

### Adding New Python Packages

Edit `requirements.txt`:
```txt
# Add your package
new-package>=1.0.0
```

### Adding New Ansible Collections

Edit `requirements.yml`:
```yaml
collections:
  - name: your.collection
    version: ">=1.0.0"
```

### Adding System Packages

Edit `bindep.txt`:
```
your-package [platform:rpm]
```

### Adding Custom Build Steps

Edit `execution-environment.yml` under `additional_build_steps`:
```yaml
append_final:
  - RUN your-custom-command
```

---

## File Validation Checklist

Before building, verify:

- [ ] All required files present
- [ ] `git-credential-environment` is executable
- [ ] `hylandgov-chain.pem` is valid PEM format
- [ ] No sensitive data in committed files
- [ ] `.gitignore` configured properly
- [ ] Token exported in environment
- [ ] Logged into Red Hat registry

---

## Minimal Required Files

For a basic working EE, you need at minimum:

1. **execution-environment.yml** - EE definition
2. **requirements.yml** - Ansible collections
3. **requirements.txt** - Python packages
4. **Makefile** or build command

Optional but recommended:
- **bindep.txt** - System packages
- **git-credential-environment** + **gitconfig** - Git integration
- **hylandgov-chain.pem** - Custom certificates

---

## File Dependencies Diagram

```
Makefile
  └─> ansible-builder build
        └─> execution-environment.yml
              ├─> requirements.yml (Ansible collections)
              ├─> requirements.txt (Python packages)
              ├─> bindep.txt (System packages)
              └─> additional_build_files/
                    ├─> git-credential-environment
                    ├─> gitconfig
                    └─> hylandgov-chain.pem
```

---

## File Sizes (Approximate)

| File | Typical Size |
|------|-------------|
| execution-environment.yml | 1-2 KB |
| requirements.yml | < 1 KB |
| requirements.txt | < 1 KB |
| bindep.txt | < 1 KB |
| Makefile | 2-3 KB |
| git-credential-environment | < 1 KB |
| gitconfig | < 1 KB |
| hylandgov-chain.pem | 3-5 KB |
| Built image (compressed) | 500 MB - 2 GB |

---

## Maintenance

### Regular Updates

Update dependencies periodically:

```bash
# Update Python packages
pip list --outdated

# Check Ansible collections
ansible-galaxy collection list

# Rebuild with updates
make rebuild
```

### Security Scanning

```bash
# Scan image for vulnerabilities
docker scan ee-onbase-deployment-automation-rhel9:latest

# Or with trivy
trivy image ee-onbase-deployment-automation-rhel9:latest
```

---

## Support Files Location

All support files should be in the repository root:

```
ee-onbase-deployment-automation-rhel9/
├── [Core Files Here]
└── docs/                    # Optional: Additional documentation
    ├── deployment-guide.md
    ├── troubleshooting.md
    └── makefile-reference.md
```