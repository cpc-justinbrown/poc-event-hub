resource "azurerm_resource_group" "rg" {
  name     = "rgEventHub"
  location = "southcentralus"
}

resource "azurerm_storage_account" "sa" {
  name                     = "sapoceventhub"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "sac_checkpoint" {
  name                  = "event-hub-checkpoint"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "sac_capture" {
  name                  = "event-hub-capture"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

resource "azurerm_eventhub_namespace" "ehn" {
  name                = "ProofOfConceptEventHubNamespace"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
}

resource "azurerm_eventhub" "eh" {
  name                = "ProofOfConceptEventHub"
  namespace_name      = azurerm_eventhub_namespace.ehn.name
  resource_group_name = azurerm_resource_group.rg.name
  partition_count     = 1
  message_retention   = 1

  capture_description {
    enabled  = true
    encoding = "Avro"

    destination {
      name                = "EventHubArchive.AzureBlockBlob"
      archive_name_format = "{Namespace}/{EventHub}/{PartitionId}/{Year}-{Month}-{Day}T{Hour}:{Minute}:{Second}"
      blob_container_name = azurerm_storage_container.sac_capture.name
      storage_account_id  = azurerm_storage_account.sa.id
    }
  }
}

resource "azurerm_service_plan" "asp" {
  name                = "asEventHub"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_application_insights" "appi" {
  name                = "appiEventHub"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

resource "azurerm_linux_function_app" "af" {
  name                       = "faEventHub"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  storage_account_name       = azurerm_storage_account.sa.name
  service_plan_id            = azurerm_service_plan.asp.id
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key

  app_settings = {
    "BUILD_FLAGS"                    = "UseExpressBuild"
    "ENABLE_ORYX_BUILD"              = true
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = 1
    "XDG_CACHE_HOME"                 = "/tmp/.cache"
  }

  site_config {
    application_insights_connection_string = azurerm_application_insights.appi.connection_string
    application_insights_key               = azurerm_application_insights.appi.instrumentation_key

    application_stack {
      python_version = 3.9
    }
  }

  tags = {
    "hidden-link: /app-insights-conn-string" = azurerm_application_insights.appi.connection_string
    "hidden-link: /app-insights-instrumentation-key" = azurerm_application_insights.appi.instrumentation_key
    "hidden-link: /app-insights-resource-id" = azurerm_application_insights.appi.id
  }
}

resource "azurerm_eventgrid_system_topic" "egst" {
  name                   = "egstEventHub"
  location               = azurerm_resource_group.rg.location
  resource_group_name    = azurerm_resource_group.rg.name
  source_arm_resource_id = azurerm_eventhub_namespace.ehn.id
  topic_type             = "Microsoft.Eventhub.Namespaces"
}

resource "azurerm_eventgrid_system_topic_event_subscription" "egstes" {
  name                = "EventHubEventSubscription"
  system_topic        = azurerm_eventgrid_system_topic.egst.name
  resource_group_name = azurerm_resource_group.rg.name

  azure_function_endpoint {
    function_id = "${azurerm_linux_function_app.af.id}/functions/EventGridTrigger"
    max_events_per_batch = 1
    preferred_batch_size_in_kilobytes = 64
  }
}