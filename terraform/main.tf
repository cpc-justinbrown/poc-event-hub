resource "azurerm_resource_group" "rg" {
  name     = "rgEventHub"
  location = "southcentralus"
}

resource "azurerm_eventhub_namespace" "ehns" {
  name                = "ProofOfConceptEventHubNamespace"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Basic"
}

resource "azurerm_eventhub" "eh" {
  name                = "ProofOfConceptEventHub"
  namespace_name      = azurerm_eventhub_namespace.ehns.name
  resource_group_name = azurerm_resource_group.rg.name
  partition_count     = 1
  message_retention   = 1
}

resource "azurerm_storage_account" "sa" {
  name                     = "sapoceventhub"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "example" {
  name                  = "event-hub-checkpoint"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}