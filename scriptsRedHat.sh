#!/bin/bash

# SHELLSCRIPT DE COMANDOS BÁSICOS - RED HAT ENTERPRISE LINUX
# Autor: Bernardo
# Limpa a tela para melhor visualização
clear

# Exibe mensagem de início
echo "=================================================="
echo "    INICIANDO SCRIPT DE COMANDOS BÁSICOS RHEL    "
echo "=================================================="
echo ""

# COMANDOS DE NAVEGAÇÃO E INFORMAÇÃO DO SISTEMA

# Mostra o diretório atual
echo "1. Diretório atual (pwd):"
pwd
echo ""

# Lista arquivos do diretório atual com detalhes
echo "2. Listando arquivos do diretório atual (ls -la):"
ls -la
echo ""

# Mostra informações do sistema
echo "3. Informações do sistema (uname -a):"
uname -a
echo ""

# Mostra informações da distribuição
echo "4. Versão do Red Hat:"
cat /etc/redhat-release
echo ""

# Mostra o hostname do sistema
echo "5. Nome do host (hostname):"
hostname
echo ""

# Mostra usuário atual
echo "6. Usuário atual (whoami):"
whoami
echo ""

# Mostra usuários logados
echo "7. Usuários logados no sistema (who):"
who
echo ""

# Mostra data e hora
echo "8. Data e hora atual (date):"
date
echo ""

# Mostra calendário
echo "9. Calendário do mês atual (cal):"
cal
echo ""

# Mostra tempo de atividade do sistema
echo "10. Tempo de atividade do sistema (uptime):"
uptime
echo ""

# COMANDOS DE GERENCIAMENTO DE ARQUIVOS

# Cria um diretório de teste
echo "11. Criando diretório de teste (mkdir):"
mkdir -p /tmp/meu_diretorio_teste
echo "Diretório /tmp/meu_diretorio_teste criado"
echo ""

# Navega para o diretório de teste
echo "12. Navegando para o diretório de teste (cd):"
cd /tmp/meu_diretorio_teste
pwd
echo ""

# Cria arquivos de exemplo
echo "13. Criando arquivos de exemplo (touch):"
touch arquivo1.txt arquivo2.txt arquivo3.txt
echo "Arquivos criados:"
ls -la
echo ""

# Adiciona conteúdo aos arquivos
echo "14. Adicionando conteúdo aos arquivos (echo com redirecionamento):"
echo "Este é o conteúdo do arquivo 1" > arquivo1.txt
echo "Conteúdo do arquivo 2" > arquivo2.txt
echo "Arquivo 3 com texto" > arquivo3.txt
echo "Conteúdo adicionado"
echo ""

# Visualiza conteúdo de arquivo
echo "15. Visualizando conteúdo de arquivo (cat):"
cat arquivo1.txt
echo ""

# Copia arquivo
echo "16. Copiando arquivo (cp):"
cp arquivo1.txt copia_arquivo1.txt
echo "Arquivo copiado:"
ls -la copia_arquivo1.txt
echo ""

# Move/Renomeia arquivo
echo "17. Renomeando arquivo (mv):"
mv arquivo2.txt arquivo_renomeado.txt
echo "Arquivo renomeado:"
ls -la arquivo_renomeado.txt
echo ""

# Conta linhas, palavras e caracteres
echo "18. Contando linhas, palavras e caracteres (wc):"
wc arquivo1.txt
echo ""

# Mostra primeiras linhas
echo "19. Primeiras 2 linhas do arquivo (head):"
head -2 arquivo1.txt
echo ""

# Mostra últimas linhas
echo "20. Últimas 2 linhas do arquivo (tail):"
tail -2 arquivo1.txt
echo ""

# COMANDOS DE PERMISSÕES

# Mostra permissões dos arquivos
echo "21. Permissões dos arquivos:"
ls -l
echo ""

# Altera permissões de arquivo
echo "22. Alterando permissões do arquivo (chmod 644):"
chmod 644 arquivo1.txt
ls -l arquivo1.txt
echo ""

# COMANDOS DE PROCESSOS E SISTEMA

# Mostra processos do usuário
echo "23. Processos do usuário atual (ps):"
ps aux | head -5
echo ""

# Mostra processos de forma hierárquica
echo "24. Árvore de processos (pstree):"
pstree | head -5
echo ""

# Mostra uso de memória
echo "25. Uso de memória (free -h):"
free -h
echo ""

# Mostra uso de disco
echo "26. Uso de disco (df -h):"
df -h | head -5
echo ""

# Mostra diretórios com maior espaço
echo "27. Tamanho dos diretórios (du -sh):"
du -sh /tmp/* 2>/dev/null | head -5
echo ""

# COMANDOS DE REDE

# Mostra configuração de rede
echo "28. Configuração de rede (ip addr):"
ip addr show | head -10
echo ""

# Mostra tabela de roteamento
echo "29. Tabela de roteamento (ip route):"
ip route
echo ""

# Testa conectividade (ping - 3 pacotes)
echo "30. Testando conectividade (ping -c 3 google.com):"
ping -c 3 google.com
echo ""

# Mostra conexões de rede
echo "31. Conexões de rede (netstat ou ss):"
ss -tuln | head -5
echo ""

# GERENCIAMENTO DE PACOTES (RHEL)

# Verifica atualizações disponíveis (comentado pois precisa de root)
echo "32. Verificando atualizações (dnf check-update):"
echo "Nota: Seria executado 'dnf check-update' mas requer privilégios de root"
echo ""

# Lista pacotes instalados
echo "33. Listando pacotes instalados (rpm -qa | head):"
rpm -qa | head -5
echo ""

# GERENCIAMENTO DE USUÁRIOS

# Mostra arquivo de usuários
echo "34. Últimas 5 linhas do arquivo de usuários (tail -5 /etc/passwd):"
tail -5 /etc/passwd
echo ""

# Mostra grupos
echo "35. Grupos do usuário atual (groups):"
groups
echo ""

# LIMPEZA

# Retorna ao diretório original
echo "36. Retornando ao diretório original:"
cd -
echo ""

# Remove diretório de teste
echo "37. Removendo diretório de teste (rm -rf):"
rm -rf /tmp/meu_diretorio_teste
echo "Diretório de teste removido"
echo ""

# Finalização
echo "=================================================="
echo "            SCRIPT FINALIZADO COM SUCESSO         "
echo "=================================================="
echo "Total de comandos executados: 37"
echo "Data/Hora: $(date)"
