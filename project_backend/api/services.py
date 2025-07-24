from django.db import transaction
from django.views.generic import detail
from .models import Settlement, SettlementDetail
from .serializers import SettlementSerializer


class SettlementService:
    def create_settlement(self, settlement_data):
        serializer = SettlementSerializer(data=settlement_data)
        serializer.is_valid(raise_exception=True)
        
        with transaction.atomic():
            settlement = serializer.save()  # Use the serializer's create method
            
        return settlement
    
    def update_settlement(self, settlement_id, settlement_data):
        settlement = Settlement.objects.get(pk=settlement_id)
        serializer = SettlementSerializer(settlement, data=settlement_data)
        serializer.is_valid(raise_exception=True)
        
        with transaction.atomic():
            updated_settlement = serializer.save()
            
        return updated_settlement