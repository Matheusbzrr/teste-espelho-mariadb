# PASSO A PASSO PARA ESSE TESTE (lembrando q o docker roda em ambiente linux e a gente vai trabalhar com windows)

- 1: rodar o docker compose 

- 2: docker exec -it mariadb-primary bash -- para entrar nos arquivos do banco 

- 3: nano /etc/mysql/conf.d/replication.cnf -- 
    aqui será dicionados as configurações. para maquina principal: 
    [mysqld]
    server_id=1
    log_bin=mysql-bin
    binlog_format=ROW

    Salvar nano: Pressione Ctrl + O, depois Enter
    Sair do nano: Ctrl + X
    Termine a conexão com o bash

- 4: docker-compose restart mariadb-primary -- resete a maquina

- 5: docker exec -it mariadb-replica bash -- para entrar nos arquivos do banco 

- 6: nano /etc/mysql/conf.d/replication.cnf -- processo parecido com o anterior, muda o conteudo adicionado.
    [mysqld]
    server_id=2

    Salvar nano: Pressione Ctrl + O, depois Enter
    Sair do nano: Ctrl + X
    Termine a conexão com o bash

- 7: docker-compose restart mariadb-replica

- 8: Crie o usuário de replicação no PRIMÁRIO. 
    docker exec -it mariadb-primary mariadb -u root -p
    CREATE USER 'replicador'@'%' IDENTIFIED BY 'outra_senha_forte'; 
    GRANT REPLICATION SLAVE ON *.* TO 'replicador'@'%';
    FLUSH PRIVILEGES;

- 9: Obtenha as coordenadas do primário.
    SHOW MASTER STATUS;

    Anote os valores das colunas File e Position.
     mysql-bin.000001 |      787 
 - 10: Conecte-se à réplica:
    docker exec -it mariadb-replica mariadb -u root -p

- 11: Configure a réplica para seguir o primário.
    CHANGE MASTER TO
    MASTER_HOST='<IP DA MAQUINA>', 
    MASTER_USER='replicador',
    MASTER_PASSWORD='outra_senha_forte',
    MASTER_LOG_FILE='mysql-bin.000001',
    MASTER_LOG_POS= 787;

- 12: Inicie o processo de replicação:
    START SLAVE;

- 13: Verifique se tudo funcionou:
    SHOW SLAVE STATUS\G

    Na saída do último comando, as duas linhas mais importantes são:
    Slave_IO_Running: Yes
    Slave_SQL_Running: Yes
    Se ambas estiverem como Yes, a replicação está ativa e funcionando perfeitamente

- 14: Como ambos os ambos já estão conectados e vazios o teste é: 
    1. No primário -- Cria banco: CREATE DATABASE IF NOT EXISTS teste_replicacao;
    2. No primário -- Conecta com o banco: USE teste_replicacao;
    3. No primário -- Cria uma tabela: CREATE TABLE clientes (id INT AUTO_INCREMENT PRIMARY KEY, nome VARCHAR(100));
    4. No primário -- Faz um insert: INSERT INTO clientes (nome) VALUES ('Cliente A'), ('Cliente B');
    5. saia do banco.

- 15: Pra finalizar, conecta o banco réplica.
    1. USE teste_replicacao;
    2. SELECT * FROM clientes;


NOTA 1: 
adicionar um arquivo base com as configuracoes no nano /etc/mysql/conf.d/replication.cnf são para instalações em Linux (e as imagens Docker baseadas nele) pois favorecem uma abordagem modular com o diretório conf.d. Isso permite que pacotes e usuários adicionem configurações sem arriscar quebrar o arquivo de configuração principal.



NOTA 2:

Primeiro passo pra realizar o serviço é ter um backup do estado atual para colocar na maquina secundaria. após isso inciiar.

Pra realizar no windows o processo de mudança para as configurações bases é diferente. nao cria algo modular mas sim edita diretamente no arquivo base.

Para achar o arquivo dando comandos no cmd
sc query state= all | findstr /I "maria"
sc qc nome-do-serviço
notepad "caminho-do-my.ini"

Abrir o Bloco de Notas como Administrador.
Ir em Arquivo > Abrir.
Navegar e abrir o arquivo my.ini do MariaDB.
Adicionar as suas diretivas de replicação (server_id, log_bin, etc.) dentro da seção [mysqld].
Salvar o arquivo.
Reiniciar o serviço do MariaDB para aplicar as alterações.

CONFIG MAQUINA PRINCIPAL: 
server_id=1
log_bin=mysql-bin
binlog_format=ROW

CONFIG MAQUINA SECUNDARIA:
server_id=2


Reiniciar o Serviço do MariaDB
achar serviço no services.msc