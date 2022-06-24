####
# Stolen from https://github.com/rom1spi/aws-bulk-tagger/blob/master/notifier.py
####

import boto3
import os

_NOTIFIER_TOPIC_ARN = os.environ.get("NOTIFIER_TOPIC_ARN", None)

# Create an SNS client
sns = boto3.client("sns")


def notify(statusCode, message):
    # Publish a simple message to the specified SNS topic
    response = sns.publish(
        TopicArn=_NOTIFIER_TOPIC_ARN,
        Message="Status Code: " + str(statusCode) + " | Message: " + message,
    )

    # Print out the response
    print(response)
