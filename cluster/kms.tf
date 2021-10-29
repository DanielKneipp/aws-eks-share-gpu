resource "aws_kms_key" "gpu_volume" {
  description              = "gpu-volume-key"
  deletion_window_in_days  = 7
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  policy                   = data.aws_iam_policy_document.gpu_volume_key.json
}

resource "aws_kms_alias" "gpu_volume" {
  name          = "alias/gpu-volume"
  target_key_id = aws_kms_key.gpu_volume.key_id
}

data "aws_caller_identity" "current" {}

# from https://docs.aws.amazon.com/autoscaling/ec2/userguide/key-policy-requirements-EBS-encryption.html
data "aws_iam_policy_document" "gpu_volume_key" {
  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["kms:*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid       = "Allow service-linked role use of the customer managed key"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"]
    }
  }

  statement {
    sid       = "Allow attachment of persistent resources"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "kms:CreateGrant",
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"]
    }

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}

resource "aws_kms_key" "cluster_secrets" {
  description              = "cluster-secrets-key"
  deletion_window_in_days  = 7
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
}

resource "aws_kms_alias" "cluster_secrets" {
  name          = "alias/cluster-secrets"
  target_key_id = aws_kms_key.cluster_secrets.key_id
}
