# -----------------------------------------------------------------------
# Cluster
# -----------------------------------------------------------------------

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.prefix_name}-cluster"
}

# -----------------------------------------------------------------------
# Autoscaling Group
# -----------------------------------------------------------------------

module "instance-profile" {
  source = "./instance-profile"
  name   = "${var.prefix_name}-profile"
}

#For now we only use the AWS ECS optimized ami 
# <https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html>
data "aws_ami" "amazon_linux_ecs" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/templates/user-data.sh")}"

  vars {
    cluster_name = "${aws_ecs_cluster.ecs_cluster.name}"
  }
}

data "template_file" "user_data_efs" {
  template = "${file("${path.module}/templates/user-data-efs.sh")}"

  vars {
    cluster_name = "${aws_ecs_cluster.ecs_cluster.name}"
    efs_dns_name = "${var.efs_dns_name}"
  }
}

module "ecs_autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "2.9.1"

  name = "${var.prefix_name}"

  # launch configuration
  lc_name              = "${var.prefix_name}"
  image_id             = "${data.aws_ami.amazon_linux_ecs.id}"
  instance_type        = "${var.instance_type}"
  security_groups      = ["${aws_security_group.ecs_hosts.id}"]
  iam_instance_profile = "${module.instance-profile.this_iam_instance_profile_id}"
  user_data            = "${var.efs_mount ? data.template_file.user_data_efs.rendered : data.template_file.user_data.rendered}"
  key_name             = "${var.instance_key_name}"

  # autoscaling group
  asg_name              = "${var.prefix_name}-group"
  vpc_zone_identifier   = "${var.subnets}"
  health_check_type     = "${var.health_check_type}"
  min_size              = "${var.min_size}"
  max_size              = "${var.max_size}"
  desired_capacity      = "${var.desired_size}"
  protect_from_scale_in = "${var.protect_from_scale_in}"

  tags = [
    {
      key                 = "${element(keys(var.default_tag), 0)}"
      value               = "${element(values(var.default_tag), 0)}"
      propagate_at_launch = true
    },
  ]
}

# -----------------------------------------------------------------------
# Elastic IP
# -----------------------------------------------------------------------

data "aws_instances" "asg" {
  filter = {
    name   = "tag:aws:autoscaling:groupName"
    values = ["${module.ecs_autoscaling.this_autoscaling_group_name}"]
  }
}

resource "aws_eip" "asg" {
  # Issue with count to compute: https://github.com/hashicorp/terraform/issues/10857
  #count    = "${var.assign_elastic_ip ? length(data.aws_instances.asg.ids) : 0}"
  count = "${var.elastic_ip_count}"

  instance = "${element(data.aws_instances.asg.ids, count.index)}"
}

# -----------------------------------------------------------------------
# Security groups
# -----------------------------------------------------------------------

data "aws_subnet" "selected" {
  id = "${var.subnets[1]}"
}

resource "aws_security_group" "ecs_hosts" {
  name        = "${var.prefix_name}-ecs-hosts"
  description = "ECS cluster hosts"

  vpc_id = "${data.aws_subnet.selected.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(var.default_tag, map(
    "Name", "${var.prefix_name}-ecs-hosts"
  ))}"
}

resource "aws_security_group_rule" "public" {
  count = "${var.security_group_public_rules_count}"

  type      = "ingress"
  from_port = "${lookup(var.security_group_public_rules[count.index], "port")}"
  to_port   = "${lookup(var.security_group_public_rules[count.index], "port")}"
  protocol  = "${lookup(var.security_group_public_rules[count.index], "protocol")}"

  cidr_blocks = ["${lookup(var.security_group_public_rules[count.index], "source")}"]

  security_group_id = "${aws_security_group.ecs_hosts.id}"
}

resource "aws_security_group_rule" "private" {
  count = "${var.security_group_private_rules_count}"

  type      = "ingress"
  from_port = "${lookup(var.security_group_private_rules[count.index], "port")}"
  to_port   = "${lookup(var.security_group_private_rules[count.index], "port")}"
  protocol  = "${lookup(var.security_group_private_rules[count.index], "protocol")}"

  source_security_group_id = "${lookup(var.security_group_private_rules[count.index], "source")}"

  security_group_id = "${aws_security_group.ecs_hosts.id}"
}

resource "aws_security_group_rule" "ssh_from_self" {
  type                     = "ingress"
  from_port                = "22"
  to_port                  = "22"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.ecs_hosts.id}"
  security_group_id        = "${aws_security_group.ecs_hosts.id}"
}
