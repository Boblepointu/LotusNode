########################
####     EFS       #####
########################

resource "aws_efs_file_system" "lotus" {
  creation_token = "${var.project_name}-lotus-${var.environment}"
  encrypted      = true
}

resource "aws_efs_access_point" "lotus" {
  file_system_id = aws_efs_file_system.lotus.id
  posix_user {
    gid = 1000
    uid = 1000
  }
  
  root_directory {
    path = "/lotus"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 0777
    }
  }
}

resource "aws_efs_mount_target" "lotus" {
  for_each = {
    for subnet in data.aws_subnets.main.ids : subnet => {
      id = subnet
    }
  }

  file_system_id = aws_efs_file_system.lotus.id
  subnet_id      = each.key
}

resource "aws_efs_file_system_policy" "lotus" {
  file_system_id = aws_efs_file_system.lotus.id
  policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{    
        Principal = { AWS = "*" }
        Action    = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess"
        ]
        Effect    = "Allow"
        Condition = {
            Bool = { "elasticfilesystem:AccessedViaMountTarget": "true" }
        }
        Resource = aws_efs_file_system.lotus.arn
      }]
  })
}