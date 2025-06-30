provider "aws" {
  region = var.region
}

resource "aws_vpc" "ahmad-vpc-terra" {
  cidr_block = var.vpc-cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    "Name" = "ahmad-vpc-terra"
    "owner" = "ahmad"
  }
}

resource "aws_internet_gateway" "ahmad-igw-terra" {  
    vpc_id = aws_vpc.ahmad-vpc-terra.id
    tags = {
        "Name" = "ahmad-igw-terra"
        "owner" = var.owner
    }
}

resource "aws_subnet" "ahmad-public-subnet1-terra" {
  vpc_id = aws_vpc.ahmad-vpc-terra.id
  cidr_block = var.subnet1-cidr
  availability_zone = "us-east-2c"

  map_public_ip_on_launch = true

  tags = {
    "Name" = "ahmad-public-subnet1-terra"
    "owner" = var.owner
  }
}

resource "aws_subnet" "ahmad-public-subnet2-terra" {
  vpc_id = aws_vpc.ahmad-vpc-terra.id
  cidr_block = var.subnet2-cidr
  availability_zone = "us-east-2a"

  map_public_ip_on_launch = true

  tags = {
    "Name" = "ahmad-public-subnet2-terra"
    "owner" = var.owner
  }
}

resource "aws_route_table" "ahmad-public-sub-rt-terra" {
  vpc_id = aws_vpc.ahmad-vpc-terra.id
  route {
    cidr_block = var.all-traffic-cidr
    gateway_id = aws_internet_gateway.ahmad-igw-terra.id
  }
  tags = {
    "Name" = "ahmad-public-sub-rt-terra"
    "owner" = var.owner
  }
}

resource "aws_route_table_association" "ahmad-subnet1-association" {
  subnet_id = aws_subnet.ahmad-public-subnet1-terra.id
  route_table_id = aws_route_table.ahmad-public-sub-rt-terra.id
}

resource "aws_route_table_association" "ahmad-subnet2-association" {
  subnet_id = aws_subnet.ahmad-public-subnet2-terra.id
  route_table_id = aws_route_table.ahmad-public-sub-rt-terra.id
}

resource "aws_security_group" "ahmad-sg-terra" {
  name = "Http and SSH"
  vpc_id = aws_vpc.ahmad-vpc-terra.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [var.all-traffic-cidr]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.all-traffic-cidr]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = [var.all-traffic-cidr]
  }  

  tags = {
    "Name" = "ahmad-sg-terra"
    "owner" = var.owner
  }
}


##################    ECS Resources    ##########################
resource "aws_ecs_cluster" "ahmad-ecs-cluster-terra" {
  name = "ahmad-ecs-cluster-terra"
  tags = {
    "Name" = "ahmad-ecs-cluster-terra"
    "owner" = "ahmad"
  }
}

resource "aws_ecs_task_definition" "ahmad-taskdef-terra" {
  family = "ahmad-taskdef-terra"
  requires_compatibilities = ["EC2"]
  network_mode = "awsvpc"
  cpu = 256
  memory = 256
  
  execution_role_arn = "arn:aws:iam::504649076991:role/ecsTaskExecutionRole"
  container_definitions = jsonencode([
    {
        name = "nginx-terra"
        image = "nginxdemos/hello:latest"
        cpu = 256
        memory = 256
        essential = true
        portMappings = [
            {
                containerPort = 80
                hostPort = 80
            }
        ]
    }
  ])

  tags = {
    "Name" = "ahmad-taskdef-terra"
    "owner" = "ahmad"
  }
}

resource "aws_ecs_service" "ahmad-service-terra" {
  name = "ahmad-service-terra"
  launch_type = "EC2"
  cluster = aws_ecs_cluster.ahmad-ecs-cluster-terra.id
  task_definition = aws_ecs_task_definition.ahmad-taskdef-terra.arn
  desired_count = 2
  
  network_configuration {
    subnets = [aws_subnet.ahmad-public-subnet1-terra.id, aws_subnet.ahmad-public-subnet2-terra.id]
    security_groups = [aws_security_group.ahmad-sg-terra.id]
    assign_public_ip = false
  }

  deployment_circuit_breaker {
    enable = true
    rollback = false
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.ahmad-lb-targroup-terra.arn
    container_name = "nginx-terra"
    container_port = 80
  }

  depends_on = [ aws_lb_listener.ahmad-lb-listener-terra ]
  tags = {
    "Name" = "ahmad-service-terra"
    "owner" = "ahmad"
  }
}


####################################################
# Create an IAM role - ecsInstanceRole  
####################################################
data "aws_iam_policy" "ecsInstanceRolePolicy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

data "aws_iam_policy_document" "ecsInstanceRolePolicy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecsInstanceRole-ahmad" {
  name               = "ecsInstanceRole-ahmad"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecsInstanceRolePolicy.json
}

resource "aws_iam_role_policy_attachment" "ecsInstancePolicy" {
  role       = aws_iam_role.ecsInstanceRole-ahmad.name
  policy_arn = data.aws_iam_policy.ecsInstanceRolePolicy.arn
}

resource "aws_iam_instance_profile" "ecsInstanceRoleProfile" {
  name = aws_iam_role.ecsInstanceRole-ahmad.name
  role = aws_iam_role.ecsInstanceRole-ahmad.name
}

resource "aws_iam_role_policy_attachment" "ecsInstanceECRPullPolicy" {
  role       = aws_iam_role.ecsInstanceRole-ahmad.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ecsInstanceSSMPolicy" {
  role       = aws_iam_role.ecsInstanceRole-ahmad.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

############ ASG Group for EC2 Instances ##############
resource "aws_launch_template" "ahmad-launch-template-terra" {
  name_prefix   = "ahmad-launch-template-terra"
  image_id      = "ami-0878cd100d0689adf"
  instance_type = "t2.micro"
 
  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo "ECS_CLUSTER=${aws_ecs_cluster.ahmad-ecs-cluster-terra.name}" >> /etc/ecs/ecs.config
    EOF
    )

  iam_instance_profile {
    name = aws_iam_instance_profile.ecsInstanceRoleProfile.name
  }

  tags = {
    "Name" = "ahmad-launch-template-terra"
    "owner" = "ahmad"
  }
}

resource "aws_autoscaling_group" "ahmad-autoscale-group-terra" {
  name = "ahmad-autoscale-group-terra"

  vpc_zone_identifier = [
    aws_subnet.ahmad-public-subnet1-terra.id, 
    aws_subnet.ahmad-public-subnet2-terra.id
  ]

  # availability_zones = ["us-east-2a", "us-east-2c"]

  desired_capacity   = 4
  max_size           = 6
  min_size           = 2
  
  launch_template {
    id      = aws_launch_template.ahmad-launch-template-terra.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }

}


############ ALB Logic  ###############
resource "aws_lb" "ahmad-lb-terra" {
  name = "ahmad-lb-terra"
  load_balancer_type = "application"
  security_groups = [ aws_security_group.ahmad-sg-terra.id ]
  subnets = [ aws_subnet.ahmad-public-subnet1-terra.id, aws_subnet.ahmad-public-subnet2-terra.id ]

  tags = {
    "Name" = "ahmad-lb-terra"
    "owner" = "ahmad"
  }
}

resource "aws_lb_target_group" "ahmad-lb-targroup-terra" {
  name = "ahmad-lb-targroup-terra"
  port = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id = aws_vpc.ahmad-vpc-terra.id
}

resource "aws_lb_listener" "ahmad-lb-listener-terra" {
  load_balancer_arn = aws_lb.ahmad-lb-terra.arn
  port = 80
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ahmad-lb-targroup-terra.arn
  }
}












