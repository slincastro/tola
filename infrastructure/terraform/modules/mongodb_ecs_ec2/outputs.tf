output "vpc_id" {
  description = "VPC ID in use"
  value       = local.selected_vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs in use"
  value       = local.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs in use"
  value       = local.public_subnet_ids
}

output "ecs_cluster_name" {
  description = "ECS cluster name for MongoDB"
  value       = aws_ecs_cluster.mongo.name
}

output "ecs_service_name" {
  description = "ECS service name for MongoDB"
  value       = aws_ecs_service.mongo.name
}

output "mongo_private_ip" {
  description = "Private IP of running Mongo EC2 instance when available"
  value       = try(data.aws_instances.mongo_ec2.private_ips[0], null)
}

output "mongo_connection_string_example" {
  description = "Example connection string using private IP"
  value       = "mongodb://${var.mongo_root_username}:${var.mongo_root_password}@${try(data.aws_instances.mongo_ec2.private_ips[0], "<mongo-private-ip>")}:${var.mongo_db_port}/admin?authSource=admin"
  sensitive   = true
}

output "mongo_sg_id" {
  description = "Security group ID used by Mongo host"
  value       = aws_security_group.mongo.id
}

output "app_sg_id" {
  description = "Example app security group allowed to reach Mongo"
  value       = aws_security_group.app.id
}

output "asg_name" {
  description = "Auto Scaling Group name for Mongo ECS hosts"
  value       = aws_autoscaling_group.mongo.name
}

output "mongo_private_ip_lookup_command" {
  description = "AWS CLI command to get Mongo host private IP"
  value       = "aws ec2 describe-instances --filters Name=tag:aws:autoscaling:groupName,Values=${aws_autoscaling_group.mongo.name} Name=instance-state-name,Values=running --query 'Reservations[].Instances[].PrivateIpAddress' --output text"
}
