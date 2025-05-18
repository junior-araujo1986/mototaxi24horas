#!/bin/bash

echo "🚀 Subindo projeto completo para GitHub - Mototaxi 24 Horas"

# Pasta base
cd ~/mototaxi24horas || { echo "❌ Pasta ~/mototaxi24horas não encontrada"; exit 1; }

# Criar repositório Git se ainda não existir
if [ ! -d ".git" ]; then
    echo "📦 Iniciando repositório Git..."
    git init
    git config --local user.email "seu@email.com"
    git config --local user.name "grupoja"
    git remote add origin git@github.com:junior-araujo1986/mototaxi24horas.git
else
    echo "🔄 Atualizando repositório Git..."
    git remote set-url origin git@github.com:junior-araujo1986/mototaxi24horas.git
fi

# Criar .gitignore se não existir
cat > .gitignore << EOL
# Arquivos temporários e builds
node_modules/
package-lock.json
build/
.dart_tool/
.pub-cache/
flutter/.dart_tool/
flutter/build/

# Configurações de IDEs
*.iml
.idea/
.vscode/
*.log
EOL

# Adicionar todos os arquivos
echo "📥 Adicionando arquivos ao repositório..."
git add .

# Commitar
echo "📝 Fazendo commit inicial..."
git commit -m "✅ Primeiro commit: Frontend web + App móvel com Flutter"

# Fazer push para GitHub
echo "📤 Enviando para GitHub..."
git branch -M main
git push -u origin main --force

echo "✅ Projeto enviado com sucesso!"
echo "🔗 Acesse em: https://github.com/junior-araujo1986/mototaxi24horas "
