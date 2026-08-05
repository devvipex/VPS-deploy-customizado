# 🚀 VPS Deploy Customizado & Base MVP Stack

Este é um projeto base open-source criado para acelerar drasticamente o setup e o deploy de novos projetos (MVPs) em uma VPS. Se você precisa de uma infraestrutura robusta, escalável e de fácil replicação para novos clientes, este repositório é a fundação ideal!

## 🎯 O Fluxo de Trabalho

O fluxo foi desenhado para ser absurdamente simples, seguro e rápido:
1. **Clone** este repositório na VPS do cliente.
2. **Ajuste** o arquivo de configuração (como o `.env`), definindo parâmetros específicos do cliente.
3. Tudo pronto para rodar!

## 🛠️ Infraestrutura e Base de Serviços

A infraestrutura foi pensada para alta disponibilidade e fácil gerenciamento, rodando sob **Docker Swarm** e **Portainer**, com o **Traefik** atuando como proxy reverso e gerenciador de certificados.

O ambiente já sobe com os seguintes serviços pré-configurados:
- **Bancos de Dados & Cache:** MongoDB, Redis e Postvector (banco vetorial).
- **Mensageria & Storage:** RabbitMQ e MinIO (compatível com S3).
- **CI/CD & Builds:** Jenkins (incluso para simplificar o processo de build das aplicações pela interface, eliminando a complexidade de gerenciar um Registry externo apenas para o Portainer).
- **Automação:** n8n.
- **Testes:** Configuração de path do Chromium pronta para rodar automações de teste E2E.

### 💻 Stack Padrão das Aplicações
Os projetos que rodam nessa base seguem uma arquitetura moderna e voltada para a melhor experiência do usuário final:
- **Backend:** NestJS API.
- **Frontend/Mobile:** Vite PWA (Progressive Web App) desenvolvido com design **Mobile First**.
- **Resiliência:** Arquitetura **Offline First**, permitindo que o usuário interaja sem internet e os dados sejam sincronizados automaticamente ao recuperar a conexão.

## 🔒 Segurança e Gerenciamento de Senhas

Não guarde senhas no código! As senhas e variáveis críticas dos serviços são geradas automaticamente no primeiro setup. 
Para garantir a segurança nas atualizações, se você precisar gerar novas senhas, o sistema identifica as credenciais existentes e salva um **backup automático** utilizando a data e um identificador único (ex: `bkp_2026-08-05_uuid`).

---

💡 **Sugestão de texto para o Post (LinkedIn):**

*"Sempre que fechava com um novo cliente, eu perdia horas configurando a infraestrutura da VPS do zero. Para resolver isso, criei e estou disponibilizando open-source meu boilerplate de infraestrutura e deploy! 🚀*

*Ele sobe um ambiente completo com Docker Swarm, Traefik, Portainer, Jenkins, MongoDB, Redis, RabbitMQ, MinIO, n8n e Postvector.*

*Tudo se resume a clonar o repositório, ajustar o `.env` e as senhas seguras são geradas automaticamente (com rotina de backup nativa). A stack base foi pensada para aplicações Mobile-First com NestJS na API e Vite PWA Offline-first no front.*

*Se você também constrói MVPs e quer acelerar seu fluxo de deploy, dá uma olhada no repositório! Toda contribuição e feedback são muito bem-vindos. 🤝 #OpenSource #DockerSwarm #NestJS #Vite #DevOps #WebDevelopment"*
