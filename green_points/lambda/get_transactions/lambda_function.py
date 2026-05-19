import json
import boto3
from boto3.dynamodb.conditions import Key, Attr
from decimal import Decimal

dynamodb = boto3.resource('dynamodb', region_name='ap-southeast-2')
transactions_table = dynamodb.Table('carboneye_transactions')

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        return super(DecimalEncoder, self).default(obj)

def lambda_handler(event, context):
    try:
        email = event.get('queryStringParameters', {}).get('email')

        if not email:
            return {
                'statusCode': 400,
                'headers': {'Access-Control-Allow-Origin': '*'},
                'body': json.dumps({'error': 'email is required'})
            }

        # Scan transactions for this email
        response = transactions_table.scan(
            FilterExpression=Attr('email').eq(email)
        )

        transactions = response.get('Items', [])

        # Sort by timestamp descending (newest first)
        transactions.sort(key=lambda x: x.get('timestamp', ''), reverse=True)

        return {
            'statusCode': 200,
            'headers': {'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({
                'transactions': transactions,
                'count': len(transactions)
            }, cls=DecimalEncoder)
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({'error': str(e)})
        }