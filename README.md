# Deploying Azure SQL VM, Synapse Workspace, and Spark Notebook Integration

Note: This repository provides an example of deploying a secure Azure environment that includes:
- An Azure VM running SQL Server.
- An Azure Synapse workspace with the capability to run Spark notebooks.
- A Network Security Group (NSG) configured for least privilege network access.

This setup is ideal for scenarios requiring a controlled environment for running Spark-based ETL pipelines that ingest data into an Azure SQL instance.

> 📌 Status: Beta – This solution is still being tested. Please report any issues and provide feedback for improvements.

## 💡 Overview

This repository demonstrates how to:
1. Automate Infrastructure Deployment: Use Bicep templates to stand up an Azure SQL VM, a Synapse workspace, and associated networking.
2. Secure Network Configuration: Implement minimal NSG rules to restrict network access, following least privilege principles.
3. Spark-Based Data Ingestion: Leverage a Synapse Spark notebook to read sample data and load it into the Azure SQL instance.
4. One-Click Deployment: Simplify deployments with a single script to quickly provision, configure, and run the environment.

Goal: Provide a blueprint for integrating compute (VM), analytics (Synapse Spark), and storage (Azure SQL) in a secure and automated manner.

## 🏗️ Infrastructure Setup

### Prerequisites:
- Azure CLI installed
- Access to create resources in Azure (subscription, resource group)
- Bicep CLI installed (if using local tooling)

### Deployment Steps:
1. Clone this repository.
2. Modify infra/main.bicep parameters or .env file with your configuration values.
3. Run ./scripts/deploy.sh to create the Resource Group, VNet, NSG, SQL VM, and Synapse Workspace.

Note: This deploy script sets up infrastructure only. It does not automatically upload the notebook to Synapse or run the Spark job. Those steps follow below.

### Infrastructure Deploy to Azure

[![Deploy To Azure](images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmarcjimz%2Fazure-quickstart-templates%2Fmaster%2Finfra%2Fazuredeploy.json)
[![Visualize](images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fmarcjimz%2Fazure-quickstart-templates%2Fmaster%2Finfra%2Fazuredeploy.json)

## 🔑 Security and Networking

NSG and Firewall Rules:
- The network.bicep module creates a VNet and NSG.
- Only essential ports (e.g., port 1433 for SQL Server) are allowed.
- Traffic is restricted to known IP ranges (e.g., Synapse subnet) for secure data flows.

Least Privilege: By default, no inbound traffic is allowed except those explicitly defined. You can adjust rules as needed in infra/dependencies/network.bicep.

## 💻 Running the Spark Notebook

### Steps:
1. After infrastructure deployment, open the Azure Synapse Studio linked to the newly created workspace.
2. Navigate to the Manage hub, and import the notebook from spark/notebooks/data_upload_notebook.ipynb.
3. Attach the notebook to a Spark pool and run it.
4. The notebook will:
   - Access sample data (e.g., from a specified storage location).
   - Write the processed data into the SQL VM instance.

Tip: Ensure that authentication and firewall rules allow the Synapse runtime to connect to the SQL VM. Use Managed Identity or SQL Authentication as configured.

## 🔍 Verifying Data in SQL

Query the SQL Database:
Connect to the SQL VM using Azure Data Studio or SSMS.
Run a simple SELECT query on the target table to confirm that the data has been successfully ingested:

```sql
SELECT TOP 10 * FROM YourDatabase.YourSchema.YourTable;
```

> ✅ Success: If you see the ingested rows, your end-to-end deployment and data flow works as intended.

## ⚙️ Configuration

### Environment Variables (sample in .env):

```bash
LOCATION='eastus'
SQL_ADMIN_USERNAME='sqlAdmin'
SQL_ADMIN_PASSWORD='YourSecureP@ssw0rd!'
SYNAPSE_ADMIN_EMAIL='admin@example.com'
```

### Bicep Parameters:

Adjust parameters in infra/main.bicep to specify resource names, sizes, and other configuration options.

Note: Do not commit secrets to your repo. Keep sensitive info in .env and add .env to .gitignore.

## 📜 Known Limitations

- Automated Notebook Uploads: Currently, notebook upload and pipeline creation in Synapse are manual steps. Future enhancements may include CLI commands or CI/CD to automate this.
- Minimal Sample: The provided notebook and data ingestion scenario is simplistic. More complex transformations, error handling, and orchestration can be integrated as needed.

## 📚 Additional Resources

- Azure Bicep Documentation: https://learn.microsoft.com/azure/azure-resource-manager/bicep/
- Azure Synapse Analytics: https://learn.microsoft.com/azure/synapse-analytics/
- Azure SQL VM Guidance: https://learn.microsoft.com/azure/azure-sql/virtual-machines/windows/overview
- Network Security Groups Overview: https://learn.microsoft.com/azure/virtual-network/security-overview

## 👥 Contributing

If you find bugs, have feature requests, or want to contribute improvements, please open an issue or submit a pull request.

## ❓Support

For any questions, feel free to reach out via the project's Issue tracker. Your feedback helps us improve this solution for broader use cases.