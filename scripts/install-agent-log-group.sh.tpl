#!/bin/bash
set -euo pipefail

LOG_GROUP_NAME="${log_group_name}" # Cần được truyền vào qua Terraform
AWS_REGION="${region}"

# 1. Cài đặt CloudWatch Agent
wget https://s3.$AWS_REGION.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo mv amazon-cloudwatch-agent.deb /tmp/amazon-cloudwatch-agent.deb
sudo dpkg -i /tmp/amazon-cloudwatch-agent.deb || sudo apt -f install -y

# 2. Tạo file cấu hình JSON tạm thời
cat << EOF > /opt/aws/amazon-cloudwatch-agent/etc/config.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/syslog",
            "log_group_name": "$LOG_GROUP_NAME",
            "log_stream_name": "{instance_id}",
            "timezone": "Local"
          }
        ]
      }
    }
  }
}
EOF

# 3. Khởi động Agent, tải cấu hình mới
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json -s