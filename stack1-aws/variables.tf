resource "aws_route_table_association" "linux_rta" {
    subnet_id = aws_subnet.linux_subnet.id
    route_table_id = aws_route_table.linux_rt.id
}
