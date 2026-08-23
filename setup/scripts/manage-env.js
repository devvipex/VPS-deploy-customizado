const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const ROOT_DIR = path.resolve(__dirname, '../../');
const DEFAULT_ENV_PATH = path.join(ROOT_DIR, '.env');
const DEFAULT_ENV_EXAMPLE_PATH = path.join(ROOT_DIR, '.env.example');
const BACKUP_DIR = path.join(ROOT_DIR, 'setup', 'backups');

const targetEnvPath = process.argv[2] ? path.resolve(process.argv[2]) : DEFAULT_ENV_PATH;
const targetEnvExamplePath = process.argv[3] ? path.resolve(process.argv[3]) : DEFAULT_ENV_EXAMPLE_PATH;

function generateSecurePassword(length = 24) {
    return crypto.randomBytes(length).toString('base64').replace(/[^a-zA-Z0-9]/g, '').slice(0, length);
}

function generateUUID() {
    return crypto.randomUUID();
}

function getFormattedDate() {
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
}

function parseEnv(content) {
    const env = {};
    const lines = content.split('\n');
    for (const line of lines) {
        const trimmed = line.trim();
        if (!trimmed || trimmed.startsWith('#')) continue;
        const eqIdx = trimmed.indexOf('=');
        if (eqIdx !== -1) {
            const key = trimmed.slice(0, eqIdx).trim();
            const value = trimmed.slice(eqIdx + 1).trim();
            env[key] = value;
        }
    }
    return env;
}

function isSecretKey(key) {
    const uppercaseKey = key.toUpperCase();
    const secretKeywords = ['PASSWORD', 'PASS', 'SECRET', 'KEY', 'TOKEN', 'AUTH'];
    return secretKeywords.some(keyword => uppercaseKey.includes(keyword));
}

function main() {
    console.log(`🚀 [Setup ENV] Processando arquivo de ambiente: ${targetEnvPath}`);

    if (!fs.existsSync(BACKUP_DIR)) {
        fs.mkdirSync(BACKUP_DIR, { recursive: true });
    }

    let envContent = '';
    let isNewFile = false;

    if (!fs.existsSync(targetEnvPath)) {
        if (!fs.existsSync(targetEnvExamplePath)) {
            console.error(`❌ Arquivo exemplo não encontrado em: ${targetEnvExamplePath}`);
            process.exit(1);
        }
        console.log(`📄 Criando novo arquivo .env a partir do template: ${targetEnvExamplePath}`);
        envContent = fs.readFileSync(targetEnvExamplePath, 'utf-8');
        isNewFile = true;
    } else {
        envContent = fs.readFileSync(targetEnvPath, 'utf-8');
        // Se .env.example existir, verificar e anexar chaves novas que estejam ausentes
        if (fs.existsSync(targetEnvExamplePath)) {
            const exampleContent = fs.readFileSync(targetEnvExamplePath, 'utf-8');
            const currentKeys = new Set(Object.keys(parseEnv(envContent)));
            const exampleLines = exampleContent.split('\n');
            let missingLines = [];
            for (const line of exampleLines) {
                const trimmed = line.trim();
                if (!trimmed || trimmed.startsWith('#')) continue;
                const eqIdx = trimmed.indexOf('=');
                if (eqIdx !== -1) {
                    const key = trimmed.slice(0, eqIdx).trim();
                    if (!currentKeys.has(key)) {
                        missingLines.push(line);
                    }
                }
            }
            if (missingLines.length > 0) {
                console.log(`➕ Adicionando ${missingLines.length} nova(s) variável(is) proveniente(s) do template.`);
                envContent += '\n# Variable(s) added automatically from template:\n' + missingLines.join('\n') + '\n';
            }
        }
    }

    const currentEnv = parseEnv(envContent);

    const hasExistingPasswords = Object.keys(currentEnv).some(key => isSecretKey(key) && currentEnv[key] && currentEnv[key].length > 0);

    if (!isNewFile && hasExistingPasswords) {
        const targetFileName = path.basename(targetEnvPath, '.env');
        const backupFileName = `env_bkp_${targetFileName}_${getFormattedDate()}_${generateUUID()}.env`;
        const backupPath = path.join(BACKUP_DIR, backupFileName);
        fs.writeFileSync(backupPath, envContent, 'utf-8');
        console.log(`📦 Backup do .env existente salvo em: setup/backups/${backupFileName}`);
    }

    let updatedLines = envContent.split('\n');
    let generatedCount = 0;

    updatedLines = updatedLines.map(line => {
        const trimmed = line.trim();
        if (!trimmed || trimmed.startsWith('#')) return line;
        
        const eqIdx = trimmed.indexOf('=');
        if (eqIdx === -1) return line;

        const key = trimmed.slice(0, eqIdx).trim();
        const currentValue = trimmed.slice(eqIdx + 1).trim();

        if (isSecretKey(key) && (!currentValue || currentValue === '')) {
            const length = (key.includes('KEY') || key.includes('SECRET') || key.includes('TOKEN')) ? 32 : 24;
            const newPassword = generateSecurePassword(length);
            generatedCount++;
            return `${key}=${newPassword}`;
        }

        return line;
    });

    fs.writeFileSync(targetEnvPath, updatedLines.join('\n'), 'utf-8');

    const finalEnv = parseEnv(fs.readFileSync(targetEnvPath, 'utf-8'));
    const credPath = path.join(ROOT_DIR, 'setup', 'CREDENTIALS.txt');
    const domain = finalEnv['DOMAIN_NAME'] || 'localhost';

    const credContent = `======================================================
     🔑 RESUMO DE CREDENCIAIS & ACESSOS DA INFRAESTRUTURA
======================================================
Cliente           : ${finalEnv.CLIENT_NAME || 'n/a'}
Domínio Principal : ${domain}
E-mail SSL        : ${finalEnv.TRAEFIK_ACME_EMAIL || 'n/a'}
Data da Atualização: ${getFormattedDate()}

--- [1. PROXY REVERSO & GESTÃO] ---
Traefik Dashboard : http://localhost:8082
Portainer CE      : https://portainer.${domain}

--- [2. CI/CD & BUILDS] ---
Jenkins CI/CD     : https://jenkins.${domain}
Jenkins Admin User: ${finalEnv.JENKINS_ADMIN_USER || 'admin'}
Jenkins Password  : ${finalEnv.JENKINS_ADMIN_PASSWORD || '(gerado dinamicamente)'}

--- [3. BANCOS DE DADOS & CACHE] ---
Postvector (AI)   : User=${finalEnv.POSTGRES_USER || 'postgres'} | Pass=${finalEnv.POSTGRES_PASSWORD || 'n/a'} | DB=${finalEnv.POSTGRES_DB || 'app_db'}
Postgres Padrão   : User=${finalEnv.POSTGRES_STD_USER || 'postgres'} | Pass=${finalEnv.POSTGRES_STD_PASSWORD || 'n/a'} | DB=${finalEnv.POSTGRES_STD_DB || 'evoc_db'}
MongoDB           : User=${finalEnv.MONGO_INITDB_ROOT_USERNAME || 'root'} | Pass=${finalEnv.MONGO_INITDB_ROOT_PASSWORD || 'n/a'}
Redis             : Pass=${finalEnv.REDIS_PASSWORD || 'n/a'}

--- [4. MESSAGING & STORAGE] ---
RabbitMQ          : User=${finalEnv.RABBITMQ_DEFAULT_USER || 'admin'} | Pass=${finalEnv.RABBITMQ_DEFAULT_PASS || 'n/a'}
MinIO Console     : https://minio.${domain} | User=${finalEnv.MINIO_ROOT_USER || 'minioadmin'} | Pass=${finalEnv.MINIO_ROOT_PASSWORD || 'n/a'}

--- [5. APLICAÇÕES EVOLUTION & AUTOMAÇÃO] ---
n8n Workflows     : https://n8n.${domain} | EncryptionKey=${finalEnv.N8N_ENCRYPTION_KEY || 'n/a'}
Evogo (API)       : https://evogo.${domain} | API_KEY=${finalEnv.EVOGO_API_KEY || 'n/a'}
Evoccrm (CRM)     : https://crm.${domain} | Secret=${finalEnv.EVOCCRM_SECRET_KEY || 'n/a'}
======================================================
`;

    fs.writeFileSync(credPath, credContent, 'utf-8');
    const bkpCredPath = path.join(BACKUP_DIR, `credentials_${getFormattedDate()}.txt`);
    fs.writeFileSync(bkpCredPath, credContent, 'utf-8');

    if (generatedCount > 0) {
        console.log(`✅ [Setup ENV] ${generatedCount} variáveis seguras geradas com sucesso!`);
    } else {
        console.log('ℹ️ [Setup ENV] Todas as variáveis de senha/segurança já estavam preenchidas.');
    }
    console.log(`📄 Resumo de credenciais salvo em: setup/CREDENTIALS.txt`);

    if (!domain || domain === 'localhost' || domain === 'cliente-demo.com') {
        console.log('\n⚠️ [ATENÇÃO DOMÍNIO] DOMAIN_NAME está configurado como "' + domain + '".');
        console.log('👉 Para produção com SSL (Let\'s Encrypt), edite o arquivo .env e defina DOMAIN_NAME com seu domínio real (ex: DOMAIN_NAME=pablodantascorretor.com).\n');
    }
}

main();
