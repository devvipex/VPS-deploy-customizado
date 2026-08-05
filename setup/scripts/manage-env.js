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
            const length = (key.includes('KEY') || key.includes('SECRET')) ? 32 : 24;
            const newPassword = generateSecurePassword(length);
            generatedCount++;
            return `${key}=${newPassword}`;
        }

        return line;
    });

    fs.writeFileSync(targetEnvPath, updatedLines.join('\n'), 'utf-8');

    if (generatedCount > 0) {
        console.log(`✅ [Setup ENV] ${generatedCount} variáveis seguras geradas com sucesso!`);
    } else {
        console.log('ℹ️ [Setup ENV] Todas as variáveis de senha/segurança já estavam preenchidas.');
    }
}

main();
