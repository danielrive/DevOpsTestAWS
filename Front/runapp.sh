#!/bin/bash

#Get variables from AWS secret Manager and export like env system variables

limit="$(echo $secrets | jq length)"
x=0
while [ $x -ne $limit ]
do
  variable_name="$(echo $secrets | jq '. | keys' | jq ".[$x]" | sed -e "s/\"//g")"
  variable_value="$(echo $secrets | jq ".$variable_name" | sed -e "s/\"//g")"
  export "$variable_name"="$variable_value"
  x=$(( $x + 1 ))
done


/usr/src/frontBinary