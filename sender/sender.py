# https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-python-get-started-send

import asyncio
from azure.eventhub.aio import EventHubProducerClient
from azure.eventhub import EventData,TransportType
import json

# Load secrets from file.
secrets = json.load(open('..\secrets.json'))
conn_str = secrets["sender"]["conn_str"]
eventhub_name = secrets["sender"]["event_hub_name"]

async def run():
    # Create a producer client to send messages to the event hub.
    # Specify a connection string to your event hubs namespace and
    # the event hub name.
    producer = EventHubProducerClient.from_connection_string(conn_str=conn_str, eventhub_name=eventhub_name,transport_type=TransportType.AmqpOverWebsocket)
    async with producer:
        # Create a batch.
        event_data_batch = await producer.create_batch()

        # Add events to the batch.
        event_data_batch.add(EventData('First event'))
        event_data_batch.add(EventData('Second event'))
        event_data_batch.add(EventData('Third event'))

        # Send the batch of events to the event hub.
        await producer.send_batch(event_data_batch)

loop = asyncio.new_event_loop()
asyncio.set_event_loop(loop)

# The following were needed to see errors like the following:
# INFO:uamqp.c_uamqp:b'Failed to verify trusted certificate in chain'
# INFO:uamqp.c_uamqp:b'Unable to verify server certificate against custom server trusted certificate'
#loop.set_debug(True)
#logging.basicConfig(level=logging.DEBUG)
# Resolution was to add CPChem root CA cert to the cert file given by: certifi.where()

loop.run_until_complete(run())