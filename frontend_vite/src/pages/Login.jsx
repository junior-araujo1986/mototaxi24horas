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
