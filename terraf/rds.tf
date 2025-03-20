# RDS Parameter Group
resource "aws_db_parameter_group" "db_params" {
  name   = "my-db-params"
  family = "mysql8.0"
}

# RDS Instance
resource "aws_db_instance" "rds" {
  identifier             = "csye6225"
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = "root"
  password               = var.db_password
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.db_sg.id]            # The Database security group is attached to this RDS instance.
  db_subnet_group_name   = aws_db_subnet_group.private_subnets.name # Use Private subnet for RDS instances
  parameter_group_name   = aws_db_parameter_group.db_params.name
  db_name                = "cloud_computing"
  skip_final_snapshot    = true
}