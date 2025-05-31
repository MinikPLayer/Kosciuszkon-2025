import ollama
from django.contrib.auth import authenticate, get_user_model
from django.shortcuts import render
from rest_framework import status, permissions
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.parsers import JSONParser
from mainApp.Kalkulator_Python.simple_calc import SimpleCalc, SimpleCalcData
from mainApp.models import AppUser
from mainApp.serializers import UserRegisterSerializer, UserSerializer
import json

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

class SimpleCalculator(APIView):
    parser_classes = [JSONParser]
    
    def post(self, request):
        try:
            print("request.body (full):", request.body)
            print("request.data (full):", request.data)
            data = request.data.get("parameters")
           
            # Walidacja danych wejściowych
            required_fields = [
                'single_year_energy_consumption',
                'first_year_energy_buying_price',
                'first_year_energy_selling_price',
                'fv_system_installation_cost_per_kw',
                'fv_system_size_kw',
                'fv_system_output_percentage',
                'autoconsumption_percentage',
                'yearly_energy_price_increase_percentage',
                'years'
            ]
            
            for field in required_fields:
                if field not in data:
                    return Response(
                        {"error": f"Brakujące pole: {field}"},
                        status=status.HTTP_400_BAD_REQUEST
                    )
     
            # Przygotowanie danych do obliczeń
            calc_data = SimpleCalcData(
                single_year_energy_consumption=float(data['single_year_energy_consumption']),
                first_year_energy_buying_price=float(data['first_year_energy_buying_price']),
                first_year_energy_selling_price=float(data['first_year_energy_selling_price']),
                fv_system_installation_cost_per_kw=float(data['fv_system_installation_cost_per_kw']),
                fv_system_size_kw=float(data['fv_system_size_kw']),
                fv_system_output_percentage=float(data['fv_system_output_percentage']),
                autoconsumption_percentage=float(data['autoconsumption_percentage']),
                yearly_energy_price_increase_percentage=float(data['yearly_energy_price_increase_percentage'])
            )
            
            years = int(data['years'])
            result = SimpleCalc.calculate(calc_data, years)
            
            # Przygotowanie odpowiedzi
            response_data = {
                'upfront_investment_cost': result.upfront_investment_cost,
                'energy_prices_per_year': [
                    {
                        'year': idx + 1,
                        'energy_price_without_fotovoltaic': year.energy_price_without_fotovoltaic,
                        'energy_price_with_fotovoltaic': year.energy_price_with_fotovoltaic,
                        'savings': year.energy_price_without_fotovoltaic - year.energy_price_with_fotovoltaic
                    }
                    for idx, year in enumerate(result.energy_prices_per_year)
                ],
                'total_savings': sum(
                    year.energy_price_without_fotovoltaic - year.energy_price_with_fotovoltaic 
                    for year in result.energy_prices_per_year
                )
            }
            
            return Response(response_data, status=status.HTTP_200_OK)
            
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            return Response(
                {"error": f"Wewnętrzny błąd serwera: {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )