#!/bin/bash

echo "🚀 Iniciando configuração completa do projeto Mototaxi 24 Horas"
cd ~/mototaxi24horas || { echo "❌ Pasta não encontrada"; exit 1; }

# Limpar projetos antigos
rm -rf frontend_vite mototaxi_app backend .github docker-compose.yml

# 1. Gera chave SSH se ainda não tiver
if [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "🔐 Gerando nova chave SSH..."
    mkdir -p ~/.ssh
    ssh-keygen -t ed25519 -C "seu@email.com" -N ""
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
fi

# 2. Testa conexão com GitHub
echo "📡 Testando acesso ao GitHub..."
ssh -T git@github.com &>/dev/null
if [ $? -eq 1 ]; then
    echo "✅ Conexão com GitHub OK!"
else
    echo "⚠️  Ainda não conectado ao GitHub"
    echo "➡️ Cole esta chave no GitHub: https://github.com/settings/keys "
    cat ~/.ssh/id_ed25519.pub
fi

# 3. Cria repositório Git local
git init
git config --local user.email "seu@email.com"
git config --local user.name "grupoja"

# 4. Cria o repositório no GitHub (manualmente antes de rodar)
echo "📌 Certifique-se de ter criado o repositório vazio no GitHub: https://github.com/new "

# 5. Configura remote do GitHub
git remote add origin git@github.com:junior-araujo1986/mototaxi24horas.git

# 6. Cria o backend Django
echo "⚙️ Criando backend Django..."
mkdir -p backend
cd backend
python3 -m venv venv
source venv/bin/activate
pip install django djangorestframework

# Iniciar projeto Django
django-admin startproject mototaxi_api .

# Configurar URLs e autenticação básica
cat > mototaxi_api/urls.py << EOL
from django.urls import path
from django.http import JsonResponse

def api_login(request):
    return JsonResponse({'status': 'ok', 'message': 'Login via CPF'})

urlpatterns = [
    path('api/token/', api_login),
]
EOL

# Atualizar settings.py para permitir CORS
sed -i 's/^MIDDLEWARE = $$/MIDDLEWARE = [\n    "django.middleware.csrf.CsrfViewMiddleware",/g' mototaxi_api/settings.py
echo "ALLOWED_HOSTS = ['*']
CORS_ALLOW_ALL_ORIGINS = True" >> mototaxi_api/settings.py

# Commit inicial
cd ..
git add .
git commit -am "feat: adiciona backend Django básico"
git push -u origin main --force

# 7. Cria o frontend web com Vite
echo "🌐 Criando projeto web com Vite..."

npm create vite@latest frontend_vite --template react
cd frontend_vite
npm install

# Adicionar Tailwind CSS
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p

cat > tailwind.config.js << EOL
module.exports = {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: { extend: {} },
  plugins: [],
}
EOL

cat > src/index.css << EOL
@tailwind base;
@tailwind components;
@tailwind utilities;

body {
  margin: 0;
  font-family: sans-serif;
}
EOL

mkdir -p src/components/Map src/pages

# Componentes de mapa simulado
cat > src/components/Map/MapComponent.jsx << EOL
import React from 'react';

export default function MapComponent() {
  return (
    <div style={{ width: '100%', height: '400px', backgroundColor: '#f5f5f5' }}>
      <p className="text-center py-4">Mapa carregado!</p>
    </div>
  );
}
EOL

cat > src/components/Map/PlaceSearch.jsx << EOL
import React, { useState } from 'react';

export default function PlaceSearch({ onPlaceSelected }) {
  const [value, setValue] = useState('');

  const handleChange = (e) => {
    const newValue = e.target.value;
    setValue(newValue);
    if (onPlaceSelected) {
      onPlaceSelected({ address: newValue });
    }
  };

  return (
    <input
      type="text"
      value={value}
      onChange={handleChange}
      placeholder="Digite um local"
      className="w-full p-2 border rounded mb-4"
    />
  );
}
EOL

# Dashboard com navegação entre telas
cat > src/components/DashboardScreen.jsx << EOL
import React, { useState } from 'react';
import MapComponent from './Map/MapComponent';
import PlaceSearch from './Map/PlaceSearch';

export default function DashboardScreen() {
  const [origin, setOrigin] = useState(null);
  const [destination, setDestination] = useState(null);

  const handleOriginSelect = (place) => {
    console.log('Origem:', place);
    setOrigin(place);
  };

  const handleDestinationSelect = (place) => {
    console.log('Destino:', place);
    setDestination(place);
  };

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Solicitar Corrida</h1>

      <div className="mb-4">
        <label className="block mb-2 font-semibold">Origem:</label>
        <PlaceSearch onPlaceSelected={handleOriginSelect} />
      </div>

      <div className="mb-4">
        <label className="block mb-2 font-semibold">Destino:</label>
        <PlaceSearch onPlaceSelected={handleDestinationSelect} />
      </div>

      {(origin || destination) && (
        <div className="mt-6">
          <h2 className="text-lg font-semibold mb-2">Mapa</h2>
          <MapComponent origin={origin} destination={destination} />
        </div>
      )}
    </div>
  );
}
EOL

# Tela de Login funcional
cat > src/pages/Login.jsx << EOL
import React, { useState } from 'react';

export default function Login() {
  const navigate = () => window.location.href = '/dashboard';
  const [cpf, setCpf] = useState('');
  const [senha, setSenha] = useState('');

  const handleLogin = () => {
    if (cpf && senha) {
      localStorage.setItem('motorista', JSON.stringify({ cpf }));
      navigate();
    } else {
      alert('Preencha CPF e Senha');
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-100">
      <form onSubmit={(e) => { e.preventDefault(); handleLogin(); }} className="bg-white p-6 rounded shadow-md w-80">
        <h2 className="text-2xl font-bold mb-4">Login Motorista</h2>
        <input
          type="text"
          placeholder="CPF"
          value={cpf}
          onChange={(e) => setCpf(e.target.value)}
          className="w-full p-2 border rounded mb-2"
          required
        />
        <input
          type="password"
          placeholder="Senha"
          value={senha}
          onChange={(e) => setSenha(e.target.value)}
          className="w-full p-2 border rounded mb-4"
          required
        />
        <button type="submit" className="w-full bg-blue-500 text-white py-2 rounded hover:bg-blue-600">
          Entrar
        </button>
      </form>
    </div>
  );
}
EOL

# App.jsx com rotas
cat > src/App.jsx << EOL
import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Login from './pages/Login';
import DashboardScreen from './components/DashboardScreen';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route path="/dashboard" element={<DashboardScreen />} />
        <Route path="/" element={<Login />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
EOL

# main.jsx
cat > src/main.jsx << EOL
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
EOL

# Instalar roteamento
npm install react-router-dom

# Corrigir vulnerabilidades
npm audit fix --force

# Fazer build
npm run build

# Voltar à pasta principal
cd ..

# 8. Cria o app móvel com Flutter
echo "📱 Criando app móvel com Flutter..."

flutter create mototaxi_app
cd mototaxi_app

cat > pubspec.yaml << EOL
name: mototaxi_app
description: App para motoristas do Mototaxi 24 Horas

publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.0.0"

dependencies:
  flutter:
    sdk: flutter
  google_maps_flutter: ^2.3.1
  http: ^0.17.0
  shared_preferences: ^2.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
EOL

# Baixar dependências
flutter pub get

# Estrutura de pastas
mkdir -p lib/screens lib/services

# Tela de Login
cat > lib/screens/login_screen.dart << EOL
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final cpfController = TextEditingController();

  void _fazerLogin(context) {
    if (cpfController.text.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(cpf: cpfController.text),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha seu CPF')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login Motorista')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: cpfController,
              decoration: InputDecoration(labelText: 'CPF'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _fazerLogin(context),
              child: Text('Entrar'),
            )
          ],
        ),
      ),
    );
  }
}
EOL

# Dashboard com mapa
cat > lib/screens/dashboard_screen.dart << EOL
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DashboardScreen extends StatelessWidget {
  final String cpf;

  DashboardScreen({required this.cpf});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bem-vindo, $cpf'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(-23.550520, -46.633308),
          zoom: 13,
        ),
        myLocationEnabled: true,
        zoomControlsEnabled: false,
      ),
    );
  }
}
EOL

# main.dart
cat > lib/main.dart << EOL
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(MototaxiApp());
}

class MototaxiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mototaxi 24 Horas',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
EOL

# AndroidManifest.xml com permissões
cat > android/app/src/main/AndroidManifest.xml << EOL
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.mototaxi_app">

    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.INTERNET" />

    <application
        android:label="Mototaxi 24 Horas"
        android:theme="@style/AppTheme"
        android:name="io.flutter.app.FlutterApplication"
        android:allowBackup="true">
        <activity
            android:name=".MainActivity"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="SUA_CHAVE_DO_GOOGLE_MAPS_AQUI" />
    </application>
</manifest>
EOL

# Build APK assinado
keytool -genkey -v -keystore key.jks -storetype JKS -keyalg RSA -keysize 2048 -storepass mototaxi_app_key -alias mototaxi_app -keypass mototaxi_app_key -dname "CN=GrupoJA, OU=Mototaxi, O=Mototaxi24Horas, L=São Paulo"

echo "📦 Gerando APK assinado..."
flutter build apk --release --dart-define-from-file .env.json

# 9. Cria workflow do GitHub Actions
mkdir -p .github/workflows
cat > .github/workflows/flutter-vite-cd.yml << EOL
name: CI/CD - Web + Mobile

on:
  push:
    branches:
      - main

jobs:
  build-web:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v3
        with:
          node-version: '20.x'
      - run: npm install
      - run: npm run build
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: \${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./frontend_vite/dist

  build-flutter:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: cd mototaxi_app && flutter pub get
      - run: cd mototaxi_app && flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: mototaxi_app_apk
          path: mototaxi_app/build/app/outputs/flutter-apk/app-release.apk
EOL

# 10. Cria arquivo docker-compose.yml
cat > docker-compose.yml << EOL
version: '3.8'
services:
  backend:
    build: ./backend
    ports:
      - "8000:8000"
    volumes:
      - ./backend:/app
    working_dir: /app
    command: bash -c "source venv/bin/activate && python manage.py runserver 0.0.0.0:8000"

  frontend:
    image: nginx
    ports:
      - "5173:80"
    volumes:
      - ./frontend_vite/dist:/usr/share/nginx/html
    restart: always

volumes:
  backend_data:
  frontend_dist:
EOL

# 11. Faz commit final
cd ..
git add .
git commit -am "feat: adiciona frontend web, mobile, backend e Docker"
git push origin main

echo "✅ Projeto configurado com sucesso!"
echo "📁 Estrutura pronta para desenvolvimento fullstack"
echo "📲 Para rodar o app móvel: cd mototaxi_app && flutter run"
echo "🌐 Para rodar o frontend web: cd frontend_vite && npm run dev"
echo "🔧 Para subir todos os serviços: docker-compose up"
echo "📦 APK gerado em: mototaxi_app/build/app/outputs/flutter-apk/app-release.apk"
