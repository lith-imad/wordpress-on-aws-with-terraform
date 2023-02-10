env= "prod"
region = "eu-west-1"
wp_admin_email= "techadmin@diversitygroup.co"
ec2_instance_type= "t2.micro"
ec2_public_key_name= "nzoi-wp-trr"
ec2_public_key_path= "~/.ssh/id_rsa.pub"
ec2_sg_ingress_ports= ["80", "443", "22"]

ec2_bastion_asg_desired_capacity= 1
ec2_bastion_asg_min_capacity= 1
ec2_bastion_asg_max_capacity= 1

ec2_wordpress_asg_desired_capacity= 2
ec2_wordpress_asg_min_capacity= 2
ec2_wordpress_asg_max_capacity= 4

certificate_arn = "arn:aws:acm:eu-west-1:066784885518:certificate/b3f5b3e0-6b6f-42db-b4eb-19380f823278"

db_host= "nzoi-wp.crdndrgkyml7.eu-west-1.rds.amazonaws.com"
db_username= "nzoi_wp"
db_password= "FwZrFB8LrN8M5bK"
db_port= "3306"
db_name= "nzoi_wp"

//cache
ec_node_type= "cache.t2.micro"
ec_nodes_count= 1
ec_az_mode= "single-az"
ec_memcached_port= "11211"





