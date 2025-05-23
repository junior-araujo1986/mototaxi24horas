#!/bin/bash

echo "🚀 Recriando estrutura web do zero - Mototaxi 24 Horas"

# Pasta base
cd ~/mototaxi24horas || { echo "❌ Pasta ~/mototaxi24horas não encontrada"; exit 1; }

# Remover projetos antigos (se existirem)
rm -rf frontend_vite node_modules package-lock.json

# Criar novo projeto com Vite + React
echo "🛠️ Criando novo projeto com Vite + React"
npm create vite@latest frontend_vite --template react

# Entrar na pasta do projeto
cd frontend_vite || { echo "❌ Erro ao acessar a pasta do projeto"; exit 1; }

# Instalar dependências mínimas
echo "📦 Instalando dependências..."
npm install

# Instalar Tailwind CSS (opcional mas recomendado)
echo "🎨 Adicionando Tailwind CSS..."
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p

# Atualizar configuração do Tailwind
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
  background-color: #f9fafb;
  font-family: sans-serif;
}
EOL

# Estrutura de pastas
mkdir -p src/components/Map src/pages

# Componente MapComponent básico
cat > src/components/Map/MapComponent.jsx << EOL
import React from 'react';

export default function MapComponent() {
  return (
    <div style={{ width: '100%', height: '400px', backgroundColor: '#e0e0e0' }}>
      <p className="text-center py-4">Mapa carregado!</p>
    </div>
  );
}
EOL

# Componente PlaceSearch básico
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

# Tela de Login funcional
cat > src/pages/Login.jsx << EOL
import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';

export default function Login() {
  const [cpf, setCpf] = useState('');
  const navigate = useNavigate();

  const handleLogin = () => {
    if (cpf) {
      localStorage.setItem('motorista', JSON.stringify({ cpf }));
      navigate('/dashboard');
    } else {
      alert('Preencha todos os campos.');
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
          value=""
          onChange={() => {}}
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

# Tela Dashboard com mapa
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

# Arquivo App.jsx com rotas
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

# Instale roteamento
npm install react-router-dom

# Corrija vulnerabilidades (atenção: pode atualizar pacotes quebrados)
echo "🔧 Corrigindo vulnerabilidades..."
npm audit fix --force

# Reinicie servidor do Vite
echo "✅ Projeto criado com sucesso!"
echo "📲 Para rodar: cd ~/mototaxi24horas/frontend_vite && npm run dev"
