from django.db import transaction
from django.views.generic import detail
from .models import Settlement, SettlementDetail
from .serializers import SettlementSerializer


class SettlementService:
    def create_settlement(self, settlement_data):
        serializer=SettlementSerializer(data=settlement_data)
        serializer.is_valid(raise_exception=True)
        with transaction.atomic():
            settlement=self._create_settlement(serializer._validated_data)
            if 'settlement_details' in serializer._validated_data:
                self._create_settlement_details(
                    settlement,
                    serializer._validated_data['settlement_details']
                )
        return settlement
    
    def _create_settlement(self,validated_data):
        settlement_data={k: v for k, v in validated_data.items() 
                         if k != 'settlement_details'}
        return Settlement.objects.create(**settlement_data)
    
    def _create_settlement_details(self,settlement, details_data):
        details= [
            SettlementDetail(
                Settlement_ID=settlement
                **{k: v for k, v in detail.items() if k != 'ID'}
            )
            for detail in details_data
        ]
        SettlementDetail.objects.bulk_create(details)