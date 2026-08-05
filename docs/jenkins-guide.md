# 🏗️ Guia do Jenkins & Gerenciamento Dinâmico de `.env`

Este guia explica como o Jenkins lê, **gera senhas seguras automaticamente (se necessário)** e injeta as variáveis de ambiente `.env` para cada projeto do cliente.

---

## 🔑 1. Como funciona a Geração & Injeção de `.env`?

Quando o Jenkins inicia o build de qualquer repositório, o estágio `2. Gerar & Injetar Variáveis (.env)` do **`Jenkinsfile`** executa o script de automação:

```bash
node /opt/vps-deploy/setup/scripts/manage-env.js /opt/vps-deploy/setup/env/apps/<NOME_APP>.env /opt/vps-deploy/setup/env/apps/<NOME_APP>.env.example
```

### O fluxo automático:
1. **Se o `.env` do aplicativo ainda não existir:** Ele cria a partir do arquivo `.env.example` do projeto.
2. **Geração Automática de Segredos:** Qualquer variável vazia referente a senhas ou chaves (`JWT_SECRET`, `API_KEY`, `DB_PASSWORD`, `TOKEN`, etc.) é preenchida com um valor aleatório de alta segurança de 24 a 32 caracteres.
3. **Backup Automático:** Se as senhas já existiam e foram modificadas, um arquivo `env_bkp_<NOME_APP>_YYYY-MM-DD_UUID.env` é gerado automaticamente na pasta `setup/backups/`.
4. **Cópia para o Build:** O arquivo verificado e seguro é copiado como `.env` no diretório do projeto antes do `docker build`.

---

## 🧹 2. Limpeza Automática de Imagens (Evitando disco cheio)

Toda vez que o Docker compila uma nova imagem (`docker build`), a imagem anterior perde a tag e se torna uma **imagem "dangling" (órfã)**. Se não forem apagadas, a VPS fica sem espaço em disco rapidamente.

O **`setup/jenkins/Jenkinsfile.template`** inclui a instrução de pós-execução:

```groovy
post {
    always {
        echo "🧹 [Limpeza Automática] Removendo imagens antigas e sem tag..."
        sh "docker image prune -f --filter 'until=24h'"
    }
}
```

---

## 🚀 3. Criando um Novo Job no Jenkins

1. Acesse o Jenkins em `http://jenkins.<DOMAIN_NAME>` (ou `http://localhost:8080`).
2. Clique em **Novo Job** -> Escolha **Pipeline**.
3. Em **Pipeline**, selecione **Pipeline script from SCM**.
4. Informe a URL do repositório Git do projeto e o caminho do arquivo `Jenkinsfile`.
5. Salve e execute o **Build Now**.
