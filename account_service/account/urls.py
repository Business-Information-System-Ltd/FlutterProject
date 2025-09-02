# # from rest_framework.routers import DefaultRouter
# # from .views import AccountViewSet

# # router = DefaultRouter()
# # router.register(r'accounts', AccountViewSet)

# # urlpatterns = router.urls
# from django.urls import path
# from . import views

# urlpatterns = [
#     path('list/', views.list_accounts, name='list_accounts'),
#     path('create/', views.create_account, name='create_account'),
# ]
from rest_framework.routers import DefaultRouter
from accounts.views import AccountViewSet

router = DefaultRouter()
router.register(r'accounts', AccountViewSet, basename='accounts')

urlpatterns = router.urls
