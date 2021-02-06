#/bin/bash

ip='127.0.0.1'

function check_info(){
  echo -e "[i] Mostrant els usuaris que es crearan... "

  find ./conf -type f -print -exec cat {} \; 
}

function main(){
  check_info
}

main
 
