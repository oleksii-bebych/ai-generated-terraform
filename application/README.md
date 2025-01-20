
# Architecture overview

The project deploys a RESTful API application that uses the following AWS Serverless technologies:

* AWS API Gateway (https://aws.amazon.com/api-gateway) to provide the REST interface to the user.
* Amazon DynamoDB (https://aws.amazon.com/dynamodb) as a data store
* AWS Lambda (https://aws.amazon.com/lambda) process the API gateway requests and read data from or write data to a DynamoDB table. 

![Architecture Diagram](https://deyn4asqcu6xj.cloudfront.net/serverless-todo-backend-arch.png) 
