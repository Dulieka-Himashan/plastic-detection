import boto3

dynamodb = boto3.resource('dynamodb', region_name='ap-southeast-2')
cards_table = dynamodb.Table('carboneye_cards')
users_table = dynamodb.Table('carboneye_users')

# Card data
cards = [
    {'card_uid': 'F3:DC:2A:1C', 'name': 'Sanvidu Perera', 'email': 'tharukaperera0060@gmail.com', 'student_id': 'tharukaperera0060'},
    {'card_uid': 'A3:90:88:13', 'name': 'Uththama Jeerasinghe', 'email': 'uththamatharu@gmail.com', 'student_id': 'uththamatharu'},
    {'card_uid': '73:F1:9F:13', 'name': 'Azra Akmal', 'email': 'theazraakmal521@gmail.com', 'student_id': 'theazraakmal521'},
    {'card_uid': 'D3:34:7B:13', 'name': 'Yashodhi Withanage', 'email': 'yashodhiwithanage@gmail.com', 'student_id': 'yashodhiwithanage'},
    {'card_uid': '73:E9:9C:13', 'name': 'Shameesha Dilshan', 'email': 'shameeshadilshan123@gmail.com', 'student_id': 'shameeshadilshan123'},
    {'card_uid': '33:1C:80:13', 'name': 'Pramodi De Silva', 'email': 'desilvapramodi36@gmail.com', 'student_id': 'desilvapramodi36'},
    {'card_uid': 'B3:FC:7B:13', 'name': 'Kavithma Wadduwage', 'email': 'kavithmaisendi@gmail.com', 'student_id': 'kavithmaisendi'},
]

print("Loading cards into DynamoDB...")

for card in cards:
    # Add to carboneye_cards table
    cards_table.put_item(Item={
        'card_uid': card['card_uid'],
        'email': card['email'],
        'name': card['name'],
        'student_id': card['student_id']
    })
    print(f"✅ Card loaded: {card['card_uid']} → {card['name']}")

    # Register user in carboneye_users if not exists
    response = users_table.get_item(Key={'email': card['email']})
    if 'Item' not in response:
        users_table.put_item(Item={
            'email': card['email'],
            'name': card['name'],
            'student_id': card['student_id'],
            'faculty': 'Faculty of Computing',
            'degree': 'BSc (Honours) Software Engineering',
            'total_points': 0,
            'card_uid': card['card_uid'],
            'created_at': '2026-06-03T00:00:00'
        })
        print(f"   👤 User registered: {card['email']}")
    else:
        # Update card_uid for existing user
        users_table.update_item(
            Key={'email': card['email']},
            UpdateExpression='SET card_uid = :uid',
            ExpressionAttributeValues={':uid': card['card_uid']}
        )
        print(f"   🔄 User updated with card UID: {card['email']}")

print("\n✅ All cards loaded successfully!")