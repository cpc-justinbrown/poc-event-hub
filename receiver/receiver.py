# https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-python-get-started-send

import asyncio
from os import name
from azure.eventhub.aio import EventHubConsumerClient
from azure.eventhub.extensions.checkpointstoreblobaio import BlobCheckpointStore
import json

# Load secrets from file.
secrets = json.load(open('..\secrets.json'))
blob_conn_str = secrets["receiver"]["blob_conn_str"]
blob_name = secrets["receiver"]["blob_name"]
event_hub_receive_conn_str = secrets["receiver"]["event_hub_receive_conn_str"]
event_hub_name = secrets["receiver"]["event_hub_name"]

async def on_event(partition_context, event):
    # Print the event data.
    print("Received the event: \"{}\" from the partition with ID: \"{}\"".format(event.body_as_str(encoding='UTF-8'), partition_context.partition_id))

    # Update the checkpoint so that the program doesn't read the events
    # that it has already read when you run it next time.
    await partition_context.update_checkpoint(event)

async def main():
    # Create an Azure blob checkpoint store to store the checkpoints.
    checkpoint_store = BlobCheckpointStore.from_connection_string(blob_conn_str, blob_name)

    # Create a consumer client for the event hub.
    client = EventHubConsumerClient.from_connection_string(event_hub_receive_conn_str, consumer_group="$Default", eventhub_name=event_hub_name, checkpoint_store=checkpoint_store)
    async with client:
        # Call the receive method. Read from the beginning of the partition (starting_position: "-1")
        await client.receive(on_event=on_event,  starting_position="-1")

if __name__ == '__main__':
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    # Run the main method.
    loop.run_until_complete(main())    