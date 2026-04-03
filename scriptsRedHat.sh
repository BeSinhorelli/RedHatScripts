#!/bin/bash

# ============================================================
# SHELLSCRIPT - RED HAT ENTERPRISE LINUX
# Autor: Bernardo
# ============================================================

# ========== CONFIGURAÇÕES GLOBAIS ==========
# Cores para output (torna as mensagens mais visíveis)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Variáveis globais
LOG_FILE="/tmp/script_intermediario_$(date +%Y%m%d_%H%M%S).log"
ERROR_COUNT=0
SUCCESS_COUNT=0

# ========== FUNÇÕES UTILITÁRIAS ==========

# Função para log com timestamp
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo -e "${timestamp} - [${level}] - ${message}" >> "$LOG_FILE"
    
    case $level in
        "ERROR")
            echo -e "${RED}❌ ERRO: ${message}${NC}"
            ;;
        "SUCCESS")
            echo -e "${GREEN}✅ ${message}${NC}"
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠️  AVISO: ${message}${NC}"
            ;;
        "INFO")
            echo -e "${CYAN}ℹ️  ${message}${NC}"
            ;;
        *)
            echo -e "${message}"
            ;;
    esac
}

# Função para tratar erros
handle_error() {
    local exit_code=$?
    local line_number=$1
    log_message "ERROR" "Falha na linha ${line_number} com código ${exit_code}"
    ((ERROR_COUNT++))
}

# Função para verificar se comando foi bem sucedido
check_success() {
    local exit_code=$?
    local success_message=$1
    local error_message=$2
    
    if [ $exit_code -eq 0 ]; then
        log_message "SUCCESS" "$success_message"
        ((SUCCESS_COUNT++))
        return 0
    else
        log_message "ERROR" "$error_message"
        ((ERROR_COUNT++))
        return 1
    fi
}

# Função para perguntar sim/não ao usuário
ask_yes_no() {
    local question=$1
    local answer
    
    while true; do
        echo -e "${YELLOW}$question (s/n): ${NC}"
        read -r answer
        case $answer in
            [Ss]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) echo "Por favor, responda 's' ou 'n'" ;;
        esac
    done
}

# Função para validar nome de usuário
validate_username() {
    local username=$1
    
    # Verifica se o nome está vazio
    if [ -z "$username" ]; then
        return 1
    fi
    
    # Verifica se contém apenas caracteres válidos (letras minúsculas, números, underscore, hífen)
    if [[ ! "$username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
        return 1
    fi
    
    return 0
}

# Função para mostrar menu interativo
show_menu() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${MAGENTA}        MENU DE OPÇÕES DO SCRIPT        ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo "1. Executar todas as verificações (modo completo)"
    echo "2. Apenas informações do sistema"
    echo "3. Apenas gerenciamento de arquivos"
    echo "4. Apenas informações de rede"
    echo "5. Backup do diretório atual"
    echo "6. Monitorar um processo específico"
    echo "7. Criar múltiplos usuários em lote (MANUAL)"
    echo "8. Criar usuários a partir de arquivo"
    echo "9. Sair"
    echo -e "${BLUE}========================================${NC}"
    echo -ne "${YELLOW}Digite sua escolha (1-9): ${NC}"
}

# ========== FUNÇÕES PRINCIPAIS ==========

# Função com estruturas de decisão (if/else, case)
check_system_requirements() {
    log_message "INFO" "Verificando requisitos do sistema..."
    
    # Estrutura if/elif/else para verificar usuário
    echo -e "${CYAN}🔍 Verificando usuário atual...${NC}"
    CURRENT_USER=$(whoami)
    
    if [ "$CURRENT_USER" = "root" ]; then
        log_message "WARNING" "Você está executando como root - tenha cuidado!"
        echo -e "${YELLOW}⚠️  Você está como root. Comandos destrutivos serão permitidos.${NC}"
    elif [ "$CURRENT_USER" = "bernardo" ] || [ "$CURRENT_USER" = "admin" ]; then
        log_message "INFO" "Usuário privilegiado: $CURRENT_USER"
        echo -e "${GREEN}✅ Usuário $CURRENT_USER com privilégios adequados${NC}"
    else
        log_message "INFO" "Usuário comum: $CURRENT_USER"
        echo -e "${BLUE}ℹ️  Usuário $CURRENT_USER - alguns comandos podem precisar de sudo${NC}"
    fi
    
    # Verificando espaço em disco com if
    DISK_SPACE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    echo -e "${CYAN}💾 Espaço em disco usado: ${DISK_SPACE}%${NC}"
    
    if [ $DISK_SPACE -gt 90 ]; then
        log_message "ERROR" "Espaço em disco CRÍTICO: ${DISK_SPACE}% usado"
        echo -e "${RED}❌ CRÍTICO: Disco quase cheio! Libere espaço imediatamente.${NC}"
    elif [ $DISK_SPACE -gt 75 ]; then
        log_message "WARNING" "Espaço em disco moderado: ${DISK_SPACE}% usado"
        echo -e "${YELLOW}⚠️  Atenção: Disco com ${DISK_SPACE}% de uso${NC}"
    else
        log_message "SUCCESS" "Espaço em disco adequado: ${DISK_SPACE}% usado"
        echo -e "${GREEN}✅ Espaço em disco OK: ${DISK_SPACE}%${NC}"
    fi
    
    check_success "Verificação do sistema concluída" "Falha na verificação do sistema"
}

# Função com loop FOR - criar múltiplos arquivos
create_multiple_files() {
    local num_files=$1
    local base_name=$2
    
    log_message "INFO" "Criando $num_files arquivos com prefixo $base_name"
    
    # Estrutura de decisão para validar input
    if [ -z "$num_files" ] || [ -z "$base_name" ]; then
        log_message "ERROR" "Número de arquivos ou nome base não fornecidos"
        return 1
    fi
    
    if ! [[ "$num_files" =~ ^[0-9]+$ ]]; then
        log_message "ERROR" "$num_files não é um número válido"
        return 1
    fi
    
    # Loop FOR para criar múltiplos arquivos
    echo -e "${CYAN}📁 Criando $num_files arquivos...${NC}"
    for i in $(seq 1 $num_files); do
        filename="${base_name}_${i}.txt"
        echo "Conteúdo do arquivo $i criado em $(date)" > "$filename"
        
        # Usando case para mostrar progresso diferente a cada 10 arquivos
        case $((i % 10)) in
            0)
                echo -e "${GREEN}✓ Criados $i arquivos até agora${NC}"
                ;;
        esac
    done
    
    check_success "$num_files arquivos criados com sucesso" "Falha ao criar arquivos"
}

# NOVA FUNÇÃO: Criar usuários manualmente (inserindo nomes um por um)
create_users_manual() {
    log_message "INFO" "Iniciando criação manual de usuários"
    
    echo -e "${CYAN}========================================${NC}"
    echo -e "${MAGENTA}     CRIAÇÃO MANUAL DE USUÁRIOS       ${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
    
    # Pergunta quantos usuários criar
    while true; do
        echo -ne "${YELLOW}Quantos usuários você deseja criar? ${NC}"
        read -r num_users
        
        # Validar se é um número positivo
        if [[ "$num_users" =~ ^[0-9]+$ ]] && [ "$num_users" -gt 0 ]; then
            break
        else
            echo -e "${RED}❌ Por favor, digite um número válido maior que zero.${NC}"
        fi
    done
    
    echo ""
    echo -e "${GREEN}✅ Você irá criar $num_users usuário(s)${NC}"
    echo -e "${CYAN}📝 Regras para nomes de usuário:${NC}"
    echo "   - Apenas letras minúsculas (a-z)"
    echo "   - Pode conter números (0-9)"
    echo "   - Pode conter underscore (_) e hífen (-)"
    echo "   - Deve começar com letra ou underscore"
    echo ""
    
    # Array para armazenar os usuários
    declare -a USERS_ARRAY
    
    # Loop para coletar os nomes dos usuários
    for i in $(seq 1 $num_users); do
        while true; do
            echo -ne "${YELLOW}Digite o nome do usuário $i: ${NC}"
            read -r username
            
            # Converter para minúsculas automaticamente
            username=$(echo "$username" | tr '[:upper:]' '[:lower:]')
            
            # Validar nome do usuário
            if validate_username "$username"; then
                USERS_ARRAY+=("$username")
                echo -e "${GREEN}✅ Nome válido: $username${NC}"
                break
            else
                echo -e "${RED}❌ Nome inválido! Use apenas letras minúsculas, números, _ ou -${NC}"
                echo -e "${YELLOW}   Exemplos válidos: joao, maria_silva, user123, admin-user${NC}"
            fi
        done
        echo ""
    done
    
    # Mostrar resumo dos usuários
    echo -e "${CYAN}========================================${NC}"
    echo -e "${MAGENTA}         RESUMO DOS USUÁRIOS          ${NC}"
    echo -e "${CYAN}========================================${NC}"
    for i in "${!USERS_ARRAY[@]}"; do
        echo "$((i+1)). ${USERS_ARRAY[$i]}"
    done
    echo ""
    
    # Confirmar criação
    if ! ask_yes_no "Deseja criar estes usuários no sistema?"; then
        log_message "INFO" "Criação de usuários cancelada pelo usuário"
        echo -e "${YELLOW}⚠️  Operação cancelada.${NC}"
        return 0
    fi
    
    echo ""
    echo -e "${CYAN}👥 Criando usuários...${NC}"
    echo -e "${YELLOW}⚠️  ATENÇÃO: Isso criará os usuários no sistema!${NC}"
    
    if ! ask_yes_no "Tem certeza que deseja continuar?"; then
        echo -e "${YELLOW}⚠️  Operação cancelada.${NC}"
        return 0
    fi
    
    echo ""
    
    # Criar os usuários
    for username in "${USERS_ARRAY[@]}"; do
        # Verificar se usuário já existe
        if id "$username" &>/dev/null; then
            log_message "WARNING" "Usuário $username já existe - ignorando"
            echo -e "${YELLOW}⚠️  Usuário '$username' já existe no sistema${NC}"
        else
            echo -ne "${BLUE}📝 Criando usuário '$username'...${NC}"
            
            # Verificar se tem permissão de root
            if [ "$EUID" -eq 0 ]; then
                # Executar como root diretamente
                useradd -m -s /bin/bash "$username" 2>/dev/null
                if [ $? -eq 0 ]; then
                    echo -e " ${GREEN}✅ CRIADO${NC}"
                    log_message "SUCCESS" "Usuário $username criado com sucesso"
                    ((SUCCESS_COUNT++))
                else
                    echo -e " ${RED}❌ FALHA${NC}"
                    log_message "ERROR" "Falha ao criar usuário $username"
                    ((ERROR_COUNT++))
                fi
            else
                # Tentar com sudo
                echo -e "\n${YELLOW}⚠️  Precisa de permissão de root. Tentando com sudo...${NC}"
                sudo useradd -m -s /bin/bash "$username" 2>/dev/null
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ Usuário '$username' criado com sucesso${NC}"
                    log_message "SUCCESS" "Usuário $username criado com sucesso (via sudo)"
                    ((SUCCESS_COUNT++))
                    
                    # Opção de definir senha
                    if ask_yes_no "Deseja definir uma senha para o usuário $username?"; then
                        echo -ne "${YELLOW}Digite a senha para $username: ${NC}"
                        read -s password
                        echo ""
                        echo "$username:$password" | sudo chpasswd
                        echo -e "${GREEN}✅ Senha definida${NC}"
                    fi
                else
                    echo -e "${RED}❌ Falha ao criar usuário '$username'${NC}"
                    log_message "ERROR" "Falha ao criar usuário $username"
                    ((ERROR_COUNT++))
                fi
            fi
        fi
        echo ""
    done
    
    log_message "SUCCESS" "Processamento de usuários concluído"
    echo -e "${GREEN}✅ Criação de usuários finalizada!${NC}"
}

# Função para criar usuários a partir de arquivo
create_users_from_file() {
    log_message "INFO" "Iniciando criação de usuários a partir de arquivo"
    
    echo -e "${CYAN}========================================${NC}"
    echo -e "${MAGENTA}     CRIAÇÃO POR ARQUIVO DE USUÁRIOS   ${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
    
    local users_file=""
    
    # Opção de usar arquivo padrão ou personalizado
    echo "1. Usar arquivo padrão (/tmp/users_list.txt)"
    echo "2. Especificar caminho do arquivo"
    echo "3. Criar novo arquivo com usuários"
    echo -ne "${YELLOW}Escolha uma opção (1-3): ${NC}"
    read -r file_option
    
    case $file_option in
        1)
            users_file="/tmp/users_list.txt"
            # Criar arquivo de exemplo se não existir
            if [ ! -f "$users_file" ]; then
                echo -e "${CYAN}📝 Criando arquivo de exemplo...${NC}"
                cat > "$users_file" << EOF
joao
maria
pedro
ana
carlos
EOF
                echo -e "${GREEN}✅ Arquivo criado: $users_file${NC}"
            fi
            ;;
        2)
            echo -ne "${YELLOW}Digite o caminho completo do arquivo: ${NC}"
            read -r users_file
            if [ ! -f "$users_file" ]; then
                echo -e "${RED}❌ Arquivo não encontrado: $users_file${NC}"
                return 1
            fi
            ;;
        3)
            echo -ne "${YELLOW}Digite o nome do arquivo a ser criado: ${NC}"
            read -r users_file
            if [ -z "$users_file" ]; then
                users_file="/tmp/meus_usuarios.txt"
            fi
            
            echo -e "${CYAN}Digite os nomes dos usuários (um por linha).${NC}"
            echo -e "${YELLOW}Digite uma linha em branco para finalizar:${NC}"
            
            > "$users_file"  # Limpar/ criar arquivo
            
            local line_count=0
            while true; do
                echo -ne "Usuário $((line_count+1)): "
                read -r username
                
                if [ -z "$username" ]; then
                    break
                fi
                
                # Validar nome
                if validate_username "$username"; then
                    echo "$username" >> "$users_file"
                    ((line_count++))
                    echo -e "${GREEN}✅ Adicionado: $username${NC}"
                else
                    echo -e "${RED}❌ Nome inválido! Ignorado.${NC}"
                fi
            done
            
            echo -e "${GREEN}✅ $line_count usuários salvos em: $users_file${NC}"
            ;;
        *)
            echo -e "${RED}❌ Opção inválida${NC}"
            return 1
            ;;
    esac
    
    # Mostrar conteúdo do arquivo
    echo ""
    echo -e "${CYAN}Conteúdo do arquivo:${NC}"
    echo -e "${YELLOW}----------------------------------------${NC}"
    cat "$users_file"
    echo -e "${YELLOW}----------------------------------------${NC}"
    echo ""
    
    if ! ask_yes_no "Deseja criar estes usuários no sistema?"; then
        log_message "INFO" "Criação de usuários cancelada pelo usuário"
        return 0
    fi
    
    # Loop para ler arquivo e criar usuários
    echo -e "${CYAN}👥 Criando usuários...${NC}"
    
    while IFS= read -r username; do
        # Pular linhas vazias
        [ -z "$username" ] && continue
        
        if id "$username" &>/dev/null; then
            log_message "WARNING" "Usuário $username já existe - ignorando"
            echo -e "${YELLOW}⚠️  Usuário '$username' já existe${NC}"
        else
            echo -ne "${BLUE}📝 Criando usuário '$username'...${NC}"
            
            if [ "$EUID" -eq 0 ]; then
                useradd -m -s /bin/bash "$username" 2>/dev/null
                if [ $? -eq 0 ]; then
                    echo -e " ${GREEN}✅ CRIADO${NC}"
                    log_message "SUCCESS" "Usuário $username criado"
                    ((SUCCESS_COUNT++))
                else
                    echo -e " ${RED}❌ FALHA${NC}"
                    log_message "ERROR" "Falha ao criar $username"
                    ((ERROR_COUNT++))
                fi
            else
                sudo useradd -m -s /bin/bash "$username" 2>/dev/null
                if [ $? -eq 0 ]; then
                    echo -e " ${GREEN}✅ CRIADO${NC}"
                    log_message "SUCCESS" "Usuário $username criado (via sudo)"
                    ((SUCCESS_COUNT++))
                else
                    echo -e " ${RED}❌ FALHA${NC}"
                    log_message "ERROR" "Falha ao criar $username"
                    ((ERROR_COUNT++))
                fi
            fi
        fi
    done < "$users_file"
    
    log_message "SUCCESS" "Processamento de usuários concluído"
    echo -e "${GREEN}✅ Criação de usuários finalizada!${NC}"
}

# Função com loop WHILE - monitorar processo
monitor_process() {
    local process_name=$1
    local max_attempts=10
    local attempt=1
    
    if [ -z "$process_name" ]; then
        echo -ne "${YELLOW}Digite o nome do processo para monitorar: ${NC}"
        read -r process_name
    fi
    
    log_message "INFO" "Monitorando processo: $process_name"
    echo -e "${CYAN}🔍 Monitorando processo '$process_name' por $max_attempts segundos...${NC}"
    
    # Loop WHILE com contador
    while [ $attempt -le $max_attempts ]; do
        if pgrep "$process_name" > /dev/null; then
            log_message "SUCCESS" "Processo $process_name está em execução (verificação $attempt)"
            echo -e "${GREEN}✅ Processo $process_name encontrado!${NC}"
            
            # Mostra detalhes do processo se encontrado
            ps aux | grep "$process_name" | grep -v grep
            return 0
        else
            log_message "INFO" "Aguardando processo $process_name (tentativa $attempt/$max_attempts)"
            echo -e "${YELLOW}⏳ Aguardando processo $process_name... ($attempt/$max_attempts)${NC}"
        fi
        
        ((attempt++))
        sleep 1
    done
    
    log_message "ERROR" "Processo $process_name não encontrado após $max_attempts tentativas"
    echo -e "${RED}❌ Processo $process_name não encontrado${NC}"
    return 1
}

# Função de backup com verificação de erros
backup_current_directory() {
    local backup_dir="/tmp/backup_$(date +%Y%m%d_%H%M%S)"
    local current_dir=$(pwd)
    
    log_message "INFO" "Iniciando backup de $current_dir"
    echo -e "${CYAN}💾 Criando backup do diretório atual...${NC}"
    
    # Verificação de erro com if e trap
    mkdir -p "$backup_dir" || {
        log_message "ERROR" "Não foi possível criar diretório de backup"
        return 1
    }
    
    # Copiar arquivos com verificação de erro
    cp -r "$current_dir"/* "$backup_dir/" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        log_message "SUCCESS" "Backup criado em $backup_dir"
        echo -e "${GREEN}✅ Backup concluído em: $backup_dir${NC}"
        echo -e "${BLUE}📊 Tamanho do backup: $(du -sh "$backup_dir" | cut -f1)${NC}"
        return 0
    else
        log_message "ERROR" "Falha ao criar backup"
        echo -e "${RED}❌ Falha ao criar backup${NC}"
        return 1
    fi
}

# Função principal com estrutura CASE
main() {
    # Trap para capturar erros e sinal de interrupção
    trap 'handle_error $LINENO' ERR
    trap 'log_message "INFO" "Script interrompido pelo usuário"; exit 130' INT TERM
    
    # Log inicial
    log_message "INFO" "=== INICIANDO SCRIPT INTERMEDIÁRIO ==="
    log_message "INFO" "Usuário: $USER"
    log_message "INFO" "Diretório: $(pwd)"
    
    # Limpa a tela
    clear
    
    # Mostra cabeçalho
    echo -e "${BLUE}==================================================${NC}"
    echo -e "${MAGENTA}    SCRIPT INTERMEDIÁRIO - RHEL v2.1         ${NC}"
    echo -e "${BLUE}==================================================${NC}"
    echo -e "${CYAN}Log será salvo em: $LOG_FILE${NC}"
    echo ""
    
    # Estrutura CASE para menu interativo
    while true; do
        show_menu
        read -r choice
        
        case $choice in
            1)
                log_message "INFO" "Modo completo selecionado"
                check_system_requirements
                
                # Loop for dentro do case
                echo -e "${CYAN}📁 Criando estrutura de diretórios...${NC}"
                for dir in teste1 teste2 teste3; do
                    mkdir -p "/tmp/$dir"
                    log_message "INFO" "Diretório /tmp/$dir criado"
                done
                
                create_multiple_files 5 "exemplo"
                backup_current_directory
                ;;
            2)
                log_message "INFO" "Modo informações do sistema"
                check_system_requirements
                ;;
            3)
                log_message "INFO" "Modo gerenciamento de arquivos"
                create_multiple_files 3 "teste"
                ;;
            4)
                log_message "INFO" "Modo informações de rede"
                echo -e "${CYAN}🌐 Configurações de rede:${NC}"
                ip addr show | head -10
                check_success "Informações de rede exibidas" "Falha ao exibir rede"
                ;;
            5)
                backup_current_directory
                ;;
            6)
                monitor_process ""
                ;;
            7)
                create_users_manual  # NOVA FUNÇÃO - Manual com inserção de nomes
                ;;
            8)
                create_users_from_file  # NOVA FUNÇÃO - A partir de arquivo
                ;;
            9)
                log_message "INFO" "Usuário escolheu sair"
                echo -e "${GREEN}👋 Saindo...${NC}"
                break
                ;;
            *)
                log_message "WARNING" "Opção inválida: $choice"
                echo -e "${RED}❌ Opção inválida! Tente novamente.${NC}"
                sleep 1
                ;;
        esac
        
        # Pausa antes de voltar ao menu (se não for sair)
        if [ "$choice" != "9" ]; then
            echo ""
            echo -ne "${YELLOW}Pressione Enter para continuar...${NC}"
            read -r
            clear
        fi
    done
    
    # Resumo final
    echo ""
    echo -e "${BLUE}==================================================${NC}"
    echo -e "${MAGENTA}              RESUMO DA EXECUÇÃO                ${NC}"
    echo -e "${BLUE}==================================================${NC}"
    echo -e "${GREEN}✅ Operações bem-sucedidas: $SUCCESS_COUNT${NC}"
    echo -e "${RED}❌ Operações com erro: $ERROR_COUNT${NC}"
    echo -e "${CYAN}📝 Log completo: $LOG_FILE${NC}"
    echo -e "${BLUE}==================================================${NC}"
    
    # Estrutura if/else baseada no resultado
    if [ $ERROR_COUNT -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Script finalizado com $ERROR_COUNT erro(s)${NC}"
        exit 1
    else
        echo -e "${GREEN}✅ Script finalizado com SUCESSO!${NC}"
        exit 0
    fi
}

# ========== EXECUÇÃO PRINCIPAL ==========
# Chamando a função principal
main "$@"
