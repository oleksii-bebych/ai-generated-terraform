# Below are some guidelines to follow for Terraform resources

# General Guidelines
* Use Terraform best practices for module development
* Create all recommended files - main.tf, variables.tf, outputs.tf, versions.tf, backend.tf and README.md
* Demonstrate usage of modules by providing basic and complete examples
* Implement input validation using Terraform's built-in functions
* Use consistent naming conventions for resources
* Provide clear and concise descriptions for variables and outputs
* Include examples of module usage in the README.md file
* Implement proper error handling and informative error messages
* Implement logging and monitoring capabilities
* Generate required output to consume by other modules
* Apply Tags for all resources

# Service Specific Guidelines
## Amazon DynamoDB
* Create DynamoDB table resource
* Configure table attributes and key schema
* Set up billing mode (PROVISIONED or PAY_PER_REQUEST)
* Configure capacity units
* Add global secondary indexes (optional)
* Add local secondary indexes (optional)
* Enable TTL (optional)

## AWS Lambda
* Create IAM role for Lambda function (if iam_role_arn not provided)
* Create Lambda function resource
* Configure function code (either from file or S3)
* Set up function configuration (memory, timeout, handler, runtime)
* Configure VPC settings (optional)
* Set up environment variables
* Create CloudWatch log group for Lambda function

## AWS IAM
* Consider security best practices (least privilege principle for IAM roles)
* Ensure the module is flexible enough to handle various use cases (e.g., different types of roles and policies)
* Use jsonencode() function for policy documents to improve readability and maintainability
* Use dynamic blocks for creating multiple resources and methods

## Amazon API Gateway
* Implement proper error handling and informative error messages
* Consider security best practices (e.g., proper authorization, API key usage)
* Optimize for reusability and flexibility to handle various API configurations
* Use dynamic blocks for creating multiple resources and methods

## Folder and File structure
The project structure should follow:
```
./modules/<service_name>/
|- main.tf
|- variables.tf
|- outputs.tf
|- versions.tf
|- README.md
|- examples/
   |- basic/
      |- main.tf
   |- complete/
      |- main.tf
```