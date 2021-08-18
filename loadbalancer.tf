
//Creates the load balancer associated with the public subnet. Its an ALB L7 load balancer. 
//Its linked to its own security group allowing only the ports specified. In this case (HTTP/80)
//Specifing internal=false we define that it will get a public IP
resource "aws_lb" "service" {
  name               = "alb"
  load_balancer_type = "application"
  subnets            = var.public_subnets
  security_groups    = [aws_security_group.alb.id]
  internal           = false    
  tags = {    
    Name   = "${var.app_name} Application load balancer"
  }
}

//Creates a listener that will get a public ip where the load balancer will listen traffic.
resource "aws_lb_listener" "https_forward" {
  load_balancer_arn = aws_lb.service.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service.arn
  }
}

resource "aws_lb_target_group" "service" {
  name        = "${var.app_name}-alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default_vpc.id
  target_type = "ip"
  
  #Added to delay the de deregistration (draining time) of the tasks so its easyer to test CI/CD. This value has to be talk with the backend developer to define how long shoud they stay up before killingit.
  deregistration_delay = 30

  health_check {
    healthy_threshold   = "3"
    interval            = "90"
    protocol            = "HTTP"
    matcher             = "200-299"
    timeout             = "20"
    path                = "/"
    unhealthy_threshold = "2"
  }
}