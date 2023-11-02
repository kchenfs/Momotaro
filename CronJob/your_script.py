import boto3
import datetime
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

# Connect to DynamoDB
dynamodb = boto3.resource('dynamodb', region_name='ca-central-1')
table = dynamodb.Table('MomotaroSushi_DB')  # Replace with your DynamoDB table name

# Calculate the date for the previous day
previous_day = datetime.date.today() - datetime.timedelta(days=1)

try:
    # Query DynamoDB for data relevant to the previous day
    response = table.scan(
        FilterExpression="OrderDate = :date",
        ExpressionAttributeValues={":date": previous_day.isoformat()}
    )

    # Calculate total revenue
    total_revenue = 0
    for item in response['Items']:
        # Process each item and calculate revenue
        revenue = item.get('TotalPrice', 0)  # Assuming the attribute name is "TotalPrice"
        total_revenue += revenue

    # Send email using AWS SES
    ses_client = boto3.client('ses', region_name='ca-central-1')

    sender_email = 'kencfs@outlook.com'
    recipient_email = 'kendxd@gmail.com'
    subject = f"Total Revenue Report for {previous_day}"

    message = MIMEMultipart()
    message['Subject'] = subject
    message['From'] = sender_email
    message['To'] = recipient_email

    body = f"Total Revenue for {previous_day}: ${total_revenue}"

    text_part = MIMEText(body, 'plain')
    message.attach(text_part)

    # Send the email
    response = ses_client.send_raw_email(
        Source=sender_email,
        Destinations=[recipient_email],
        RawMessage={'Data': message.as_string()}
    )
    print("Email sent successfully!")

except Exception as e:
    print(f"An error occurred: {str(e)}")
    # Handle the error here, e.g., log it or send a notification
