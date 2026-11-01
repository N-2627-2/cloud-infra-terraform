data "aws_region" "current" {}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [aws_route_table.private.id]

  tags = {
    Name = "securechain-s3-endpoint-${var.environment}"
  }
}
