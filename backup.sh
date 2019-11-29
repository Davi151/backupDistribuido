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
           echo "Parâmetro Inválido..."
           exit 1
        fi

        getopts "c:d:t:" OPTVAR
        if [ "$OPTVAR" == "t" ]
        then
                tempo=$OPTARG
        else
                echo "Parâmetro Inválido..."
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
                echo "Parâmetro Inválido..."
                exit 1
        fi

        getopts "c:d:t:" OPTVAR
        if [ "$OPTVAR" == "t" ]
        then
                tempo=$OPTARG
        else
                echo "Parâmetro Inválido..."
                exit 1
        fi

        ;;

   "t") getopts "c:d:t:" OPTVAR
        if [ "$OPTVAR" == "t" ]
        then
                tempo=$OPTARG
        else
                echo "Parâmetro Inválido..."
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

      comm -1 -3 /tmp/old.txt /tmp/new.txt >> N.log

      arquivo=`awk '{print $2}' N.log`
      rm N.log

      for i in `sed 's/ /:/g' $arquivoConfig`
      do
         ip=`echo $i | cut -f1 -d":"`
         user=`echo $i | cut -f2 -d":"`
         chave=`echo $i | cut -f3 -d":"`
         diretorioDestino=`echo $i | cut -f4 -d":"`


         echo "Enviando para $user"
         scp -r -i $chave $arquivo $user@$ip:$diretorioDestino
         echo

         Hora=`date +[%d-%m-%Y" "%H:%M:%S]`
         echo $Hora "Adicionados: " `comm -1 -3 /tmp/old.txt /tmp/new.txt` >> dirSensors.log
      done
   fi


   if [ $qtdAtu -lt $qtdAnt ] || [ $qtdAtu -eq $qtdAnt ]
   then

      comm -2 -3 /tmp/old.txt /tmp/new.txt >> N.log

      arquivo=`awk -F"/" '{print $2}' N.log`
      rm N.log

      if [ -n "$arquivo" ]
      then

      for i in `sed 's/ /:/g' $arquivoConfig`
      do
         ip=`echo $i | cut -f1 -d":"`
         user=`echo $i | cut -f2 -d":"`
         chave=`echo $i | cut -f3 -d":"`
         diretorioDestino=`echo $i | cut -f4 -d":"`


         ssh -i $chave $user@$ip "cd $diretorioDestino ; rm "$arquivo""

         Hora=`date +[%d-%m-%Y" "%H:%M:%S]`
         echo $Hora "Removidos: " `comm -1 -3 /tmp/old.txt /tmp/new.txt` >> dirSensors.log
      done
      fi
   fi


   if [ $qtdAtu -eq $qtdAnt ]
   then

      comm -1 -3 /tmp/old.txt /tmp/new.txt >> N.log

      arquivo=`awk '{print $2}' N.log`
      rm N.log

      if [ -n "$arquivo" ]
         then

         for i in `sed 's/ /:/g' $arquivoConfig`
         do
            ip=`echo $i | cut -f1 -d":"`
            user=`echo $i | cut -f2 -d":"`
            chave=`echo $i | cut -f3 -d":"`
            diretorioDestino=`echo $i | cut -f4 -d":"`

            echo "Arquivos Modificados em $user"
            scp -r -i $chave $arquivo $user@$ip:$diretorioDestino
            echo

            Hora=`date +[%d-%m-%Y" "%H:%M:%S]`
            echo $Hora "Modificados: " `comm -1 -3 /tmp/old.txt /tmp/new.txt` >> dirSensors.log
         done
      fi
   fi
done
