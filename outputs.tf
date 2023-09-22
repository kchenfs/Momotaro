output "get_item_info_url" {
  value = "${aws_api_gateway_deployment.momotaro_deployment.invoke_url}/Momotaro/GetItemPrice/GET"
}

output "get_menu_items_url" {
  value = "${aws_api_gateway_deployment.momotaro_deployment.invoke_url}/Momotaro/GetMenuItems/GET"
}

output "save_customer_info_url" {
  value = "${aws_api_gateway_deployment.momotaro_deployment.invoke_url}/Momotaro/SaveCustomerInfo/POST"
}


output "sns_topic_id" {
  value = aws_sns_topic.my_topic.id
}