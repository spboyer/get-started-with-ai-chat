locals {
  tags = { azd-env-name : var.environment_name }
  sha = base64encode(sha256("${var.environment_name}${var.location}${data.azurerm_client_config.current.subscription_id}"))
  resource_token = substr(replace(lower(local.sha), "[^A-Za-z0-9_]", ""), 0, 13)
}

data "azurerm_client_config" "current" {}

resource "azurecaf_name" "rg_name" {
  name          = var.environment_name
  resource_type = "azurerm_resource_group"
  random_length = 0
  clean_input   = true
}

# Deploy resource group
resource "azurerm_resource_group" "rg" {
  name     = azurecaf_name.rg_name.result
  location = var.location
  // Tag the resource group with the azd environment name
  // This should also be applied to all resources created in this module
  tags = { azd-env-name : var.environment_name }
}

# Deploy storage account
resource "azurecaf_name" "storage_account_name" {
  name          = local.resource_token
  resource_type = "azurerm_storage_account"
  random_length = 0
  clean_input   = true
}

resource "azurerm_storage_account" "storage" {
  name                            = azurecaf_name.storage_account_name.result
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  
  # Required by Azure policies
  allow_nested_items_to_be_public = false
  # Disable shared access key to comply with Azure policies
  shared_access_key_enabled       = false
  # Use Azure AD authentication instead
  default_to_oauth_authentication = true  # Ensure minimum TLS version
  min_tls_version                 = "TLS1_2"
  
  blob_properties {
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }
  
  # Add identity for Azure AD authentication
  identity {
    type = "SystemAssigned"
  }
  
  tags = local.tags
}

# Storage container
resource "azurerm_storage_container" "default" {
  name                 = "default"
  storage_account_name = azurerm_storage_account.storage.name
  container_access_type = "private"
}

# Deploy log analytics workspace
resource "azurecaf_name" "log_analytics_name" {
  name          = local.resource_token
  resource_type = "azurerm_log_analytics_workspace"
  random_length = 0
  clean_input   = true
}

resource "azurerm_log_analytics_workspace" "logs" {
  name                = azurecaf_name.log_analytics_name.result
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}

# Deploy application insights
resource "azurecaf_name" "app_insights_name" {
  name          = local.resource_token
  resource_type = "azurerm_application_insights"
  random_length = 0
  clean_input   = true
}

resource "azurerm_application_insights" "appinsights" {
  name                = azurecaf_name.app_insights_name.result
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.logs.id
  tags                = local.tags
}

# Deploy cognitive services account
resource "azurecaf_name" "cognitive_account_name" {
  name          = local.resource_token
  resource_type = "azurerm_cognitive_account"
  random_length = 0
  clean_input   = true
}

resource "azurerm_cognitive_account" "ai_services" {
  name                = azurecaf_name.cognitive_account_name.result
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "OpenAI"
  sku_name            = "S0"
  
  custom_subdomain_name = azurecaf_name.cognitive_account_name.result
  public_network_access_enabled = true
  
  identity {
    type = "SystemAssigned"
  }
  
  tags = local.tags
}

# OpenAI model deployments
resource "azurerm_cognitive_deployment" "chat_deployment" {
  name                 = "gpt-4o-mini"
  cognitive_account_id = azurerm_cognitive_account.ai_services.id
  
  model {
    format  = "OpenAI"
    name    = "gpt-4o-mini"
    version = "2024-07-18"
  }
  
  scale {
    type = "Standard"
  }
}

resource "azurerm_cognitive_deployment" "embedding_deployment" {
  name                 = "text-embedding-3-small"
  cognitive_account_id = azurerm_cognitive_account.ai_services.id
  
  model {
    format  = "OpenAI"
    name    = "text-embedding-3-small"
    version = "1"
  }
  
  scale {
    type = "Standard"
  }
}

# Deploy search service
resource "azurecaf_name" "search_service_name" {
  name          = local.resource_token
  resource_type = "azurerm_search_service"
  random_length = 0
  clean_input   = true
}

resource "azurerm_search_service" "search" {
  name                          = azurecaf_name.search_service_name.result
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = var.location
  sku                           = "standard"
  semantic_search_sku           = "standard"
  local_authentication_enabled = true
  
  identity {
    type = "SystemAssigned"
  }
  
  tags = local.tags
}

# Deploy container registry
resource "azurecaf_name" "container_registry_name" {
  name          = local.resource_token
  resource_type = "azurerm_container_registry"
  random_length = 0
  clean_input   = true
}

resource "azurerm_container_registry" "registry" {
  name                = azurecaf_name.container_registry_name.result
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = true
  
  identity {
    type = "SystemAssigned"
  }
  
  tags = local.tags
}

# Deploy container apps environment
resource "azurecaf_name" "container_apps_env_name" {
  name          = local.resource_token
  resource_type = "azurerm_container_app_environment"
  random_length = 0
  clean_input   = true
}

resource "azurerm_container_app_environment" "env" {
  name                       = azurecaf_name.container_apps_env_name.result
  location                   = var.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id
  
  tags = local.tags
}

# Deploy container app
resource "azurecaf_name" "container_app_name" {
  name          = local.resource_token
  resource_type = "azurerm_container_app"
  random_length = 0
  clean_input   = true
}

resource "azurerm_container_app" "app" {
  name                         = azurecaf_name.container_app_name.result
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "chat-app"
      image  = "nginx:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
    
    min_replicas = 1
    max_replicas = 3
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 80
    
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = merge(local.tags, {
    "azd-service-name" = "api"
  })
}
