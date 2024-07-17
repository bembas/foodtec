module "alb_wordpress" {
  source = "terraform-aws-modules/alb/aws"

  name                       = "alb-${var.project_name}-${var.env}-${var.account_prefix}"
  load_balancer_type         = "application"
  enable_deletion_protection = true
  idle_timeout               = 60
  vpc_id                     = data.terraform_remote_state.network.outputs.vpc_id

  subnets = data.terraform_remote_state.network.outputs.public_subnets

  security_groups = [aws_security_group.sg_alb.id]

  access_logs = {
    bucket  = module.s3_bucket_load_balancer_logs.s3_bucket_id
    prefix  = "alb-${var.project_name}-${var.env}-${var.account_prefix}"
    enabled = true
  }

  target_groups = [
    # target_group_index = 0
    {
      name                 = "tg-${var.project_name}-${var.env}-${var.account_prefix}"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/health"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200"
      }
    }
  ]

  https_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
      # action_type        = "forward"
    }
  ]

  tags = {
    Environment = var.env
    Project     = var.project_name
    Terraform   = true
  }
}

resource "aws_security_group" "sg_alb" {
  name        = "${var.account_prefix}-alb-${var.env}"
  description = "Load Balancer Traffic coming from world"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
    from_port = "443"
    to_port   = "443"
  }

  ingress {
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
    from_port = "80"
    to_port   = "80"
  }


  egress {
    protocol    = "-1"
    cidr_blocks = data.terraform_remote_state.network.outputs.private_subnets_cidr_blocks
    from_port   = "0"
    to_port     = "0"
  }

  tags = {
    Name        = "${var.account_prefix}-alb-${var.env}"
    Environment = var.env
    Project     = var.project_name
    Terraform   = true
  }
}

# LOAD BALANCER LOGS BUCKET
module "s3_bucket_load_balancer_logs" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket                  = "${var.account_prefix}-load-balancer-logs-${var.env}"
  acl                     = "private"
  restrict_public_buckets = true
  block_public_policy     = true
  block_public_acls       = true
  ignore_public_acls      = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
  versioning = {
    enabled = false
  }

  attach_policy = true
  policy        = data.aws_iam_policy_document.s3_bucket_load_balancer_logs_policy_document.json

  lifecycle_rule = [
    {
      id     = "delete-backups-older-than-30-days"
      status = "Enabled"
      prefix = "backups/"
      tags = {
        "rule" = "delete-old-backups"
      }
      expiration = {
        days = 30
      }
    }
  ]
}

data "aws_elb_service_account" "default" {}


# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-logging-bucket-permissions
data "aws_iam_policy_document" "s3_bucket_load_balancer_logs_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.default.arn]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${module.s3_bucket_load_balancer_logs.s3_bucket_arn}/*",
    ]
  }

  statement {
    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:*",
    ]

    resources = [
      "${module.s3_bucket_load_balancer_logs.s3_bucket_arn}/*",
    ]

    condition {
      test     = "StringNotEquals"
      variable = "aws:SecureTransport"
      values   = [true]
    }
  }
}
