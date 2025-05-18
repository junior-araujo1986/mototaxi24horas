from rest_framework import serializers
from .models import Usuario, Motorista, Corrida

class UsuarioSerializer(serializers.ModelSerializer):
    class Meta:
        model = Usuario
        fields = ['id', 'nome', 'telefone', 'data_cadastro']


class MotoristaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Motorista
        fields = ['id', 'nome', 'cnh', 'placa', 'ativo']


class CorridaSerializer(serializers.ModelSerializer):
    usuario = serializers.StringRelatedField()
    motorista = serializers.StringRelatedField()

    class Meta:
        model = Corrida
        fields = ['id', 'usuario', 'motorista', 'origem', 'destino', 'distancia', 'preco', 'status', 'data_pedido']
