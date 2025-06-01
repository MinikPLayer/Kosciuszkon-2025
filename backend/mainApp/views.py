import csv

import ollama
from django.contrib.auth import authenticate, get_user_model
from django.shortcuts import render
from rest_framework import status, permissions
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.parsers import JSONParser
from mainApp.Kalkulator_Python.advanced_calc import AdvancedCalc, AdvancedCalcData, load_data_from_files
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


def load_knowledge(file_path):
    """Wczytuje wiedzę z pliku tekstowego"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return f.read()
    except FileNotFoundError:
        print(f"Plik {file_path} nie istnieje!")
        return ""


class ChatAPI(APIView):

    # def get(self, request):
    #     serializer = UserSerializer(request.user)
    #     return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request):
        prompt = request.data.get("prompt")
        print(request.data)

        knowledge = load_knowledge('mainApp/wiedza_o_fotowoltaice.txt')

        response = ollama.generate(
            model='mistral',
            prompt=prompt,
            system=f"""
                    Jesteś ekspertem od energii słonecznej. 
                    Odpowiadaj na pytania korzystając z tej wiedzy:
                    {knowledge}.
                    Jeśli nie znasz odpowiedzi, powiedz że nie wiesz.
                    """,
            options={'temperature': 0.7}
        )

        return Response({"answer": response['response']}, status=status.HTTP_200_OK)

class DeviceAPI(APIView):

    def get(self, request):

        return Response(status=status.HTTP_200_OK)

    def post(self, request):

        return Response(status=status.HTTP_200_OK)


class AdvanceCalculator(APIView):
    parser_classes = [JSONParser, MultiPartParser]

    def post(self, request):
        try:
            # Handle CSV file uploads if present
            consumption_data, fv_production_data = load_data_from_files()
            
            
            # Get parameters from request data
            data = request.data.get('parameters', {})
            if isinstance(data, str):
                data = json.loads(data)
            
            # Required fields validation
            required_fields = [
                'fv_system_size_kw',
                'energy_storage_size_kwh',
                'first_year_energy_buying_price',
                'first_year_energy_selling_price',
                'fv_system_installation_cost_per_kw',
                'yearly_energy_price_increase_percentage',
                'fv_degradation_percentage_per_year',
                'energy_storage_degradation_percentage_per_year',
                'years'
            ]
            
            for field in required_fields:
                if field not in data:
                    return Response(
                        {"error": f"Brakujące pole: {field}"},
                        status=status.HTTP_400_BAD_REQUEST
                    )
            
            # Prepare consumption and production functions
            def consumption_func(calc_data, day_of_year, hour_of_day):
                key = (day_of_year, hour_of_day)
                if key in consumption_data:
                    return consumption_data[key]
                return float(data.get('default_consumption', 1713 / (24 * 365)))
            
            def production_func(calc_data, day_of_year, hour_of_day):
                key = (day_of_year, hour_of_day)
                if key in fv_production_data:
                    return fv_production_data[key]
                # Default production pattern (peaks at noon)
                diff = hour_of_day - 6
                normalized_hour = (diff / 6.0) - 1
                v = 1 - abs(normalized_hour)
                return max(0.0, v)
            
            # Create calculation data
            calc_data = AdvancedCalcData(
                fv_system_size_kw=float(data['fv_system_size_kw']),
                energy_storage_size_kwh=float(data['energy_storage_size_kwh']),
                consumption_kwh_at_time_func=consumption_func,
                fv_production_kwh_per_panel_at_time_func=production_func,
                first_year_energy_buying_price=float(data['first_year_energy_buying_price']),
                first_year_energy_selling_price=float(data['first_year_energy_selling_price']),
                fv_system_installation_cost_per_kw=float(data['fv_system_installation_cost_per_kw']),
                yearly_energy_price_increase_percentage=float(data['yearly_energy_price_increase_percentage']),
                fv_degradation_percentage_per_year=float(data['fv_degradation_percentage_per_year']),
                energy_storage_degradation_percentage_per_year=float(data['energy_storage_degradation_percentage_per_year'])
            )
            
            years = int(data['years'])
            result = AdvancedCalc.calculate(calc_data, years)
            
            # Prepare response
            response_data = {
                'upfront_investment_cost': result.upfront_investment_cost,
                'results_per_year': [
                    {
                        'year': idx + 1,
                        'non_fv_price': year.non_fv_price,
                        'fv_price': year.fv_price,
                        'savings': year.non_fv_price - year.fv_price,
                        'es_charge_kwh': year.es_charge_kwh,
                        'consumption_kwh': year.consumption_kwh,
                        'production_kwh': year.production_kwh
                    }
                    for idx, year in enumerate(result.results_per_year)
                ],
                'total_savings': sum(
                    year.non_fv_price - year.fv_price 
                    for year in result.results_per_year
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
    
    def load_csv_data(self, path):
        ret = {}
        with open(path, 'r') as file:
            print(f"Loading data from {path}")
            reader = csv.reader(file)
            # Skip first row (header)
            next(reader, None)
            for row in reader:
                # Skip empty rows
                if not row or len(row) < 3 or not row[0].isdigit():
                    continue

                day_of_year = int(row[0])
                hour_of_day = int(row[1])
                data = float(row[2])
                ret[(day_of_year, hour_of_day)] = data

        
        return ret
