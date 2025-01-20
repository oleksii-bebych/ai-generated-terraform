import json
import logging
import os
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
        html = '''
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Welcome to re:Invent 2024</title>
                <style>
                    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 800px; margin: 0 auto; padding: 20px; }
                    h1 { color: #0066cc; }
                    .logo-container { background-color: #232F3E; padding: 20px; text-align: center; }
                    .logo-container img { max-width: 100%; height: auto; }
                </style>
            </head>
            <body>
                <div class="logo-container">
                    <a href="https://reinvent.awsevents.com/?trk=direct">
                        <img src="https://reinvent.awsevents.com/content/dam/reinvent/2022/media/logo/reinvent-white.png" 
                            alt="AWS re:Invent Home" 
                            title="AWS re:Invent Home">
                    </a>
                </div>
                <h1>Welcome to re:Invent 2024</h1>
                <h1>DOP 326 - Terraform expertise: Accelerate AWS deployments with modular IaC & AI!</h1>
            </body>
            </html>
        '''
        
        return {
            'statusCode': 200,
            'body': html,
            "headers": {"Content-type": "text/html", "Access-Control-Allow-Origin" : "*"}
        }
