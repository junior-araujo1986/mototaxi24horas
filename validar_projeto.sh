#!/bin/bash

echo "🔍 Iniciando validação completa do projeto Mototaxi 24 Horas"

# Pasta base
cd ~/mototaxi24horas || { echo "❌ Pasta ~/mototaxi24horas não encontrada"; exit 1; }

# Variáveis de caminho
FRONTEND_DIR="frontend_vite"
MOBILE_DIR="mototaxi_app"
BACKEND_DIR="backend"
MAP_COMPONENT="$FRONTEND_DIR/src/components/Map/MapComponent.jsx"
PLACE_SEARCH="$FRONTEND_DIR/src/components/Map/PlaceSearch.jsx"
MOTORISTA_DASHBOARD="$FRONTEND_DIR/src/components/MotoristaDashboard.jsx"
MAIN_DART="$MOBILE_DIR/lib/main.dart"
DASHBOARD_DART="$MOBILE_DIR/lib/screens/dashboard_screen.dart"
LOGIN_DART="$MOBILE_DIR/lib/screens/login_screen.dart"
ANDROID_MANIFEST="$MOBILE_DIR/android/app/src/main/AndroidManifest.xml"
DOCKER_COMPOSE="docker-compose.yml"
GITHUB_SSH_KEY=~/.ssh/id_ed25519
GITHUB_SSH_PUB=~/.ssh/id_ed25519.pub

# Função para validar arquivos
function verificar_arquivo() {
    if [ -f "$1" ]; then
        echo "✅ $1 — arquivo OK"
    else
        echo "❌ Arquivo não encontrado: $1"
        echo "➡️ Crie-o ou confira a importação"
    fi
}

# Função para validar diretórios
function verificar_diretorio() {
    if [ -d "$1" ]; then
        echo "📁 $1 — pasta OK"
    else
        echo "❌ Pasta não encontrada: $1"
        echo "➡️ Execute: mkdir -p $1"
    fi
}

# Função para validar chave SSH
function validar_ssh() {
    if [ -f "$GITHUB_SSH_KEY" ] && [ -f "$GITHUB_SSH_PUB" ]; then
        echo "🔐 Chave SSH encontrada"
        ssh -T git@github.com &>/dev/null
        if [ $? -eq 1 ]; then
            echo "✅ Conexão com GitHub via SSH OK"
        else
            echo "⚠️ Chave SSH criada, mas não reconhecida pelo GitHub"
            echo "➡️ Cole esta chave pública no GitHub: https://github.com/settings/keys "
            cat "$GITHUB_SSH_PUB"
        fi
    else
        echo "🔑 Chave SSH não encontrada"
        echo "➡️ Gerando nova chave..."
        ssh-keygen -t ed25519 -C "seu@email.com" -N ""
        eval "$(ssh-agent -s)"
        ssh-add ~/.ssh/id_ed25519
        echo "➡️ Chave criada. Cole no GitHub:"
        cat ~/.ssh/id_ed25519.pub
    fi
}

# Função para validar estrutura do frontend web
function validar_frontend() {
    verificar_diretorio "$FRONTEND_DIR"
    verificar_arquivo "$MAP_COMPONENT"
    verificar_arquivo "$PLACE_SEARCH"
    verificar_arquivo "$MOTORISTA_DASHBOARD"
}

# Função para validar estrutura do app móvel
function validar_mobile() {
    verificar_diretorio "$MOBILE_DIR"
    verificar_arquivo "$MAIN_DART"
    verificar_arquivo "$DASHBOARD_DART"
    verificar_arquivo "$LOGIN_DART"
    verificar_arquivo "$ANDROID_MANIFEST"
}

# Função para validar Docker
function validar_docker() {
    verificar_arquivo "$DOCKER_COMPOSE"
}

# Função para validar vulnerabilidades npm
function validar_npm() {
    cd "$FRONTEND_DIR" || return
    echo "🧾 Rodando npm audit..."
    npm audit fix --force
}

# Função para validar build do Flutter
function validar_flutter_build() {
    cd "$MOBILE_DIR" || return
    echo "📱 Fazendo flutter pub get..."
    flutter pub get
    echo "📱 Fazendo flutter build apk --release..."
    flutter build apk --release
    if [ $? -eq 0 ]; then
        echo "✅ APK gerado com sucesso!"
    else
        echo "❌ Erro ao gerar APK. Confira dependências e AndroidManifest.xml"
    fi
}

# Valida tudo
echo "📄 Validando frontend web..."
validar_frontend

echo ""
echo "📱 Validando app móvel..."
validar_mobile

echo ""
echo "🔒 Validando chave SSH..."
validar_ssh

echo ""
echo "📦 Validando Docker..."
validar_docker

echo ""
echo "🧱 Validando build do Flutter..."
validar_flutter_build

echo ""
echo "🛡️ Validando vulnerabilidades do npm..."
validar_npm

echo ""
echo "✅ Validação finalizada!"
echo "📌 Projeto pronto para desenvolvimento e deploy"
