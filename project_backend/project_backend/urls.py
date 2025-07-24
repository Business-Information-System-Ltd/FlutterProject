# from django.conf.urls import url,include
# from django.contrib import admin

# urlpatterns = [
#     url(r'^admin/', admin.site.urls),
#     url(r'^api/',include('api.urls')),
# ]

from django.contrib import admin
from django.urls import path, include  
from api.views import filter_advances, filter_cashpayments, filter_projects, filter_trips, get_next_project_code, get_next_trip_code, get_next_operation_code, get_next_request_code,UserLoginView, get_next_payment_code, get_operation_budgets, get_paginated_advances, get_paginated_payments, get_paginated_projects, get_paginated_trips, get_project_budgets, get_trip_budgets


urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('api.urls')),
    path('api/projects/next-code/', get_next_project_code),
    path('api/trips/next-code/', get_next_trip_code),
    path('api/operations/next-code/', get_next_operation_code),
    path('api/requests/next-code/', get_next_request_code),
    path('api/payments/next-code/', get_next_payment_code),
    path('api/projects/<int:project_id>/budgets/', get_project_budgets, name='project-budgets'),
    path('api/projects/filterKeyword/', filter_projects, name='filter-projects'),
    path('api/projects/pagination/', get_paginated_projects, name='paginated-projects'),
    path('api/trips/<int:trip_id>/budgets/', get_trip_budgets, name='trip-budgets'),
    path('api/trips/filterKeyword/', filter_trips, name='filter-trips'),
    path('api/trips/pagination/', get_paginated_trips, name='paginated-trips'),
    path('api/operations/<int:operation_id>/budgets/', get_operation_budgets, name='operation_budgets'),
    path('api/advances/filterKeyword/', filter_advances, name='filter-advances'),
    path('api/advances/pagination/', get_paginated_advances, name='paginated-advances'),
    path('api/payments/filterKeyword/', filter_cashpayments, name='filter-payments'),
    path('api/payments/pagination/', get_paginated_payments, name='paginated-payments'),
    path('api/login/', UserLoginView.as_view(), name='user_login')
] 