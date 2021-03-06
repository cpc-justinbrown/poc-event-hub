import asyncio
from azure.eventhub.aio import EventHubProducerClient
from azure.eventhub import EventData,TransportType
import json
from datetime import datetime

# Load secrets from file.
secrets = json.load(open('..\secrets.json'))
event_hub_send_conn_str = secrets["sender"]["event_hub_send_conn_str"]
event_hub_name = secrets["sender"]["event_hub_name"]

async def run():
    # Create a producer client to send messages to the event hub.
    # Specify a connection string to your event hubs namespace and
    # the event hub name.
    producer = EventHubProducerClient.from_connection_string(conn_str=event_hub_send_conn_str, eventhub_name=event_hub_name,transport_type=TransportType.AmqpOverWebsocket)
    async with producer:
        # Create a batch.
        event_data_batch = await producer.create_batch()

        # Add events to the batch.
        print("Enter messages (or hit Return to quit):")
        while True:
            message = input("> ")
            if message:
                body = {
                    "message": message,
                    "timestamp": datetime.utcnow().isoformat('T',timespec='milliseconds')
                }
                event_data_batch.add(EventData(json.dumps(body)))
            else:
                break

        # Send the batch of events to the event hub.
        await producer.send_batch(event_data_batch)

loop = asyncio.new_event_loop()
asyncio.set_event_loop(loop)
loop.run_until_complete(run())