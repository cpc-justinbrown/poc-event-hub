# poc-event-hub
Proof of concept for sending messages to and receiving messages from an Event Hub Instance.

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
