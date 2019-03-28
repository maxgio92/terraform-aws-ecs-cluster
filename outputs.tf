output "id" {
  value       = "${aws_ecs_cluster.ecs_cluster.id}"
  description = "The ID of the cluster"
}

output "name" {
  value       = "${aws_ecs_cluster.ecs_cluster.name}"
  description = "The name of the cluster"
}

output "eips" {
  value       = "${aws_eip.asg.*.public_ip}"
  description = "The elastic IP generated and attached to the instances of the cluster, if specified in 'elastic_ip_count'"
}

output "private_ips" {
  value       = "${data.aws_instances.asg.private_ips}"
  description = "The private IPs of the instances of the cluster"
}

output "security_group_id" {
  value       = "${aws_security_group.ecs_hosts.id}"
  description = "The security group ID of the cluster"
}
