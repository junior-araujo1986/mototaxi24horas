#!/bin/bash

echo "🚀 Recriando app móvel do zero - Mototaxi 24 Horas"

cd ~/mototaxi24horas || { echo "❌ Pasta ~/mototaxi24horas não encontrada"; exit 1; }

# Remover projeto antigo (se existir)
rm -rf mototaxi_app

# Criar novo projeto Flutter
flutter create mototaxi_app
cd mototaxi_app || { echo "❌ Erro ao acessar pasta do projeto"; exit 1; }

# Instalar dependências básicas
echo "📦 Instalando dependências do Flutter..."
cat > pubspec.yaml << EOL
name: mototaxi_app
description: App móvel para motoristas do Mototaxi 24 Horas

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
  provider: ^6.1.1

dev_dependencies:
  flutter_test:
    sdk: flutter
EOL

# Baixar dependências
flutter pub get

# Estrutura de pastas
mkdir -p lib/screens lib/components lib/services

# Arquivo main.dart
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

  void _fazerLogin() {
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
              onPressed: _fazerLogin,
              child: Text('Entrar'),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            )
          ],
        ),
      ),
    );
  }
}
EOL

# Tela do Dashboard com Mapa
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
            onPressed: () {
              Navigator.pop(context);
            },
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

# Componente reutilizável de mapa (opcional por enquanto)

cat > lib/components/map_component.dart << EOL
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapComponent extends StatelessWidget {
  final double lat;
  final double lng;

  const MapComponent({Key? key, this.lat = -23.550520, this.lng = -46.633308}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(lat, lng),
        zoom: 13,
      ),
      myLocationEnabled: true,
    );
  }
}
EOL

# Serviço de API (opcional por enquanto)
cat > lib/services/api_service.dart << EOL
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl = 'http://localhost:8000/api';

  Future<bool> login(String cpf, String senha) async {
    final response = await http.post(
      Uri.parse('\$baseUrl/token/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'cpf': cpf, 'senha': senha}),
    );

    return response.statusCode == 200;
  }
}
EOL

# Configurar permissões no AndroidManifest.xml
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

# Rode o projeto (use Chrome Web ou emulador Android)
echo "✅ App móvel criado com sucesso!"
echo "📲 Para rodar: cd ~/mototaxi24horas/mototaxi_app && flutter run"
