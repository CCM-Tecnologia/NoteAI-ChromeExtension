# 🔧 Guia de Instalação da Extensão Chrome

## Meeting AI by P&D - CCM Tecnologia

Este guia explica como instalar e configurar a extensão Chrome para transcrição de áudio.

---

## 📋 Pré-requisitos

- Google Chrome ou navegador baseado em Chromium (Edge, Brave, etc)
- Acesso à URL do backend da API (ex: `https://meetingai.ccm.com.br/api`)

---

## 🚀 Método 1: Instalação Manual (Modo Desenvolvedor)

### Para Usuários Finais:

1. **Baixar a extensão**
   - Faça download do arquivo ZIP da extensão
   - Descompacte em uma pasta de sua preferência

2. **Configurar o backend**
   - Abra o arquivo `config.js` na pasta da extensão
   - Edite a URL do backend:
   ```javascript
   const CONFIG = {
       API_BASE_URL: 'https://SEU-DOMINIO.com/api'
   };
   ```

3. **Instalar no Chrome**
   - Abra o Chrome e vá em `chrome://extensions/`
   - Ative o **Modo do desenvolvedor** (canto superior direito)
   - Clique em **Carregar sem compactação**
   - Selecione a pasta onde descompactou a extensão
   - A extensão aparecerá na barra de ferramentas

4. **Primeiro uso**
   - Clique no ícone da extensão
   - Faça login com suas credenciais
   - Configure sua chave OpenAI nas configurações
   - Comece a gravar!

---

## 🏢 Método 2: Chrome Web Store (Produção - Recomendado)

### Para Administradores:

**Vantagens:**
- ✅ Instalação com 1 clique
- ✅ Atualizações automáticas
- ✅ Mais profissional e seguro
- ✅ Gerenciamento centralizado via Google Workspace

**Processo de publicação:**

1. **Criar conta de desenvolvedor Chrome**
   - Acesse: https://chrome.google.com/webstore/devconsole
   - Taxa única: $5 USD

2. **Preparar a extensão**
   ```bash
   cd extension
   # Editar config.js com URL de produção
   # Criar arquivo ZIP
   zip -r meeting-ai-extension.zip . -x "*.git*" -x "*node_modules*"
   ```

3. **Upload na Chrome Web Store**
   - Faça upload do ZIP
   - Preencha informações (nome, descrição, screenshots)
   - Definir visibilidade:
     - **Pública**: Qualquer pessoa pode instalar
     - **Não listada**: Apenas quem tem o link
     - **Privada**: Apenas usuários do Google Workspace da empresa

4. **Publicar**
   - Tempo de revisão: 1-3 dias úteis
   - Após aprovação, usuários podem instalar diretamente

---

## 🔐 Método 3: Google Workspace (Empresas)

### Instalação Forçada para Toda Empresa:

Se sua empresa usa Google Workspace, pode forçar a instalação:

1. **Admin Console** → **Dispositivos** → **Chrome** → **Aplicativos e extensões**
2. Adicionar a extensão pelo ID (após publicar)
3. Configurar política de instalação:
   - Instalação forçada
   - Instalação permitida
   - Instalação bloqueada

**Vantagens:**
- Instalação automática em todos os computadores
- Configuração centralizada via política
- Não precisa de ação do usuário

---

## 🐳 Método 4: Servidor Web Interno (Self-Hosted)

Para distribuir internamente sem Chrome Web Store:

1. **Criar pacote CRX assinado**
   ```bash
   cd extension
   # Criar chave privada (faça UMA VEZ e guarde com segurança)
   openssl genrsa 2048 | openssl pkcs8 -topk8 -nocrypt -out key.pem
   
   # Gerar CRX assinado
   google-chrome --pack-extension=. --pack-extension-key=key.pem
   ```

2. **Hospedar no servidor web**
   ```bash
   # Copiar para servidor web
   cp meeting-ai-extension.crx /var/www/html/downloads/
   ```

3. **Criar página de download**
   ```html
   <a href="meeting-ai-extension.crx">
     Instalar Meeting AI Extension
   </a>
   ```

⚠️ **Limitação**: Chrome bloqueou instalação de CRX externos. Usuários verão aviso de segurança.

---

## ☸️ Configuração para Kubernetes

### Preparar extensão para ambiente K8s:

1. **Criar ConfigMap com configuração**
   ```yaml
   # extension-config.yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: meeting-ai-extension-config
   data:
     config.js: |
       const CONFIG = {
           API_BASE_URL: 'https://meetingai.ccm.com.br/api'
       };
   ```

2. **Gerar extensão automaticamente no CI/CD**
   ```yaml
   # .gitlab-ci.yml ou .github/workflows/build.yml
   build-extension:
     stage: build
     script:
       - cd extension
       - envsubst < config.template.js > config.js
       - zip -r meeting-ai-extension-${CI_COMMIT_TAG}.zip .
     artifacts:
       paths:
         - extension/meeting-ai-extension-*.zip
   ```

3. **Hospedar extensão em Pod nginx**
   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: extension-server
   spec:
     template:
       spec:
         containers:
         - name: nginx
           image: nginx:alpine
           volumeMounts:
           - name: extension-files
             mountPath: /usr/share/nginx/html
         volumes:
         - name: extension-files
           configMap:
             name: extension-zip-files
   ```

---

## 🌐 Configuração de URLs Dinâmicas

Para facilitar mudança de ambiente (dev/staging/prod):

1. **Criar template de config**
   ```javascript
   // config.template.js
   const CONFIG = {
       API_BASE_URL: '${API_BASE_URL}'
   };
   ```

2. **Script de build**
   ```bash
   #!/bin/bash
   # build-extension.sh
   
   ENVIRONMENT=$1  # dev, staging, prod
   
   case $ENVIRONMENT in
     dev)
       API_URL="http://localhost:8000/api"
       ;;
     staging)
       API_URL="https://staging-api.ccm.com.br/api"
       ;;
     prod)
       API_URL="https://api.ccm.com.br/api"
       ;;
   esac
   
   # Substituir variável
   export API_BASE_URL=$API_URL
   envsubst < extension/config.template.js > extension/config.js
   
   # Atualizar manifest.json com host_permissions correto
   # ...
   
   # Criar ZIP
   cd extension
   zip -r ../meeting-ai-extension-${ENVIRONMENT}.zip . \
     -x "*.git*" -x "config.template.js"
   ```

---

## 📝 Checklist de Distribuição

### Antes de distribuir:

- [ ] Atualizar `config.js` com URL de produção
- [ ] Atualizar `manifest.json`:
  - [ ] Versão incrementada
  - [ ] `host_permissions` com domínio correto
  - [ ] Descrição clara
- [ ] Testar login e gravação
- [ ] Criar screenshots para documentação
- [ ] Documentar requisitos (chave OpenAI)
- [ ] Criar guia de início rápido

### Após distribuir:

- [ ] Monitorar erros no console
- [ ] Coletar feedback dos usuários
- [ ] Planejar atualizações
- [ ] Manter changelog atualizado

---

## 🆘 Solução de Problemas

### "Extension blocked"
- Publicar na Chrome Web Store ou usar Google Workspace policy

### "API não conecta"
- Verificar `config.js` tem URL correta
- Verificar CORS no backend permite origem da extensão
- Verificar `host_permissions` no manifest.json

### "Não aparece ícone de gravação"
- Extensão precisa de `tabCapture` permission
- Funciona apenas em páginas web (não em chrome://)

---

## 📞 Suporte

Problemas com a extensão? Entre em contato:
- Email: suporte@ccm.com.br
- Documentação: https://github.com/CCM-Tecnologia/NoteAI-ChromeExtension

---

**Meeting AI by P&D - CCM Tecnologia**
Versão 2.0.0
