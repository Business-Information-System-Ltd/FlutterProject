# -*- coding: utf-8 -*-
from rest_framework import filters, viewsets
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.views import APIView
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Budget,Department,User,Project,ProjectBudget,Trip,TripBudget,Operation,OperationBudget, AdvanceRequest, CashPayment, RequestSetUp, ApproverSetupStep, Settlement,SettlementDetail
from .serializers import BudgetSerializer,DepartmentSerializer, UserLoginSerializer,UserSerializer, ProjectSerializer, ProjectBudgetSerializer,TripSerializer,TripBudgetSerializer,OperationSerializer,OperationBudgetSerializer,AdvanceRequestSerializer, CashPaymentSerializer,RequestSetUpSerializer, ApproverSetupStepSerializer,SettlementSerializer,SettlementDetailSerializer

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

class CashPaymentViewSet(viewsets.ModelViewSet):
    queryset=CashPayment.objects.all()
    serializer_class=CashPaymentSerializer
@api_view(['GET'])
def get_next_payment_code(request):
    last_request = CashPayment.objects.order_by('-ID').first()
    next_id = 1 if not last_request else last_request.ID + 1
    next_code = f"Pay-000-{str(next_id).zfill(3)}"
    return Response({'next_payment_code': next_code})

class SettlementViewSet(viewsets.ModelViewSet):
    queryset = Settlement.objects.all().select_related('Payment_ID')
    serializer_class = SettlementSerializer
    filter_backends = [
        DjangoFilterBackend,
        filters.SearchFilter,
        filters.OrderingFilter
    ]
    filterset_fields = {
        'Payment_ID': ['exact'],
        'Settlement_Date': ['exact', 'gte', 'lte'],
        'Currency': ['exact'],
    }
    search_fields = ['Payment_ID__some_field']  
    ordering_fields = ['Settlement_Date', 'Settlement_Amount']
    ordering = ['-Settlement_Date']
    
    def get_queryset(self):
        queryset = super().get_queryset()
        # Add any additional filtering logic here
        return queryset.prefetch_related('settlement_details')

class SettlementDetailViewSet(viewsets.ModelViewSet):
    queryset = SettlementDetail.objects.all().select_related(
        'Settlement_ID', 
        'Budget_ID'
    )
    serializer_class = SettlementDetailSerializer
    filter_backends = [
        DjangoFilterBackend,
        filters.OrderingFilter
    ]
    filterset_fields = {
        'Settlement_ID': ['exact'],
        'Budget_ID': ['exact'],
    }
    ordering_fields = ['Budget_Amount']
    ordering = ['Budget_ID']

