import json

def lambda_handler(event, context):
    message = 'Hello World!'
    print(message)

    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': message
        })
    }
