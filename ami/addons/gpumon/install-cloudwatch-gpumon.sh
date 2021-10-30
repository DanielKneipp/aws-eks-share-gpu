#!/usr/bin/env bash

# Stop on any error
set -e

yum install -y pip
pip install -r requirements.txt

mv gpumon.py /etc/gpumon.py
mv gpumon.service /etc/systemd/system/gpumon.service

systemctl enable --now gpumon
