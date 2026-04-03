#!/bin/bash

# ============================================================
# SCRIPT DE GERENCIAMENTO DE USUÁRIOS - RED HAT
# Autor: Bernardo
# Versão: 7.0 - Com Monitoramento de Processos
# ============================================================

# ========== CONFIGURAÇÕES ==========
VERDE='\033[0;32m'
VERMELHO='\033[0;31m'
AMARELO='\033[1;33m'
AZUL='\033[0;34m'
ROXO='\033[0;35m'
CIANO='\033[0;36m'
FIM='\033[0m'

# Arquivo para armazenar usuários (simulação local)
USERS_FILE="$HOME/.script_usuarios.txt"
LOG_FILE="$HOME/.script_redhat_$(date +%Y%m%d_%H%M%S).log"

# ========== INICIALIZAR ARQUIVO DE USUÁRIOS ==========
inicializar_arquivo() {
    if [ ! -f "$USERS_FILE" ]; then
        # Criar arquivo com usuários de exemplo
        cat > "$USERS_FILE" << EOF
joao:Joao Silva:/bin/bash:ativo
maria:Maria Santos:/bin/bash:ativo
carlos:Carlos Alberto:/bin/bash:ativo
ana:Ana Paula:/bin/bash:ativo
pedro:Pedro Lima:/bin/bash:ativo
EOF
        echo "Arquivo de usuários criado: $USERS_FILE"
    fi
}

# ========== FUNÇÃO PARA LOG ==========
log() {
    local tipo=$1
    local msg=$2
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [$tipo] - $msg" >> "$LOG_FILE"
}

# ========== FUNÇÃO PARA MOSTRAR MENSAGENS ==========
mensagem() {
    local tipo=$1
    local texto=$2
    
    case $tipo in
        "ERRO") echo -e "${VERMELHO}❌ $texto${FIM}" ;;
        "SUCESSO") echo -e "${VERDE}✅ $texto${FIM}" ;;
        "AVISO") echo -e "${AMARELO}⚠️  $texto${FIM}" ;;
        "INFO") echo -e "${CIANO}ℹ️  $texto${FIM}" ;;
        "TITULO") echo -e "${AZUL}$texto${FIM}" ;;
    esac
    log "$tipo" "$texto"
}

# ========== FUNÇÃO PARA MONITORAR PROCESSOS ==========
monitorar_processos() {
    clear
    echo -e "${AZUL}═══════════════════════════════════════════════════════════${FIM}"
    echo -e "${VERDE}                 MONITORAMENTO DE PROCESSOS                ${FIM}"
    echo -e "${AZUL}═══════════════════════════════════════════════════════════${FIM}"
    echo ""
    
    echo -e "${CIANO}📌 O que você quer monitorar?${FIM}"
    echo ""
    echo "   1. 🔍 Monitorar um processo específico (por nome)"
    echo "   2. 📊 Ver todos os processos do sistema"
    echo "   3. 👤 Ver processos de um usuário específico"
    echo "   4. 💻 Ver processos mais pesados (CPU/Memória)"
    echo "   5. 🔄 Monitorar processo em tempo real (top)"
    echo "   6. ⏱️  Monitorar processo por tempo (ex: 10 segundos)"
    echo "   7. 📋 Ver processos de um usuário do script"
    echo "   8. 🔙 Voltar"
    echo ""
    echo -ne "${AMARELO}Escolha (1-8): ${FIM}"
    read -r opcao_proc
    
    case $opcao_proc in
        1)
            echo -ne "${AMARELO}Digite o nome do processo (ex: bash, sshd, chrome): ${FIM}"
            read -r processo
            echo ""
            echo -e "${CIANO}🔍 Processos encontrados para '$processo':${FIM}"
            echo -e "${AMARELO}─────────────────────────────────────────────────────────────────${FIM}"
            ps aux | grep -E "$processo" | grep -v grep
            echo -e "${AMARELO}─────────────────────────────────────────────────────────────────${FIM}"
            ;;
        2)
            echo ""
            echo -e "${CIANO}📊 TODOS OS PROCESSOS DO SISTEMA:${FIM}"
            echo -e "${AMARELO}─────────────────────────────────────────────────────────────────${FIM}"
            ps aux | head -20
            echo -e "${AMARELO}─────────────────────────────────────────────────────────────────${FIM}"
            echo -e "${CIANO}Total de processos: $(ps aux | wc -l)${FIM}"
            ;;
        3)
            echo -ne "${AMARELO}Digite o nome do usuário: ${FIM}"
            read -r usuario_proc
            echo ""
            echo -e "${CIANO}👤 Processos do usuário '$usuario_proc':${FIM}"
            echo -e "${AMARELO}─────────────────────────────────────────────────────────────────${FIM}"
            ps aux | grep -E "^$usuario_proc" | grep -v grep
            echo -e "${AMARELO}─────────────────────────────────────────────────────────────────${FIM}"
            if [ $(ps aux | grep -E "^$usuario_proc" | grep -v grep | wc -l) -eq 0 ]; then
                mensagem "AVISO" "Nenhum processo encontrado para este usuário"
            fi
            ;;
        4)
            echo ""
            echo -e "${CIANO}💻 TOP 10 PROCESSOS MAIS PESADOS (CPU):${FIM}"
            echo -e "${AMARELO}─────────────────────────────────────────────────────────────────${FIM}"
            ps aux --sort=-%cpu | head -11
            echo -e "${AMARELO}─────────────────────────────────────────────────────────────────${FIM}"
            echo ""
            echo -e "${CIANO}💾 TOP 10 PROCESSOS MAIS PESADOS (MEMÓRIA):${FIM}"
            echo -e "${AMARELO}─────────────────────────────────────────────────────────────────${FIM}"
            ps aux --sort=-%mem | head -11
            echo -e "${AMARELO}─────────────────────────────────────────────────────────────────${FIM}"
            ;;
        5)
            echo ""
            echo -e "${CIANO}🔄 Abrindo monitor em tempo real...${FIM}"
            echo -e "${AMARELO}Pressione 'q' para sair do monitor${FIM}"
            sleep 2
            top
            ;;
        6)
            echo -ne "${AMARELO}Digite o nome do processo para monitorar: ${FIM}"
            read -r processo_mon
            echo -ne "${AMARELO}Digite o tempo de monitoramento (segundos): ${FIM}"
            read -r tempo_mon
            echo ""
            
            if ! [[ "$tempo_mon" =~ ^[0-9]+$ ]]; then
                mensagem "ERRO" "Tempo inválido! Usando 10 segundos"
                tempo_mon=10
            fi
            
            echo -e "${CIANO}⏱️  Monitorando '$processo_mon' por $tempo_mon segundos...${FIM}"
            echo ""
            
            local encontrado=0
            for i in $(seq 1 $tempo_mon); do
                if pgrep -x "$processo_mon" > /dev/null 2>&1; then
                    echo -e "${VERDE}✅ [$i/$tempo_mon] Processo '$processo_mon' está em execução!${FIM}"
                    encontrado=1
                else
                    echo -e "${AMARELO}⏳ [$i/$tempo_mon] Aguardando processo '$processo_mon'...${FIM}"
                fi
                sleep 1
            done
            
            if [ $encontrado -eq 1 ]; then
                mensagem "SUCESSO" "Processo monitorado com sucesso"
            else
                mensagem "AVISO" "Processo não encontrado durante o monitoramento"
            fi
            ;;
        7)
            echo ""
            echo -e "${CIANO}📋 Usuários cadastrados no script:${FIM}"
            echo -e "${AMARELO}─────────────────────────────────────────────────────────────────${FIM}"
            cut -d':' -f1 "$USERS_FILE" | nl -w2 -s'. '
            echo -e "${AMARELO}─────────────────────────────────────────────────────────────────${FIM}"
            echo ""
            echo -ne "${AMARELO}Digite o número do usuário para ver seus processos: ${FIM}"
            read -r num_user
            
            if [[ "$num_user" =~ ^[0-9]+$ ]]; then
                usuario_sistema=$(sed -n "${num_user}p" "$USERS_FILE" | cut -d':' -f1)
                if [ -n "$usuario_sistema" ]; then
                    echo ""
                    echo -e "${CIANO}👤 Processos do usuário '$usuario_sistema' (no sistema real):${FIM}"
                    echo -e "${AMARELO}─────────────────────────────────────────────────────────────────${FIM}"
                    ps aux | grep -E "^$usuario_sistema" | grep -v grep
                    echo -e "${AMARELO}─────────────────────────────────────────────────────────────────${FIM}"
                fi
            fi
            ;;
        8)
            return
            ;;
        *)
            mensagem "ERRO" "Opção inválida!"
            ;;
    esac
    
    echo ""
    echo -ne "${AMARELO}Pressione ENTER para continuar...${FIM}"
    read -r
}

# ========== FUNÇÃO PARA LISTAR TODOS OS USUÁRIOS ==========
listar_usuarios() {
    clear
    echo -e "${AZUL}═══════════════════════════════════════════════════════════${FIM}"
    echo -e "${VERDE}                      LISTA DE USUÁRIOS                    ${FIM}"
    echo -e "${AZUL}═══════════════════════════════════════════════════════════${FIM}"
    echo ""
    
    if [ ! -s "$USERS_FILE" ]; then
        mensagem "AVISO" "Nenhum usuário cadastrado!"
        echo ""
        echo -ne "${AMARELO}Pressione ENTER para continuar...${FIM}"
        read -r
        return
    fi
    
    # Conta usuários
    total=$(wc -l < "$USERS_FILE")
    echo -e "${CIANO}📊 Total de usuários: ${total}${FIM}"
    echo ""
    
    # Mostra tabela de usuários
    printf "${VERDE}%-3s %-15s %-25s %-12s %s${FIM}\n" "Nº" "USUÁRIO" "NOME COMPLETO" "SHELL" "STATUS"
    echo -e "${AMARELO}─────────────────────────────────────────────────────────────────${FIM}"
    
    local num=1
    while IFS=':' read -r user name shell status; do
        # Mostra status com cor
        if [ "$status" == "ativo" ]; then
            status_show="${VERDE}ATIVO${FIM}"
        else
            status_show="${VERMELHO}BLOQUEADO${FIM}"
        fi
        
        printf "%-3s %-15s %-25s %-12s ${status_show}\n" "$num" "$user" "$name" "$shell"
        ((num++))
    done < "$USERS_FILE"
    
    echo -e "${AMARELO}─────────────────────────────────────────────────────────────────${FIM}"
    echo ""
    
    # Menu de detalhes
    echo -ne "${AMARELO}Digite o número do usuário para ver detalhes (0 para voltar): ${FIM}"
    read -r escolha
    
    if [ "$escolha" -gt 0 ] 2>/dev/null; then
        ver_detalhes_usuario "$escolha"
    fi
}

# ========== FUNÇÃO PARA VER DETALHES DE UM USUÁRIO ==========
ver_detalhes_usuario() {
    local num=$1
    local linha=$(sed -n "${num}p" "$USERS_FILE")
    
    if [ -z "$linha" ]; then
        mensagem "ERRO" "Usuário não encontrado!"
        echo -ne "${AMARELO}Pressione ENTER...${FIM}"
        read -r
        return
    fi
    
    IFS=':' read -r user name shell status <<< "$linha"
    
    clear
    echo -e "${AZUL}═══════════════════════════════════════════════════════════${FIM}"
    echo -e "${VERDE}                   DETALHES DO USUÁRIO                     ${FIM}"
    echo -e "${AZUL}═══════════════════════════════════════════════════════════${FIM}"
    echo ""
    echo -e "${CIANO}📋 Informações:${FIM}"
    echo "   Usuário: $user"
    echo "   Nome completo: $name"
    echo "   Shell: $shell"
    echo "   Status: $( [ "$status" == "ativo" ] && echo "ATIVO" || echo "BLOQUEADO" )"
    echo ""
    echo -e "${CIANO}📁 Diretório home simulado: /home/$user${FIM}"
    echo -e "${CIANO}🆔 UID simulado: $((1000 + num))${FIM}"
    echo ""
    
    echo -e "${AZUL}═══════════════════════════════════════════════════════════${FIM}"
    echo -ne "${AMARELO}Pressione ENTER para continuar...${FIM}"
    read -r
}

# ========== FUNÇÃO PARA CRIAR USUÁRIO ==========
criar_usuario() {
    clear
    echo -e "${AZUL}═══════════════════════════════════════════════════════════${FIM}"
    echo -e "${VERDE}                     CRIAR USUÁRIO                        ${FIM}"
    echo -e "${AZUL}═══════════════════════════════════════════════════════════${FIM}"
    echo ""
    
    echo -e "${CIANO}📋 REGRAS:${FIM}"
    echo "   - Login: letras minúsculas (a-z), números, _ e -"
    echo "   - Login deve começar com letra"
    echo "   - Exemplos: joao, maria_silva, user123"
    echo ""
    
    # Nome de usuário
    while true; do
        echo -ne "${AMARELO}Login do usuário: ${FIM}"
        read -r login
        login=$(echo "$login" | tr '[:upper:]' '[:lower:]')
        
        if [[ ! "$login" =~ ^[a-z][a-z0-9_-]*$ ]]; then
            mensagem "ERRO" "Login inválido! Use apenas letras minúsculas, números, _ e -"
            continue
        fi
        
        if grep -q "^$login:" "$USERS_FILE"; then
            mensagem "ERRO" "Usuário '$login' já existe!"
            continue
        fi
        break
    done
    
    # Nome completo
    echo -ne "${AMARELO}Nome completo: ${FIM}"
    read -r nome_completo
    [ -z "$nome_completo" ] && nome_completo="$login"
    
    # Shell
    echo ""
    echo -e "${CIANO}Shell disponíveis:${FIM}"
    echo "   1. /bin/bash"
    echo "   2. /bin/sh"
    echo "   3. /bin/csh"
    echo "   4. /bin/tcsh"
    echo -ne "${AMARELO}Escolha o shell (1-4) [padrão=1]: ${FIM}"
    read -r shell_opcao
    
    case $shell_opcao in
        2) shell="/bin/sh" ;;
        3) shell="/bin/csh" ;;
        4) shell="/bin/tcsh" ;;
        *) shell="/bin/bash" ;;
    esac
    
    # Senha
    echo ""
    while true; do
        echo -ne "${AMARELO}Senha: ${FIM}"
        read -s senha
        echo ""
        echo -ne "${AMARELO}Confirmar senha: ${FIM}"
        read -s senha2
        echo ""
        
        if [ "$senha" != "$senha2" ]; then
            mensagem "ERRO" "Senhas não conferem!"
        elif [ ${#senha} -lt 4 ]; then
            mensagem "ERRO" "Senha muito curta (mínimo 4 caracteres)"
        else
            break
        fi
    done
    
    # Confirmar
    echo ""
    echo -e "${CIANO}📝 Resumo:${FIM}"
    echo "   Login: $login"
    echo "   Nome: $nome_completo"
    echo "   Shell: $shell"
    echo ""
    
    if perguntar_sim_nao "Confirmar criação do usuário?"; then
        # Adiciona ao arquivo
        echo "$login:$nome_completo:$shell:ativo" >> "$USERS_FILE"
        mensagem "SUCESSO" "Usuário '$login' criado com sucesso!"
        
        # Cria senha em arquivo separado (simulação)
        echo "$login:$senha" >> "$HOME/.script_senhas.txt"
        chmod 600 "$HOME/.script_senhas.txt" 2>/dev/null
    fi
    
    echo ""
    echo -ne "${AMARELO}Pressione ENTER para continuar...${FIM}"
    read -r
}

# ========== FUNÇÃO PARA EDITAR USUÁRIO ==========
editar_usuario() {
    clear
    echo -e "${AZUL}═══════════════════════════════════════════════════════════${FIM}"
    echo -e "${VERDE}                     EDITAR USUÁRIO                       ${FIM}"
    echo -e "${AZUL}═══════════════════════════════════════════════════════════${FIM}"
    echo ""
    
    if [ ! -s "$USERS_FILE" ]; then
        mensagem "AVISO" "Nenhum usuário cadastrado!"
        echo -ne "${AMARELO}Pressione ENTER...${FIM}"
        read -r
        return
    fi
    
    # Mostrar lista
    echo -e "${CIANO}📋 USUÁRIOS CADASTRADOS:${FIM}"
    echo -e "${AMARELO}─────────────────────────────────────────────────────────────────${FIM}"
    printf "%-3s %-15s %-25s\n" "Nº" "LOGIN" "NOME"
    echo -e "${AMARELO}─────────────────────────────────────────────────────────────────${FIM}"
    
    local num=1
    while IFS=':' read -r user name shell status; do
        printf "%-3s %-15s %-25s\n" "$num" "$user" "$name"
        ((num++))
    done < "$USERS_FILE"
    
    echo -e "${AMARELO}─────────────────────────────────────────────────────────────────${FIM}"
    echo ""
    
    echo -ne "${AMARELO}Digite o número do usuário para editar (0 para voltar): ${FIM}"
    read -r escolha
    
    if [ "$escolha" -eq 0 ] 2>/dev/null; then
        return
    fi
    
    if ! [[ "$escolha" =~ ^[0-9]+$ ]]; then
        mensagem "ERRO" "Número inválido!"
        echo -ne "${AMARELO}Pressione ENTER...${FIM}"
        read -r
        return
    fi
    
    # Pegar linha do usuário
    linha=$(sed -n "${escolha}p" "$USERS_FILE")
    if [ -z "$linha" ]; then
        mensagem "ERRO" "Usuário não encontrado!"
        echo -ne "${AMARELO}Pressione ENTER...${FIM}"
        read -r
        return
    fi
    
    IFS=':' read -r old_user old_name old_shell old_status <<< "$linha"
    
    clear
    echo -e "${AZUL}═══════════════════════════════════════════════════════════${FIM}"
    echo -e "${VERDE}              EDITANDO USUÁRIO: $old_user                 ${FIM}"
    echo -e "${AZUL}═══════════════════════════════════════════════════════════${FIM}"
    echo ""
    
    echo -e "${CIANO}O que deseja editar?${FIM}"
    echo "   1. Nome completo"
    echo "   2. Shell"
    echo "   3. Status (Ativo/Bloqueado)"
    echo "   4. Senha"
    echo "   5. Voltar"
    echo ""
    echo -ne "${AMARELO}Escolha (1-5): ${FIM}"
    read -r opcao
    
    case $opcao in
        1)
            echo -ne "${AMARELO}Novo nome completo [atual: $old_name]: ${FIM}"
            read -r novo_nome
            [ -n "$novo_nome" ] && old_name="$novo_nome"
            ;;
        2)
            echo "Shells: 1-/bin/bash 2-/bin/sh 3-/bin/csh 4-/bin/tcsh"
            echo -ne "${AMARELO}Novo shell [atual: $old_shell]: ${FIM}"
            read -r shell_opcao
            case $shell_opcao in
                2) old_shell="/bin/sh" ;;
                3) old_shell="/bin/csh" ;;
                4) old_shell="/bin/tcsh" ;;
                *) old_shell="/bin/bash" ;;
            esac
            ;;
        3)
            if [ "$old_status" == "ativo" ]; then
                old_status="bloqueado"
                mensagem "INFO" "Usuário será BLOQUEADO"
            else
                old_status="ativo"
                mensagem "INFO" "Usuário será ATIVADO"
            fi
            ;;
        4)
            while true; do
                echo -ne "${AMARELO}Nova senha: ${FIM}"
                read -s nova_senha
                echo ""
                echo -ne "${AMARELO}Confirmar senha: ${FIM}"
                read -s confirma_senha
                echo ""
                
                if [ "$nova_senha" != "$confirma_senha" ]; then
                    mensagem "ERRO" "Senhas não conferem!"
                elif [ ${#nova_senha} -lt 4 ]; then
                    mensagem "ERRO" "Senha muito curta!"
                else
                    # Atualiza senha no arquivo de senhas
                    if [ -f "$HOME/.script_senhas.txt" ]; then
                        sed -i "/^$old_user:/d" "$HOME/.script_senhas.txt" 2>/dev/null
                    fi
                    echo "$old_user:$nova_senha" >> "$HOME/.script_senhas.txt"
                    chmod 600 "$HOME/.script_senhas.txt" 2>/dev/null
                    mensagem "SUCESSO" "Senha alterada!"
                    break
                fi
            done
            ;;
        5)
            return
            ;;
        *)
            mensagem "ERRO" "Opção inválida!"
            ;;
    esac
    
    # Salvar alterações
    if [ $opcao -ge 1 ] && [ $opcao -le 3 ]; then
        sed -i "${escolha}s/.*/$old_user:$old_name:$old_shell:$old_status/" "$USERS_FILE"
        mensagem "SUCESSO" "Usuário atualizado com sucesso!"
    fi
    
    echo ""
    echo -ne "${AMARELO}Pressione ENTER para continuar...${FIM}"
    read -r
}

# ========== FUNÇÃO PARA DELETAR USUÁRIO ==========
deletar_usuario() {
    clear
    echo -e "${AZUL}═══════════════════════════════════════════════════════════${FIM}"
    echo -e "${VERMELHO}                    DELETAR USUÁRIO                     ${FIM}"
    echo -e "${AZUL}═══════════════════════════════════════════════════════════${FIM}"
    echo ""
    
    if [ ! -s "$USERS_FILE" ]; then
        mensagem "AVISO" "Nenhum usuário cadastrado!"
        echo -ne "${AMARELO}Pressione ENTER...${FIM}"
        read -r
        return
    fi
    
    # Mostrar lista
    echo -e "${CIANO}📋 USUÁRIOS CADASTRADOS:${FIM}"
    echo -e "${AMARELO}─────────────────────────────────────────────────────────────────${FIM}"
    printf "%-3s %-15s %-25s %-10s\n" "Nº" "LOGIN" "NOME" "STATUS"
    echo -e "${AMARELO}─────────────────────────────────────────────────────────────────${FIM}"
    
    local num=1
    while IFS=':' read -r user name shell status; do
        status_icon="[${status}]"
        printf "%-3s %-15s %-25s %-10s\n" "$num" "$user" "$name" "$status_icon"
        ((num++))
    done < "$USERS_FILE"
    
    echo -e "${AMARELO}─────────────────────────────────────────────────────────────────${FIM}"
    echo ""
    
    echo -ne "${AMARELO}Digite o número do usuário para DELETAR (0 para voltar): ${FIM}"
    read -r escolha
    
    if [ "$escolha" -eq 0 ] 2>/dev/null; then
        return
    fi
    
    if ! [[ "$escolha" =~ ^[0-9]+$ ]]; then
        mensagem "ERRO" "Número inválido!"
        echo -ne "${AMARELO}Pressione ENTER...${FIM}"
        read -r
        return
    fi
    
    # Pegar nome do usuário
    linha=$(sed -n "${escolha}p" "$USERS_FILE")
    if [ -z "$linha" ]; then
        mensagem "ERRO" "Usuário não encontrado!"
        echo -ne "${AMARELO}Pressione ENTER...${FIM}"
        read -r
        return
    fi
    
    IFS=':' read -r user name shell status <<< "$linha"
    
    echo ""
    echo -e "${VERMELHO}⚠️  ATENÇÃO: Você está prestes a DELETAR o usuário '$user'${FIM}"
    echo -e "${CIANO}   Nome: $name${FIM}"
    echo -e "${CIANO}   Status: $status${FIM}"
    echo ""
    
    if perguntar_sim_nao "Tem certeza que deseja DELETAR este usuário?"; then
        # Remover do arquivo principal
        sed -i "${escolha}d" "$USERS_FILE"
        
        # Remover senha
        if [ -f "$HOME/.script_senhas.txt" ]; then
            sed -i "/^$user:/d" "$HOME/.script_senhas.txt"
        fi
        
        mensagem "SUCESSO" "Usuário '$user' foi DELETADO com sucesso!"
    else
        mensagem "INFO" "Operação cancelada"
    fi
    
    echo ""
    echo -ne "${AMARELO}Pressione ENTER para continuar...${FIM}"
    read -r
}

# ========== FUNÇÃO PARA PERGUNTAR SIM/NÃO ==========
perguntar_sim_nao() {
    local pergunta=$1
    local resposta
    
    while true; do
        echo -ne "${AMARELO}$pergunta (s/n): ${FIM}"
        read -r resposta
        case $resposta in
            [Ss]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) echo -e "${VERMELHO}Responda 's' ou 'n'${FIM}" ;;
        esac
    done
}

# ========== INFORMAÇÕES DO SISTEMA ==========
info_sistema() {
    clear
    echo -e "${AZUL}═══════════════════════════════════════════════════════════${FIM}"
    echo -e "${VERDE}                   INFORMAÇÕES DO SISTEMA                 ${FIM}"
    echo -e "${AZUL}═══════════════════════════════════════════════════════════${FIM}"
    echo ""
    
    echo -e "${CIANO}📅 Data/Hora:${FIM}      $(date)"
    echo -e "${CIANO}💻 Computador:${FIM}     $(hostname)"
    echo -e "${CIANO}👤 Usuário:${FIM}        $(whoami)"
    echo -e "${CIANO}📁 Diretório:${FIM}      $(pwd)"
    echo ""
    
    if [ -f /etc/redhat-release ]; then
        echo -e "${CIANO}🐧 Sistema:${FIM}        $(cat /etc/redhat-release)"
    else
        echo -e "${CIANO}🐧 Sistema:${FIM}        Red Hat Enterprise Linux"
    fi
    
    echo -e "${CIANO}⏱️  Atividade:${FIM}      $(uptime | awk -F'up' '{print $2}' | awk -F',' '{print $1}')"
    echo ""
    echo -e "${CIANO}📊 Usuários logados:${FIM}"
    who | awk '{print "   " $1 " - " $3 " " $4}'
    echo ""
    
    echo -e "${CIANO}💾 Espaço em disco:${FIM}"
    df -h / | awk 'NR==2 {print "   " $5 " usado de " $2 " total"}'
    echo ""
    
    echo -e "${CIANO}👥 Usuários no script: $(wc -l < "$USERS_FILE") cadastrados${FIM}"
    echo ""
    echo -e "${CIANO}🔄 Total de processos no sistema: $(ps aux | wc -l)${FIM}"
    
    echo ""
    echo -e "${AZUL}═══════════════════════════════════════════════════════════${FIM}"
    echo -ne "${AMARELO}Pressione ENTER para voltar...${FIM}"
    read -r
}

# ========== CRIAR ARQUIVOS DE TESTE ==========
criar_arquivos() {
    clear
    echo -e "${AZUL}═══════════════════════════════════════════════════════════${FIM}"
    echo -e "${VERDE}                   CRIAÇÃO DE ARQUIVOS                    ${FIM}"
    echo -e "${AZUL}═══════════════════════════════════════════════════════════${FIM}"
    echo ""
    
    echo -e "${CIANO}📁 Diretório atual: $(pwd)${FIM}"
    echo ""
    
    echo -ne "${AMARELO}Quantos arquivos? ${FIM}"
    read -r qtd
    
    if ! [[ "$qtd" =~ ^[0-9]+$ ]] || [ "$qtd" -eq 0 ]; then
        mensagem "ERRO" "Número inválido"
        echo -ne "${AMARELO}Enter para voltar...${FIM}"
        read -r
        return
    fi
    
    echo -ne "${AMARELO}Nome base: ${FIM}"
    read -r base
    [ -z "$base" ] && base="arquivo"
    
    echo ""
    echo -e "${VERDE}Criando $qtd arquivo(s)...${FIM}"
    
    for i in $(seq 1 $qtd); do
        nome="${base}_${i}.txt"
        echo "Arquivo criado em $(date) por $(whoami)" > "$nome"
        echo -e "   ✅ $nome"
    done
    
    mensagem "SUCESSO" "$qtd arquivos criados"
    
    echo ""
    echo -ne "${AMARELO}Enter para voltar...${FIM}"
    read -r
}

# ========== MENU PRINCIPAL ==========
mostrar_menu() {
    clear
    echo -e "${AZUL}═══════════════════════════════════════════════════════════${FIM}"
    echo -e "${ROXO}              SISTEMA DE GERENCIAMENTO - RHEL               ${FIM}"
    echo -e "${AZUL}═══════════════════════════════════════════════════════════${FIM}"
    echo -e "${CIANO}Arquivo de dados: $USERS_FILE${FIM}"
    echo -e "${AZUL}═══════════════════════════════════════════════════════════${FIM}"
    echo ""
    echo -e "${VERDE}📌 MENU PRINCIPAL${FIM}"
    echo ""
    echo "   1. 🖥️  Informações do sistema"
    echo "   2. 📁 Criar arquivos de teste"
    echo "   3. 🔄 Monitorar processos"
    echo ""
    echo -e "${CIANO}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${FIM}"
    echo -e "${VERDE}👥 GERENCIAMENTO DE USUÁRIOS ${FIM}"
    echo -e "${CIANO}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${FIM}"
    echo ""
    echo "   4. 📋 LISTAR todos os usuários (READ)"
    echo "   5. ➕ CRIAR novo usuário (CREATE)"
    echo "   6. ✏️  EDITAR usuário (UPDATE)"
    echo "   7. 🗑️  DELETAR usuário (DELETE)"
    echo ""
    echo "   8. 🚪 Sair"
    echo ""
    echo -e "${AZUL}═══════════════════════════════════════════════════════════${FIM}"
    echo -ne "${AMARELO}Digite sua escolha (1-8): ${FIM}"
}

# ========== FUNÇÃO PRINCIPAL ==========
main() {
    # Inicializar arquivo de usuários
    inicializar_arquivo
    
    # Tela de boas-vindas
    clear
    echo -e "${VERDE}═══════════════════════════════════════════════════════════${FIM}"
    echo -e "${VERDE}         SISTEMA DE GERENCIAMENTO DE USUÁRIOS              ${FIM}"
    echo -e "${VERDE}═══════════════════════════════════════════════════════════${FIM}"
    echo ""
    echo -e "${CIANO}✅ Sistema 100% FUNCIONAL sem necessidade de root${FIM}"
    echo -e "${CIANO}✅ CRUD completo de usuários funcionando${FIM}"
    echo -e "${CIANO}✅ Monitoramento de processos incluído${FIM}"
    echo -e "${CIANO}✅ Dados salvos em: $USERS_FILE${FIM}"
    echo ""
    echo -e "${AMARELO}⚠️  Este é um sistema de simulação local${FIM}"
    echo -e "${AMARELO}   Os usuários são salvos em um arquivo local, não no sistema operacional${FIM}"
    echo ""
    echo -ne "${AMARELO}Pressione ENTER para começar...${FIM}"
    read -r
    
    while true; do
        mostrar_menu
        read -r opcao
        
        case $opcao in
            1) info_sistema ;;
            2) criar_arquivos ;;
            3) monitorar_processos ;;
            4) listar_usuarios ;;
            5) criar_usuario ;;
            6) editar_usuario ;;
            7) deletar_usuario ;;
            8)
                clear
                echo -e "${VERDE}═══════════════════════════════════════════════════════════${FIM}"
                echo -e "${VERDE}                    SCRIPT FINALIZADO                     ${FIM}"
                echo -e "${VERDE}═══════════════════════════════════════════════════════════${FIM}"
                echo ""
                echo -e "${CIANO}📊 RESUMO FINAL:${FIM}"
                echo -e "   📁 Arquivo de usuários: $USERS_FILE"
                echo -e "   👥 Total de usuários: $(wc -l < "$USERS_FILE")"
                echo -e "   📝 Log: $LOG_FILE"
                echo ""
                echo -e "${VERDE}👋 Obrigado por usar o sistema!${FIM}"
                exit 0
                ;;
            *)
                mensagem "ERRO" "Opção inválida! Digite 1-8"
                sleep 1
                ;;
        esac
    done
}

# ========== EXECUTAR ==========
main
