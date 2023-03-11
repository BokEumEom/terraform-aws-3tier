resource "aws_db_subnet_group" "database_subnet_group" {
  subnet_ids = [aws_subnet.rds_private_subnet_1.id, aws_subnet.rds_private_subnet_2.id]
}

resource "random_password" "database_password" {
  length  = 16
  special = false
}

module "aurora" {
  source = "terraform-aws-modules/rds-aurora/aws"

  name           = "rds-cluster"
  engine         = "aurora-mysql"
  engine_version = "8.0.mysql_aurora.3.02.0"
  instances = {
    1 = {
      instance_class      = "db.r6g.2xlarge"
      identifier          = "rds-instance"
      publicly_accessible = false
    }

    2 = {
      instance_class      = "db.r6g.2xlarge"
      identifier          = "rds-reader-instance"
      publicly_accessible = false
    }
  }

  vpc_id                 = aws_vpc.vpc.id
  db_subnet_group_name   = aws_db_subnet_group.database_subnet_group.name
  create_db_subnet_group = false
  create_security_group  = false

  iam_database_authentication_enabled = false
  master_username                     = "admin"
  master_password                     = random_password.database_password.result
  create_random_password              = false
  database_name                       = "admin"

  apply_immediately   = true
  skip_final_snapshot = true
  deletion_protection = true
  monitoring_interval = "60"
  ca_cert_identifier  = "rds-ca-2019"
  port                = "3306"

  db_parameter_group_name         = "default"
  db_cluster_parameter_group_name = "default"
  enabled_cloudwatch_logs_exports = ["error", "slowquery", "general", "audit"]

  vpc_security_group_ids = [aws_security_group.database_sg.id]
}

output "database_endpoint" {
  value = module.aurora.cluster_endpoint
}
