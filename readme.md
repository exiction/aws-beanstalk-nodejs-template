# AWS Elastic Beanstalk AL2023 Setup Template

This repository provides a template for deploying an frontend or/and backend application on AWS Elastic Beanstalk (version: AL2023) with a custom Nginx configuration.
- Please consider your Beanstalk Environment Version before following this tutorial!

It took me some days to debug and build this template, i was very frustrated that AWS has very bad documentation, so i have a guide here to hopefully help someone. I tested it only with NodeJS, but I think it works also with GO, etc. You need to 

The setup includes:
 - Basic authentication
 - SSL/TLS with self signed certificate
 - Nginx custom location routes
 - src/ with typescript (not specific)
 - git pipeline

## A word to .ebextensions
- Some documentation says that the folder `.ebextensions` is still supported in AL2023, some not. So in my experience it throwed just errors. So use the `.platform` folder where you can place your configurations. I mostly explored them using `ls -la` with `hooks`. Would be better to SSH in it.

## Key Points About Hooks:
(Instance deployment workflow)[https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/platforms-linux-extend.html#platforms-linux-extend.workflow]
- **Pre-deploy Hooks**: Run before the application is deployed, often used to prepare the environment or perform setup tasks.
- **Post-deploy Hooks**: Execute after the application is deployed, typically used for final adjustments or cleanups.
- **Pre-build Hooks**: Run before the build process, useful for setting up prerequisites.
- **Post-build Hooks**: Execute after the build process, used to finalize configurations or perform additional tasks.


## Directory Structure

- `.platform/`
  - `nginx/`
    - `nginx.conf`          # Custom Nginx configuration file
    - `conf.d/`
      - `custom.conf`       # Custom Nginx configuration for basic authentication and routing
  - `hooks/`
    - `postdeploy/`
      - `00_move_htpasswd.sh`               # Script to move .htpasswd file from zip package to Nginx configuration directory
      - `01_move_custom_nginx_locations.sh` # Script to move custom defined nginx locations from zip package to Nginx configuration directory
	  - `02_create_nginx_config.sh`          # Script to replace default nginx.conf with custom configuration
- `src/`                  # Source code for the application (in my case its typescript)
- `Procfile`              # Specifies commands to start your application
- `...`

## Setup and Configuration

## VPC

- create a default VPC.
  - I have 2 public subnets and one private.
  | Name       | Subnet-ID            | Status    | VPC                           | IPv4-CIDR | IPv6-CIDR | IPv6 CIDR Association ID | Available IPv4 Addresses | Availability Zone | Availability Zone-ID | Network Border Group | Routing Table                                      | Network ACL                  | Default Subnet | Automatically Assign Public IPv4 Address | Automatically Assign Customer IPv4 Address | Customer IPv4 Pool | Automatically Assign IPv6 Address | Owner-ID      |
|------------|-----------------------|-----------|-------------------------------|------------|-----------|--------------------------|---------------------------|-------------------|-----------------------|-----------------------|----------------------------------------------------|-------------------------------|----------------|-------------------------------------------|------------------------------------------------|--------------------|------------------------------|----------------|
| private    | subnet-... | Available | vpc-... | 10.0.2.0/24 | –         | –                        | 251                       | eu-central-1a     | euc1-az2              | eu-central-1          | rtb-... | private                     | acl-... | No               | No                                         | No                                             | -                  | No                           | 654957580575  |
| public     | subnet-... | Available | vpc-... | 10.0.1.0/24 | –         | –                        | 248                       | eu-central-1a     | euc1-az2              | eu-central-1          | rtb-... | public                      | acl-... | No               | No                                         | No                                             | -                  | No                           | 654957580575  |
| public-1   | subnet-... | Available | vpc-... | 10.0.3.0/24 | –         | –                        | 250                       | eu-central-1b     | euc1-az3              | eu-central-1          | rtb-... | public                      | acl-... | No               | No                                         | No                                             | -                  | No                           | 654957580575  |



### Nginx Configuration

- **`nginx.conf`**: Customized Nginx configuration file located in `.platform/nginx/nginx.conf`. This file sets up the Nginx server with default settings and includes directives for HTTP to HTTPS redirection. Its better to integrate changes in the:
- (I changed the logging output)

- **`custom.conf`**: Additional Nginx configuration located in `.platform/nginx/conf.d/custom.conf`. This file is used for custom nginx config.

### Basic Authentication

- **`htpasswd`**: A file will be generated in the git pipeline (using secrets) and moved to the Nginx configuration directory to handle basic authentication. The `.htpasswd` file is used to secure certain routes.
- The username can be changed in the pipeline "main.yml" (default: "username")

- **`00_move_htpasswd.sh`**: A script in `.platform/hooks/postdeploy/` that moves the `.htpasswd` file from the deployment package to the Nginx configuration directory and restarts Nginx.

### SSL/TLS Configuration

- In my case I added a `Elastic load Balancer` which handles the TLS. For this you need to change your configuration in EB or you create one in the EC2 Dashboard.

### Logging Real Client IPs

- I encountered an issue where the IP addresses in the logs were incorrect after applying the load balancer, as they were internal IPs forwarded by the ELB. To resolve this, I updated the log format in nginx.conf to use $http_x_forwarded_for, which captures and logs the real client IP addresses (to identify problems easier).

## Deployment

1. **Clone the Repository**: Clone this repository.

2. **Configure Elastic Beanstalk**: Create a new Elastic Beanstalk application and environment, and configure it with a public ip.
-> Set your Plattform. I used Node.js 20 running on 64bit Amazon Linux 2023/6.2.1

3. **Update Configuration**: Ensure that `.platform/nginx/nginx.conf` and `.platform/nginx/conf.d/custom.conf` are configured according to your needs.

4. **Deploy Application**: Push your changes to Elastic Beanstalk using the pipeline or manually (s3). The `postdeploy` hooks will handle moving the `.htpasswd` file before the final deployment is made, setting up Nginx, and configuring SSL/TLS. https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/platforms-linux-extend.html

5. **Verify Deployment**: Check the Elastic Beanstalk environment to ensure the application is running, and verify that Nginx is correctly configured.

## Notes

- **SSL/TLS Certificates**: For production use, consider using a trusted certificate authority for SSL/TLS certificates rather than self-signed certificates.

## Troubleshooting

- **Logs**: Check the Elastic Beanstalk logs for any errors or issues.

- **Load Balancer**: I had some issues to attach it, I got this error: `Creating load balancer failed Reason: Resource handler returned message: "A load balancer cannot be attached to multiple subnets in the same Availability Zone (Service: ElasticLoadBalancingV2, Status Code: 400, Request ID: ...)" (RequestToken: ..., HandlerErrorCode: InvalidRequest)` -> to fix this add another public-subnet with a other Zone (like eu-central-1b instead of eu-central-1a) to your VPC and attach it with the ACLs/Route Table. Then it worked.


- **Configuration**: Ensure all paths and filenames in the scripts and configuration files match your actual setup. The config files that start with numbers (like 00_file.sh, 01_script.sh, etc.) are typically used to control the order in which scripts are executed.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
