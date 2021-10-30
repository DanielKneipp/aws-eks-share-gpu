#!/usr/bin/env bash

# Stop on any error
set -e

sudo yum install -y amazon-cloudwatch-agent

echo '
{
    "agent": {
        "metrics_collection_interval": 60,
        "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
    },
    "metrics": {
        "metrics_collected": {
            "disk": {
                "measurement": [
                    "used_percent",
                    "inodes_free"
                ],
                "resources": [
                    "*"
                ],
                "ignore_file_system_types": [
                    "sysfs",
                    "tmpfs",
                    "devtmpfs",
                    "overlay",
                    "shm"
                ]
            },
            "diskio": {
                "measurement": [
                    "read_bytes",
                    "write_bytes"
                ]
            },
            "swap": {
                "measurement": [
                    "used_percent"
                ]
            },
            "mem": {
                "measurement": [
                    "used_percent"
                ]
            }
        },
        "append_dimensions": {
            "ImageId": "${aws:ImageId}",
            "InstanceId": "${aws:InstanceId}",
            "InstanceType": "${aws:InstanceType}",
            "AutoScalingGroupName": "${aws:AutoScalingGroupName}"
        },
        "aggregation_dimensions": [
            [
                "AutoScalingGroupName"
            ],
            [
                "InstanceId",
                "InstanceType"
            ]
        ]
    }
}
' | sudo tee /etc/amazon-cloudwatch-agent.json > /dev/null

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config -m ec2 -s \
    -c file:/etc/amazon-cloudwatch-agent.json
