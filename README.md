# poc-event-hub
Proof of concept for sending messages to and receiving messages from an Event Hub Instance.

## Installation
1. Clone the repo locally.
2. Create a secrets.json file with the necessary prerequisites.

```json
{
    "sender": {
        "conn_str": "Endpoint=sb://<EVENT HUB NAMESPACE>.servicebus.windows.net/;SharedAccessKeyName=<SEND POLICY NAME>;SharedAccessKey=<SEND POLICY KEY>",
        "event_hub_name": "<EVENT HUB INSTANCE NAME>"
    },
    "receiver": {
        "blob_conn_str": "DefaultEndpointsProtocol=https;AccountName=<STORAGE ACCOUNT NAME>;AccountKey=<STORAGE ACCOUNT ACCESS KEY>;EndpointSuffix=core.windows.net",
        "blob_name": "event-hub-checkpoint",
        "eventhub_listener_conn_str": "Endpoint=sb://<EVENT HUB NAMESPACE>.servicebus.windows.net/;SharedAccessKeyName=<RECEIVE POLICY NAME>;SharedAccessKey=<RECEIVE POLICY KEY>",
        "eventhub_name": "<EVENT HUB INSTANCE NAME>"
    }
}
```

## receiver
Receives and displays messages from the Event Hub Instance.

### Prerequisites
```python
pip install asyncio
pip install azure.eventhub
pip install azure-eventhub-checkpointstoreblob-aio
```

A SAS policy at the Event Hub Namespace with Listen claim.

## sender
Sends messages to the Event Hub Instance.

### Prerequisites
```python
pip install asyncio
pip install azure.eventhub
```

A SAS policy at the Event Hub Namespace with Send claim.

## terraform
This provisions an Event Hub Namespace with one Event Hub Instance. It also provisions a Storage Account and a blob Container for the Event Hub to use for maintaining a processing checkpoint.