# get a random adjective-noun phrase using the same source files as random routes in CF
#    outputs the phrase

generate_passphrase () {
  words=$1
  counter=0
  delimiter="-"
  passphrase=""
  while [ $counter -lt $words ] ; do
    word="$(gshuf -n1 /usr/share/dict/words)"
    passphrase="${passphrase}${word}"
    let counter=counter+1
    if [ $counter -lt $words ] ; then
      passphrase="${passphrase}${delimiter}"
    fi
  done

  echo "${passphrase}" | tr '[:upper:]' '[:lower:]'
}
