resource "aws_vpc" "vpc" {
    cidr_block           = "${var.cidr}"
    enable_dns_hostnames = true

    tags {
        Name        = "${var.app_name}-${var.enviroment}"
    }
}

resource "aws_internet_gateway" "vpc" {
    vpc_id = "${aws_vpc.vpc.id}"

    tags {
          Name = "${var.app_name}-${var.enviroment}"
    }
}