#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo "Welcome to My Salon, how can I help you?"


MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi  
 
  ALL_SERVICES=$($PSQL "SELECT * FROM services order by service_id;")

  if [[ $ALL_SERVICES ]]
  then
    echo "$ALL_SERVICES" | while read SERVICE_ID NAME
    do
      echo $SERVICE_ID $NAME | sed 's/ |/)/'
    done

  fi

  read SERVICE_ID_SELECTED
  SERVICE_ID_SELECTED=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")
  NAME_SERVICE=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")


  if [[ -z $SERVICE_ID_SELECTED ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')") 

                 

    fi
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    echo -e "\nWhat time would you like your$NAME_SERVICE, $CUSTOMER_NAME?"
    read SERVICE_TIME

    if [[ $SERVICE_TIME ]]
    then
      echo $CUSTOMER_ID, $SERVICE_ID_SELECTED
      INSERT_APPMT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
      echo -e "\nI have put you down for a$NAME_SERVICE at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/^ *| *$//g')."
    fi

  fi


}

MAIN_MENU