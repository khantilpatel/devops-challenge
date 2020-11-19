Infrastructure Coding Test
==========================

# Goal

Script the creation of a web server, and a script to check the server is up.

# Prerequisites

You will need an AWS account. Create one if you don't own one already. You can use free-tier resources for this test.

# The Task

You are required to set up a new server in AWS. It must:

* Be publicly accessible.
* Run Nginx.
* Serve a `/version.txt` file, containing only static text representing a version number, for example:

```
1.0.6
```

# Mandatory Work

Fork this repository.

* Provide instructions on how to create the server.
* Provide a script that can be run periodically (and externally) to check if the server is up and serving the expected version number. Use your scripting language of choice.
* Provide scripts for the install steps (it doesn't have to be a single script)
* Alter the README to contain the steps required to:
  * Create the server.
  * Run the checker script.


# Extra Credit

We know time is precious, we won't mark you down for not doing the extra credits, but if you want to give them a go...

* Use a configuration management tool (such as Terraform or Ansible) to bootstrap the server.
* Put the server behind a load balancer.
* Run Nginx inside a Docker container.
* Make the checker script SSH into the instance, check if Nginx is running and start it if it isn't.
* Have a domain name and a valid SSL certificate (Let's Encrypt) or be able to decribe what would need to happen to get SSL certificate and a decure nginx configuration.
* Provide an upstream application on a seperate port, and use nginx to serve it.  Bonus points if docker is used.

# Questions

#### What scripting languages can I use?

Any one you like. You’ll have to justify your decision. We use bash, Ansible and Terraform. Howevr, feel free to pick something you're familiar with, as you'll need to be able to discuss it.

#### Will I have to pay for the AWS charges?

No. You are expected to use free-tier resources only and not generate any charges. Please remember to delete your resources once the review process is over so you are not charged by AWS.

#### What will you be evaluating me on?

Scripting skills, ellegance, understanding of the technologies you use, security, documentation.

#### Will I have a chance to explain my choices?

Feel free to comment your code, or put explanations in a pull request within the repo.
If we proceed to a phone interview, we’ll be asking questions about why you made the choices you made.

-------------------------

### Features:

1. Complete infra as code deployment.

2. Fault-tolerant, multi-AZ instance deploy.

3. Zero downtime updates to server with rolling updates.

4. Secured, all the network and access is configured through the security groups and IAM instance profile roles. 

### Perquisites

- awscli
- packer
- terraform
- ansible

Verify setup

```
./verify-tooling

aws setup looks good.
docker setup looks good.
terraform setup looks good.
packer setup looks good.
ansible-playbook setup looks good.
AWS profile setup looks good.
You're all set!

```

## Create Server

[1]. First create ECR registery with terraform, build and push docker images.

The images are published to private ECR repo instead of a public docker repo.
 
```
./docker/build
```

[2]. Build a base AMI from Amazon linux for our app's server setup.

```
./packer/build-ami
```

[3]. Build the infra with auto scaling group and elb.

```
./terraform/build-infra plan
```

```
./terraform/build-infra apply
```


## Run checker script (optional) 

Checker script to verify if docker containers are running and restart if not. This is optional because this job is primarily
done by the auto scaling group, it monitors the instances health and if their health degrades it'll automatically replace the instance
with a new one.

```
./ansible/run-checker
```

### Scenario to upgrade the AMI image.

Once the app infra is deployed, there might be some maintenance tasks like update the OS for security patches, upgrade docker engine etc.
This is being done without downtime.

[1]. Make the changes in the packer configuration if required. 

[2]. Build the new image:

```
./packer/build-ami
```

[3]. Replace the existing servers with the new one's.

```
./terraform/build-infra plan
```

```
./terraform/build-infra apply
```

Terraform will wait for instances in the new ASG to show up as InService in the ELB before considering the ASG successfully created. 

### Scenario to deploy newer version of php-app

This will just need to push the new docker image to ECR and running Ansible to deploy these images on each of instances.

[1]. Make change to the code and push the new image

```
./docker/build
```

[2]. Deploy the new image

```
./ansible/check-update-app
```