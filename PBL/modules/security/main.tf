# Security group for external alb, to allow acess from any where for HTTP and HTTPS traffic
resource "aws_security_group" "ext-alb-sg" {
  name        = var.security_groups_detail.name.ext-alb
  vpc_id      = var.vpc_id
  description = var.security_groups_detail.description.ext-alb

  # Use dynamic block to create ingress rules from the list
  dynamic "ingress" {
    for_each = local.ext_alb_ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  dynamic "egress" {
    for_each = local.egress_rule
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.security_groups_detail.name.ext-alb
    },
  )

}

# Security group for bastion, to allow access into the bastion host from your IP
resource "aws_security_group" "bastion_sg" {
  name        = var.security_groups_detail.name.bastion
  vpc_id      = var.vpc_id
  description = var.security_groups_detail.description.bastion

  dynamic "ingress" {
    for_each = local.bastion_ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  dynamic "egress" {
    for_each = local.egress_rule
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.security_groups_detail.name.bastion
    },
  )
}

#Security group for nginx reverse proxy, to allow access only from the external load balancer and bastion instance
resource "aws_security_group" "nginx-sg" {
  name        = var.security_groups_detail.name.nginx
  vpc_id      = var.vpc_id
  description = var.security_groups_detail.description.nginx

  dynamic "ingress" {
    for_each = local.nginx_ingress_rules
    content {
      description     = ingress.value.description
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      security_groups = ingress.value.security_groups
    }
  }

  dynamic "egress" {
    for_each = local.egress_rule
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.security_groups_detail.name.nginx
    },
  )

  depends_on = [
    aws_security_group.ext-alb-sg,
    aws_security_group.bastion_sg
  ]
}

# Security group for internal alb, to have access only from nginx reverser proxy server
resource "aws_security_group" "int-alb-sg" {
  name        = var.security_groups_detail.name.int-alb
  vpc_id      = var.vpc_id
  description = var.security_groups_detail.description.int-alb

  dynamic "ingress" {
    for_each = local.int_alb_ingress_rules
    content {
      description     = ingress.value.description
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      security_groups = ingress.value.security_groups
    }
  }
  dynamic "egress" {
    for_each = local.egress_rule
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.security_groups_detail.name.int-alb
    },
  )

  depends_on = [
    aws_security_group.nginx-sg
  ]
}

# Security group for webservers, to have access only from the internal load balancer and bastion instance
resource "aws_security_group" "webserver-sg" {
  name        = var.security_groups_detail.name.webservers
  vpc_id      = var.vpc_id
  description = var.security_groups_detail.description.webservers

  dynamic "ingress" {
    for_each = local.webservers_ingress_rules
    content {
      description     = ingress.value.description
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      security_groups = ingress.value.security_groups
    }
  }
  dynamic "egress" {
    for_each = local.egress_rule
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.security_groups_detail.name.webservers
    },
  )

  depends_on = [
    aws_security_group.int-alb-sg,
    aws_security_group.bastion_sg
  ]
}

# Security group for datalayer to alow traffic from websever on nfs and mysql port and bastion host on mysql port
resource "aws_security_group" "datalayer-sg" {
  name        = var.security_groups_detail.name.datalayer
  vpc_id      = var.vpc_id
  description = var.security_groups_detail.description.datalayer

  dynamic "ingress" {
    for_each = local.datalayer_ingress_rules
    content {
      description     = ingress.value.description
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      security_groups = ingress.value.security_groups
    }
  }

  dynamic "egress" {
    for_each = local.egress_rule
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.security_groups_detail.name.datalayer
    },
  )

  depends_on = [
    aws_security_group.webserver-sg,
    aws_security_group.nginx-sg,
    aws_security_group.bastion_sg
  ]
}