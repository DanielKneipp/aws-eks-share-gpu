packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  version = "0-1"
}

source "amazon-ebs" "gpu" {
  ami_name      = "packer-gpu-ami-${local.version}"
  instance_type = "g4dn.xlarge"
  region        = "us-east-1"
  source_ami    = "ami-0d70d9df5122400da" # release 1.21.4-20211013 of type  AL2_x86_64_GPU
  ssh_username  = "ec2-user"

  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    delete_on_termination = true
    volume_size           = 20
    volume_type           = "gp2"
    encrypted             = true
  }

  tags = {
    Name = "packer-gpu-ami-${local.version}"
  }

  snapshot_tags = {
    Name = "packer-gpu-snap-${local.version}"
  }

  run_tags = {
    Name = "packer-gpu-builder-${local.version}"
  }

  run_volume_tags = {
    Name = "packer-gpu-volume-${local.version}"
  }
}

build {
  sources = [
    "source.amazon-ebs.gpu"
  ]

  provisioner "file" {
    source      = "./addons/gpumon"
    destination = "/home/ec2-user/gpumon"
  }

  provisioner "shell" {
    inline = [
      "cd /home/ec2-user/gpumon",
      "sudo bash ./install-cloudwatch-gpumon.sh"
    ]
  }

  provisioner "shell" {
    script = "./scripts/install-cloudwatch-agent.sh"
  }
}
