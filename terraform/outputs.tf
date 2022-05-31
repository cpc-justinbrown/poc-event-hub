output "event_hub_send_conn_str" {
  description = "Event Hub Namespace's send access policy's primary connection string."
  value       = azurerm_eventhub_authorization_rule.ehar_sender.primary_connection_string
  sensitive   = true
}

output "event_hub_listen_conn_str" {
  description = "Event Hub Namespace's listen access policy's primary connection string."
  value       = azurerm_eventhub_authorization_rule.ehar_listener.primary_connection_string
  sensitive   = true
}

output "blob_conn_str" {
  description = "Storage Account's primary connection string."
  value       = azurerm_storage_account.sa.primary_connection_string
  sensitive   = true
}