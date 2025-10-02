FROM mariadb:10.11
#  editor de texto 'nano' para facilitar a edição manual de arquivos
RUN apt-get update && apt-get install -y nano && rm -rf /var/lib/apt/lists/*