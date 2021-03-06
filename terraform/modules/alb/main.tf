# Default ALB implementation that can be used connect ECS instances to it

resource "aws_alb_target_group" "default" {
  name                 = "tg-${var.app_name}-df-${var.environment}"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = "${var.vpc_id}"
  deregistration_delay = "${var.deregistration_delay}"

  health_check {
    path     = "${var.health_check_path}"
    protocol = "HTTP"
  }
}

resource "aws_alb" "alb" {
  name            = "elb-${var.app_name}-${var.environment}"
  subnets         = ["${var.public_subnet_ids}"]
  security_groups = ["${var.security_group_id}"]

  access_logs {
    bucket = "${var.bucket_log}"
    prefix = "alb-${var.environment}"
  }

}

resource "aws_alb_listener" "https" {
  load_balancer_arn = "${aws_alb.alb.id}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${var.certificate_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.default.id}"
    type             = "forward"
  }
}

data "aws_route53_zone" "selected" {
  name         = "${var.route53_name}"
  private_zone = false
}

resource "aws_route53_record" "record" {
    zone_id = "${data.aws_route53_zone.selected.zone_id}"
    name    = "${var.environment}.${data.aws_route53_zone.selected.name}"
    type    = "CNAME"
    ttl     = "300"
    records = ["${aws_alb.alb.dns_name}"]
}