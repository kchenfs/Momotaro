output "get_item_info_url" {
  value = aws_api_gateway_deployment.momotaro_deployment.invoke_url
}

output "get_menu_items_url" {
  value = aws_api_gateway_deployment.momotaro_deployment.invoke_url
}

output "save_customer_info_url" {
  value = aws_api_gateway_deployment.momotaro_deployment.invoke_url
}
