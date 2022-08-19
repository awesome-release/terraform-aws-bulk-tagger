#####
# Stolen from https://github.com/rom1spi/aws-bulk-tagger/blob/master/handler.py
#####

import json
import boto3
import sys
import time
from responseManager import manageReponse

client = boto3.client("resourcegroupstaggingapi")

_TAG_FILTERS = "TagFilters"
_MATCH_ALL_FILTERS = "MustMatchAllTagFilters"
_TAGS_TO_APPLY = "TagsToApply"
_TAGS_TO_FILTER = "TagKeyExclusion"
_RESOURCE_TYPE_FILTERS = "ResourceTypeFilters"
_RESOURCE_TAG_MAPPING_LIST = "ResourceTagMappingList"
_FAILED_RESOURCES_MAP = "FailedResourcesMap"
_STATUS_CODE = "StatusCode"

def divide_chunks(l, n):
    for i in range(0, len(l), n):
        yield l[i:i + n]

def bulk_tagger(event, context):
    # check request's arguments
    if (
        _TAG_FILTERS not in event
        or _RESOURCE_TYPE_FILTERS not in event
        or _TAGS_TO_APPLY not in event
    ):
        return manageReponse(
            400,
            "Missing arguments in your request. View README file to rectify your request payload.",
        )

    arns_list = []

    # filter Tag keys as OR instead of AND
    if _MATCH_ALL_FILTERS in event and event[_MATCH_ALL_FILTERS].lower() == "false":
        event.pop(_MATCH_ALL_FILTERS, None)
        try:
            for tag_filter in event[_TAG_FILTERS]:
                resources = (client.get_resources(
                    ResourceTypeFilters=event[_RESOURCE_TYPE_FILTERS],
                    TagFilters=[tag_filter],
                ))

                for resource in resources[_RESOURCE_TAG_MAPPING_LIST]:
                    arns_list.append(resource["ResourceARN"])

            if len(arns_list) == 0:
                return manageReponse(204, "No resource to tag")

        except KeyError as err:
            return manageReponse(204, "KeyError: {0}".format(err))
        except:
            return manageReponse(500, "Unexpected error: {0}".format(sys.exc_info()[0]))
    else:
        # get all resources with ALL specified tags
        tag_exclusion = ""
        resources = []
        if _TAGS_TO_FILTER in event:
            tag_exclusion = event[_TAGS_TO_FILTER]

        operation_parameters = {'ResourceTypeFilters': event[_RESOURCE_TYPE_FILTERS],
            			'TagFilters': event[_TAG_FILTERS]}
        try:
            paginator = client.get_paginator('get_resources')
            page_iterator = paginator.paginate(**operation_parameters)
            
        except KeyError as err:
            return manageReponse(204, "KeyError: {0}".format(err))
        except:
            return manageReponse(500, "Unexpected error: {0}".format(sys.exc_info()[0]))

        for page in page_iterator:
            resources.extend(page['ResourceTagMappingList'])

        if len(resources) == 0:
            return manageReponse(204, "No resource to tag")

        #print(json.dumps(resources))

        for resource in resources:
            if tag_exclusion != "":
                if tag_exclusion not in [t['Key'] for t in resource["Tags"]]:
                    arns_list.append(resource["ResourceARN"])
                else:
                    print("Excluding, key " + tag_exclusion + " exists in: " + resource["ResourceARN"])
            else:
                arns_list.append(resource["ResourceARN"])

    FailedResourcesMap = []
    chunked_arns_list=list(divide_chunks(arns_list, 20))
    for arns in chunked_arns_list:
        # Tag resources with the new tags
        tagging_result = client.tag_resources(
            ResourceARNList=arns, Tags=event[_TAGS_TO_APPLY]
        )

        for key, value in tagging_result[_FAILED_RESOURCES_MAP].items():
            if value[_STATUS_CODE] > 400:
                FailedResourcesMap.append(tagging_result[_FAILED_RESOURCES_MAP])

        time.sleep(5)

    count_FailedResourcesMap = len(FailedResourcesMap)

    if count_FailedResourcesMap > 0:
        return manageReponse(500, "Failed Resources: " + json.dumps(FailedResourcesMap))

    #return manageReponse(200, len(arns_list) + " Tagged Resources", False)
    return manageReponse(200, "Tagged Resources: " + json.dumps(arns_list), False)
