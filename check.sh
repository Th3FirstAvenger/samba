#/bin/bash

ip='127.0.0.1' # Modificar

function check_info(){
  echo -e "[i] Mostrant els usuaris que es crearan... "

  find ./conf -type f -print -exec cat {} \; 
}

## Agafa els primers usuaris de cada fitxer i fa la prova
function check_smb(){
  echo -e "[i] Usuaris que utilitzarem per fer les comprovacions..."
  find conf -type f -print -exec head -n1 {} \; | tee tmp.txt
  
  users=$(cat tmp.txt | grep ';')

  for user in ${users}; do 
    echo -e "[*] Comprovacio de permisos amb l'usuari $(echo "${user}" | cut -d ';' -f 1)..."
    echo -e "${user}"| awk -F';' '{print "username=" $1 "\npassword=" $2}' > tmp_$(echo "${user}" | cut -d ';' -f 1).txt ## Creem un fitxer temporal per guardar el usuari i la contrasenya
    u=$(echo "${user}" | cut -d ';' -f 1)
    smb_conn tmp_${u}.txt

    rm tmp_${u}.txt

  done

}

## Permet la conexió a samba i fer els checks 
function smb_conn(){
  filetxt=$1
  classe=$(cat tmp.txt | grep -v ';' | awk -F'/' '{print $FN}' | xargs )
  users=$(cat tmp.txt | grep ';'| awk -F ';' '{print $1}'| xargs)
  
  num=$(echo "${users}"| wc -l)
  for user in ${users}; do 
    echo -e "\n[*] Llistant els directoris de l'usuari ${user}..."
    echo -e "\t";smbclient \\\\${ip}\\${user} -A ${filetxt} -c 'recurse ON; ls *'
    
    echo -e "\n[*] check escriptura de l'usuari ${user}..."
    if [[ $(smbclient \\\\${ip}\\${user} -A ${filetxt} -c 'recurse ON; ls *'| grep 'Notas') ]]; then 
      smbclient \\\\${ip}\\${user} -A ${filetxt} -c 'recurse ON; cd Notas; put test.txt'
    else 
      smbclient \\\\${ip}\\${user} -A ${filetxt} -c 'recurse ON; cd Apunts; put test.txt'
    fi
    
    sleep 2
    
    if [[ $(smbclient \\\\${ip}\\${user} -A ${filetxt} -c 'recurse ON; ls *'| grep 'Notas') ]]; then 
      smbclient \\\\${ip}\\${user} -A ${filetxt} -c 'recurse ON; cd Notas; get baixada.txt'
    else 
      smbclient \\\\${ip}\\${user} -A ${filetxt} -c 'recurse ON; cd Apunts; put baixada.txt'
    fi
    sleep 2
    
  done
}

function main(){
  check_info
  echo -e "\n"
  sleep 2
  check_smb
  echo -e "\n"
  sleep 2

}

main
 
