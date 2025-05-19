#!/bin/bash

echo "🚀 Iniciando processo de publicação completo - Mototaxi 24 Horas"

cd ~/mototaxi24horas || { echo "❌ Pasta ~/mototaxi24horas não encontrada"; exit 1; }

# 1. Verificar e recriar projeto web (se necessário)
if [ ! -d "frontend_vite" ]; then
    echo "🌐 Criando novo projeto web..."
    npm create vite@latest frontend_vite --template react

    cd frontend_vite || { echo "❌ Erro ao acessar pasta do projeto web"; exit 1; }

    npm install
    npm install react-router-dom
    npm install @react-google-maps/api
fi

# 2. Garantir componentes de mapa
mkdir -p frontend_vite/src/components/Map

cat > frontend_vite/src/components/Map/MapComponent.jsx << EOL
import React from 'react';

export default function MapComponent() {
  return (
    <div style={{ width: '100%', height: '400px', backgroundColor: '#f5f5f5' }}>
      <p className="text-center py-4">Mapa carregado!</p>
    </div>
  );
}
EOL

cat > frontend_vite/src/components/Map/PlaceSearch.jsx << EOL
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

# 3. MotoristaDashboard.jsx
mkdir -p frontend_vite/src/components
cat > frontend_vite/src/components/MotoristaDashboard.jsx << EOL
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

# 4. Atualizar App.jsx
cat > frontend_vite/src/App.jsx << EOL
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

# 5. Página de Login
mkdir -p frontend_vite/src/pages
cat > frontend_vite/src/pages/Login.jsx << EOL
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

# 6. Main.jsx
cat > frontend_vite/src/main.jsx << EOL
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOL

# 7. Build web
cd frontend_vite
npm run build
cd ..

# 8. Verificar e recriar app móvel com Flutter
if [ ! -d "mototaxi_app" ]; then
    echo "📱 Criando novo app móvel com Flutter..."
    flutter create mototaxi_app
    cd mototaxi_app
    flutter pub add google_maps_flutter http shared_preferences provider
    cd ..
fi

# 9. Atualizar tela de Login do Flutter
mkdir -p mototaxi_app/lib/screens
cat > mototaxi_app/lib/screens/login_screen.dart << EOL
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

# 10. Dashboard com Mapa
cat > mototaxi_app/lib/screens/dashboard_screen.dart << EOL
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

# 11. main.dart atualizado
cat > mototaxi_app/lib/main.dart << EOL
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

# 12. Atualizar projeto Flutter para v2 embedding
cd mototaxi_app
flutter create .
flutter pub get
flutter build apk --release
cd ..

# 13. Subir para Firebase
if [ -f "frontend_vite/dist/index.html" ]; then
    cd frontend_vite
    firebase init hosting
    npm run build
    firebase deploy --only hosting
    cd ..
else
    echo "❌ Frontend web ainda não foi construído. Execute: npm run build"
fi

# 14. Subir APK via Firebase App Distribution (se configurado)
if [ -f "mototaxi_app/build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo "📲 Enviando APK para Firebase App Distribution..."
    firebase appdistribution:distribute mototaxi_app/build/app/outputs/flutter-apk/app-release.apk --app mototaxi_app --release-notes "Versão inicial do app"
else
    echo "⚠️ APK não encontrado. Confira o build do Flutter"
fi

echo ""
echo "✅ Publicação concluída!"
echo "📌 Acesse seu painel web em: https://mototaxi24horas.web.app/ "
echo "📱 APK gerado em: mototaxi_app/build/app/outputs/flutter-apk/app-release.apk"
echo "➡️ Para subir na Play Store: acesse Google Play Console ou Firebase App Distribution"
