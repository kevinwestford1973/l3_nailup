#!/bin/bash

# any custom setup networking or otherwise

source functions.sh
source nailedup.conf


set -x
USAGE="custom_setup"

echo "number of args given $#"

if [ $# -eq 0 ];
then
  echo $USAGE
  exit 1 
fi

###
##   write your own code if you wish 
##

printf "\nDONE  custom setup \n"
