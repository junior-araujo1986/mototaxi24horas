#!/bin/bash

echo "🚀 Iniciando integração do Google Maps no frontend web..."

# Verificar se está na pasta certa
cd ~/mototaxi24horas/frontend_vite || { echo "❌ Pasta frontend_vite não encontrada"; exit 1; }

# Instalar dependência do Google Maps
npm install @react-google-maps/api

# Criar pasta Map (se não existir)
mkdir -p src/components/Map

# Componente MapComponent.jsx com Google Maps real
cat > src/components/Map/MapComponent.jsx << EOL
import React from 'react';
import { GoogleMap, LoadScript } from '@react-google-maps/api';

const mapContainerStyle = {
  width: '100%',
  height: '400px',
};

const center = {
  lat: -23.550520, // São Paulo como padrão
  lng: -46.633308,
};

export default function MapComponent({ origin, destination }) {
  const [map, setMap] = React.useState(null);

  const onLoad = React.useCallback(function callback(map) {
    setMap(map);
  }, []);

  const onUnmount = React.useCallback(() => {
    setMap(null);
  }, []);

  return (
    <LoadScript googleMapsApiKey="SUA_CHAVE_DO_GOOGLE_MAPS_AQUI">
      <GoogleMap
        mapContainerStyle={mapContainerStyle}
        zoom={13}
        center={center}
        onLoad={onLoad}
        onUnmount={onUnmount}
      >
        {/* Marcadores futuros */}
      </GoogleMap>
    </LoadScript>
  );
}
EOL

# Componente PlaceSearch.jsx com Autocomplete
cat > src/components/Map/PlaceSearch.jsx << EOL
import React, { useState } from 'react';
import { Autocomplete } from '@react-google-maps/api';

export default function PlaceSearch({ onPlaceSelected }) {
  const [autocomplete, setAutocomplete] = useState(null);

  const onLoad = (auto) => {
    setAutocomplete(auto);
  };

  const onPlaceChanged = () => {
    if (autocomplete !== null) {
      const place = autocomplete.getPlace();
      if (place.geometry && place.geometry.location) {
        onPlaceSelected({
          address: place.formatted_address,
          lat: place.geometry.location.lat(),
          lng: place.geometry.location.lng(),
        });
      }
    }
  };

  return (
    <Autocomplete onLoad={onLoad} onPlaceChanged={onPlaceChanged}>
      <input
        type="text"
        placeholder="Digite um local"
        className="w-full p-2 border rounded mb-4"
      />
    </Autocomplete>
  );
}
EOL

# Atualizar MotoristaDashboard.jsx para usar os novos componentes
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

# Garantir que App.jsx importa corretamente
cat > src/App.jsx << EOL
import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import Login from './pages/Login';
import MotoristaDashboard from './components/MotoristaDashboard';

function App() {
  return (
    <Router>
      <AuthProvider>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route path="/dashboard" element={<MotoristaDashboard />} />
          <Route path="/" element={<Login />} />
        </Routes>
      </AuthProvider>
    </Router>
  );
}

export default App;
EOL

echo "✅ Integração com Google Maps finalizada!"
echo "📌 Arquivos atualizados em src/components/Map/"
echo "📌 Use sua própria chave do Google Maps em MapComponent.jsx"
echo "👉 Acesse http://localhost:5173/login após rodar npm run dev"
