#####
# Stolen from https://github.com/rom1spi/aws-bulk-tagger/blob/master/responseManager.py
#####

import notifier
import os

_STATUS_CODE = "statusCode"
_BODY = "body"
_DEFAULT_NOTIFIER = os.environ.get("SNS_NOTIFY", "FALSE").upper() == "TRUE"


def manageReponse(statusCode, message, notify=_DEFAULT_NOTIFIER):
    response = {"statusCode": statusCode, "body": message}
    print(response)
    if notify:
        notifier.notify(statusCode, message)
    return response
