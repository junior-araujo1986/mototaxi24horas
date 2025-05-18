from django.db import models

class Usuario(models.Model):
    nome = models.CharField(max_length=100)
    telefone = models.CharField(max_length=15)
    data_cadastro = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.nome


class Motorista(models.Model):
    nome = models.CharField(max_length=100)
    cnh = models.CharField(max_length=20)
    placa = models.CharField(max_length=10)
    ativo = models.BooleanField(default=True)

    def __str__(self):
        return self.nome


class Corrida(models.Model):
    usuario = models.ForeignKey(Usuario, on_delete=models.CASCADE)
    motorista = models.ForeignKey(Motorista, on_delete=models.SET_NULL, null=True)
    origem = models.TextField()
    destino = models.TextField()
    distancia = models.FloatField(default=0)
    preco = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(max_length=20, default='Pendente')
    data_pedido = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.usuario} → {self.destino}"
