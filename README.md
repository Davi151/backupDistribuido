# backupDistribuido
Script backup distribuido - programação de script

Nesse script, é realizado um backup distribuido.

  Aqui usa-se nos parâmetros do script a tag ("-c", "-d", "-t"), sendo "-c" o arquivo de configuração para onde será destiinado os arquivos do backup, contendo o ip, usuário, chave de acesso,e destino do local do backup remoto. "-d" é o diretório que será executado a verificação se houve acréscimo de arquivos ou exclusão, e modificação dos mesmos. "-t" é o tempo em segundos que o script verifica o diretório.

A execução do script funciona da seguinte forma:


Inicialmente, realiza a seguinte estrutura:

./backup.sh -c <arquivo de configuração> -d <diretorio a ser monitorado> -t <intervalo de monitoração>
  
  O script realizará uma distribuição de arquivos do <diretorio monitorado> para as máquinas especificadas no <arquivo de configuração>, para que tudo ocorra funcionalmente as máquinas de destino devem ter o serviço ssh previamente instalado e habilitado com acesso de conexão via chave de autenticação
  
  Iniciado o tempo de monitoração do diretorio, o script verifica se houve o acréscimo de arquivos no diretorio ou a diminuição, com isso, ele acessa via ssh as máquinas alvos setadas no <arquivo de configuração> e envia os arquivos ou os remove.
  
  De forma "prematura e comparacional", a idéia do script é basicamente poder ter um sistema parecido com o do comando "rsync", em que pode-se realizar backups distribuidos automáticos e "inteligentes" de forma rápida e funcional.
