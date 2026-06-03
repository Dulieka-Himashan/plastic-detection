import json
import boto3
from decimal import Decimal

dynamodb = boto3.resource('dynamodb', region_name='ap-southeast-2')
cards_table = dynamodb.Table('carboneye_cards')
users_table = dynamodb.Table('carboneye_users')

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return int(obj)
        return super(DecimalEncoder, self).default(obj)

def lambda_handler(event, context):
    try:
        card_uid = event.get('queryStringParameters', {}).get('card_uid')

        if not card_uid:
            return {
                'statusCode': 400,
                'headers': {'Access-Control-Allow-Origin': '*'},
                'body': json.dumps({'error': 'card_uid is required'})
            }

        # Look up card
        card_response = cards_table.get_item(Key={'card_uid': card_uid})
        if 'Item' not in card_response:
            return {
                'statusCode': 404,
                'headers': {'Access-Control-Allow-Origin': '*'},
                'body': json.dumps({'error': 'Card not registered'})
            }

        email = card_response['Item']['email']

        # Get user
        user_response = users_table.get_item(Key={'email': email})
        if 'Item' not in user_response:
            return {
                'statusCode': 404,
                'headers': {'Access-Control-Allow-Origin': '*'},
                'body': json.dumps({'error': 'User not found'})
            }

        user = user_response['Item']
        user['total_points'] = int(user.get('total_points', 0))

        return {
            'statusCode': 200,
            'headers': {'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({'user': user}, cls=DecimalEncoder)
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({'error': str(e)})
        }