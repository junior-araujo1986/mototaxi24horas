// src/components/Map/PlaceSearch.jsx
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
