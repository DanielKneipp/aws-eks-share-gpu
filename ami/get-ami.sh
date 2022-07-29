#!/usr/bin/env bash

function cuda_only() {
    # Docs: https://docs.aws.amazon.com/dlami/latest/devguide/find-dlami-id.html
    # How to get the name:https://docs.aws.amazon.com/dlami/latest/devguide/appendix-ami-release-notes.html

    local name='Deep Learning AMI GPU CUDA 11.5.2 (Amazon Linux 2) ????????'

    aws ec2 describe-images --region us-east-1 --owners amazon \
        --filters "Name=name,Values=${name}" 'Name=state,Values=available' \
        --query 'reverse(sort_by(Images, &CreationDate))[].[ImageId, Name]' --output=text
}


function cuda_eks() {
    local cluster_version='1.21'

    aws ssm get-parameter \
        --name /aws/service/eks/optimized-ami/${cluster_version}/amazon-linux-2-gpu/recommended/image_id \
        --region us-east-1 --query "Parameter.Value" --output text
}

cuda_eks
