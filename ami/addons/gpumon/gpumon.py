# Copyright 2017 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License is located at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#  or in the "license" file accompanying this file. This file is distributed
#  on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
#  express or implied. See the License for the specific language governing
#  permissions and limitations under the License.


import urllib2
import boto3
from pynvml import *
from datetime import datetime
from time import sleep

### CHOOSE REGION ####
EC2_REGION = 'us-east-1'

###CHOOSE NAMESPACE PARMETERS HERE###
my_NameSpace = 'GPU'

### CHOOSE PUSH INTERVAL ####
sleep_interval = 10

### CHOOSE STORAGE RESOLUTION (BETWEEN 1-60) ####
store_reso = 60

#Instance information
BASE_URL = 'http://169.254.169.254/latest/meta-data/'
INSTANCE_ID = urllib2.urlopen(BASE_URL + 'instance-id').read()
IMAGE_ID = urllib2.urlopen(BASE_URL + 'ami-id').read()
INSTANCE_TYPE = urllib2.urlopen(BASE_URL + 'instance-type').read()
INSTANCE_AZ = urllib2.urlopen(BASE_URL + 'placement/availability-zone').read()
EC2_REGION = INSTANCE_AZ[:-1]

TIMESTAMP = datetime.now().strftime('%Y-%m-%dT%H')
TMP_FILE = '/tmp/GPU_TEMP'
TMP_FILE_SAVED = TMP_FILE + TIMESTAMP

# Create CloudWatch client
cloudwatch = boto3.client('cloudwatch', region_name=EC2_REGION)


# Flag to push to CloudWatch
PUSH_TO_CW = True

def getPowerDraw(handle):
    powDraw = nvmlDeviceGetPowerUsage(handle) / 1000.0
    return float('%.2f' % powDraw)

def getTemp(handle):
    return nvmlDeviceGetTemperature(handle, NVML_TEMPERATURE_GPU)

def getUtilization(handle):
    return nvmlDeviceGetUtilizationRates(handle).gpu

def getMemUtilization(handle):
    mem_info = nvmlDeviceGetMemoryInfo(handle)
    return mem_info.used, mem_info.free

def logResults(i, util, mem_info_used, mem_info_free, pow_draw, temp):
    print(str(i) + ',' + str(util) + ',' + str(mem_info_used) + str(mem_info_free) + ',' + str(pow_draw) + ',' + str(temp) + '\n')

    MY_DIMENSIONS=[
        {
            'Name': 'InstanceId',
            'Value': INSTANCE_ID
        },
        {
            'Name': 'ImageId',
            'Value': IMAGE_ID
        },
        {
            'Name': 'InstanceType',
            'Value': INSTANCE_TYPE
        },
        {
            'Name': 'GPUNumber',
            'Value': str(i)
        }
    ]
    cloudwatch.put_metric_data(
        MetricData=[
            {
                'MetricName': 'GPU Usage',
                'Dimensions': MY_DIMENSIONS,
                'Unit': 'Percent',
                'StorageResolution': store_reso,
                'Value': util
            },
            {
                'MetricName': 'Memory Usage',
                'Dimensions': MY_DIMENSIONS,
                'Unit': 'Bytes',
                'StorageResolution': store_reso,
                'Value': mem_info_used
            },
            {
                'MetricName': 'Memory Free',
                'Dimensions': MY_DIMENSIONS,
                'Unit': 'Bytes',
                'StorageResolution': store_reso,
                'Value': mem_info_free
            },
            {
                'MetricName': 'Power Usage (Watts)',
                'Dimensions': MY_DIMENSIONS,
                'Unit': 'None',
                'StorageResolution': store_reso,
                'Value': pow_draw
            },
            {
                'MetricName': 'Temperature (C)',
                'Dimensions': MY_DIMENSIONS,
                'Unit': 'None',
                'StorageResolution': store_reso,
                'Value': temp
            },
        ],
        Namespace=my_NameSpace
    )


nvmlInit()
deviceCount = nvmlDeviceGetCount()

def main():
    try:
        while True:
            # Find the metrics for each GPU on instance
            for i in range(deviceCount):
                handle = nvmlDeviceGetHandleByIndex(i)

                try:
                    pow_draw = getPowerDraw(handle)
                    temp = getTemp(handle)
                    util = getUtilization(handle)
                    mem_info_used, mem_info_free = getMemUtilization(handle)

                    logResults(i, util, mem_info_used, mem_info_free, pow_draw, temp)
                except NVMLError as err:
                    print(err)

            sleep(sleep_interval)

    finally:
        nvmlShutdown()

if __name__=='__main__':
    main()
