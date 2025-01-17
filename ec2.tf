data "aws_ami" "amzn_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

locals {
  credentials = {
    db_name        = var.db_name
    db_username    = var.db_username
    db_password    = var.db_password
    db_host        = var.db_host
    wp_title       = aws_ssm_parameter.wp_title.value
    wp_username    = aws_ssm_parameter.wp_username.value
    wp_password    = aws_ssm_parameter.wp_password.value
    wp_email       = aws_ssm_parameter.wp_email.value
    site_url       = aws_ssm_parameter.site_url.value
    region         = var.region
    file_system_id = aws_efs_file_system.wordpress_fs.id
  }
}

resource "aws_key_pair" "public_key" {
  key_name   = var.ec2_public_key_name
  public_key = file(var.ec2_public_key_path)
}

resource "aws_launch_template" "bastion_lt" {
  name          = "bastion_lt"
  description   = "Launch Template for the Bastion instances"
  image_id      = data.aws_ami.amzn_linux_2.id
  instance_type = var.ec2_instance_type
  key_name      = var.ec2_public_key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.bastion-sg.id]
  }
}

resource "aws_autoscaling_group" "bastion_asg" {
  name                = "bastion-asg"
  desired_capacity    = var.ec2_bastion_asg_desired_capacity
  min_size            = var.ec2_bastion_asg_min_capacity
  max_size            = var.ec2_bastion_asg_max_capacity
  vpc_zone_identifier = aws_subnet.public_subnets[*].id


  launch_template {
    id      = aws_launch_template.bastion_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "bastion-asg"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "wordpress_lt" {
  name          = "wordpress_lt"
  description   = "Launch Template for the WordPress instances"
  image_id      = data.aws_ami.amzn_linux_2.id
  instance_type = var.ec2_instance_type
  key_name      = var.ec2_public_key_name
  user_data     = base64encode(templatefile("./scripts/bootstrap.sh", local.credentials))

  iam_instance_profile {
    name = aws_iam_instance_profile.parameter_store_profile.name
  }

  network_interfaces {
    security_groups = [aws_security_group.wordpress_sg.id]
  }
}

resource "aws_autoscaling_group" "wordpress_asg" {
  name             = "wordpress-asg"
  desired_capacity = var.ec2_wordpress_asg_desired_capacity
  min_size         = var.ec2_wordpress_asg_min_capacity
  max_size         = var.ec2_wordpress_asg_max_capacity

  vpc_zone_identifier = aws_subnet.private_subnets[*].id
  target_group_arns   = [aws_lb_target_group.wordpress_tg.arn]
  health_check_type   = "ELB"


  launch_template {
    id      = aws_launch_template.wordpress_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "wordpress-asg"
    propagate_at_launch = true
  }
}
