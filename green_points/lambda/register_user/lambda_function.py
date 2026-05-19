import json
import boto3
from datetime import datetime
from decimal import Decimal

dynamodb = boto3.resource('dynamodb', region_name='ap-southeast-2')
table = dynamodb.Table('carboneye_users')

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return int(obj)
        return super(DecimalEncoder, self).default(obj)

def lambda_handler(event, context):
    try:
        body = json.loads(event.get('body', '{}'))
        email = body.get('email')
        name = body.get('name')
        student_id = body.get('student_id')
        faculty = body.get('faculty', '')
        degree = body.get('degree', '')

        if not email or not name or not student_id:
            return {
                'statusCode': 400,
                'headers': {'Access-Control-Allow-Origin': '*'},
                'body': json.dumps({'error': 'email, name and student_id are required'})
            }

        if not email.endswith('@students.nsbm.ac.lk') and not email.endswith('@gmail.com'):
            return {
                'statusCode': 403,
                'headers': {'Access-Control-Allow-Origin': '*'},
                'body': json.dumps({'error': 'Only NSBM student emails allowed'})
            }

        # Check if user already exists
        response = table.get_item(Key={'email': email})
        if 'Item' in response:
            return {
                'statusCode': 200,
                'headers': {'Access-Control-Allow-Origin': '*'},
                'body': json.dumps({'message': 'User already exists', 'user': response['Item']}, cls=DecimalEncoder)
            }

        # Create new user
        user = {
            'email': email,
            'name': name,
            'student_id': student_id,
            'faculty': faculty,
            'degree': degree,
            'total_points': 0,
            'card_uid': '',
            'created_at': datetime.utcnow().isoformat()
        }

        table.put_item(Item=user)

        return {
            'statusCode': 201,
            'headers': {'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({'message': 'User registered successfully', 'user': user}, cls=DecimalEncoder)
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({'error': str(e)})
        }