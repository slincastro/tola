# MongoDB on AWS ECS (EC2) with EBS Persistence

This setup provisions single-node MongoDB (`desired_count = 1`) on ECS using EC2 launch type with host-mounted EBS storage.

## What it deploys

- ECS cluster + service (EC2 launch type)
- Launch template + Auto Scaling Group + Capacity Provider
- IMDSv2-required EC2 instances
- Encrypted `gp3` EBS data volume (default `mongo_ebs_size_gb = 50`)
- `user_data` boot script that detects/initializes/mounts data disk at `/var/lib/mongo`
- ECS task with bind mount from host `/var/lib/mongo` to container `/data/db`
- CloudWatch log group for Mongo logs
- Security groups:
  - `app` SG (example caller SG)
  - `mongo` SG allowing inbound `27017` only from `app` SG

No public load balancer or public Mongo exposure is created.

## Terraform apply

From repository root:

```bash
cd infrastructure/terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars # if needed
terraform init
terraform plan
terraform apply
```

Key variables (in `terraform.tfvars`):

- `enable_ecs_mongo = true`
- `create_vpc = true` (or `false` and provide existing subnet/VPC IDs)
- `mongo_ebs_size_gb = 50`
- `mongo_root_username`
- `mongo_root_password` (sensitive)

## Verify EBS mount persistence

1. Find Mongo EC2 instance in ASG and connect via SSM Session Manager or bastion.
2. Check mount:

```bash
findmnt /var/lib/mongo
lsblk -f
```

3. Restart instance (or stop/start ASG instance), then re-check mount and Mongo data presence:

```bash
findmnt /var/lib/mongo
ls -la /var/lib/mongo
```

If mount is healthy, the same filesystem UUID remains in `/etc/fstab` and data persists.

## Test connectivity from inside VPC

Launch or use an instance/ECS task attached to the exported `app` security group. Then test:

```bash
nc -vz <mongo-private-ip> 27017
```

Or with Mongo shell:

```bash
mongosh "mongodb://<user>:<pass>@<mongo-private-ip>:27017/admin?authSource=admin"
```

## Expected application env vars

Preferred:

- `MONGO_URI=mongodb://<user>:<pass>@<mongo-private-ip>:27017/admin?authSource=admin`

Alternative split form:

- `MONGO_USER`
- `MONGO_PASSWORD`
- `MONGO_HOST`
- `MONGO_PORT`

## High availability note

Current deployment is intentionally single-node for simplicity. Future HA work should implement a MongoDB replica set across multiple AZs, plus backup/restore, maintenance strategy, and failure testing.
