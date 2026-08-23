#!/usr/bin/env bash
set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
STACK_FILE="${ROOT_DIR}/setup/docker/docker-stack.yml"
DEV_FILE="${ROOT_DIR}/setup/docker/docker-compose.dev.yml"

echo "======================================================"
echo "    🚀 MENU INTERATIVO DE DEPLOY DE SERVIÇOS VPS      "
echo "======================================================"
echo "Selecione o ambiente de implantação:"
echo "1) Produção (Docker Swarm - docker stack deploy)"
echo "2) Desenvolvimento (Docker Compose - docker compose up)"
echo "3) Sair"
echo "======================================================"
read -p "Opção [1-3]: " ENV_CHOICE

if [ "$ENV_CHOICE" == "3" ]; then
    echo "Saindo..."
    exit 0
fi

# 1. Garantir que as chaves de ambiente foram geradas
if command -v node >/dev/null 2>&1; then
    node "${ROOT_DIR}/setup/scripts/manage-env.js"
fi
if [ -f "${ROOT_DIR}/.env" ]; then
    set -a
    source "${ROOT_DIR}/.env"
    set +a
fi

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

echo ""
echo "======================================================"
echo "          SELEÇÃO DE SERVIÇOS PARA SUBIR             "
echo "======================================================"
echo "Selecione quais serviços devem ir para o ar."
echo "Digite os números separados por espaço (ex: 1 4 5 10 12) ou 'ALL' para todos:"
echo ""

for i in "${!ALL_SERVICES[@]}"; do
    echo "  $((i+1))) ${ALL_SERVICES[$i]}"
done
echo "======================================================"
read -p "Serviços a ativar: " SELECTION

SELECTED_SERVICES=()

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
    echo "❌ Nenhum serviço válido foi selecionado."
    exit 1
fi

echo ""
echo "📋 Serviços Selecionados (${#SELECTED_SERVICES[@]}):"
for s in "${SELECTED_SERVICES[@]}"; do
    echo "  • $s"
done
echo ""

if [ "$ENV_CHOICE" == "2" ]; then
    echo "🐋 Subindo serviços no ambiente de Desenvolvimento (Docker Compose)..."
    docker compose -f "$DEV_FILE" --env-file "${ROOT_DIR}/.env" up -d "${SELECTED_SERVICES[@]}"
    echo "🎉 Deploy em Desenvolvimento concluído com sucesso!"
else
    echo "🐋 Preparando ambiente de Produção (Docker Swarm)..."
    if ! docker info 2>/dev/null | grep -q "Swarm: active"; then
        docker swarm init || true
    fi
    docker network create --driver overlay public_net 2>/dev/null || true

    # Se todos foram selecionados, usa a stack completa diretamente
    if [ ${#SELECTED_SERVICES[@]} -eq ${#ALL_SERVICES[@]} ]; then
        docker stack deploy -c "$STACK_FILE" infra
    else
        echo "⚙️  Filtrando stack para serviços selecionados..."
        SELECTED_STACK_FILE="${ROOT_DIR}/setup/docker/docker-stack.selected.yml"
        
        # Gerar arquivo de stack seletivo a partir do yml principal usando script auxiliares ou yq/node
        node -e '
            const fs = require("fs");
            const yamlContent = fs.readFileSync(process.argv[1], "utf8");
            const selected = process.argv[2].split(",");
            
            let lines = yamlContent.split("\n");
            let outLines = [];
            let inServices = false;
            let currentService = null;
            let skipService = false;
            
            for (let line of lines) {
                if (line.trim().startsWith("services:")) {
                    inServices = true;
                    outLines.push(line);
                    continue;
                }
                if (line.trim().startsWith("networks:") || line.trim().startsWith("volumes:")) {
                    inServices = false;
                    currentService = null;
                    skipService = false;
                    outLines.push(line);
                    continue;
                }
                if (inServices) {
                    const match = line.match(/^  ([a-zA-Z0-9_-]+):/);
                    if (match) {
                        currentService = match[1];
                        skipService = !selected.includes(currentService);
                    }
                }
                if (!skipService) {
                    outLines.push(line);
                }
            }
            fs.writeFileSync(process.argv[3], outLines.join("\n"), "utf8");
        ' "$STACK_FILE" "$(IFS=,; echo "${SELECTED_SERVICES[*]}")" "$SELECTED_STACK_FILE"

        docker stack deploy -c "$SELECTED_STACK_FILE" infra
    fi
    echo "🎉 Deploy no Swarm executado para os serviços selecionados!"
fi
