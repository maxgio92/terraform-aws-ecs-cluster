variable "instance_type" {
  description = "The size of instance to launch"
  default     = "t3.micro"
}

variable "subnets" {
  description = "A list of subnet IDs to launch the cluster in"
  type        = "list"
}

variable "health_check_type" {
  description = "'EC2' or 'ELB'. Controls how checking is done"
  default     = "EC2"
}

variable "min_size" {
  description = "The minimum capacity of the autoscaling group"
}

variable "max_size" {
  description = "The maximum capacity of the autoscaling group"
}

variable "desired_size" {
  description = "The desired capacity of the autoscaling group"
}

variable "protect_from_scale_in" {
  description = "Enable the instance protection setting for the autoscaling group"
  default     = false
}

# Issue with count to compute: https://github.com/hashicorp/terraform/issues/10857
#variable "assign_elastic_ip" {
#  description = "If true assign an elastic IP for each instance in the autoscaling group"
#  default     = false
#}

variable "elastic_ip_count" {
  description = "The number of elastic IP to associate to the instances in the autoscaling group"
  default     = false
}

variable "instance_key_name" {
  default     = ""
  description = "The key name that should be used for the cluster's instances"
}

# SG Rules

# structure:
#[
#  {
#    port:   "port number"
#    protocol: "protocol"
#    source: "CIDR block"
#  }
#]
variable "security_group_public_rules" {
  default = []
}

# Workaround to:
# https://github.com/hashicorp/terraform/issues/17421
variable "security_group_public_rules_count" {
  default = 0
}

# structure:
#[
#  {
#    port:   "port number"
#    protocol: "protocol"
#    source: "source security group id"
#  }
#]
variable "security_group_private_rules" {
  default = []
}

# Workaround to:
# https://github.com/hashicorp/terraform/issues/17421
variable "security_group_private_rules_count" {
  default = 0
}

variable "efs_mount" {
  default = false

  description = <<EOF
  Enable to mount an EFS filesystem on the cluster's instances.
  If true, please specify the efs_dns_name field.
  EOF
}

variable "efs_dns_name" {
  default     = ""
  description = "The DNS name of the EFS filesystem to mount on the cluster's instances."
}

variable "prefix_name" {
  description = "The prefix for the name of the resources"
  default     = "my"
}

variable "default_tag" {
  type        = "map"
  description = "The default tag to apply to the resoures"

  default = {
    Terraform = "true"
  }
}
