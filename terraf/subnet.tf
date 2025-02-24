# data source
data "aws_availability_zones" "available" {
  state = "available"
}

# Create subnets in the available availability zones in sequence
resource "aws_subnet" "first_private" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "first private"
  }


}

resource "aws_subnet" "second_private" {
  vpc_id            = aws_vpc.my_vpc.ibad
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "second private"
  }


}

resource "aws_subnet" "third_private" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "third private"
  }


}

resource "aws_subnet" "first_public" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "first public"
  }


}

resource "aws_subnet" "second_public" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "second public"
  }


}

resource "aws_subnet" "third_public" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.6.0/24"
  availability_zone       = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = true
  tags = {
    Name = "third public"
  }


}
