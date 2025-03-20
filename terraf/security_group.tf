resource "aws_security_group" "application_security_group" {
  name        = "application_security_group"
  description = "application_security_group"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Web App"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-security-group"
  }
}

# Create DB Security Group
resource "aws_security_group" "db_sg" {
  name_prefix = "database-security-group"
  vpc_id      = aws_vpc.my_vpc.id
}

# Add ingress rule to allow TCP traffic on the port 3306 for MySQL/MariaDB
resource "aws_security_group_rule" "db_ingress" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_sg.id
  source_security_group_id = aws_security_group.application_security_group.id # The source of the traffic should be the application security group.
}