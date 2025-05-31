import ollama
from django.contrib.auth import authenticate, get_user_model
from django.shortcuts import render
from rest_framework import status, permissions
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken

from mainApp.models import AppUser
from mainApp.serializers import UserRegisterSerializer, UserSerializer

UserModel = get_user_model()


# class UserLogout(APIView):
#     def post(self, request):
#         user = request.user
#         user.is_online = False
#         user.save()
#         return Response(status=status.HTTP_200_OK)
#
#
# class OneUserData(APIView):# Only authenticated users can log out
#     parser_classes = (MultiPartParser, FormParser)
#
#     def get(self, request):
#         serializer = UserSerializer(request.user)
#         return Response(serializer.data, status=status.HTTP_200_OK)
#
#     def post(self, request):
#         user = request.user
#         profile_picture = request.FILES.get('profile_picture')  # Use 'avatar' as the field name for the image
#         if profile_picture:
#             user.profile_picture = profile_picture  # Assuming 'avatar' is a field on your User model
#             print(profile_picture)
#             print(user.profile_picture)
#             user.save()
#             serializer = UserSerializer(user)
#             return Response(serializer.data, status=status.HTTP_200_OK)
#         return Response({'error': 'No avatar image provided'}, status=status.HTTP_400_BAD_REQUEST)
#
#     def put(self, request):
#         user = request.user
#         user.email = request.data.get("email")
#         user.name = request.data.get("name")
#         user.username = request.data.get("username")
#         user.telephone = request.data.get("phone")
#         user.address = request.data.get("address")
#         user.surname = request.data.get("surname")
#         user.save()
#         serializer = UserSerializer(request.user)
#         return Response(serializer.data, status=status.HTTP_200_OK)
#
#     def delete(self, request):
#         user = request.user
#         user.delete()
#         return Response({'message': 'User deleted successfully'}, status=status.HTTP_204_NO_CONTENT)


def load_knowledge(file_path):
    """Wczytuje wiedzę z pliku tekstowego"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return f.read()
    except FileNotFoundError:
        print(f"Plik {file_path} nie istnieje!")
        return ""


class ChatAPI(APIView):
    authentication_classes = []  # No authentication required
    permission_classes = [AllowAny]  # Only authenticated users can log out
    parser_classes = [JSONParser, FormParser]

    def get(self, request):
        serializer = UserSerializer(request.user)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request):

        prompt = request.data.get("prompt")

        # Wczytaj wiedzę o fotowoltaice
        knowledge = load_knowledge('mainApp/wiedza_o_fotowoltaice.txt')
        
        system_prompt = f"""
        Jesteś ekspertem od energii słonecznej. 
        Odpowiadaj na pytania użytkownika Julia korzystając z tej wiedzy:
        {knowledge}
        Jeśli nie znasz odpowiedzi, powiedz że nie wiesz.
        Bądź zwięzły i konkretny.
        """
        response = ollama.generate(
            model='mistral',
            prompt=prompt,
            system=system_prompt,
            options={'temperature': 0.7}
        )

        return Response({
            "answer": response['response'],
            "model": "mistral",
        }, status=status.HTTP_200_OK)
        #
        # try:
        #
        #
        # except Exception as e:
        #     return Response(
        #         {"error": str(e)},
        #         status=status.HTTP_500_INTERNAL_SERVER_ERROR
        #     )