# Declare output values for the main terraform module.
#
# This allows the main terraform module outputs to be referenced by other modules,
# or by the local machine as a way to reference created resources in Azure for local development.
# Secrets should not be added here.
#
# Outputs are automatically saved in the local azd environment .env file.
# To see these outputs, run `azd env get-values`. `azd env get-values --output json` for json output.

output "AZURE_LOCATION" {
  value = var.location
}

output "AZURE_TENANT_ID" {
  value = data.azurerm_client_config.current.tenant_id
}

output "AZURE_RESOURCE_GROUP" {
  value = azurerm_resource_group.rg.name
}

# Storage outputs
output "AZURE_STORAGE_ACCOUNT_NAME" {
  value = azurerm_storage_account.storage.name
}

output "AZURE_STORAGE_CONTAINER_NAME" {
  value = azurerm_storage_container.default.name
}

# Azure AI Services outputs
output "AZURE_OPENAI_ENDPOINT" {
  value = azurerm_cognitive_account.ai_services.endpoint
}

# Azure AI deployment outputs
output "AZURE_OPENAI_CHAT_DEPLOYMENT_NAME" {
  value = azurerm_cognitive_deployment.chat_deployment.name
}

output "AZURE_OPENAI_EMBEDDING_DEPLOYMENT_NAME" {
  value = azurerm_cognitive_deployment.embedding_deployment.name
}

# Search service outputs
output "AZURE_SEARCH_ENDPOINT" {
  value = "https://${azurerm_search_service.search.name}.search.windows.net"
}

output "AZURE_SEARCH_SERVICE_NAME" {
  value = azurerm_search_service.search.name
}

# Container App outputs
output "AZURE_CONTAINER_APPS_ENVIRONMENT_NAME" {
  value = azurerm_container_app_environment.env.name
}

output "AZURE_CONTAINER_REGISTRY_NAME" {
  value = azurerm_container_registry.registry.name
}

output "AZURE_CONTAINER_REGISTRY_ENDPOINT" {
  value = azurerm_container_registry.registry.login_server
}

# Application Insights outputs
output "AZURE_APPLICATION_INSIGHTS_CONNECTION_STRING" {
  value     = azurerm_application_insights.appinsights.connection_string
  sensitive = true
}

output "AZURE_APPLICATION_INSIGHTS_NAME" {
  value = azurerm_application_insights.appinsights.name
}

# Container App URL
output "SERVICE_API_ENDPOINTS" {
  value = azurerm_container_app.app.latest_revision_fqdn != null ? "https://${azurerm_container_app.app.latest_revision_fqdn}" : ""
}
