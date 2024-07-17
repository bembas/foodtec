
module "wordpress_rds" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "rds-${var.project_name}-${var.env}-${var.account_prefix}"

  engine                = "mysql"
  engine_version        = "5.7"
  instance_class        = "db.t3a.large"
  allocated_storage     = 50
  max_allocated_storage = 100
  multi_az              = true

  db_name  = "wordpress-assesment"
  username = var.database_username
  password = var.database_password
  port     = "3306"

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [aws_security_group.sg_rds.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"


  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval    = "30"
  monitoring_role_name   = "MyRDSMonitoringRole-${var.project_name}-${var.env}-${var.account_prefix}"
  create_monitoring_role = true

  tags = {
    Environment = var.env
    Project     = var.project_name
    Terraform   = true
  }

  # DB subnet group
  subnet_ids = data.terraform_remote_state.network.outputs.database_subnets

  # DB parameter group
  family = "mysql5.7"

  # DB option group
  major_engine_version = "5.7"

  # Database Deletion Protection
  deletion_protection = true
  skip_final_snapshot = false

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}


resource "aws_security_group" "sg_rds" {
  name        = "${var.account_prefix}-rds-${var.env}"
  description = "RDS traffic on Databse subnets"
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
    Name        = "${var.account_prefix}-rds-${var.env}"
    Environment = var.env
    Project     = var.project_name
    Terraform   = true
  }
}
