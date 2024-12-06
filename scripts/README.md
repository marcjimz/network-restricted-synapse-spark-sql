
# SQL VM and Network Deployment Scripts

This repository contains a set of scripts to deploy, build, and clean up an Azure SQL Virtual Machine and its associated resources. The deployment utilizes Azure Bicep templates to create the infrastructure.

## Scripts Overview

### 1. `build.sh`
This script builds the Bicep template to ensure it is syntactically correct and generates an ARM template.

#### Usage:
```bash
./build.sh
```

- **What it does**:
  1. Runs the Azure CLI command to build the `infra/main.bicep` file into an ARM template.

---

### 2. `deploy.sh`
This script deploys the Azure resources using the Bicep template located in the `infra` folder.

#### Usage:
```bash
./deploy.sh <SQL_Admin_Password>
```

- **Parameters**:
  - `SQL_Admin_Password`: The SQL admin password for the virtual machine. This is required and must be provided as the first argument.
  
- **What it does**:
  1. Creates a resource group with a unique identifier.
  2. Deploys an Azure SQL VM and network resources using the `infra/main.bicep` template.

---

### 3. `cleanup.sh`
This script deletes all resource groups that start with the prefix `nw-restr-spark-sql`.

#### Usage:
```bash
./cleanup.sh
```

- **What it does**:
  1. Lists all resource groups starting with the prefix `nw-restr-spark-sql`.
  2. Schedules these resource groups for deletion.

---

## Prerequisites
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed and authenticated.
- The `az bicep` extension installed:
  ```bash
  az bicep install
  ```
- Execute permission for the scripts:
  ```bash
  chmod +x deploy.sh cleanup.sh build.sh
  ```

## Notes
- Ensure the `SQL_Admin_Password` is securely stored and not hardcoded in any script.
- Review the Bicep template in `infra/main.bicep` for customization and resource details.
