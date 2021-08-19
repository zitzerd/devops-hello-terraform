# devops assessment terraform

## What is expected

We should be able to request the application using the DNS of an external load
balancer on port 80. (443 not needed).

These are the services you have access to:

 * Full ECS permissions
 * Full EC2 permissions
 * Full LoadBalancer (ELB/ELBv2) permissions
 * Full VPC permissions
 * Read-only access to IAM role 'ecsTaskExecutionRole'
 * Permissions to manage IAM credentials for yourself

## Notes

 * A basic working VPC is already in place in AWS, you can build on top of it.
 * You don't have access to S3, so use a local state file or store remote
   states somewhere else.
 * Right now only 2 replicas are accepted due to service limits. Don't try to
   deploy more.
 * Keep in mind that Fargate needs to reach outside the VPC to download the
   containers from ECR. A `CannotPullContainerError` is not only a permission
   error. There are two ways to achieve this, all seem fine to us.
 * There is a role called `ecsTaskExecutionRole` available and can be used as
   execution role of the tasks.
 * Remember that if you're having issues, you can always deploy services
   manually in AWS and then import your resources in terraform.
 * Don't prepare CI/CD workflow for this project, just share the code with us.
 * We encourage you to be verbose and write comments, that will be very useful
   for us, especially if you don't have time to complete the full assessment.




## What i did
* Created 2 ElasticIPs for the NAT Gateways on each AZ.
* Created NAT Gateways on the public subnets on each AZ. 
    
* Created ECR Repository (Uploaded the first image with docker push)
* Created the Network Security Groups for the Private and Public Subnets.
    * Only the *load balancer* can reach the private subnet where the tasks are running on the port 5000
    * Only the port 80 is open on the load balancer and exposed to the internet.
    * Created routes associated with to the private subnet *overriding the main* to access internet through the nat gateways. In that way they can access the ECR for example
    * Lowered the time the scheduler drains the tasks so its faster to test the deploys. 
* The output of the plan shows the Load Balancer URL, ECR repository arn and name.    

* Considerations
    * To be able to use the existing VPC and its Pub/Priv Subnets i imported the resources on the availablity zones 1a/1b. I decided to import the subnets instead instead of just use them as datasources so i could be able to update some values if needed. (in this case just tags/names)

    * For this reasons the variables have some special settings like public-subnets, private-subnets. If i could generate from scratch the VPC those wont be necesary since i could just use the count function and generate the subnets on the availability zones without the need to import and match the names.
    * Imported Interget Gateway that its part of the default vpc.
    * Use the ecsTaskExecutionRole as a datasource to enable fargate execute tasks 
    * Didn't enable cloudwatch on the tasks since my user didn't have access to it.
    * Used the same user (diezit) for the deployment of the application from github actions since i wasnt able to generate a new user. Both templates are generated with the name _pending in case it was just a problem with the policy on my user
    


