from django.urls import path
from django.http import JsonResponse

def api_login(request):
    return JsonResponse({'status': 'ok', 'message': 'Login via CPF'})

urlpatterns = [
    path('api/token/', api_login),
]
