#Task1
------------------------------------
ECS with ALB, RDS and SecretsManager
------------------------------------

Created an ECS Cluster module with the services running in Private Subnets.

The two service definitions has created

        1.Wordpress
        
        2.microservices running on port 3000  with nodejs code
        
Created an RDS module to create RDS instance to be used by wordpress service as a database

Created passwords using secrets manager and loaded into RDS mysql database

RDS is Deployed in private subnets

Created IAM module to give permissions to fetch secrets from secrets manager and fetch images from ECR into ECS and add to ECS  task definition role

Created ALB load balancer module to create load balancer and target groups 

Attached the targets to the target groups and created host based routing for the services

        wordpress.venugopalmoka.site ------> redirect to wordpress website
        
        microservice.venugopalmoka.site ----> redirect to microservice application 
        
For SSL created wildcard certificates for my domain and imported to aws certificates 

Created HTTPS listner and added both target groups

Modified http listner to route traffic to https



#Task2
------------------------------------
EC2 Instance with Domain Mapping and NGINX
------------------------------------

Created VPC module to create vpc with 2 public subnets, 2 private subnets, NAT gateway and IGW and created Route table associations

created EC2 module to create EC2 instances in private subnet and load userdata wile provisioning 

The userdata is used to install NGINX, DOCKER, and created Nginx proxy and to run the docker images nd userdata is in root module **userdata.sh  file

Created ALB load balancer module to create load balancer and target groups 

Attached the targets to the target groups and created host based routing for the services

        ec2-alb-instance.venugopalmoka.site ------> redirect to Nginx output
        ec2-alb-docker.venugopalmoka.site ----> redirect to containers output

For SSL created wildcard certificates for  domain and imported to aws certificates 

Created HTTPS listner and added both target groups

Modified http listner to route traffic to https


#Task3
------------------------------------
Observability
-----------------------------------

Created a ec2 instance, ssh into it and run the below commands to configure metrics and logs 

    wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb

    sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard

    sudo apt-get update -y

    sudo apt-get install collectd

    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s

    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status


#Task4
------------------------------------
GitHub Actions
-----------------------------------

Created a custom microservice with nodejs code stored in Github repository

created a Dockerfile to create docker Images for nodejs application

Created Github actions code to create images and push to ECR repository and update the ecs service

The screts are stored in repository secrets


#Task5
------------------------------------
S3 Static Website Hosting with CDN (Optional)
-----------------------------------

Configured Terraform to deploy a static website hosted on an S3 bucket.

    Static website URL:

        http://venugopalmoka.site.s3-website.eu-west-2.amazonaws.com


