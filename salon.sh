#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t -c"

# 显示欢迎信息
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo "Welcome to My Salon, how can I help you?\n"

# 显示服务列表函数
display_services() {
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
}

# 显示服务列表
display_services

# 获取服务ID
get_service_id() {
  read SERVICE_ID_SELECTED
  
  # 验证服务是否存在
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]
  then
    echo -e "\nI could not find that service. What would you like today?\n"
    display_services
    get_service_id
  fi
}

get_service_id

# 获取客户电话
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# 检查客户是否存在
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# 如果客户不存在，获取客户姓名
if [[ -z $CUSTOMER_ID ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  
  # 插入新客户
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
else
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
fi

# 获取预约时间
echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -e 's/^[ \t]*//'), $CUSTOMER_NAME?"
read SERVICE_TIME

# 插入预约记录
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

# 输出确认信息
echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -e 's/^[ \t]*//') at $SERVICE_TIME, $CUSTOMER_NAME."
