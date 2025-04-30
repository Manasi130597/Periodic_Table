#!/bin/bash

# Define PSQL command
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Store the input argument
ELEMENT=$1

# Check if input is provided
if [[ -z $ELEMENT ]]; then
  echo "Please provide an element as an argument."
  exit
fi

# Initialize query variable
QUERY=""

# Determine which query to run based on the input
if [[ $ELEMENT =~ ^[0-9]+$ ]]; then
  # Search by atomic number
  QUERY="SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius 
         FROM elements e 
         JOIN properties p USING(atomic_number) 
         JOIN types t USING(type_id) 
         WHERE e.atomic_number = $ELEMENT"
else
  # Search by symbol or name
  QUERY="SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius 
         FROM elements e 
         JOIN properties p USING(atomic_number) 
         JOIN types t USING(type_id) 
         WHERE e.symbol = INITCAP('$ELEMENT') OR e.name = INITCAP('$ELEMENT')"
fi

# Run the query
RESULT=$($PSQL "$QUERY")

# If no result, print not found
if [[ -z $RESULT ]]; then
  echo "I could not find that element in the database."
  exit
fi

# Parse and display result
IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE ATOMIC_MASS MELTING_POINT_CELSIUS BOILING_POINT_CELSIUS <<< "$RESULT"
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."

