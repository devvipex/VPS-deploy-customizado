#!/usr/bin/env bash
set -e

echo "🚀 [VPS Deploy] Iniciando setup da infraestrutura..."

# 1. Gerar / Gerenciar arquivo .env e credenciais
if command -v node >/dev/null 2>&1; then
    node setup/scripts/manage-env.js
else
    echo "⚠️ Node.js não instalado localmente. Certifique-se de que o .env está preenchido."
fi

# 2. Inicializar Docker Swarm se não estiver ativo
if ! docker info 2>/dev/null | grep -q "Swarm: active"; then
    echo "🐋 Inicializando Docker Swarm..."
    docker swarm init || true
else
    echo "✅ Docker Swarm já está ativo."
fi

# 3. Criar rede overlay pública
echo "🌐 Criando rede overlay 'public_net'..."
docker network create --driver overlay public_net 2>/dev/null || true

# 4. Imprimir instrução final
echo ""
echo "🎉 Setup concluído com sucesso!"
echo "Para abrir a central única de gestão DevOps (Deploy, Backups, Logs, Hardening e Status), execute:"
echo "   bash setup/devops.sh"
echo ""
