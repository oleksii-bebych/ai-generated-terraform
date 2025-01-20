from random import random
from uuid import uuid4
import boto3
import json
import urllib3
import sys
import os

sys.path.append(os.path.join(os.path.dirname(os.path.realpath(__file__)),"../../"))

from app import stack_name

test_id = ''
random_title = ''
apiEndpoint = None

def test_get_all_todos():
    
    stackName = stack_name
    http = urllib3.PoolManager(num_pools=3)

    global apiEndpoint
    
    if (not apiEndpoint):
        apiEndpoint = get_api_endpoint(stackName)

    # Testing getting all todos
    response = http.request('GET', apiEndpoint)

    assert response.status == 200


def test_add_todo():
    http = urllib3.PoolManager(num_pools=3)

    global random_title
    random_title = "Integration Testing {}".format(uuid4().hex)
    
    todo = json.dumps({"title": random_title})

    response = http.request('POST', apiEndpoint, 
        headers={'Content-Type': 'application/json'},
        body=todo
    )

    assert response.status == 201


def test_get_todo():
    http = urllib3.PoolManager(num_pools=3)
    
    response = http.request('GET', apiEndpoint)

    response = json.loads(response.data.decode('utf-8'))

    test_item = next(item for item in response if item['title'] == random_title)

    global test_id
    test_id = test_item['id']
    
    response = http.request('GET', apiEndpoint + '/{}'.format(test_id))

    assert response.status == 200

def test_update_todo():
    http = urllib3.PoolManager(num_pools=3)

    todo = json.dumps({"completed": "True"})
    
    response = http.request('PUT', apiEndpoint + '/{}'.format(test_id),
        headers={'Content-Type': 'application/json'},
        body=todo   
    )

    response = json.loads(response.data.decode('utf-8'))

    assert response['completed'] == 'True'


def test_delete_todo():
    http = urllib3.PoolManager(num_pools=3)
    
    response = http.request('DELETE', apiEndpoint + '/{}'.format(test_id))

    assert response.status == 200


def get_api_endpoint(stackName):
    cloudFormationClient = boto3.client('cloudformation')
    stack = cloudFormationClient.describe_stacks(StackName=stackName)

    stack = stack['Stacks'][0]

    apiEndpoint = next(item for item in stack['Outputs'] if item['OutputKey'] == 'ApiEndpoint')

    apiEndpoint = apiEndpoint['OutputValue'] + '/api'

    return apiEndpoint + '/todos'
