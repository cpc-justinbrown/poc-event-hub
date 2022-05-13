# https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-python-get-started-send

import asyncio
from os import name
from azure.eventhub.aio import EventHubConsumerClient
from azure.eventhub.extensions.checkpointstoreblobaio import BlobCheckpointStore


async def on_event(partition_context, event):
    # Print the event data.
    print("Received the event: \"{}\" from the partition with ID: \"{}\"".format(event.body_as_str(encoding='UTF-8'), partition_context.partition_id))

    # Update the checkpoint so that the program doesn't read the events
    # that it has already read when you run it next time.
    await partition_context.update_checkpoint(event)

async def main():
    # Create an Azure blob checkpoint store to store the checkpoints.
    conn_str = 'DefaultEndpointsProtocol=https;AccountName=sapoceventhub;AccountKey=L/pu0CXO+6M/d+dZ5kTrUKALh80xYxMOwIhD+oBVVrrlkqMr1dmk2N3cgJ2Aw0ZOZ9PpGYQDsVOzyjVVnVNWmg==;EndpointSuffix=core.windows.net'
    name = 'event-hub-checkpoint'
    checkpoint_store = BlobCheckpointStore.from_connection_string(conn_str, name)

    # Create a consumer client for the event hub.
    conn_str = "Endpoint=sb://proofofconcepteventhubnamespace.servicebus.windows.net/;SharedAccessKeyName=Listener;SharedAccessKey=LFVK7gtvw55tuDKzp+v601g+QnmAIvHXQBy6vGZbvaU="
    eventhub_name = "proofofconcepteventhub"
    client = EventHubConsumerClient.from_connection_string(conn_str, consumer_group="$Default", eventhub_name=eventhub_name, checkpoint_store=checkpoint_store)
    async with client:
        # Call the receive method. Read from the beginning of the partition (starting_position: "-1")
        await client.receive(on_event=on_event,  starting_position="-1")

if __name__ == '__main__':
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    # Run the main method.
    loop.run_until_complete(main())    