# 📦 Extensão Chrome - Pacotes de Distribuição

Este diretório contém os pacotes ZIP da extensão prontos para distribuição.

## Arquivos Disponíveis

- `meeting-ai-extension-dev-v2.0.0.zip` - Para desenvolvimento (localhost)
- `meeting-ai-extension-staging-v2.0.0.zip` - Para ambiente de staging
- `meeting-ai-extension-prod-v2.0.0.zip` - Para produção

## 🚀 Como Distribuir

### Opção 1: Instalação Manual (Modo Desenvolvedor)

Envie o arquivo ZIP para os usuários e instrua a:

1. Descompactar o arquivo ZIP
2. Abrir `chrome://extensions/`
3. Ativar "Modo desenvolvedor"
4. Clicar em "Carregar sem compactação"
5. Selecionar a pasta descompactada

**Guia completo:** `../extension/INSTALL-GUIDE.md`

### Opção 2: Chrome Web Store (Recomendado)

1. Acesse: https://chrome.google.com/webstore/devconsole
2. Faça upload do arquivo ZIP (prod)
3. Preencha informações e screenshots
4. Publique (revisão leva 1-3 dias)

**Vantagens:**
- ✅ Instalação com 1 clique
- ✅ Atualizações automáticas
- ✅ Não precisa "Modo desenvolvedor"

### Opção 3: Servidor Interno

Hospede o ZIP em um servidor web interno:

```bash
# Copiar para servidor web
cp meeting-ai-extension-prod-v2.0.0.zip /var/www/html/downloads/

# Ou usar Kubernetes (veja ../k8s/extension-server.yaml)
kubectl apply -f ../k8s/extension-server.yaml
```

Usuários acessam: `http://extensions.ccm.com.br/download`

## 🔄 Rebuild

Para gerar novos pacotes:

```bash
# Desenvolvimento
./build-extension.sh dev

# Staging
./build-extension.sh staging

# Produção
./build-extension.sh prod
```

## 📋 URLs Configuradas

| Ambiente | API URL |
|----------|---------|
| dev | http://localhost:8000/api |
| staging | https://staging-api.ccm.com.br/api |
| prod | https://api.ccm.com.br/api |

Para alterar URLs, edite: `../build-extension.sh`

## 🎯 Próximos Passos

1. **Testar localmente**
   - Descompactar o ZIP dev
   - Instalar no Chrome
   - Verificar funcionamento

2. **Publicar na Web Store**
   - Upload do ZIP prod
   - Aguardar aprovação

3. **Configurar CI/CD**
   - Automatizar build em cada release
   - Publicar automaticamente

4. **Monitorar**
   - Coletar feedback dos usuários
   - Acompanhar erros no console
