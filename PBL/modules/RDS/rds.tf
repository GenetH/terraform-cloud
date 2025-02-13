# This section will create the subnet group for the RDS instance using the private subnet
resource "aws_db_subnet_group" "g-rds" {
  name       = "g-rds"
  subnet_ids = var.private_subnets

  tags = merge(
    var.tags,
    {
      Name = "g-rds"
    },
  )
}

# create the RDS instance with the subnets group
resource "aws_db_instance" "g-rds" {
  allocated_storage      = 50
  storage_type           = "gp3"
  engine                 = "mysql"
  engine_version         = "8.0.35"
  instance_class         = "db.t3.micro"
  db_name                = "gdb"
  username               = var.db-username
  password               = var.db-password
  db_subnet_group_name   = aws_db_subnet_group.g-rds.name
  vpc_security_group_ids = var.db-sg
  skip_final_snapshot    = true
  multi_az               = "true"
}