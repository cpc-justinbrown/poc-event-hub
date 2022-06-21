# poc-event-hub
Proof of concept for sending messages to and receiving messages from an Event Hub Instance.

This codebase was adapted from:
- [Send or receive events from Azure Event Hubs using Python (latest) - Azure Event Hubs | Microsoft Docs](https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-python-get-started-send)
- [Tutorial: Send Event Hubs data to data warehouse - Event Grid - Azure Event Grid | Microsoft Docs](https://docs.microsoft.com/en-us/azure/event-grid/event-grid-event-hubs-integration)
- [azure-event-hubs/samples/e2e/EventHubsCaptureEventGridDemo at master · Azure/azure-event-hubs · GitHub](https://github.com/Azure/azure-event-hubs/tree/master/samples/e2e/EventHubsCaptureEventGridDemo)

## Architecture Overview
![Architecture](docs/Architecture.png)

A message producer generates messages and sends them to the Event Hub.  The Event Hub captures ingested events to a storage account once per minute and generates a corresponding event.

A message consumer subscribes to the Event Hub to listen for new messages. A Function App handles new capture file events by inspecting the file for events to log to a database.

A Power BI report displays analytics from the database.

## Installation
1. Clone the repo locally.
1. Deploy the terraform infrastructure. (partial)
1. Deploy the Azure Function.
1. Deploy the terraform infrastructure. (complete)
1. Deploy the SQL database script.
1. Create a secrets.json file with the necessary prerequisites.
    * See outputs.tf for sensitive values exposed in state for prerequisites.

```json
{
    "sender": {
        "event_hub_send_conn_str": "Endpoint=sb://<EVENT HUB NAMESPACE>.servicebus.windows.net/;SharedAccessKeyName=<SEND POLICY NAME>;SharedAccessKey=<SEND POLICY KEY>",
        "event_hub_name": "<EVENT HUB INSTANCE NAME>"
    },
    "receiver": {
        "blob_conn_str": "DefaultEndpointsProtocol=https;AccountName=<STORAGE ACCOUNT NAME>;AccountKey=<STORAGE ACCOUNT ACCESS KEY>;EndpointSuffix=core.windows.net",
        "blob_container_name": "event-hub-checkpoint",
        "event_hub_receive_conn_str": "Endpoint=sb://<EVENT HUB NAMESPACE>.servicebus.windows.net/;SharedAccessKeyName=<RECEIVE POLICY NAME>;SharedAccessKey=<RECEIVE POLICY KEY>",
        "event_hub_name": "<EVENT HUB INSTANCE NAME>"
    }
}
```

## listener
Subscribes to the Event Hub Instance consumer group and displays received messages.

### Prerequisites
```python
pip install asyncio
pip install azure.eventhub
pip install azure-eventhub-checkpointstoreblob-aio
```

A SAS policy at the Event Hub Namespace with `Listen` claim.

## sender
Sends messages to the Event Hub Instance.

### Prerequisites
```python
pip install asyncio
pip install azure.eventhub
```

A SAS policy at the Event Hub Namespace with `Send` claim.

Add the CPChem Root CA to Python's certificate store given by `certifi.where()`.

## terraform
This provisions an Event Hub Namespace with one Event Hub Instance. It also provisions a Storage Account and a blob Container for the Event Hub to use for maintaining a processing checkpoint.

### Prerequisites

```python
pip install azure-storage-blob
```

# Event Hub Recommendations

* Create SendOnly and ListenOnly policies for the event publisher and consumer, respectively.
* When using the SDK to send events to Event Hubs, ensure the exceptions thrown by the retry policy (EventHubsException or OperationCancelledException) are properly caught.
* In high-throughput scenarios, use batched events.
* Every consumer can read events from one to 32 partitions.
* When developing new applications, use EventProcessorClient (.NET and Java) or EventHubConsumerClient (Python and JavaScript) as the client SDK.
* As part of your solution-wide availability and disaster recovery strategy, consider enabling the Event Hubs geo disaster-recovery option.
* When a solution has a large number of independent event publishers, consider using Event Publishers for fine-grained access control.
* Don't publish events to a specific partition.
* When publishing events frequently, use the AMQP protocol when possible.
* The number of partitions reflect the degree of downstream parallelism you can achieve.
* Ensure each consuming application uses a separate consumer group and only one active receiver per consumer group is in place.
* When using the Capture feature, carefully consider the configuration of the time window and file size, especially with low event volumes.

[Event Hubs and reliability - Checklist] (https://docs.microsoft.com/en-us/azure/architecture/framework/services/messaging/event-hubs/reliability#checklist)
