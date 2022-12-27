########################
## User defined vars ####
########################

# Global AWS account.
# Select the AWS region and AWS VPC id.
region                   = "eu-west-3"
vpc_id                   = "vpc-052bc5d16953c7e7b"

# Custom dns
# The dns zone must be preregistered and domain name NS records pointed to AWS NS.
dns_zone_name            = "frenchbtc.fr."
lb_dns_record_lotus   = "lotus-rpc.frenchbtc.fr"

# ECS task definitions. How powerful we want the ECS pods.
task_definition_configs  = {
  lotus = {
    memory            = 2048
    cpu               = 1024
    soft_memory_limit = 1010
  }
}