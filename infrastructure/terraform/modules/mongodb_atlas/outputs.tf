output "connection_string" {
  description = "MongoDB Atlas connection string"
  value       = mongodbatlas_cluster.this.connection_strings[0].standard
  sensitive   = true
}

output "srv_connection_string" {
  description = "MongoDB Atlas SRV connection string"
  value       = mongodbatlas_cluster.this.connection_strings[0].standard_srv
  sensitive   = true
}

output "cluster_id" {
  description = "MongoDB Atlas cluster ID"
  value       = mongodbatlas_cluster.this.cluster_id
}

output "project_id" {
  description = "MongoDB Atlas project ID"
  value       = mongodbatlas_project.this.id
}

output "cluster_name" {
  description = "MongoDB Atlas cluster name"
  value       = mongodbatlas_cluster.this.name
}

output "database_name" {
  description = "MongoDB database name"
  value       = var.database_name
}

output "username" {
  description = "MongoDB database username"
  value       = mongodbatlas_database_user.this.username
}