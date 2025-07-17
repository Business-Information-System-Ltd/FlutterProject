# from django.conf.urls import url, include
# from rest_framework.routers import DefaultRouter
# from .views import BudgetViewSet

# router = DefaultRouter()
# router.register(r'budget', BudgetViewSet)

# urlpatterns = [
#     url(r'^', include(router.urls)),
# ]

from django.urls import path, include  # Changed import
from rest_framework.routers import DefaultRouter
from .views import BudgetViewSet,DepartmentViewSet,UserViewSet, ProjectViewSet, ProjectBudgetViewSet, TripViewSet, TripBudgetViewSet,OperationViewSet,OperationBudgetViewSet,AdvanceRequestViewSet, CashPaymentViewSet,RequestSetUpViewSet,ApproverSetupStepViewSet,SettlementViewSet,SettlementDetailViewSet

router = DefaultRouter()
router.register(r'budget', BudgetViewSet)
router.register(r'department', DepartmentViewSet) 
router.register(r'user', UserViewSet) 
router.register(r'project', ProjectViewSet)
router.register(r'projectbudget', ProjectBudgetViewSet)
router.register(r'trip', TripViewSet) 
router.register(r'tripbudget', TripBudgetViewSet)
router.register(r'operation', OperationViewSet)
router.register(r'operationbudget', OperationBudgetViewSet)
router.register(r'advancerequest', AdvanceRequestViewSet)
router.register(r'cashpayment', CashPaymentViewSet)
router.register(r'requestsetup', RequestSetUpViewSet)
router.register(r'approversetupstep', ApproverSetupStepViewSet)
router.register(r'settlement', SettlementViewSet)
router.register(r'settlementdetail', SettlementDetailViewSet)


urlpatterns = [
    path('', include(router.urls)),
]