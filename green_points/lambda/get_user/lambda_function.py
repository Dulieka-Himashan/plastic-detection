import json
import boto3

dynamodb = boto3.resource('dynamodb', region_name='ap-southeast-2')
table = dynamodb.Table('carboneye_users')

def lambda_handler(event, context):
    try:
        email = event.get('queryStringParameters', {}).get('email')

        if not email:
            return {
                'statusCode': 400,
                'headers': {'Access-Control-Allow-Origin': '*'},
                'body': json.dumps({'error': 'email is required'})
            }

        response = table.get_item(Key={'email': email})

        if 'Item' not in response:
            return {
                'statusCode': 404,
                'headers': {'Access-Control-Allow-Origin': '*'},
                'body': json.dumps({'error': 'User not found'})
            }

        user = response['Item']
        # Convert Decimal to int for JSON serialization
        user['total_points'] = int(user.get('total_points', 0))

        return {
            'statusCode': 200,
            'headers': {'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({'user': user})
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({'error': str(e)})
        }