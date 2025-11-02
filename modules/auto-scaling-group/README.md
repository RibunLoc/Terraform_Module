# Auto Scaling Group Module

Provision an AWS Launch Template and Auto Scaling Group.

## Inputs

- `name` (string, required)
- `subnet_ids` (list(string), required)
- `security_group_ids` (list(string), optional)
- `ami_id` (string, required)
- `instance_type` (string, default `t2.micro`)
- `block_device_mapping` (list(object), optional)
- `iam_instance_profile` (string, optional)
- `key_name` (string, optional)
- `user_data_vars` (map(string), optional)
- `desired_capacity` (number, required)
- `min_size` (number, required)
- `max_size` (number, required)
- `target_group_arns` (list(string), optional)
- `tags` (map(string), optional)

## Outputs

- `launch_template_id`
- `launch_template_latest_version`
- `autoscaling_group_name`
- `autoscaling_group_arn`

## Notes

- User data is rendered from `templates/user_data.sh.tftpl` if present.
- Name and provided tags are applied to instances and volumes; ASG propagates tags to instances.

