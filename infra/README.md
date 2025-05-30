# Azure AI Chat Application - Terraform Infrastructure

This directory contains the Terraform infrastructure-as-code configuration for deploying the Azure AI Chat application using Azure Developer CLI (azd) with Terraform as the IaC provider.

## Prerequisites

1. [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (v2.38.0+)
2. [Terraform](https://learn.microsoft.com/en-us/azure/developer/terraform/quickstart-configure) (v1.1.7+)
3. [Azure Developer CLI (azd)](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd)

## Quick Start

Deploy the application with a single command:

```bash
# Initialize and deploy
azd up
```

The configuration uses local Terraform state files, which is perfect for individual development and getting started quickly.

## Configuration

### Environment Variables

You can customize the deployment by setting environment variables:

```bash
# Set the Azure region (default: eastus)
azd env set AZURE_LOCATION "westus2"

# Set a custom environment name (default: random)
azd env set AZURE_ENV_NAME "myapp-dev"

# Enable/disable AI Search (default: false)
azd env set USE_SEARCH_SERVICE "true"
```

### Advanced Configuration

For more advanced customization, you can create a `terraform.tfvars` file in this directory:

```hcl
# Example terraform.tfvars
location = "westus2"
environmentName = "myapp-prod"
principalId = "your-user-object-id"
```

## Deployment

Deploy the infrastructure using azd:

```bash
# Initialize the environment (if not already done)
azd init

# Deploy the infrastructure and application
azd up
```

## Infrastructure Components

This Terraform configuration deploys:

- **Resource Group**: Container for all resources
- **Azure AI Services**: Cognitive Services account with OpenAI models
- **Storage Account**: For AI Hub and application data
- **Log Analytics Workspace**: For monitoring and logging
- **Application Insights**: Application performance monitoring
- **Container Registry**: For container images
- **Container Apps Environment**: Serverless container hosting
- **Container App**: API application hosting
- **User Assigned Managed Identity**: For secure service-to-service authentication
- **Role Assignments**: Proper RBAC permissions for all services
- **Azure Search** (optional): For RAG capabilities

## Key Features

- **AI Model Deployments**: Automatically deploys GPT and embedding models
- **Secure Authentication**: Uses managed identities and RBAC
- **Monitoring**: Integrated Application Insights and Log Analytics
- **Scalable Hosting**: Container Apps for automatic scaling
- **Simple Deployment**: One-command deployment with azd

## Outputs

The Terraform configuration outputs all necessary environment variables that the application needs, including:

- AI service endpoints and deployment names
- Resource identifiers
- Authentication configuration
- Monitoring settings

## Customization

You can customize the deployment by:

1. Modifying variables in `terraform.tfvars`
2. Enabling/disabling features like search service
3. Adjusting AI model configurations
4. Setting custom resource names

## Cleanup

To remove all resources:

```bash
azd down
```

## Troubleshooting

### Common Issues

1. **Quota Limits**: Ensure your subscription has sufficient quota for AI services in your chosen region
2. **Permissions**: Verify you have Contributor access to the subscription
3. **Resource Names**: Storage account and other resource names must be globally unique

### Getting Help

- [Azure Developer CLI Documentation](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/)
- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure AI Services Documentation](https://learn.microsoft.com/en-us/azure/ai-services/)
