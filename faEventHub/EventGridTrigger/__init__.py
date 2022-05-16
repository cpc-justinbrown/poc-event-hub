import logging
import azure.functions as func
from avro.datafile import DataFileReader
from avro.io import DatumReader
import requests
import tempfile

def main(event: func.EventGridEvent):
    fileUrl = event.get_json()["fileUrl"]
    logging.info("Reading Avro file from: {fileUrl}".format(fileUrl=fileUrl))
    
    with tempfile.TemporaryFile() as file:
        file.write(requests.get(fileUrl).content)
        reader = DataFileReader(open(file,'rb'), DatumReader())
        logging.info("Schema: {schema}".format(schema=reader.meta))

    # result = json.dumps({
    #     'id': event.id,
    #     'data': event.get_json(),
    #     'topic': event.topic,
    #     'subject': event.subject,
    #     'event_type': event.event_type,
    # })
    # logging.info('Python EventGrid trigger processed an event: %s', result)

    # Sample Output:
    # Python EventGrid trigger processed an event:
    # {
    #   "id": "58c28314-b654-4fa7-9146-cd17b1b0e454",
    #   "data": {
    #       "fileUrl": "https://sapoceventhub.blob.core.windows.net/event-hub-capture/proofofconcepteventhubnamespace/proofofconcepteventhub/0/2022-05-13T18:36:22.avro",
    #       "fileType": "AzureBlockBlob",
    #       "partitionId": "0",
    #       "sizeInBytes": 217,
    #       "eventCount": 3,
    #       "firstSequenceNumber": 81,
    #       "lastSequenceNumber": 83,
    #       "firstEnqueueTime": "2022-05-13T18:38:53.436Z",
    #       "lastEnqueueTime": "2022-05-13T18:38:53.436Z"
    #   },
    #   "topic": "/subscriptions/d6b69936-f472-40b4-a433-ee83e31adaf8/resourcegroups/rgEventHub/providers/Microsoft.EventHub/namespaces/proofofconcepteventhubnamespace",
    #   "subject": "proofofconcepteventhub",
    #   "event_type": "Microsoft.EventHub.CaptureFileCreated"
    # }
