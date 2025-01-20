"""
File: test_get_todo.py
Description: Runs a test for our 'get_todo' Lambda
"""
import os
import sys
import boto3
import json
import pytest
from moto import mock_dynamodb

sys.path.append(os.path.join(os.path.dirname(os.path.realpath(__file__)),"../../../python/lambda"))

from get_todo import lambda_handler

@pytest.fixture(scope='function')
def aws_credentials():
    """Mocked AWS Credentials for moto."""
    os.environ['AWS_ACCESS_KEY_ID'] = 'testing'
    os.environ['AWS_SECRET_ACCESS_KEY'] = 'testing'
    os.environ['AWS_SECURITY_TOKEN'] = 'testing'
    os.environ['AWS_SESSION_TOKEN'] = 'testing'
    os.environ['AWS_DEFAULT_REGION'] = 'us-east-1'
    os.environ['DDB_TABLE'] = 'DDB_TABLE'

def test_initialization(aws_credentials):
    event = {}
    context = None

    os.environ['DDB_TABLE'] = ''

    payload = lambda_handler(event, context)

    assert payload['statusCode'] == 500

def test_empty_event(aws_credentials):
    event = {}
    context = None

    payload = lambda_handler(event, context)

    assert payload['statusCode'] == 400

@mock_dynamodb
def test_valid_request(aws_credentials):
    event = { 'pathParameters':
        {
            'id': '123'
        }
    }
    context = None

    create_mock_ddb_table()

    payload = lambda_handler(event, context)

    assert payload['statusCode'] == 200

@mock_dynamodb
def create_mock_ddb_table():
    mock_ddb = boto3.resource('dynamodb')
    mock_ddb.create_table(
        TableName='DDB_TABLE',
        AttributeDefinitions=[
            {
                'AttributeName': 'id',
                'AttributeType': 'S'
            },
        ],
        KeySchema=[
            {
                'AttributeName': 'id',
                'KeyType': 'HASH'
            }
        ],
        ProvisionedThroughput={
            'ReadCapacityUnits': 123,
            'WriteCapacityUnits': 123
        }
    )
    mock_ddb_table = mock_ddb.Table('DDB_TABLE')

    todo = {
        'id': '123',
        'completed': False,
        'created_at': '2022-10-20T18:58:52.548072',
        'title': 'Testing'
    }

    mock_ddb_table.put_item(
        Item=todo
    )

    return mock_ddb_table
