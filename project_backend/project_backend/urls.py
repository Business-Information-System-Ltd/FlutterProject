# from django.conf.urls import url,include
# from django.contrib import admin

# urlpatterns = [
#     url(r'^admin/', admin.site.urls),
#     url(r'^api/',include('api.urls')),
# ]

from django.contrib import admin
from django.urls import path, include  # Changed from django.conf.urls import url, include
from api.views import get_next_project_code, get_next_trip_code, get_next_operation_code, get_next_request_code,UserLoginView, get_next_payment_code


urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('api.urls')),
    path('api/projects/next-code/', get_next_project_code),
    path('api/trips/next-code/', get_next_trip_code),
    path('api/operations/next-code/', get_next_operation_code),
    path('api/requests/next-code/', get_next_request_code),
    path('api/payments/next-code/', get_next_payment_code),
    path('api/login/', UserLoginView.as_view(), name='user_login')
]