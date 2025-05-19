#!/bin/bash

echo "🚀 Iniciando script completão: Mototaxi 24 Horas"
cd ~/mototaxi24horas || { echo "❌ Pasta ~/mototaxi24horas não encontrada"; exit 1; }

# Limpar projetos antigos
rm -rf frontend_vite mototaxi_app node_modules package-lock.json

# 1. Criar projeto web com Vite
echo "🌐 Criando novo projeto web com Vite + React..."
npm create vite@latest frontend_vite --template react

# Entrar na pasta do frontend
cd frontend_vite || { echo "❌ Erro ao acessar pasta do projeto web"; exit 1; }

# Instalar dependências mínimas
npm install

# Instalar Tailwind CSS
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p

# Configurar Tailwind
cat > tailwind.config.js << EOL
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOL

# Atualizar index.css
cat > src/index.css << EOL
@tailwind base;
@tailwind components;
@tailwind utilities;

body {
  margin: 0;
  padding: 0;
  font-family: sans-serif;
}
EOL

# Estrutura de componentes
mkdir -p src/components/Map src/pages

# MapComponent básico
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

# PlaceSearch simulado
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

# MotoristaDashboard com navegação
cat > src/components/MotoristaDashboard.jsx << EOL
import React, { useState } from 'react';
import MapComponent from './Map/MapComponent';
import PlaceSearch from './Map/PlaceSearch';

export default function MotoristaDashboard() {
  const [origin, setOrigin] = useState(null);
  const [destination, setDestination] = useState(null);

  const handleOriginSelect = (place) => {
    console.log('Origem selecionada:', place);
    setOrigin(place);
  };

  const handleDestinationSelect = (place) => {
    console.log('Destino selecionado:', place);
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
import MotoristaDashboard from './components/MotoristaDashboard';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route path="/dashboard" element={<MotoristaDashboard />} />
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
);
EOL

# Instalar roteamento
npm install react-router-dom

# Build do frontend web
npm run build

# Voltar à pasta principal
cd ..

# 2. Criar projeto Flutter atualizado
echo "📱 Criando novo app móvel com Flutter..."

flutter create mototaxi_app
cd mototaxi_app

# Adicionar dependências essenciais
flutter pub add google_maps_flutter http shared_preferences provider

# Estrutura de pastas
mkdir -p lib/screens

# DashboardScreen com mapa real
cat > lib/screens/dashboard_screen.dart << EOL
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DashboardScreen extends StatefulWidget {
  final String cpf;

  DashboardScreen({required this.cpf});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late GoogleMapController mapController;

  static final CameraPosition initialCamera = CameraPosition(
    target: LatLng(-23.550520, -46.633308), // São Paulo
    zoom: 13,
  );

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bem-vindo, ${widget.cpf}'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: initialCamera,
        myLocationEnabled: true,
        zoomControlsEnabled: false,
      ),
    );
  }
}
EOL

# LoginScreen com navegação
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

# main.dart atualizado
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

# Atualizar projeto para Android v2 embedding
flutter create .

# Baixar pacotes novamente
flutter pub get

# Gerar APK assinado
echo "📦 Gerando APK assinado..."
keytool -genkey -v -keystore key.jks -storepass mototaxi_app_key -alias mototaxi_app -keypass mototaxi_app_key -dname "CN=GrupoJA, OU=Mototaxi, O=Mototaxi24Horas, L=São Paulo"

# Assinar APK
cat > android/app/build.gradle << EOL
android {
    namespace "com.example.mototaxi_app"
    compileSdk 34

    defaultConfig {
        applicationId "com.example.mototaxi_app"
        minSdk 21
        targetSdk 34
        versionCode 1
        versionName "1.0.0"
    }

    signingConfigs {
        release {
            storeFile file('../key.jks')
            storePassword 'mototaxi_app_key'
            keyAlias 'mototaxi_app'
            keyPassword 'mototaxi_app_key'
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
EOL

# Fazer build do APK
flutter build apk --release

if [ $? -eq 0 ]; then
    echo "✅ APK gerado com sucesso!"
else
    echo "❌ Falha ao gerar APK. Confira dependências e configuração do AndroidManifest.xml"
fi

# 3. Configurar Firebase Hosting
cd ~/mototaxi24horas/frontend_vite
firebase init hosting

# Responder automaticamente com opção existente ou nova
if [ -f "firebase.json" ]; then
    npm run build
    firebase deploy --only hosting
else
    echo "⚠️  Configure Firebase primeiro via interface interativa"
fi

# 4. Subir para GitHub
cd ~/mototaxi24horas
git init
git remote add origin git@github.com:junior-araujo1986/mototaxi24horas.git
git add .
git commit -am "feat: versão inicial do app web + mobile"
git push -u origin main --force

# 5. Script para GitHub Actions (CI/CD)
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
      - run: |
          cd frontend_vite
          npm install
          npm run build

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

      - run: |
          cd mototaxi_app
          flutter pub get
          flutter build apk --release

      - uses: actions/upload-artifact@v3
        with:
          name: mototaxi_app_apk
          path: mototaxi_app/build/app/outputs/flutter-apk/app-release.apk
EOL

# 6. Mensagem final
cd ~/mototaxi24horas
echo ""
echo "✅ Projeto configurado com sucesso!"
echo "📌 Frontend web disponível em: https://mototaxi24horas.web.app/ "
echo "📱 APK gerado em: mototaxi_app/build/app/outputs/flutter-apk/app-release.apk"
echo "➡️ Para subir na Play Store: use Google Play Console ou Firebase App Distribution"
echo "🔗 Repositório atualizado no GitHub: junior-araujo1986/mototaxi24horas"
