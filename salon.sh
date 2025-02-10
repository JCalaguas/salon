#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo "Welcome to My Salon, how can I help you?"

# Display services
SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME; do
  echo "$SERVICE_ID) $SERVICE_NAME"
done

# Read user selection
read SERVICE_ID_SELECTED

SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")

# If service doesn't exist, repeat the prompt
while [[ -z $SERVICE_NAME ]]; do
  echo -e "\nI could not find that service. What would you like today?"
  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME; do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
done

# Get customer details
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_DATA=$($PSQL "SELECT customer_id, name FROM customers WHERE phone='$CUSTOMER_PHONE';")

if [[ -z $CUSTOMER_DATA ]]; then
  echo "I don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  $PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');"
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
else
  CUSTOMER_ID=$(echo $CUSTOMER_DATA | cut -d '|' -f1)
  CUSTOMER_NAME=$(echo $CUSTOMER_DATA | cut -d '|' -f2)
fi

# Get appointment time
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

# Insert appointment
$PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"

echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
