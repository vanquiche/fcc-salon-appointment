#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
# echo $($PSQL "TRUNCATE TABLE")
SERVICE_MENU() {
  if [[ $1 ]]
    then
    echo -e "\n $1"
  fi

  SERVICE_RESULT="$($PSQL "SELECT * FROM services")"
  echo -e "\nSelect a service\n"
  echo "$SERVICE_RESULT" | while read SERVICE_ID BAR SERVICE_NAME
    do
      echo "$SERVICE_ID) $SERVICE_NAME"
    done
  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ [1-3] ]] 
    then 
      SERVICE_MENU "Invalid selection."
    else
      SELECTED_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      BOOK_APPOINTMENT $SERVICE_ID_SELECTED $SELECTED_SERVICE_NAME
  fi
}

BOOK_APPOINTMENT() {
  echo -e "Please enter your phone number.\n"
  read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_ID ]] 
    then
      echo -e "\nPlease enter your first name\n"
      read CUSTOMER_NAME
      echo -e "\nWhat time would you like to request\n"
      read SERVICE_TIME
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
        if [[ $INSERT_CUSTOMER_RESULT == 'INSERT 0 1' ]] 
          then
          echo -e "\nCreated your account successfully."
          else
          echo -e "\nCould not create your account."
        fi
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      # echo "ID is $CUSTOMER_PHONE"
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (time, customer_id, service_id) VALUES ('$SERVICE_TIME', $CUSTOMER_ID, $1)")
        if [[ $INSERT_APPOINTMENT_RESULT == 'INSERT 0 1'  ]]
          then 
          echo -e "\nI have put you down for a $2 at $SERVICE_TIME, $CUSTOMER_NAME.\n"
          else 
          echo -e "\nCould not book your appointment. Please Try again.\n"
        fi
    else
      echo -e "\nWhat time would you like to request\n"
      read SERVICE_TIME
      CUSTOMER_INFO=$($PSQL "SELECT customer_id, name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      echo "$CUSTOMER_INFO" | while read CUSTOMER_ID BAR CUSTOMER_NAME
        do

      # CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (time, customer_id, service_id) VALUES ('$SERVICE_TIME', $CUSTOMER_ID, $1)")
        if [[ $INSERT_APPOINTMENT_RESULT == 'INSERT 0 1'  ]]
          then 
          echo -e "\nI have put you down for a $2 at $SERVICE_TIME, $CUSTOMER_NAME.\n"
          else 
          echo -e "\nCould not book your appointment. Please Try again.\n"
        fi
        done
  fi

}

SERVICE_MENU
