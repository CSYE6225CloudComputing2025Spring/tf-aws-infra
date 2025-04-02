data "aws_route53_zone" "subdomain" {
  name         = "${var.subdomain}.${var.domain}."  
  private_zone = false
}

resource "aws_route53_record" "webapp_dns" {
  zone_id = data.aws_route53_zone.subdomain.zone_id
  name    = "${var.subdomain}.${var.domain}"                    
  type    = "A"

  alias {
    name                   = aws_lb.webapp_alb.dns_name
    zone_id                = aws_lb.webapp_alb.zone_id
    evaluate_target_health = true
  }
}