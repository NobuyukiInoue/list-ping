#!/bin/bash

CheckOS() {
  if [ "$(uname)" == 'Darwin' ]; then
    echo 'Mac'
  elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
    echo 'Linux'
  elif [ "$(expr substr $(uname -s) 1 10)" == 'MINGW32_NT' ]; then
    echo 'Cygwin'
  else
    if [ $OSTYPE == 'cygwin' ]; then
      echo 'cygwin'
    else
      # echo "Your platform ($(uname -a)) is not supported."
      echo ''
    fi
  fi
}

##-------------------------##
## Main
##-------------------------##

if [ $# = 0 ]; then
  echo "USAGE : list-ping.sh targetfile [ping count]"
  exit

elif [ $# = 1 ]; then
  REPEATCOUNT=3

#elif [ ! -s $2 ]; then
elif [ $# = 2 ]; then
  PARAM_1=$2
  expr $PARAM_1 + 1 > /dev/null 2>&1
  RET=$?

  if [ $RET = 0 ]; then
    REPEATCOUNT=$2
  else
    echo "USAGE : list-ping.sh targetfile [ping count]"
    exit
  fi

fi

# OS=`./CheckOS.sh`
OS=`CheckOS`

if [ $OS = "Mac" ]; then
  MAX=`wc -l $1 | cut -d " " -f 8`
elif [ $OS = "Linux" ]; then
  MAX=`wc -l $1 | cut -d " " -f 1`
else
  MAX=`wc -l $1 | cut -d " " -f 1`
fi

for ((i=1; i<=$MAX; i++)); do
  DST=`sed -n "${i}p" $1`
  # echo $DST

  if [ ! $DST = "" ]; then
    if [ $OS == "cygwin" ]; then
        ping $DST -n $REPEATCOUNT > "result${i}.txt" &
    else
        ping $DST -c $REPEATCOUNT > "result${i}.txt" &
    fi
  fi
done

sleep $REPEATCOUNT

while ((COUNT < MAX))
do
  COUNT=0
  for ((i=1; i<=$MAX; i++)); do
    if [ $OS == "cygwin" ];then
      CHECK_FIN=`grep '%' result$i.txt | wc -l | cut -d " " -f 8`
    else
      CHECK_FIN=`grep loss result$i.txt | wc -l | cut -d " " -f 8`
    fi

    COUNT=$(expr $COUNT + $CHECK_FIN)
  done
done

for ((i=1; i<=$MAX; i++)); do
  cat "result${i}.txt"
  rm -f "result${i}.txt"
done
