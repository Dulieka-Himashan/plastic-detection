import json
import boto3
import uuid
from datetime import datetime
from decimal import Decimal

dynamodb = boto3.resource('dynamodb', region_name='ap-southeast-2')
users_table = dynamodb.Table('carboneye_users')
transactions_table = dynamodb.Table('carboneye_transactions')

POINTS_PER_GRAM = 0.5

def lambda_handler(event, context):
    try:
        body = json.loads(event.get('body', '{}'))
        email = body.get('email')
        weight_grams = body.get('weight_grams')
        bin_id = body.get('bin_id', 'BIN_001')

        if not email or weight_grams is None:
            return {
                'statusCode': 400,
                'headers': {'Access-Control-Allow-Origin': '*'},
                'body': json.dumps({'error': 'email and weight_grams are required'})
            }

        # Check user exists
        user_response = users_table.get_item(Key={'email': email})
        if 'Item' not in user_response:
            return {
                'statusCode': 404,
                'headers': {'Access-Control-Allow-Origin': '*'},
                'body': json.dumps({'error': 'User not found'})
            }

        # Calculate points
        points_earned = int(float(weight_grams) * POINTS_PER_GRAM)

        # Save transaction
        transaction = {
            'transaction_id': str(uuid.uuid4()),
            'email': email,
            'weight_grams': Decimal(str(weight_grams)),
            'points_earned': points_earned,
            'bin_id': bin_id,
            'timestamp': datetime.utcnow().isoformat()
        }
        transactions_table.put_item(Item=transaction)

        # Update user total points
        users_table.update_item(
            Key={'email': email},
            UpdateExpression='SET total_points = total_points + :points',
            ExpressionAttributeValues={':points': points_earned}
        )

        # Get updated total
        updated_user = users_table.get_item(Key={'email': email})
        new_total = int(updated_user['Item']['total_points'])

        return {
            'statusCode': 200,
            'headers': {'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({
                'message': 'Points added successfully',
                'points_earned': points_earned,
                'total_points': new_total,
                'transaction_id': transaction['transaction_id']
            })
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({'error': str(e)})
        }