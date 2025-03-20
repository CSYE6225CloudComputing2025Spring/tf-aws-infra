# Create RDS subnet group, Use Private subnet for RDS instances
resource "aws_db_subnet_group" "private_subnets" {
  name = "private-database-subnet-group"
  subnet_ids = [
    aws_subnet.first_private.id,
    aws_subnet.second_private.id,
    aws_subnet.third_private.id
  ]

  tags = {
    Name = "Private Subnet Group For RDS"
  }
}