# MongoDB Atlas module

# MongoDB Atlas Project
resource "mongodbatlas_project" "this" {
  name   = "${var.project_name}-${var.environment}"
  org_id = var.org_id
}

# MongoDB Atlas Cluster
resource "mongodbatlas_cluster" "this" {
  project_id = mongodbatlas_project.this.id
  name       = "${var.cluster_name}-${var.environment}"

  # Cluster configuration
  provider_name               = "TENANT"
  backing_provider_name       = "AWS"
  provider_region_name        = var.cluster_region
  provider_instance_size_name = var.cluster_tier
  mongo_db_major_version      = var.mongodb_version

  # Only configure these for paid tiers (M10+)
  dynamic "advanced_configuration" {
    for_each = var.cluster_tier != "M0" && var.cluster_tier != "M2" && var.cluster_tier != "M5" ? [1] : []
    content {
      javascript_enabled           = true
      minimum_enabled_tls_protocol = "TLS1_2"
    }
  }

  # Backup settings (only for paid tiers)
  # For MongoDB Atlas provider, backup_enabled is a direct boolean attribute, not a block
  cloud_backup = var.backup_enabled && var.cluster_tier != "M0" && var.cluster_tier != "M2" && var.cluster_tier != "M5" ? true : false

  # Add auto-scaling configuration for higher tiers if needed

  # Add tags - MongoDB Atlas uses labels instead of tags
  labels {
    key   = "environment"
    value = var.environment
  }

  labels {
    key   = "project"
    value = var.project_name
  }
}

# Database User
resource "mongodbatlas_database_user" "this" {
  username           = var.db_username
  password           = var.db_password
  project_id         = mongodbatlas_project.this.id
  auth_database_name = "admin"

  # Set appropriate roles based on your application needs
  roles {
    role_name     = "readWrite"
    database_name = var.database_name
  }

  # Optional: Add more roles as needed
  roles {
    role_name     = "dbAdmin"
    database_name = var.database_name
  }

  scopes {
    name = mongodbatlas_cluster.this.name
    type = "CLUSTER"
  }
}

# IP Access List (Whitelist)
resource "mongodbatlas_project_ip_access_list" "cidr_blocks" {
  for_each   = toset(var.allowed_cidr_blocks)
  project_id = mongodbatlas_project.this.id
  cidr_block = each.value
  comment    = "CIDR block for ${each.value}"
}

# Add individual IP addresses if specified
resource "mongodbatlas_project_ip_access_list" "ip_addresses" {
  count      = length(var.ip_whitelist)
  project_id = mongodbatlas_project.this.id
  ip_address = var.ip_whitelist[count.index].ip_address
  comment    = var.ip_whitelist[count.index].comment
}