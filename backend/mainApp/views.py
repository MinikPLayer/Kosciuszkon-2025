import ollama
from django.contrib.auth import authenticate, get_user_model
from django.shortcuts import render
from rest_framework import status, permissions
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken

from mainApp.models import AppUser
from mainApp.serializers import UserRegisterSerializer, UserSerializer

UserModel = get_user_model()


# class UserRegister(APIView):
#     permission_classes = (permissions.AllowAny,)
#
#     def post(self, request):
#
#         if AppUser.objects.filter(username=request.data['username']).exists():
#             return Response({"error": "Wybrana nazwa użytkownika już istnieje."}, status=status.HTTP_400_BAD_REQUEST)
#         if AppUser.objects.filter(email=request.data['email']).exists():
#             return Response({"error": "Istnieje już konto powiązane z tym adresem email."}, status=status.HTTP_400_BAD_REQUEST)
#         if len(request.data['password']) < 8:
#             return Response({"error": "Hasło powinno mieć minimum 8 znaków."}, status=status.HTTP_400_BAD_REQUEST)
#         if request.data['password'] != request.data['passwordSecond']:
#             return Response({"error": "Hasła nie są ze sobą zgodne."}, status=status.HTTP_400_BAD_REQUEST)
#
#         serializer = UserRegisterSerializer(data=request.data)
#         if serializer.is_valid(raise_exception=True):
#             user = serializer.create(request.data)
#             user.save()
#
#             if user:
#                 return Response(serializer.data, status=status.HTTP_201_CREATED)
#         return Response(status.HTTP_400_BAD_REQUEST)
#
#
# class UserLogin(APIView):
#     permission_classes = [permissions.AllowAny,]  # Allow any user to access this view
#
#     def post(self, request):
#         email = request.data.get("email")
#         password = request.data.get("password")
#
#         print(request.data)
#
#         errors = {}
#
#         # Ensure both fields are present
#         if not email:
#             return Response({"error": "Email jest wymagany.", "type": "email"}, status=status.HTTP_400_BAD_REQUEST)
#
#         if not password:
#             return Response({"error": "Hasło jest wymagane", "type": "password"}, status=status.HTTP_400_BAD_REQUEST)
#
#         # Authenticate the user
#         user = authenticate(request, email=email, password=password)
#
#         if user is None:
#             return Response({"error": "Invalid credentials", "type": "credentials"}, status=status.HTTP_401_UNAUTHORIZED)
#
#         user.is_online = True
#         user.save()
#         # Generate JWT tokens
#         refresh = RefreshToken.for_user(user)
#         return Response({
#             "access": str(refresh.access_token),
#             "refresh": str(refresh),
#         }, status=status.HTTP_200_OK)
#
#
# class UserLogout(APIView):
#     def post(self, request):
#         user = request.user
#         user.is_online = False
#         user.save()
#         return Response(status=status.HTTP_200_OK)
#
#
# class OneUserData(APIView):
#     permission_classes = (permissions.IsAuthenticated,)  # Only authenticated users can log out
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
#

class ChatAPI(APIView):
    # permission_classes = (permissions.IsAuthenticated,)  # Only authenticated users can log out

    def get(self, request):
        serializer = UserSerializer(request.user)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request):
        prompt = request.data.get("prompt")

        response = ollama.generate(
            model='mistral',
            prompt="Jak działa fotowoltaika?",
            system=prompt,
            options={'temperature': 0.7}
        )

        return Response({"answer": response}, status=status.HTTP_200_OK)