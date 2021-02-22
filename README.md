# DevOpsTestAWS
DevOps test by Daniel Rivera

## General Information
The project has been divided into two folders, the Front folder contains the code to run the server web, this was built using Golang and the module net/http. The folder infrastructure contains the Terraform code to deploy the AWS components to run the web application


## Infrastructure

The Infrastructure folder contains the terraform code to deploy AWS resources, a Modules folder has been created to store the Terraform modules used in this project. Terraform state is storing locally but feel free to use external tools like S3 bucket or Terraform Cloud.
The resources created by scripts are:

- AWS Networking resources, following best practices for HA
- ECS Cluster
- ECS Service
- Application Load Balancer(Public) 
- Secret Manager to store env variables necessary for the application
- IAM Roles for ECS Tasks, CodePipeline, and CodeBuild
- Security Groups
- CodePipeline
- CodeBuild Project
- KMS key to encrypt Secret Manager

#### General Steps
There are general steps that you must follow to launch the resources.

Before launching a resource you need to have in mind  the following:

  - Install terraform, use Terraform v0.13.5, you can download it here 
     https://releases.hashicorp.com/terraform/0.13.5/
  - Configure the AWS credentials into your laptop(for Linux  ~/.aws/credentials), you need to use the following format:

            [PROFILE_NAME]
            aws_access_key_id = Replace_for_correct_Access_Key
            aws_secret_access_key = Replace_for_correct_Secret_Key

       If you have more AWS profiles feel free to add them.


#### Usage

**1.** Clone the repository

**2.** Run Terraform init to dowload the providers and install the modules
```terraform
terraform init 
```
**3.** Run the terraform plan command, feel free if you want to use a tfvars file to specify the variables.
The variables that you need to set are:
+ **AWS_PROFILE** = according to profiles name in ~/.aws/credentials)
+ **AWS_REGION** = the region in which you want to create the resources
+ **ENVIRONMENT_NAME** = a unique name for the resources.


```terraform
terraform plan -var AWS_PROFILE="develop-account"  -var AWS_REGION="us-east-1"  -var ENVIRONMENT_NAME="testenv"
```
 
**3.** Review the terraform plan, take a look at the actions that terraform will take. If it is tour first time that runs this project you should have just resources to add and nothing to change and destroy.

```terraform
terraform apply -var AWS_PROFILE="develop-account"  -var AWS_REGION="us-east-1"  -var ENVIRONMENT_NAME="testenv"
```

#### Remove resources

Run the following command if you want to delete the resources created.

```terraform
terraform destroy -var AWS_PROFILE="develop-account"  -var AWS_REGION="us-east-1"  -var ENVIRONMENT_NAME="testenv"
```

## Application

The Front folder contains the code to run the webserver, this code was built using Golang, the web application uses the port 9191 but you can change it. The code runs a web server that allows two paths:

+ **/home:** This path just prints a welcome message

+ **/health:** Used to validate the status of the webserver

+ **/wantajoke:** use this path if you want a joke

**NOTE:** If you specify a different path you will get a 404 error
#### Usage

To run this application you have two options

**1. Run locally using Docker**
For this case, you need to have installed Docker on your local computer, use the 20.10.2 version or higher, follow this [link](https://docs.docker.com/engine/install/#server) to install Docker. 

Once you have docker installed you can create the docker image
``` shell
 docker build -t docker_image_name ./Front/.
```

The above command will create a docker image, you can validate the image creation by running the following command
``` shell
 docker images
```

With the docker image already created you can run a container using that image, for that run the following command.

``` shell
 docker run -itd -p 9191:9191 docker_image_name 
```

once you have the container running you can test in your browser
``` shell
 http://localhost:9191/wantajoke
```

**2. Run locally using Golang**

For this case, you need to have installed Golang on your local computer, use go1.15.2 version or higher, follow this [link](https://golang.org/doc/install) to install Golang. 

Once you have Golang installed you can run the application, for that move to the Front folder, and run
``` shell
 go run main.go
```
With that command Golang will start a web server waiting for a request, you can test in your browser
``` shell
 http://localhost:9191/wantajoke
```

If you want to generate a binary with the application you must run 
``` shell
 go build -o binary_name .
```

The above command will create a binary that you can execute.

