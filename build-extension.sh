#!/bin/bash

# Script para criar pacote da extensão Chrome
# Uso: ./build-extension.sh [dev|staging|prod]

set -e

ENVIRONMENT=${1:-dev}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTENSION_DIR="${SCRIPT_DIR}/extension"
BUILD_DIR="${SCRIPT_DIR}/dist"

echo "🚀 Building Meeting AI Extension for: ${ENVIRONMENT}"
echo "================================================"

# Criar diretório de build
mkdir -p "${BUILD_DIR}"

# Definir URLs por ambiente
case $ENVIRONMENT in
  dev)
    API_URL="http://localhost:8000/api"
    HOST_PERMISSIONS='["http://localhost:8000/*", "https://api.openai.com/*", "<all_urls>"]'
    echo "📍 Environment: Development"
    ;;
  staging)
    API_URL="https://staging-api.ccm.com.br/api"
    HOST_PERMISSIONS='["https://staging-api.ccm.com.br/*", "https://api.openai.com/*", "<all_urls>"]'
    echo "📍 Environment: Staging"
    ;;
  prod)
    API_URL="https://api.ccm.com.br/api"
    HOST_PERMISSIONS='["https://api.ccm.com.br/*", "https://api.openai.com/*", "<all_urls>"]'
    echo "📍 Environment: Production"
    ;;
  *)
    echo "❌ Ambiente inválido: ${ENVIRONMENT}"
    echo "Uso: ./build-extension.sh [dev|staging|prod]"
    exit 1
    ;;
esac

echo "🔗 API URL: ${API_URL}"

# Criar diretório temporário para build
TEMP_DIR=$(mktemp -d)
echo "📁 Temp directory: ${TEMP_DIR}"

# Copiar arquivos da extensão
echo "📋 Copying extension files..."
cp -r "${EXTENSION_DIR}"/* "${TEMP_DIR}/"

# Criar config.js com URL correta
echo "⚙️  Generating config.js..."
cat > "${TEMP_DIR}/config.js" << EOF
// Configuração da extensão - Ambiente: ${ENVIRONMENT}
const CONFIG = {
    API_BASE_URL: '${API_URL}'
};
EOF

# Atualizar manifest.json com host_permissions correto (se necessário)
# Nota: Para produção, pode querer restringir os host_permissions

# Remover arquivos desnecessários
echo "🧹 Cleaning up..."
rm -f "${TEMP_DIR}/config.example.js"
rm -f "${TEMP_DIR}/README.md"
rm -rf "${TEMP_DIR}/.git"
rm -f "${TEMP_DIR}/.gitignore"
rm -f "${TEMP_DIR}/popup-old.js"
rm -f "${TEMP_DIR}/popup-old-backup.js"
rm -f "${TEMP_DIR}/popup-old-backup.html"
rm -f "${TEMP_DIR}/popup-new.html"
rm -f "${TEMP_DIR}/popup-auth.js"

# Obter versão do manifest
VERSION=$(grep '"version"' "${TEMP_DIR}/manifest.json" | sed 's/.*"version": "\(.*\)".*/\1/')
OUTPUT_FILE="${BUILD_DIR}/meeting-ai-extension-${ENVIRONMENT}-v${VERSION}.zip"

# Criar ZIP
echo "📦 Creating ZIP package..."
cd "${TEMP_DIR}"
zip -r "${OUTPUT_FILE}" . -x "*.DS_Store" > /dev/null

# Limpar
rm -rf "${TEMP_DIR}"

# Verificar resultado
if [ -f "${OUTPUT_FILE}" ]; then
    SIZE=$(du -h "${OUTPUT_FILE}" | cut -f1)
    echo ""
    echo "✅ Extension built successfully!"
    echo "================================================"
    echo "📦 Package: ${OUTPUT_FILE}"
    echo "📏 Size: ${SIZE}"
    echo "🏷️  Version: ${VERSION}"
    echo "🌍 Environment: ${ENVIRONMENT}"
    echo ""
    echo "📖 Installation instructions:"
    echo "   1. Open Chrome and go to chrome://extensions/"
    echo "   2. Enable 'Developer mode'"
    echo "   3. Click 'Load unpacked' and select the unzipped folder"
    echo "   OR"
    echo "   Upload ${OUTPUT_FILE} to Chrome Web Store"
    echo ""
else
    echo "❌ Build failed!"
    exit 1
fi
