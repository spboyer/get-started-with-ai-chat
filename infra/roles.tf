# Role assignments for the Azure resources

# Assign Cognitive Services User role to current user for AI Services
resource "azurerm_role_assignment" "ai_services_user" {
  scope                = azurerm_cognitive_account.ai_services.id
  role_definition_name = "Cognitive Services User"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Assign Storage Blob Data Contributor role to current user
resource "azurerm_role_assignment" "storage_blob_contributor" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Assign Search Index Data Contributor role to current user
resource "azurerm_role_assignment" "search_index_contributor" {
  scope                = azurerm_search_service.search.id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Assign Search Service Contributor role to current user
resource "azurerm_role_assignment" "search_service_contributor" {
  scope                = azurerm_search_service.search.id
  role_definition_name = "Search Service Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}
