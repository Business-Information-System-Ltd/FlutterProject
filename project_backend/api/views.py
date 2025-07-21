# -*- coding: utf-8 -*-
from decimal import Decimal
from django.db.models.query_utils import Q
from .services import SettlementService
from rest_framework import filters, viewsets
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.pagination import PageNumberPagination
from rest_framework.views import APIView
from rest_framework.decorators import action, api_view
from rest_framework.response import Response
from .models import ApprovalStatus, Budget,Department,User,Project,ProjectBudget,Trip,TripBudget,Operation,OperationBudget, AdvanceRequest, CashPayment, RequestSetUp, ApproverSetupStep, Settlement,SettlementDetail, UserApproval
from .serializers import ApprovalStatusSerializer, BudgetSerializer,DepartmentSerializer, UserApprovalSerializer, UserLoginSerializer,UserSerializer, ProjectSerializer, ProjectBudgetSerializer,TripSerializer,TripBudgetSerializer,OperationSerializer,OperationBudgetSerializer,AdvanceRequestSerializer, CashPaymentSerializer,RequestSetUpSerializer, ApproverSetupStepSerializer,SettlementSerializer,SettlementDetailSerializer

class BudgetViewSet(viewsets.ModelViewSet):
    queryset = Budget.objects.all()
    serializer_class = BudgetSerializer

class DepartmentViewSet(viewsets.ModelViewSet):
    queryset = Department.objects.all()
    serializer_class = DepartmentSerializer 

from rest_framework import viewsets
from rest_framework.views import APIView

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        return Response(
            {
                'status': 'success',
                'message': 'User registered successfully',
                'data': serializer.data
            },
             status=status.HTTP_201_CREATED,
             headers=headers
        )

class UserLoginView(APIView):
    def post(self, request):
        serializer = UserLoginSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.validated_data
            return Response({
                'status': 'success',
                'message': 'Login successful',
                'data': {
                    'ID': user.ID,
                    'UserName': user.UserName,
                    'User_Email': user.User_Email,
                    'Role': user.Role,
                    'Department_ID': user.Department_ID.ID,
                    'Department_Name': user.Department_ID.Department_Name
                }
            }, status=status.HTTP_200_OK)
        return Response({
            'status': 'error',
            'message': 'Login failed',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)
@api_view(['GET'])
def get_departments(request):
    departments = Department.objects.all()
    serializer = DepartmentSerializer(departments, many=True)
    return Response(serializer.data)


from rest_framework import viewsets, status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Project, ProjectBudget
from .serializers import ProjectSerializer, ProjectBudgetSerializer

class ProjectViewSet(viewsets.ModelViewSet):
    queryset = Project.objects.all().prefetch_related('projectbudget_set__Budget_ID')
    serializer_class = ProjectSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if not serializer.is_valid():
            print("❌ Serializer errors:", serializer.errors)  
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        self.perform_create(serializer)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

@api_view(['GET'])
def get_next_project_code(request):
    last_project = Project.objects.order_by('-ID').first()
    next_id = 1 if not last_project else last_project.ID + 1
    next_code = f"PRJ-000-{str(next_id).zfill(3)}"
    return Response({'next_project_code': next_code})

#API endpoint to get budgets for each project
@api_view(['GET'])
def get_project_budgets(request, project_id):
    try:
        project = Project.objects.get(pk=project_id)
        project_budgets = ProjectBudget.objects.filter(Project_ID=project)
        serializer = ProjectBudgetSerializer(project_budgets, many=True)
        return Response(serializer.data)
    except Project.DoesNotExist:
        return Response(
            {"error": "Project not found"},
            status=status.HTTP_404_NOT_FOUND
        )
    
# search project by keyword
@api_view(['GET'])
def filter_projects(request):

    search_term = request.query_params.get('search', '').strip()
    
    if not search_term:
        return Response(
            {"error": "Please provide a search term using the 'search' parameter"},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    projects = Project.objects.filter(
        Q(Project_Code__icontains=search_term) |
        Q(Project_Description__icontains=search_term) |
        Q(Department_ID__Department_Name__icontains=search_term) |
        Q(Currency__icontains=search_term) |
        Q(Requestable__icontains=search_term)
    ).distinct().prefetch_related('projectbudget_set__Budget_ID')
    
    if not projects.exists():
        return Response(
            {"message": "No projects found matching your search criteria"},
            status=status.HTTP_404_NOT_FOUND
        )
    
    serializer = ProjectSerializer(projects, many=True)
    return Response(serializer.data)

# pagination for project
class ProjectPagination(PageNumberPagination):
    page_size=10 
    page_size_query_param="_limit"
    page_query_param="_page"

@api_view(['GET'])
def get_paginated_projects(request):

    projects=Project.objects.all().prefetch_related('projectbudget_set__Budget_ID')
    paginator=ProjectPagination()
    paginated_projects=paginator.paginate_queryset(projects,request)
    serializer=ProjectSerializer(paginated_projects,many=True)
    return paginator.get_paginated_response(serializer.data)



class ProjectBudgetViewSet(viewsets.ModelViewSet):
    queryset = ProjectBudget.objects.all()
    serializer_class = ProjectBudgetSerializer


from rest_framework import viewsets, status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Trip, TripBudget
from .serializers import TripSerializer, TripBudgetSerializer
class TripViewSet(viewsets.ModelViewSet):
    queryset = Trip.objects.all().prefetch_related('tripbudget_set__Budget_ID')
    serializer_class = TripSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if not serializer.is_valid():
            print("❌ Serializer errors:", serializer.errors)  
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            self.perform_create(serializer)
            instance = serializer.instance
            
            if 'budgets' in request.data:
                # Clear existing budgets
                instance.tripbudget_set.all().delete()
                
                # Add new budgets
                for budget_id in request.data['budgets']:
                    TripBudget.objects.create(
                        Trip_ID=instance,
                        Budget_ID_id=budget_id
                    )
            
            headers = self.get_success_headers(serializer.data)
            return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)
            
        except Exception as e:
            return Response(
                {"detail": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
@api_view(['GET'])
def get_next_trip_code(request):
    last_trip = Trip.objects.order_by('-ID').first()
    next_id = 1 if not last_trip else last_trip.ID + 1
    next_code = f"TRP-000-{str(next_id).zfill(3)}"
    return Response({'next_trip_code': next_code})

# API endpoint to get budget for each trip
@api_view(['GET'])
def get_trip_budgets(request,trip_id):
    try:
        trip= Trip.objects.get(pk=trip_id)
        trip_budgets=TripBudget.objects.filter(Trip_ID=trip)
        serializer=TripBudgetSerializer(trip_budgets, many=True)
        return Response(serializer.data)
    except Trip.DoesNotExist:
        return Response(
            {"error": "Trip is not found"},
            status=status.HTTP_404_NOT_FOUND
        )

# Trip search by keyword
@api_view(['GET'])
def filter_trips(request):
    search_term=request.query_params.get('search','').strip()

    if not search_term:
        return Response(
            {"error":"Please provide a search term using the 'search' parameter"},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    trips= Trip.objects.filter(
        Q(Trip_Code__icontains=search_term)|
        Q(Trip_Description__icontains=search_term)|
        Q(Department_ID__Department_Name__icontains=search_term)|
        Q(Currency__icontains=search_term)
    ).distinct().prefetch_related('tripbudget_set__Budget_ID')

    if not trips.exists():
        return Response(
            {"message":"No trips found matching your search criteria"},
            status=status.HTTP_404_NOT_FOUND
        )
    serializer=TripSerializer(trips,many=True)
    return Response(serializer.data)

# pagination for trip 
class TripPagination(PageNumberPagination):
    page_size=10
    page_size_query_param="_Limit"
    page_query_param="_page"

@api_view(['GET'])
def get_paginated_trips(request):
    trips= Trip.objects.all().prefetch_related('tripbudget_set__Budget_ID')
    paginator=TripPagination()
    paginated_trips=paginator.paginate_queryset(trips,request)
    serializer=TripSerializer(paginated_trips,many=True)
    return paginator.get_paginated_response(serializer.data)

class TripBudgetViewSet(viewsets.ModelViewSet):
    queryset=TripBudget.objects.all()
    serializer_class=TripBudgetSerializer


class OperationViewSet(viewsets.ModelViewSet):
    queryset = Operation.objects.all().prefetch_related('operationbudget_set__Budget_ID')
    serializer_class = OperationSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if not serializer.is_valid():
            print("❌ Serializer errors:", serializer.errors)  
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            self.perform_create(serializer)
            instance = serializer.instance
            
            if 'budgets' in request.data:
                # Clear existing budgets
                instance.operationbudget_set.all().delete()
                
                # Add new budgets
                for budget_id in request.data['budgets']:
                    OperationBudget.objects.create(
                        Operation_ID=instance,
                        Budget_ID_id=budget_id
                    )
            
            headers = self.get_success_headers(serializer.data)
            return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)
            
        except Exception as e:
            return Response(
                {"detail": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
@api_view(['GET'])
def get_next_operation_code(request):
    last_operation = Operation.objects.order_by('-ID').first()
    next_id = 1 if not last_operation else last_operation.ID + 1
    next_code = f"OPR-000-{str(next_id).zfill(3)}"
    return Response({'next_operation_code': next_code})

# API endpoint to get budget for each operation
@api_view(['GET'])
def get_operation_budgets(request,operation_id):
    try:
        operation= Operation.objects.get(pk=operation_id)
        operation_budgets= OperationBudget.objects.filter(Operation_ID=operation)
        serializer=OperationBudgetSerializer(operation_budgets, many=True)
        return Response(serializer.data)
    except Operation.DoesNotExist:
        return Response(  
            {"error": "Operation is not found"},
            status=status.HTTP_404_NOT_FOUND      
        )


class OperationBudgetViewSet(viewsets.ModelViewSet):
    queryset=OperationBudget.objects.all()
    serializer_class=OperationBudgetSerializer

class RequestSetUpViewSet(viewsets.ModelViewSet):
    queryset = RequestSetUp.objects.all()
    serializer_class = RequestSetUpSerializer
@api_view(['POST'])
def request_setup_create(request):
    serializer = RequestSetUpSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class ApproverSetupStepViewSet(viewsets.ModelViewSet):
    queryset = ApproverSetupStep.objects.all()
    serializer_class = ApproverSetupStepSerializer
    
class AdvanceRequestViewSet(viewsets.ModelViewSet):
    queryset = AdvanceRequest.objects.all()
    serializer_class = AdvanceRequestSerializer

@api_view(['GET'])
def get_next_request_code(request):
    last_request = AdvanceRequest.objects.order_by('-ID').first()
    next_id = 1 if not last_request else last_request.ID + 1
    next_code = f"Req-000-{str(next_id).zfill(3)}"
    return Response({'next_request_code': next_code})

# search Advance by keyword
@api_view(['GET'])
def filter_advances(request):
    search_term= request.query_params.get('search','').strip()

    if not search_term:
        return Response(
            {"error":"Please provide a search term using the 'search' parameter"},
            status=status.HTTP_400_BAD_REQUEST
        )
    advances= AdvanceRequest.objects.filter(
        Q(Request_No__icontains=search_term) |
        Q(Requester__icontains=search_term) |
        Q(Request_Type__icontains=search_term) |
        Q(Request_Amount__icontains=search_term) |
        Q(Currency__icontains=search_term) |
        Q(Purpose_Of_Request__icontains=search_term) |
        Q(Project_ID__Project_Code__icontains=search_term) | 
        Q(Trip_ID__Trip_Code__icontains=search_term) |  
        Q(Operation_ID__Operation_Code__icontains=search_term)  
    ).distinct()

    if not advances.exists():
        return Response(
            {"message": "No advance requests found matching your search criteria"},
            status=status.HTTP_404_NOT_FOUND
        )
    serializer=AdvanceRequestSerializer(advances,many=True)
    return Response(serializer.data)

#pagination for advance request
class AdvancePagination(PageNumberPagination):
    page_size=10
    page_size_query_param="_limit"
    page_query_param="_page"

@api_view(['GET'])
def get_paginated_advances(request):

    advances= AdvanceRequest.objects.all()
    paginator=AdvancePagination()
    paginated_advances=paginator.paginate_queryset(advances,request)
    serializer=AdvanceRequestSerializer(paginated_advances,many=True)
    return paginator.get_paginated_response(serializer.data)

class ApprovalStatusViewSet(viewsets.ModelViewSet):
    queryset=ApprovalStatus.objects.all()
    serializer_class=ApprovalStatusSerializer

class UserApprovalViewSet(viewsets.ModelViewSet):
    queryset=UserApproval.objects.all()
    serializer_class=UserApprovalSerializer


class CashPaymentViewSet(viewsets.ModelViewSet):
    queryset=CashPayment.objects.all()
    serializer_class=CashPaymentSerializer
@api_view(['GET'])
def get_next_payment_code(request):
    last_request = CashPayment.objects.order_by('-ID').first()
    next_id = 1 if not last_request else last_request.ID + 1
    next_code = f"Pay-000-{str(next_id).zfill(3)}"
    return Response({'next_payment_code': next_code})

#search cashpayment by keyword
@api_view(['GET'])
def filter_cashpayments(request):
    search_term = request.query_params.get('search', '').strip()

    if not search_term:
        return Response(
            {"error": "Please provide a search term using the 'search' parameter"},
            status=status.HTTP_400_BAD_REQUEST
        )

    try:
        payments = CashPayment.objects.filter(
            Q(Payment_No__icontains=search_term) |
            Q(Currency__icontains=search_term) |
            Q(Payment_Method__icontains=search_term) |
            Q(Payment_Note__icontains=search_term) |
            Q(Received_Person__icontains=search_term) |
            Q(Paid_Person__icontains=search_term) |
            Q(Payment_Amount__exact=try_parse_decimal(search_term))  # Handle decimal parsing
        ).distinct()

        if not payments.exists():
            return Response(
                {"message": "No payments found matching your search criteria"},
                status=status.HTTP_404_NOT_FOUND
            )
        serializer = CashPaymentSerializer(payments, many=True)
        return Response(serializer.data)
    except Exception as e:
        return Response(
            {"error": str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )

def try_parse_decimal(value):
    try:
        return Decimal(value)
    except:
        return None
    
#pagination for payments
class PaymentPagination(PageNumberPagination):
    page_size=10
    page_size_query_param="_limit"
    page_query_param= "_page"

@api_view(['GET'])
def get_paginated_payments(request):
    payments= CashPayment.objects.all()
    paginator=PaymentPagination()
    paginated_payments=paginator.paginate_queryset(payments,request)
    serializer=CashPaymentSerializer(paginated_payments,many=True)
    return paginator.get_paginated_response(serializer.data)

# class SettlementViewSet(viewsets.ModelViewSet):
#     queryset = Settlement.objects.all().select_related('Payment_ID')
#     serializer_class = SettlementSerializer
#     filter_backends = [
#         DjangoFilterBackend,
#         filters.SearchFilter,
#         filters.OrderingFilter
#     ]
#     filterset_fields = {
#         'Payment_ID': ['exact'],
#         'Settlement_Date': ['exact', 'gte', 'lte'],
#         'Currency': ['exact'],
#     }
#     search_fields = ['Payment_ID__some_field']  
#     ordering_fields = ['Settlement_Date', 'Settlement_Amount']
#     ordering = ['-Settlement_Date']
    
#     def get_queryset(self):
#         queryset = super().get_queryset()
#         # Add any additional filtering logic here
#         return queryset.prefetch_related('settlement_details')

# class SettlementDetailViewSet(viewsets.ModelViewSet):
#     queryset = SettlementDetail.objects.all().select_related(
#         'Settlement_ID', 
#         'Budget_ID'
#     )
#     serializer_class = SettlementDetailSerializer
#     filter_backends = [
#         DjangoFilterBackend,
#         filters.OrderingFilter
#     ]
#     filterset_fields = {
#         'Settlement_ID': ['exact'],
#         'Budget_ID': ['exact'],
#     }
#     ordering_fields = ['Budget_Amount']
#     ordering = ['Budget_ID']

class SettlementViewSet(viewsets.ModelViewSet):
    queryset=Settlement.objects.all().select_related('Payment_ID')
    serializer_class=SettlementSerializer
    service=SettlementService()

    def get_queryset(set):
        queryset=super().get_queryset()
        return queryset.prefetch_related('settlement_details')
    
    def create(self, request, *args, **kwargs):
        try:
            settlement= self.service.create_settlement(request.data)
            serializer=self.get_serializer(settlement)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        except Exception as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )

class RequestSetupFacadeViewSet(viewsets.ModelViewSet):
    queryset = RequestSetUp.objects.all()
    serializer_class = RequestSetUpSerializer
    
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        
        # Return the full created object
        instance = RequestSetUp.objects.get(pk=serializer.data['ID'])
        response_serializer = RequestSetUpCreateSerializer(instance)
        return Response(response_serializer.data, status=status.HTTP_201_CREATED, headers=headers)
    
    def update(self, request, *args, **kwargs):
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        self.perform_update(serializer)
        
        # Return the full updated object
        instance = RequestSetUp.objects.get(pk=serializer.data['ID'])
        response_serializer = RequestSetUpCreateSerializer(instance)
        return Response(response_serializer.data)
    
    @action(detail=True, methods=['get'])
    def full_details(self, request, pk=None):
        instance = self.get_object()
        serializer = self.get_serializer(instance)
        return Response(serializer.data)