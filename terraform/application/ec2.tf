
module "ec2_complete" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "ec2-${var.project_name}-${var.env}-${var.account_prefix}"

  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "c5.large" # used to set core count below

  vpc_security_group_ids = [aws_security_group.single_node_server_access.id, aws_security_group.sg_cloudflare.id]
  subnet_id              = element(data.terraform_remote_state.network.outputs.public_subnets, 0)


  associate_public_ip_address = true

  enable_volume_tags = false

  ebs_block_device = [
    {
      device_name = "/dev/sdf"
      volume_type = "gp3"
      volume_size = 5
      throughput  = 200
      encrypted   = true
      kms_key_id  = aws_kms_key.this.arn
      tags = {
        MountPoint = "/mnt/data"
      }
    }
  ]

  tags = {
    Environment = var.env
    Project     = var.project_name
    Terraform   = true
  }
}


data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# Backups
locals {
  backups = {
    schedule  = "cron(0 5 ? * MON-FRI *)" /* UTC Time */
    retention = 7 // days
  }
}

resource "aws_backup_vault" "wordpress-backup-vault" {
  name = "wordpress-backup-vault-${var.project_name}-${var.env}-${var.account_prefix}"
  tags = {
    Project = var.project_name
    Role    = "backup-vault"
  }
}

resource "aws_backup_plan" "wordpress-backup-plan" {
  name = "backup-plan-${var.project_name}-${var.env}-${var.account_prefix}"

  rule {
    rule_name         = "weekdays-every-2-hours-${local.backups.retention}-day-retention"
    target_vault_name = aws_backup_vault.wordpress-backup-vault.name
    schedule          = local.backups.schedule
    start_window      = 60
    completion_window = 300

    lifecycle {
      delete_after = local.backups.retention
    }

    recovery_point_tags = {
      Project = var.project_name
      Role    = "backup"
      Creator = "aws-backups"
    }
  }

  tags = {
    Environment = var.env
    Project     = var.project_name
    Terraform   = true
  }
}

resource "aws_backup_selection" "wordpress-selection" {
  iam_role_arn = aws_iam_role.wordpress-aws-backup-service-role.arn
  name         = "server-ami-${var.project_name}-${var.env}-${var.account_prefix}"
  plan_id      = aws_backup_plan.wordpress-backup-plan.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Backup"
    value = "true"
  }
}


/* Assume Role Policy for Backups */
data "aws_iam_policy_document" "wordpress-aws-backup-service-assume-role-policy-doc" {
  statement {
    sid     = "AssumeServiceRole"
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

/* The policies that allow the backup service to take backups and restores */
data "aws_iam_policy" "aws-backup-service-policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

data "aws_iam_policy" "aws-restore-service-policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

data "aws_caller_identity" "current_account" {}

/* Needed to allow the backup service to restore from a snapshot to an EC2 instance
 See https://stackoverflow.com/questions/61802628/aws-backup-missing-permission-iampassrole */
data "aws_iam_policy_document" "wordpress-pass-role-policy-doc" {
  statement {
    sid       = "ExamplePassRole"
    actions   = ["iam:PassRole"]
    effect    = "Allow"
    resources = ["arn:aws:iam::${data.aws_caller_identity.current_account.account_id}:role/*"]
  }
}

/* Roles for taking AWS Backups */
resource "aws_iam_role" "wordpress-aws-backup-service-role" {
  name               = "ExampleAWSBackupServiceRole"
  description        = "Allows the AWS Backup Service to take scheduled backups"
  assume_role_policy = data.aws_iam_policy_document.wordpress-aws-backup-service-assume-role-policy-doc.json

  tags = {
    Project = var.project_name
    Role    = "iam"
  }
}

resource "aws_iam_role_policy" "wordpress-backup-service-aws-backup-role-policy" {
  policy = data.aws_iam_policy.aws-backup-service-policy.policy
  role   = aws_iam_role.wordpress-aws-backup-service-role.name
}

resource "aws_iam_role_policy" "wordpress-restore-service-aws-backup-role-policy" {
  policy = data.aws_iam_policy.aws-restore-service-policy.policy
  role   = aws_iam_role.wordpress-aws-backup-service-role.name
}

resource "aws_iam_role_policy" "wordpress-backup-service-pass-role-policy" {
  policy = data.aws_iam_policy_document.wordpress-pass-role-policy-doc.json
  role   = aws_iam_role.wordpress-aws-backup-service-role.name
}
