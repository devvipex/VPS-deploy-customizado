#!/usr/bin/env bash
set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BACKUP_DIR="${ROOT_DIR}/setup/backups"
TIMESTAMP="$(date +'%Y-%m-%d_%H%M%S')"

mkdir -p "${BACKUP_DIR}"

echo "======================================================"
echo "      📦 MENU DE BACKUP DA INFRAESTRUTURA VPS        "
echo "======================================================"
echo "Diretório de Backups: ${BACKUP_DIR}"
echo "Data/Hora: ${TIMESTAMP}"
echo "------------------------------------------------------"
echo "1) Backup Completo da Infraestrutura (Todos os Bancos + .env)"
echo "2) Backup Seletivo de Banco de Dados"
echo "3) Backup Apenas das Configurações (.env e certificados)"
echo "4) Restaurar a partir de um Backup Existente"
echo "5) Sair"
echo "======================================================"
read -p "Escolha uma opção [1-5]: " OPTION

# Carregar variáveis de ambiente se o .env existir
if [ -f "${ROOT_DIR}/.env" ]; then
    set -a
    source "${ROOT_DIR}/.env"
    set +a
fi

find_container() {
    local service_name="$1"
    local cid
    cid=$(docker ps --filter "name=${service_name}" --format "{{.ID}}" | head -n 1)
    echo "$cid"
}

backup_postvector() {
    echo "🗄️  Iniciando backup do Postvector (PostgreSQL + pgvector)..."
    local cid
    cid=$(find_container "postvector")
    if [ -n "$cid" ]; then
        local file="${BACKUP_DIR}/postvector_backup_${TIMESTAMP}.sql"
        docker exec -t "$cid" pg_dump -U "${POSTGRES_USER:-postgres}" "${POSTGRES_DB:-app_db}" > "$file"
        echo "✅ Backup do Postvector salvo em: $file"
    else
        echo "⚠️ Container 'postvector' não está rodando no momento."
    fi
}

backup_postgres_std() {
    echo "🗄️  Iniciando backup do Postgres Padrão (Unmodified)..."
    local cid
    cid=$(find_container "postgres")
    if [ -n "$cid" ]; then
        local file="${BACKUP_DIR}/postgres_std_backup_${TIMESTAMP}.sql"
        docker exec -t "$cid" pg_dump -U "${POSTGRES_STD_USER:-postgres}" "${POSTGRES_STD_DB:-evoc_db}" > "$file"
        echo "✅ Backup do Postgres Padrão salvo em: $file"
    else
        echo "⚠️ Container 'postgres' não está rodando no momento."
    fi
}

backup_mongodb() {
    echo "🍃 Iniciando backup do MongoDB..."
    local cid
    cid=$(find_container "mongodb")
    if [ -n "$cid" ]; then
        local file="${BACKUP_DIR}/mongodb_backup_${TIMESTAMP}.archive"
        docker exec -t "$cid" mongodump --username "${MONGO_INITDB_ROOT_USERNAME:-root}" --password "${MONGO_INITDB_ROOT_PASSWORD}" --authenticationDatabase admin --archive > "$file"
        echo "✅ Backup do MongoDB salvo em: $file"
    else
        echo "⚠️ Container 'mongodb' não está rodando no momento."
    fi
}

backup_redis() {
    echo "🔴 Iniciando backup do Redis..."
    local cid
    cid=$(find_container "redis")
    if [ -n "$cid" ]; then
        docker exec "$cid" redis-cli -a "${REDIS_PASSWORD}" SAVE >/dev/null 2>&1 || true
        local file="${BACKUP_DIR}/redis_dump_${TIMESTAMP}.rdb"
        docker cp "$cid:/data/dump.rdb" "$file" 2>/dev/null || echo "⚠️ Dump do Redis não pôde ser copiado."
        if [ -f "$file" ]; then
            echo "✅ Backup do Redis salvo em: $file"
        fi
    else
        echo "⚠️ Container 'redis' não está rodando no momento."
    fi
}

backup_env() {
    echo "🔑 Gerando backup das variáveis de ambiente (.env)..."
    if [ -f "${ROOT_DIR}/.env" ]; then
        local file="${BACKUP_DIR}/env_backup_${TIMESTAMP}.env"
        cp "${ROOT_DIR}/.env" "$file"
        echo "✅ Backup do .env salvo em: $file"
    else
        echo "⚠️ Arquivo .env não encontrado em ${ROOT_DIR}/.env"
    fi
}

restore_backup() {
    echo "🔄 RESTAURAÇÃO DE BACKUPS"
    echo "------------------------------------------------------"
    if [ ! -d "${BACKUP_DIR}" ] || [ -z "$(ls -A "${BACKUP_DIR}" 2>/dev/null)" ]; then
        echo "❌ Nenhum arquivo de backup encontrado em ${BACKUP_DIR}"
        return
    fi

    echo "Arquivos de backup disponíveis:"
    local files=()
    local i=1
    for f in "${BACKUP_DIR}"/*; do
        if [ -f "$f" ]; then
            files+=("$f")
            echo "$i) $(basename "$f")"
            i=$((i+1))
        fi
    done

    read -p "Selecione o número do arquivo para restaurar [1-$((i-1))]: " FILE_IDX
    local selected_file="${files[$((FILE_IDX-1))]}"

    if [ -z "$selected_file" ] || [ ! -f "$selected_file" ]; then
        echo "❌ Seleção inválida."
        return
    fi

    echo "Você selecionou: $(basename "$selected_file")"
    read -p "Tem certeza que deseja restaurar este arquivo? (s/N): " CONFIRM
    if [[ "$CONFIRM" =~ ^[Ss]$ ]]; then
        if [[ "$selected_file" == *.sql ]]; then
            read -p "Deseja restaurar no 'postvector' (1) ou no 'postgres' padrão (2)? " DB_CHOICE
            if [ "$DB_CHOICE" == "1" ]; then
                local cid
                cid=$(find_container "postvector")
                if [ -n "$cid" ]; then
                    docker exec -i "$cid" psql -U "${POSTGRES_USER:-postgres}" -d "${POSTGRES_DB:-app_db}" < "$selected_file"
                    echo "✅ Restauração no Postvector concluída."
                fi
            else
                local cid
                cid=$(find_container "postgres")
                if [ -n "$cid" ]; then
                    docker exec -i "$cid" psql -U "${POSTGRES_STD_USER:-postgres}" -d "${POSTGRES_STD_DB:-evoc_db}" < "$selected_file"
                    echo "✅ Restauração no Postgres Padrão concluída."
                fi
            fi
        elif [[ "$selected_file" == *.env ]]; then
            cp "$selected_file" "${ROOT_DIR}/.env"
            echo "✅ Arquivo .env restaurado com sucesso!"
        else
            echo "ℹ️ Formato de arquivo selecionado deve ser restaurado manualmente ou via container específico."
        fi
    else
        echo "Operação cancelada."
    fi
}

case $OPTION in
    1)
        echo "🚀 Executando Backup Completo da Infraestrutura..."
        backup_postvector
        backup_postgres_std
        backup_mongodb
        backup_redis
        backup_env
        echo "🎉 Backup completo finalizado com sucesso!"
        ;;
    2)
        echo "Selecione o banco de dados:"
        echo "1) Postvector (pgvector)"
        echo "2) Postgres Padrão"
        echo "3) MongoDB"
        echo "4) Redis"
        read -p "Opção [1-4]: " DB_OPT
        case $DB_OPT in
            1) backup_postvector ;;
            2) backup_postgres_std ;;
            3) backup_mongodb ;;
            4) backup_redis ;;
            *) echo "Opção inválida." ;;
        esac
        ;;
    3)
        backup_env
        ;;
    4)
        restore_backup
        ;;
    5)
        echo "Saindo..."
        exit 0
        ;;
    *)
        echo "❌ Opção inválida."
        exit 1
        ;;
esac
