#!/usr/bin/env bash
set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STACK_FILE="${ROOT_DIR}/setup/docker/docker-stack.yml"
DEV_FILE="${ROOT_DIR}/setup/docker/docker-compose.dev.yml"
BACKUP_DIR="${ROOT_DIR}/setup/backups"
ENV_FILE="${ROOT_DIR}/.env"

mkdir -p "${BACKUP_DIR}"

# Função para carregar variáveis do .env
load_env() {
    if [ -f "$ENV_FILE" ]; then
        set -a
        source "$ENV_FILE"
        set +a
    fi
}

# Helper para encontrar ID de container por nome
find_container() {
    local service_name="$1"
    docker ps --filter "name=${service_name}" --format "{{.ID}}" | head -n 1
}

# Listar todos os serviços disponíveis
ALL_SERVICES=(
    "traefik"
    "portainer"
    "jenkins"
    "postvector"
    "postgres"
    "mongodb"
    "redis"
    "rabbitmq"
    "minio"
    "evogo"
    "evoccrm"
    "n8n"
    "chromium-automation"
)

# ----------------------------------------------------
# 1. DEPLOY & ORQUESTRAÇÃO
# ----------------------------------------------------
menu_deploy() {
    echo ""
    echo "🚀 [DevOps] SELEÇÃO E DEPLOY DE SERVIÇOS"
    echo "------------------------------------------------------"
    echo "1) Produção (Docker Swarm - docker stack deploy)"
    echo "2) Desenvolvimento (Docker Compose - docker compose up)"
    echo "3) Voltar ao Menu Principal"
    echo "------------------------------------------------------"
    read -p "Opção [1-3]: " ENV_CHOICE

    if [ "$ENV_CHOICE" == "3" ]; then return; fi

    # Atualizar/Gerar chaves antes de subir
    menu_env_generate
    load_env

    echo ""
    echo "Selecione quais serviços devem ir para o ar:"
    for i in "${!ALL_SERVICES[@]}"; do
        echo "  $((i+1))) ${ALL_SERVICES[$i]}"
    done
    echo "------------------------------------------------------"
    read -p "Digite os números separados por espaço (ex: 1 4 5 10 12) ou 'ALL': " SELECTION

    local SELECTED_SERVICES=()
    if [ "$SELECTION" == "ALL" ] || [ "$SELECTION" == "all" ] || [ -z "$SELECTION" ]; then
        SELECTED_SERVICES=("${ALL_SERVICES[@]}")
    else
        for num in $SELECTION; do
            idx=$((num-1))
            if [ $idx -ge 0 ] && [ $idx -lt ${#ALL_SERVICES[@]} ]; then
                SELECTED_SERVICES+=("${ALL_SERVICES[$idx]}")
            fi
        done
    fi

    if [ ${#SELECTED_SERVICES[@]} -eq 0 ]; then
        echo "❌ Nenhum serviço válido selecionado."
        return
    fi

    echo ""
    echo "📋 Serviços Ativados (${#SELECTED_SERVICES[@]}): ${SELECTED_SERVICES[*]}"
    echo ""

    if [ "$ENV_CHOICE" == "2" ]; then
        echo "🐋 Subindo ambiente de Desenvolvimento (Docker Compose)..."
        docker compose -f "$DEV_FILE" --env-file "$ENV_FILE" up -d "${SELECTED_SERVICES[@]}"
        echo "✅ Deploy em Desenvolvimento concluído!"
    else
        echo "🐋 Subindo ambiente de Produção (Docker Swarm)..."
        if ! docker info 2>/dev/null | grep -q "Swarm: active"; then
            docker swarm init || true
        fi
        docker network create --driver overlay public_net 2>/dev/null || true

        if [ ${#SELECTED_SERVICES[@]} -eq ${#ALL_SERVICES[@]} ]; then
            docker stack deploy -c "$STACK_FILE" infra
        else
            local SELECTED_STACK_FILE="${ROOT_DIR}/setup/docker/docker-stack.selected.yml"
            node -e '
                const fs = require("fs");
                const yamlContent = fs.readFileSync(process.argv[1], "utf8");
                const selected = process.argv[2].split(",");
                let lines = yamlContent.split("\n");
                let outLines = [], inServices = false, skipService = false;
                for (let line of lines) {
                    if (line.trim().startsWith("services:")) { inServices = true; outLines.push(line); continue; }
                    if (line.trim().startsWith("networks:") || line.trim().startsWith("volumes:")) {
                        inServices = false; skipService = false; outLines.push(line); continue;
                    }
                    if (inServices) {
                        const match = line.match(/^  ([a-zA-Z0-9_-]+):/);
                        if (match) { skipService = !selected.includes(match[1]); }
                    }
                    if (!skipService) outLines.push(line);
                }
                fs.writeFileSync(process.argv[3], outLines.join("\n"), "utf8");
            ' "$STACK_FILE" "$(IFS=,; echo "${SELECTED_SERVICES[*]}")" "$SELECTED_STACK_FILE"

            docker stack deploy -c "$SELECTED_STACK_FILE" infra
        fi
        echo "✅ Deploy no Docker Swarm concluído!"
    fi
}

menu_stop() {
    echo ""
    echo "🛑 [DevOps] PARAR SERVIÇOS"
    echo "------------------------------------------------------"
    echo "1) Parar Stack de Produção (Docker Swarm)"
    echo "2) Parar Containers de Desenvolvimento (Docker Compose)"
    echo "3) Cancelar"
    echo "------------------------------------------------------"
    read -p "Opção [1-3]: " STOP_OPT
    case $STOP_OPT in
        1)
            echo "🛑 Removendo stack 'infra' do Swarm..."
            docker stack rm infra || true
            echo "⏳ Aguardando desligamento completo dos containers do Swarm (5s)..."
            sleep 5
            echo "✅ Stack encerrada com sucesso."
            ;;
        2)
            echo "🛑 Parando containers de dev..."
            docker compose -f "$DEV_FILE" down || true
            echo "✅ Ambiente de dev encerrado."
            ;;
        *) echo "Operação cancelada." ;;
    esac
}

show_status() {
    echo ""
    echo "📊 [DevOps] STATUS DA INFRAESTRUTURA"
    echo "======================================================"
    if docker info 2>/dev/null | grep -q "Swarm: active"; then
        echo "🌐 STACK DO DOCKER SWARM (infra):"
        docker stack ps infra 2>/dev/null || echo "Nenhuma stack 'infra' ativa no Swarm."
        echo ""
    fi
    echo "🐳 CONTAINERS DOCKER EM EXECUÇÃO:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    echo "======================================================"
}

# ----------------------------------------------------
# 2. SEGREDO E CREDENCIAIS (.env)
# ----------------------------------------------------
menu_env_generate() {
    echo "🔑 Processando e verificando chaves de segurança no .env..."
    if command -v node >/dev/null 2>&1; then
        node "${ROOT_DIR}/setup/scripts/manage-env.js"
    else
        echo "⚠️ Node.js não instalado localmente. Garanta que o .env esteja configurado."
    fi
}

# ----------------------------------------------------
# 3. BACKUPS E RESTAURAÇÃO
# ----------------------------------------------------
menu_backup() {
    load_env
    local TIMESTAMP="$(date +'%Y-%m-%d_%H%M%S')"
    echo ""
    echo "📦 [DevOps] GESTÃO DE BACKUPS"
    echo "------------------------------------------------------"
    echo "1) Backup Completo da Infraestrutura (Postvector, Postgres, Mongo, Redis, .env)"
    echo "2) Backup Seletivo por Banco de Dados"
    echo "3) Restaurar a partir de Backup"
    echo "4) Limpar Backups Antigos (>30 dias)"
    echo "5) Voltar ao Menu Principal"
    echo "------------------------------------------------------"
    read -p "Opção [1-5]: " BKP_OPT

    case $BKP_OPT in
        1)
            echo "🚀 Executando Backup Completo..."
            # Postvector
            local cid_pv=$(find_container "postvector")
            if [ -n "$cid_pv" ]; then
                docker exec -t "$cid_pv" pg_dump -U "${POSTGRES_USER:-postgres}" "${POSTGRES_DB:-app_db}" > "${BACKUP_DIR}/postvector_${TIMESTAMP}.sql"
                echo "✅ Postvector exportado."
            fi
            # Postgres Padrão
            local cid_pg=$(find_container "postgres")
            if [ -n "$cid_pg" ]; then
                docker exec -t "$cid_pg" pg_dump -U "${POSTGRES_STD_USER:-postgres}" "${POSTGRES_STD_DB:-evoc_db}" > "${BACKUP_DIR}/postgres_std_${TIMESTAMP}.sql"
                echo "✅ Postgres Padrão exportado."
            fi
            # MongoDB
            local cid_mg=$(find_container "mongodb")
            if [ -n "$cid_mg" ]; then
                docker exec -t "$cid_mg" mongodump --username "${MONGO_INITDB_ROOT_USERNAME:-root}" --password "${MONGO_INITDB_ROOT_PASSWORD}" --authenticationDatabase admin --archive > "${BACKUP_DIR}/mongodb_${TIMESTAMP}.archive"
                echo "✅ MongoDB exportado."
            fi
            # Redis
            local cid_rd=$(find_container "redis")
            if [ -n "$cid_rd" ]; then
                docker exec "$cid_rd" redis-cli -a "${REDIS_PASSWORD}" SAVE >/dev/null 2>&1 || true
                docker cp "$cid_rd:/data/dump.rdb" "${BACKUP_DIR}/redis_${TIMESTAMP}.rdb" 2>/dev/null || true
                echo "✅ Redis exportado."
            fi
            # .env
            if [ -f "$ENV_FILE" ]; then
                cp "$ENV_FILE" "${BACKUP_DIR}/env_${TIMESTAMP}.env"
                echo "✅ .env exportado."
            fi
            echo "🎉 Backup completo finalizado em: ${BACKUP_DIR}"
            ;;
        2)
            echo "1) Postvector | 2) Postgres Padrão | 3) MongoDB | 4) Redis"
            read -p "Opção [1-4]: " SUB_BKP
            if [ "$SUB_BKP" == "1" ]; then
                local cid=$(find_container "postvector")
                [ -n "$cid" ] && docker exec -t "$cid" pg_dump -U "${POSTGRES_USER:-postgres}" "${POSTGRES_DB:-app_db}" > "${BACKUP_DIR}/postvector_${TIMESTAMP}.sql" && echo "✅ Salvo."
            elif [ "$SUB_BKP" == "2" ]; then
                local cid=$(find_container "postgres")
                [ -n "$cid" ] && docker exec -t "$cid" pg_dump -U "${POSTGRES_STD_USER:-postgres}" "${POSTGRES_STD_DB:-evoc_db}" > "${BACKUP_DIR}/postgres_std_${TIMESTAMP}.sql" && echo "✅ Salvo."
            elif [ "$SUB_BKP" == "3" ]; then
                local cid=$(find_container "mongodb")
                [ -n "$cid" ] && docker exec -t "$cid" mongodump --username "${MONGO_INITDB_ROOT_USERNAME:-root}" --password "${MONGO_INITDB_ROOT_PASSWORD}" --authenticationDatabase admin --archive > "${BACKUP_DIR}/mongodb_${TIMESTAMP}.archive" && echo "✅ Salvo."
            elif [ "$SUB_BKP" == "4" ]; then
                local cid=$(find_container "redis")
                [ -n "$cid" ] && docker exec "$cid" redis-cli -a "${REDIS_PASSWORD}" SAVE >/dev/null 2>&1 && docker cp "$cid:/data/dump.rdb" "${BACKUP_DIR}/redis_${TIMESTAMP}.rdb" && echo "✅ Salvo."
            fi
            ;;
        3)
            echo "Arquivos disponíveis em ${BACKUP_DIR}:"
            ls -1 "${BACKUP_DIR}" 2>/dev/null || echo "Nenhum backup encontrado."
            ;;
        4)
            echo "🧹 Removendo backups com mais de 30 dias..."
            find "${BACKUP_DIR}" -type f -mtime +30 -delete
            echo "✅ Limpeza concluída."
            ;;
    esac
}

# ----------------------------------------------------
# 4. SEGURANÇA & HARDENING DA VPS
# ----------------------------------------------------
menu_security() {
    echo ""
    echo "🛡️  [DevOps] SEGURANÇA E HARDENING DA VPS"
    echo "------------------------------------------------------"
    echo "1) Executar Hardening da VPS (UFW, Fail2ban, Sysctl)"
    echo "2) Verificar Status do Firewall (UFW)"
    echo "3) Voltar"
    echo "------------------------------------------------------"
    read -p "Opção [1-3]: " SEC_OPT
    case $SEC_OPT in
        1)
            if [ -f "${ROOT_DIR}/setup/security/harden-vps.sh" ]; then
                echo "⚡ Executando script de hardening..."
                bash "${ROOT_DIR}/setup/security/harden-vps.sh"
            else
                echo "❌ Script harden-vps.sh não encontrado."
            fi
            ;;
        2)
            if command -v ufw >/dev/null 2>&1; then
                ufw status verbose
            else
                echo "⚠️ UFW não instalado no sistema."
            fi
            ;;
    esac
}

# ----------------------------------------------------
# 5. MANUTENÇÃO & LIMPEZA DOCKER
# ----------------------------------------------------
menu_maintenance() {
    echo ""
    echo "🧹 [DevOps] MANUTENÇÃO & LIMPEZA DOCKER"
    echo "------------------------------------------------------"
    echo "1) Diagnóstico de Uso de Disco (df -h & docker system df)"
    echo "2) Executar Prune Padrão no Docker (Imagens e Caches)"
    echo "3) 🔥 Hard Reset Profundo (Remover Stacks + Volumes Nomeados + Volume Prune)"
    echo "4) Voltar"
    echo "------------------------------------------------------"
    read -p "Opção [1-4]: " MNT_OPT
    case $MNT_OPT in
        1)
            echo "💾 USO DE DISCO DO SISTEMA:"
            df -h /
            echo ""
            echo "🐳 USO DE DISCO DO DOCKER:"
            docker system df
            ;;
        2)
            echo "⚠️ Esta ação irá remover containers parados, redes não utilizadas e imagens sem uso."
            read -p "Deseja continuar? (s/N): " CONFIRM
            if [[ "$CONFIRM" =~ ^[Ss]$ ]]; then
                docker system prune -af --volumes
                echo "✅ Limpeza do Docker executada com sucesso!"
            fi
            ;;
        3)
            echo "⚠️ ATENÇÃO: Esta ação irá parar a stack 'infra' e apagar TODOS os volumes nomeados do Docker (dados de bancos, certificados do Traefik, etc)."
            read -p "Tem certeza absoluta que deseja executar a LIMPEZA PROFUNDA DE VOLUMES? (digite DEEP-PURGE): " CONFIRM
            if [ "$CONFIRM" == "DEEP-PURGE" ]; then
                echo "🛑 Encerrando stack 'infra'..."
                docker stack rm infra 2>/dev/null || true
                sleep 5
                echo "🧹 Removendo volumes nomeados da infraestrutura..."
                docker volume rm $(docker volume ls -q -f name=infra_) 2>/dev/null || true
                docker volume prune -af
                docker system prune -af --volumes
                echo "🎉 Limpeza profunda concluída com sucesso! Nenhum resquício de volume antigo permaneceu."
            else
                echo "Operação de limpeza profunda cancelada."
            fi
            ;;
    esac
}

# ----------------------------------------------------
# 6. LOGS E DIAGNÓSTICO
# ----------------------------------------------------
menu_logs() {
    local target_service="$1"
    if [ -z "$target_service" ]; then
        echo "Selecione o serviço para visualizar os logs ao vivo:"
        for i in "${!ALL_SERVICES[@]}"; do
            echo "  $((i+1))) ${ALL_SERVICES[$i]}"
        done
        read -p "Número do serviço: " NUM
        idx=$((NUM-1))
        target_service="${ALL_SERVICES[$idx]}"
    fi

    if [ -n "$target_service" ]; then
        echo "📜 Exibindo logs ao vivo de: $target_service (Ctrl+C para sair)..."
        local cid=$(find_container "$target_service")
        if [ -n "$cid" ]; then
            docker logs -f --tail 100 "$cid"
        else
            docker service logs -f "infra_${target_service}" 2>/dev/null || echo "❌ Serviço/Container '$target_service' não encontrado rodando."
        fi
    fi
}

# ----------------------------------------------------
# INTERFACE PRINCIPAL & CLI HANDLER
# ----------------------------------------------------
case "$1" in
    deploy) menu_deploy ;;
    stop) menu_stop ;;
    status) show_status ;;
    env) menu_env_generate ;;
    credentials|passwords) show_credentials ;;
    backup) menu_backup ;;
    harden|security) menu_security ;;
    prune|clean) menu_maintenance ;;
    logs) menu_logs "$2" ;;
    help|--help|-h)
        echo "Uso: bash setup/devops.sh [comando]"
        echo "Comandos disponíveis: deploy, stop, status, env, credentials, backup, security, prune, logs"
        exit 0
        ;;
    *)
        while true; do
            echo ""
            echo "======================================================"
            echo "    🛠️  SCRIPT MESTRE DE GESTÃO DEVOPS (VPS)         "
            echo "======================================================"
            echo " 1) 🚀 Deploy Seletivo / Orquestração (Dev/Prod)"
            echo " 2) 🛑 Parar Serviços / Encerrar Stacks"
            echo " 3) 📊 Status da Infraestrutura & Containers"
            echo " 4) 🔑 Gerar / Ver Resumo de Credenciais (CREDENTIALS.txt)"
            echo " 5) 📦 Backup & Restauração de Dados"
            echo " 6) 🛡️  Segurança & Hardening da VPS"
            echo " 7) 🧹 Limpeza & Manutenção Docker (Prune / Limpeza de Volumes)"
            echo " 8) 📜 Logs em Tempo Real por Serviço"
            echo " 9) 🚪 Sair"
            echo "======================================================"
            read -p "Opção [1-9]: " MAIN_OPT
            case $MAIN_OPT in
                1) menu_deploy ;;
                2) menu_stop ;;
                3) show_status ;;
                4) show_credentials ;;
                5) menu_backup ;;
                6) menu_security ;;
                7) menu_maintenance ;;
                8) menu_logs ;;
                9) echo "Até logo!"; exit 0 ;;
                *) echo "❌ Opção inválida." ;;
            esac
        done
        ;;
esac
