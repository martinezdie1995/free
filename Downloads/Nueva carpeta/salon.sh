#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"

SERVICE_LIST=$($PSQL "SELECT service_id || ') ' || name FROM services ORDER BY service_id")

echo "$SERVICE_LIST"

read SERVICE_ID_SELECTED

while [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] ||
      [[ -z $($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED") ]]
do
  echo -e "\nI could not find that service. What would you like today?\n"
  echo "$SERVICE_LIST"
  read SERVICE_ID_SELECTED
done

SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

# PHONE
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

while [[ -z "${CUSTOMER_PHONE//[[:space:]]/}" ]]
do
  echo -e "\nPlease enter a valid phone number."
  read CUSTOMER_PHONE
done

# CUSTOMER
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_NAME ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME

  while [[ -z "${CUSTOMER_NAME//[[:space:]]/}" ]]
  do
    echo -e "\nPlease enter your name."
    read CUSTOMER_NAME
  done

  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
fi

# CUSTOMER ID
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# APPOINTMENT TIME
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

while [[ -z "${SERVICE_TIME//[[:space:]]/}" ]]
do
  echo -e "\nPlease enter a valid time."
  read SERVICE_TIME
done

# INSERT APPOINTMENT
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
