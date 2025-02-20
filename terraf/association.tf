resource "aws_route_table_association" "first_public_association" {
  subnet_id      = aws_subnet.first_public.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "second_public_association" {
  subnet_id      = aws_subnet.second_public.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "third_public_association" {
  subnet_id      = aws_subnet.third_public.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "first_private_association" {
  subnet_id      = aws_subnet.first_private.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "second_private_association" {
  subnet_id      = aws_subnet.second_private.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "third_private_association" {
  subnet_id      = aws_subnet.third_private.id
  route_table_id = aws_route_table.private_route_table.id
}



