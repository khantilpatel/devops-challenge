#! /bin/bash

aws_account_id=$(aws sts get-caller-identity --query Account --output text)

sudo -u ec2-user docker run --restart unless-stopped --name nginx -p 80:80 -d $aws_account_id.dkr.ecr.us-east-1.amazonaws.com/nginx-web-app:latest

sudo -u ec2-user docker run --restart unless-stopped --name php-app -p 3000:80 -d $aws_account_id.dkr.ecr.us-east-1.amazonaws.com/php-app:latest