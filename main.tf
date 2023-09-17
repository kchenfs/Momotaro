resource "aws_dynamodb_table" "momotaro_sushi_db" {
  name         = "MomotaroSushi_DB"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "OrderID"

  attribute {
    name = "OrderID"
    type = "S"
  }
}

resource "aws_dynamodb_table" "momotaro_sushi_menu_db" {
  name         = "MomotaroSushiMenu_DB"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ItemName"

  attribute {
    name = "ItemName"
    type = "S"
  }
}

resource "aws_pinpoint_app" "MomotaroPinpoint" {
  name = "MomotaroPinpoint"
  tags = {
    Environment = "Production"
  }
}


resource "aws_sns_topic" "my_topic" {
  name = "MomotaroSNS"
}

resource "aws_ses_email_identity" "sender" {
  email = "kencfs@outlook.com"
}

resource "aws_ses_email_identity" "receiver" {
  email = "kendxd@gmail.com"
}



resource "aws_api_gateway_rest_api" "momotaro_api" {
  name = "MomotaroAPI"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Create a stage for your REST API
resource "aws_api_gateway_stage" "momotaro_stage" {
  deployment_id = aws_api_gateway_deployment.momotaro_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.momotaro_api.id
  stage_name    = "test" # Same as the stage_name in the deployment
 
}



# Create a deployment for your REST API
resource "aws_api_gateway_deployment" "momotaro_deployment" {
  rest_api_id = aws_api_gateway_rest_api.momotaro_api.id

  triggers = {
    get_item_price_integration = "Triggered by get_item_price_integration",
    get_menu_items_integration = "Triggered by get_menu_items_integration",
    save_customer_info_integration = "Triggered by save_customer_info_integration",
  }

  lifecycle {
    create_before_destroy = true
  }
}



resource "aws_api_gateway_resource" "momotaro" {
  parent_id   = aws_api_gateway_rest_api.momotaro_api.root_resource_id
  path_part   = "Momotaro"
  rest_api_id = aws_api_gateway_rest_api.momotaro_api.id
}


resource "aws_api_gateway_resource" "get_item_price" {
  parent_id   = aws_api_gateway_resource.momotaro.id
  path_part   = "GetItemPrice"
  rest_api_id = aws_api_gateway_rest_api.momotaro_api.id
}

resource "aws_api_gateway_method" "get_item_price_method" {
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.get_item_price.id
  rest_api_id   = aws_api_gateway_rest_api.momotaro_api.id
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_item_price_integration" {
  http_method             = aws_api_gateway_method.get_item_price_method.http_method
  resource_id             = aws_api_gateway_resource.get_item_price.id
  rest_api_id             = aws_api_gateway_rest_api.momotaro_api.id
  type                    = "AWS"
  integration_http_method = "POST" # The HTTP method used to invoke the AWS service
  uri                     = "arn:aws:apigateway:ca-central-1:dynamodb:action/GetItem"
  credentials             = "arn:aws:iam::798965869505:role/MomotaroAPIGateway"

  # Request Templates for Mapping
  request_templates = {
    # Define your custom template
    "application/json" = <<EOF
   {
  #set($item_name = $input.path('$.item_name'))
  "TableName": "MomotaroSushiMenu_DB",
  "Key": {
    "ItemName": {
      "S": "$item_name"
    }
  },
  "ProjectionExpression": "price"
}

    EOF
  }

  # Request Parameters for Mapping
  request_parameters = {
    "integration.request.header.Content-Type" = "'application/json'"
  }

  passthrough_behavior = "WHEN_NO_TEMPLATES"
}


resource "aws_api_gateway_method_response" "get_item_price_method_response" {
  rest_api_id = aws_api_gateway_rest_api.momotaro_api.id
  resource_id = aws_api_gateway_resource.get_item_price.id
  http_method = aws_api_gateway_method.get_item_price_method.http_method
  status_code = "200" # You can specify other status codes as needed
}

resource "aws_api_gateway_integration_response" "get_item_price_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.momotaro_api.id
  resource_id = aws_api_gateway_resource.get_item_price.id
  http_method = aws_api_gateway_method.get_item_price_method.http_method
  status_code = aws_api_gateway_method_response.get_item_price_method_response.status_code

  response_templates = {
    "application/json" = <<EOF
{
  #set($item = $input.path('$.Item'))
  "price": $item.price.N
}
EOF
  }
}

# Method settings for GetItemPrice method
resource "aws_api_gateway_method_settings" "get_item_price_settings" {
  rest_api_id = aws_api_gateway_rest_api.momotaro_api.id
  stage_name  = aws_api_gateway_stage.momotaro_stage.stage_name
  method_path = "*/*" # Corrected method path

  settings {
    logging_level      = "INFO"
    data_trace_enabled = true
    metrics_enabled    = true
  }
}



resource "aws_api_gateway_resource" "get_menu_items" {
  parent_id   = aws_api_gateway_resource.momotaro.id
  path_part   = "GetMenuItems"
  rest_api_id = aws_api_gateway_rest_api.momotaro_api.id
}

resource "aws_api_gateway_method" "get_menu_items_method" {
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.get_menu_items.id
  rest_api_id   = aws_api_gateway_rest_api.momotaro_api.id
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_menu_items_integration" {
  http_method             = aws_api_gateway_method.get_menu_items_method.http_method
  resource_id             = aws_api_gateway_resource.get_menu_items.id
  rest_api_id             = aws_api_gateway_rest_api.momotaro_api.id
  type                    = "AWS"
  integration_http_method = "POST" # The HTTP method used to invoke the AWS service
  uri                     = "arn:aws:apigateway:ca-central-1:dynamodb:action/Scan"
  credentials             = "arn:aws:iam::798965869505:role/MomotaroAPIGateway"

  # Request Templates for Mapping
  request_templates = {
    # Define your custom template
    "application/json" = <<EOF
    {
      #set(\$inputRoot = \$input.path('\$'))
      "TableName": "MomotaroSushiMenu_DB",
      "ProjectionExpression": "ItemName"
    }
    EOF
  }

  # Request Parameters for Mapping
  request_parameters = {
    "integration.request.header.Content-Type" = "'application/json'"
  }

  passthrough_behavior = "WHEN_NO_TEMPLATES"
}


resource "aws_api_gateway_method_response" "get_menu_items_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.momotaro_api.id
  resource_id = aws_api_gateway_resource.get_menu_items.id
  http_method = aws_api_gateway_method.get_menu_items_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "get_menu_items_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.momotaro_api.id
  resource_id = aws_api_gateway_resource.get_menu_items.id
  http_method = aws_api_gateway_method.get_menu_items_method.http_method
  status_code = aws_api_gateway_method_response.get_menu_items_integration_response.status_code

  response_templates = {
    "application/json" = <<EOF
{
  #set($items = $input.path('$.Items'))
  "items": [
    #foreach($item in $items)
    "$item.ItemName.S"
    #if($foreach.hasNext),#end
    #end
  ]
}
EOF
  }
}


# Method settings for GetMenuItems method
resource "aws_api_gateway_method_settings" "get_menu_items_settings" {
  rest_api_id = aws_api_gateway_rest_api.momotaro_api.id
  stage_name  = aws_api_gateway_stage.momotaro_stage.stage_name
  method_path = "*/*" # Corrected method path

  settings {
    logging_level      = "INFO"
    data_trace_enabled = true
    metrics_enabled    = true
  }
}

resource "aws_api_gateway_resource" "save_customer_info" {
  parent_id   = aws_api_gateway_resource.momotaro.id
  path_part   = "SaveCustomerInfo"
  rest_api_id = aws_api_gateway_rest_api.momotaro_api.id
}

resource "aws_api_gateway_method" "save_customer_info_method" {
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.save_customer_info.id
  rest_api_id   = aws_api_gateway_rest_api.momotaro_api.id
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "save_customer_info_integration" {
  http_method             = aws_api_gateway_method.save_customer_info_method.http_method
  resource_id             = aws_api_gateway_resource.save_customer_info.id
  rest_api_id             = aws_api_gateway_rest_api.momotaro_api.id
  type                    = "AWS"
  integration_http_method = "POST" # The HTTP method used to invoke the AWS service
  uri                     = "arn:aws:apigateway:ca-central-1:dynamodb:action/PutItem"
  credentials             = "arn:aws:iam::798965869505:role/MomotaroAPIGateway"

  # Request Templates for Mapping
  request_templates = {
    # Define your custom template
    "application/json" = <<EOF
    {
      #set(\$inputRoot = \$input.path('\$'))
      "TableName": "MomotaroSushi_DB",
      "Item": {
        "OrderID": {
          "S": "\$inputRoot.order_id"
        },
        "CustomerName": {
          "S": "\$inputRoot.name"
        },
        "CustomerOrder": {
          "S": "\$inputRoot.ordered_items"
        },
        "PhoneNumber": {
          "S": "\$inputRoot.phone_number"
        },
        "PickUpTime": {
          "S": "\$inputRoot.pickup_time"
        },
        "TotalPrice": {
          "S": "\$inputRoot.total_price_with_tax"
        }
      }
    }
    EOF
  }

  # Request Parameters for Mapping
  request_parameters = {
    "integration.request.header.Content-Type" = "'application/json'"
  }

  passthrough_behavior = "WHEN_NO_TEMPLATES"
}


resource "aws_api_gateway_method_response" "save_customer_info_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.momotaro_api.id
  resource_id = aws_api_gateway_resource.save_customer_info.id
  http_method = aws_api_gateway_method.save_customer_info_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "save_customer_info_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.momotaro_api.id
  resource_id = aws_api_gateway_resource.save_customer_info.id
  http_method = aws_api_gateway_method.save_customer_info_method.http_method
  status_code = aws_api_gateway_method_response.save_customer_info_integration_response.status_code

  response_templates = {
    "application/json" = <<EOF
{
   #set($inputRoot = $input.path('$'))
$input.json('$')

}

EOF
  }
}

# Method settings for SaveCustomerInfo method
resource "aws_api_gateway_method_settings" "save_customer_info_settings" {
  rest_api_id = aws_api_gateway_rest_api.momotaro_api.id
  stage_name  = aws_api_gateway_stage.momotaro_stage.stage_name
  method_path = "*/*" # Corrected method path

  settings {
    logging_level      = "INFO"
    data_trace_enabled = true
    metrics_enabled    = true
  }
}



# Back end

resource "aws_s3_bucket" "state_bucket" {
  bucket = "momotaro-state-backend"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }
}

resource "aws_dynamodb_table" "state_lock_db" {
  name         = "Momotaro_State_Lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}



resource "aws_lambda_layer_version" "momotaro_layer" {
  layer_name         = "momotaro-layer"
  description        = "My Lambda Layer"
  compatible_runtimes = ["python3.11"]

  s3_bucket = "momotaropackage"  # Replace with your S3 bucket name
  s3_key    = "python.zip"  # Set the key to the filename "python.zip"
}

