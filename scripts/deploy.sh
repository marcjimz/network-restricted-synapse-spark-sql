#!/bin/bash
if [ -z "$1" ]; then
  echo "Error: SQL Admin Password is required as the first argument."
  echo "Usage: $0 <SQL_Admin_Password>"
  exit 1
fi

# Capture the SQL Admin Password from the first argument
sql_admin_password="$1"

# Generate a unique 3-character alphanumeric identifier
unique_id=$(printf "%03d" $((RANDOM % 1000)))
region="eastus2"

# Function to measure the time taken for each step
measure_time() {
    start_time=$(date +%s)
    "$@"
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    echo "Time taken for $1: $duration seconds"
}

# Create the resource group for the deployment
sql_spark_rg_name="nw-restr-spark-sql-$unique_id"
echo "Creating resource group: $sql_spark_rg_name"
measure_time az group create --name "$sql_spark_rg_name" --location "$region"

# Parameters for the deployment
deployment_name="demo"
vnet_name="CoreVnet-$unique_id"
vnet_rg_name="$sql_spark_rg_name"
subnet_name="default"
sql_admin_username="azureuser"
synapse_admin_email="admin@example.com"

# Deploy the main Bicep file
main_bicep_file="infra/main.bicep"
echo "Deploying main Bicep file: $main_bicep_file"
measure_time az deployment group create \
    --resource-group "$sql_spark_rg_name" \
    --template-file "$main_bicep_file" \
    --parameters deploymentName="$deployment_name" \
                 location="$region" \
                 tags="{}" \
                 vnetName="$vnet_name" \
                 vnetRgName="$vnet_rg_name" \
                 subnetName="$subnet_name" \
                 sqlAdminUsername="$sql_admin_username" \
                 sqlAdminPassword="$sql_admin_password"

echo "Deployment complete."