import json
import boto3
import uuid
from datetime import datetime
from decimal import Decimal

dynamodb = boto3.resource('dynamodb', region_name='ap-southeast-2')
users_table = dynamodb.Table('carboneye_users')
redemptions_table = dynamodb.Table('carboneye_redemptions')

VOUCHERS = {
    'nsbm_gift_shop': {'name': 'NSBM Gift Shop', 'points_required': 500, 'value': 100},
    'ps': {'name': 'P&S', 'points_required': 1000, 'value': 200},
    'finagle': {'name': 'Finagle', 'points_required': 750, 'value': 150},
}

def lambda_handler(event, context):
    try:
        body = json.loads(event.get('body', '{}'))
        email = body.get('email')
        voucher_type = body.get('voucher_type')

        if not email or not voucher_type:
            return {
                'statusCode': 400,
                'headers': {'Access-Control-Allow-Origin': '*'},
                'body': json.dumps({'error': 'email and voucher_type are required'})
            }

        if voucher_type not in VOUCHERS:
            return {
                'statusCode': 400,
                'headers': {'Access-Control-Allow-Origin': '*'},
                'body': json.dumps({'error': 'Invalid voucher type', 'valid_types': list(VOUCHERS.keys())})
            }

        # Get user
        user_response = users_table.get_item(Key={'email': email})
        if 'Item' not in user_response:
            return {
                'statusCode': 404,
                'headers': {'Access-Control-Allow-Origin': '*'},
                'body': json.dumps({'error': 'User not found'})
            }

        user = user_response['Item']
        current_points = int(user.get('total_points', 0))
        voucher = VOUCHERS[voucher_type]
        points_required = voucher['points_required']

        # Check sufficient points
        if current_points < points_required:
            return {
                'statusCode': 400,
                'headers': {'Access-Control-Allow-Origin': '*'},
                'body': json.dumps({
                    'error': 'Insufficient points',
                    'current_points': current_points,
                    'points_required': points_required
                })
            }

        # Generate voucher code
        voucher_code = str(uuid.uuid4()).upper()[:12].replace('-', '')

        # Save redemption
        redemption = {
            'redemption_id': str(uuid.uuid4()),
            'email': email,
            'voucher_type': voucher_type,
            'voucher_name': voucher['name'],
            'voucher_code': voucher_code,
            'points_spent': points_required,
            'value': voucher['value'],
            'redeemed_at': datetime.utcnow().isoformat(),
            'status': 'active'
        }
        redemptions_table.put_item(Item=redemption)

        # Deduct points from user
        users_table.update_item(
            Key={'email': email},
            UpdateExpression='SET total_points = total_points - :points',
            ExpressionAttributeValues={':points': points_required}
        )

        new_total = current_points - points_required

        return {
            'statusCode': 200,
            'headers': {'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({
                'message': 'Redemption successful',
                'voucher_code': voucher_code,
                'voucher_name': voucher['name'],
                'value': voucher['value'],
                'points_spent': points_required,
                'remaining_points': new_total
            })
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({'error': str(e)})
        }