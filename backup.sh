#!/bin/bash

#diretorioDestino=$4

rm /tmp/old.txt /tmp/new.txt 2>/dev/null

getopts "c:d:t:" OPTVAR
case "$OPTVAR" in
   "c") arquivoConfig=$OPTARG
        getopts "c:d:t:" OPTVAR
        if [ "$OPTVAR" == "d" ]
        then
           diretorioMonitorado=$OPTARG
        else
           echo "Está errado, babaca..."
           exit 1
        fi

        getopts "c:d:t:" OPTVAR
        if [ "$OPTVAR" == "t" ]
        then
                tempo=$OPTARG
        else
                echo "Está errado, babaca..."
                exit 1
        fi
        ;;


   "d") getopts "c:d:t:" OPTVAR
        diretorioMonitorado=$OPTARG
        getopts "c:d:t:" OPTVAR
        if [ "$OPTVAR" == "c" ]
        then
            arquivoConfig=$OPTARG
        else
                echo "Está errado, babaca ..."
                exit 1
        fi

        getopts "c:d:t:" OPTVAR
        if [ "$OPTVAR" == "t" ]
        then
                tempo=$OPTARG
        else
                echo "Está errado, babaca..."
                exit 1
        fi

        ;;

   "t") getopts "c:d:t:" OPTVAR
        if [ "$OPTVAR" == "t" ]
        then
                tempo=$OPTARG
        else
                echo "Está errado, babaca..."
                exit 1
        fi
        ;;
   "*") echo "Coloque opções válidas."
        exit 1
        ;;
esac


while true
do

   find $diretorioMonitorado -type f -exec md5sum {} \; | sort > /tmp/old.txt
   sleep $tempo
   find $diretorioMonitorado -type f -exec md5sum {} \; | sort > /tmp/new.txt


   qtdAnt=`cat /tmp/old.txt | wc -l`
   qtdAtu=`cat /tmp/new.txt | wc -l`



   if [ $qtdAtu -gt $qtdAnt ]
   then
      Hora=`date +[%d-%m-%Y" "%H:%M:%S]`
      echo $Hora "Adicionados: " `comm -1 -3 /tmp/old.txt /tmp/new.txt` >> dirSensors.log
      comm -1 -3 /tmp/old.txt /tmp/new.txt >> N.log

      arquivo=`awk '{print $2}' N.log`
      rm N.log


      ip=`cat $arquivoConfig | cut -f1 -d" "`
      user=`cat $arquivoConfig | cut -f2 -d" "`
      chave=`cat $arquivoConfig | cut -f3 -d" "`
      diretorioDestino=`cat $arquivoConfig | cut -f4 -d" "`

      scp -r -i $chave $arquivo $user@$ip:$diretorioDestino

      cp $arquivo $diretorioDestino

   fi


   if [ $qtdAtu -lt $qtdAnt ] || [ $qtdAtu -eq $qtdAnt ]
   then
      Hora=`date +[%d-%m-%Y" "%H:%M:%S]`
      echo $Hora "Removidos: "`comm -2 -3 /tmp/old.txt /tmp/new.txt` >> dirSensors.log
      comm -2 -3 /tmp/old.txt /tmp/new.txt >> N.log

#     arquivo=`awk -F"/" '{print $2}' N.log`
      for i in `cat N.log | cut -d'/' -f2`
      do
         rm "$diretorioDestino/$i" 2> /dev/null
      done
      rm N.log
   fi


   if [ $qtdAtu -eq $qtdAnt ]
   then

      Hora=`date +[%d-%m-%Y" "%H:%M:%S]`
      echo $Hora "Modificados: " `comm -1 -3 /tmp/old.txt /tmp/new.txt` >> dirSensors.log
      comm -1 -3 /tmp/old.txt /tmp/new.txt >> N.log

      arquivo=`awk '{print $2}' N.log`
      rm N.log
      cp $arquivo $diretorioDestino 2>/dev/null

   fi

done
