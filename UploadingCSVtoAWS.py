import pandas as pd
import boto3
import numpy as np

dynamodb = boto3.client('dynamodb')
table_name = 'MomotaroSushiMenu_DB'  # Replace with your actual table name
file_path = r'C:\Users\Ken\Desktop\Momotaro\MomotaroSushi_MENU.xlsx'  # Replace with the path to your Excel file

# Read the Excel file into a pandas DataFrame
df = pd.read_excel(file_path)

# Convert all values to lowercase
df = df.apply(lambda x: x.astype(str).str.lower())

# Replace NaN values in 'Price' and 'ItemNumber' columns with 0
df['Price'].replace('nan', 0, inplace=True)
df['ItemNumber'].replace('nan', 0, inplace=True)

# Iterate over the rows in the DataFrame and insert into DynamoDB
# ...

# Iterate over the rows in the DataFrame and insert into DynamoDB
for _, row in df.iterrows():
    item_name = str(row['Name'])
    
    # Check if the item already exists in the DynamoDB table based on the primary key 'ItemName'
    existing_item = dynamodb.get_item(TableName=table_name, Key={'ItemName': {'S': item_name}})
    
    if 'Item' not in existing_item:
        # Item does not exist, so insert it into the DynamoDB table
        
        # Convert 'Price' and 'ItemNumber' values to numeric
        item_price = float(row['Price'])  # Convert to float
        item_number = float(row['ItemNumber'])  # Convert to float
        
        response = dynamodb.put_item(
            TableName=table_name,
            Item={
                'ItemName': {'S': item_name},  # Primary key attribute
                'category': {'S': str(row['Category'])},
                'price': {'N': str(item_price)},
                'ItemNumber': {'N': str(item_number)}
            }
        )
        print(f"Added menu item: {item_name}")
    else:
        # Item already exists, skip inserting and print a message
        print(f"Skipping duplicate menu item: {item_name}")

# ...
