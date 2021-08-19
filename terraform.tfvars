default_region = "eu-west-1"
availability_zone_names =  ["eu-west-1a", "eu-west-1b"]
public_subnets = ["subnet-33178069","subnet-825207e4"]
private_subnets = ["subnet-0d02d2d2addb7351e","subnet-09cc34c502bc8858d"]
app_name              = "devops-hello-python"
ecs_execution_role_arn = "arn:aws:iam::303981612052:role/ecsTaskExecutionRole" 
task_port = 5000