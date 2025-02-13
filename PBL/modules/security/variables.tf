variable "vpc_id" {
  type        = string
  description = "the vpc id"
}

variable "tags" {
  description = "A mapping of tags to assign to all resources."
  type        = map(string)
  default     = {}
}

variable "security_groups_detail" {
  description = "Name and Description of the Security Groups"
  type        = map(map(string))
  default = {
    name = {
      ext-alb    = "ext-alb-sg",
      bastion    = "bastion_sg",
      nginx      = "nginx-sg",
      int-alb    = "int-alb-sg",
      webservers = "webserver-sg",
      datalayer  = "datalayer-sg"
    }
    description = {
      ext-alb    = "Allow TLS inbound traffic",
      bastion    = "Allow incoming SSH connections.",
      nginx      = "Allow HTTPS inbound traffic from ex-ALB and SSH traffic from bastion",
      int-alb    = "Allow TLS inbound traffic from nginx",
      webservers = "Allow TLS inbound traffic from int-ALB and SSH traffic from bastion",
      datalayer  = "Allow mysql inbound traffic from webservers",
    }
  }
}