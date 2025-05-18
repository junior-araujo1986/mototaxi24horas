// src/components/Map/MapComponent.jsx
import React from 'react';
import { GoogleMap, LoadScript } from '@react-google-maps/api';

const mapContainerStyle = {
  width: '100%',
  height: '400px',
};

const center = {
  lat: -23.550520,
  lng: -46.633308,
};

export default function MapComponent() {
  return (
    <LoadScript googleMapsApiKey="AIzaSyB-_60JnuTN_PmnToZbUJ1z_KRg-r1ndAk">
      <GoogleMap
        mapContainerStyle={mapContainerStyle}
        zoom={13}
        center={center}
      >
        {/* Marcadores futuros */}
      </GoogleMap>
    </LoadScript>
  );
}
