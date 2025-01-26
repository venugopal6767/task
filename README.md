#
For Task1:
----------
vpc.tf
=========
created a vpc with 2 pubic subnets and 2 private subnets required for vpc

ecs.tf 
========
1.IN the ecs.tf file script will create a roles required for ecs taskdefinition and services
2.created a alb with host based routing to route traffic to wordpress and microservice container 
3.Trying to implement RDS and configuring task definitions to fetch secrets from aws secrets manager
4.created a hosted zone in aws and created a A records for both subdomains and configured the load balancer
5.stored secrets in aws secrets manager and retrived using secrets manager data  and passed to db and task definition 

If we hit(http) 
 wordpress.venugopalmoka.site  -----> it will give wordpress website
 microservice.venugopalmoka.site ----> It will redirect to microservice output (getting 502 error)

 

For Task2:
---------
Manual:

1.create a vpc 
2.create 2 insatnces in private subnet and one 1 instance in public subnet to connect to private subnet instances
3.ssh into public subnet and  copy keypair into it and ssh into private subnet
4.Install Nginx and docker and run docker container running on port 8080(In both instances using step3)
5.create Target groups( Targetgroup1 for nginx and target group2 for docker)
6.create load balncer, added target groups and add listner and In listner created rules for hostbased routing
7.modified the nginx conf in /etc/nginx/sites-enabled/default to get nginx proxy to route traffic
8.created a host based routing 
    ec2-alb-docker.venugopalmoka.site -----> docker containeroutput
    ec2-alb-docker.venugopalmoka.sie ------> instance output

using Terraform:
1. Created vpc, Ec2 instances in private subnet and routes in dns

#task3
-----------------
1. created a ec2 instance and installed aws cloudwatch agent manually using below commands
    wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
    sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
    sudo apt-get update -y
    sudo apt-get install collectd
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status

#task4:
---------
1. created a sample nodejs microservice and created dockerfile
2. created a ecr conatiner from aws 
3. written github actions code to create docker images and push to ecr and update the ecs service


#task5
-----------
1. created terraform code to deploy static website on s3 bucket 

