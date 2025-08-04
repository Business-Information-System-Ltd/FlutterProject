from django.db import transaction
from django.views.generic import detail
from .models import ApproverSetupStep, Department, RequestSetUp, Settlement, SettlementDetail, UserApproval
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

# class RequestSetupFacadeService:
#     @transaction.atomic
#     def create_request_setup(self, data):
#         # Extract nested data
#         approval_steps_data = data.pop('approval_steps', [])
        
#         # Create main request setup
#         request_setup = RequestSetUp.objects.create(**data)
        
#         # Create approval steps and approvers
#         for step_data in approval_steps_data:
#             approvers_data = step_data.pop('user_approval', [])
#             step = ApproverSetupStep.objects.create(Setup_ID=request_setup, **step_data)
            
#             for approver_data in approvers_data:
#                 UserApproval.objects.create(
#                     Setup_Step_ID=step,
#                     User_ID=approver_data['User_ID']
#                 )
        
#         return request_setup

#     @transaction.atomic
#     def update_request_setup(self, instance, data):
#         approval_steps_data = data.pop('approval_steps', None)
        
#         # Update main fields
#         for attr, value in data.items():
#             setattr(instance, attr, value)
#         instance.save()
        
#         if approval_steps_data is not None:
#             self._update_approval_steps(instance, approval_steps_data)
        
#         return instance

#     def _update_approval_steps(self, instance, steps_data):
#         existing_step_ids = {step.ID for step in instance.approval_steps.all()}
#         received_step_ids = set()
        
#         for step_data in steps_data:
#             approvers_data = step_data.pop('user_approval', [])
#             step_id = step_data.get('ID', None)
            
#             if step_id and step_id in existing_step_ids:
#                 # Update existing step
#                 step = ApproverSetupStep.objects.get(ID=step_id, Setup_ID=instance)
#                 for attr, value in step_data.items():
#                     setattr(step, attr, value)
#                 step.save()
#                 received_step_ids.add(step_id)
                
#                 # Update approvers
#                 self._update_approvers(step, approvers_data)
#             else:
#                 # Create new step
#                 step = ApproverSetupStep.objects.create(Setup_ID=instance, **step_data)
#                 received_step_ids.add(step.ID)
                
#                 # Create approvers
#                 for approver_data in approvers_data:
#                     UserApproval.objects.create(
#                         Setup_Step_ID=step,
#                         User_ID=approver_data['User_ID']
#                     )
        
#         # Delete steps not in request
#         instance.approval_steps.exclude(ID__in=received_step_ids).delete()

#     def _update_approvers(self, step, approvers_data):
#         existing_approver_ids = {approver.ID for approver in step.user_approval.all()}
#         received_approver_ids = set()
        
#         for approver_data in approvers_data:
#             approver_id = approver_data.get('ID', None)
            
#             if approver_id and approver_id in existing_approver_ids:
#                 # Update existing approver
#                 approver = UserApproval.objects.get(ID=approver_id, Setup_Step_ID=step)
#                 approver.User_ID = approver_data['User_ID']
#                 approver.save()
#                 received_approver_ids.add(approver_id)
#             else:
#                 # Create new approver
#                 approver = UserApproval.objects.create(
#                     Setup_Step_ID=step,
#                     User_ID=approver_data['User_ID']
#                 )
#                 received_approver_ids.add(approver.ID)
        
#         # Delete approvers not in request
#         step.user_approval.exclude(ID__in=received_approver_ids).delete()

class RequestSetupFacadeService:
    @transaction.atomic
    def create_request_setup(self, data):
        # Get department instance
        department_id = data.pop('Department_ID')
        try:
            department = Department.objects.get(pk=department_id)
        except Department.DoesNotExist:
            raise ValueError("Department does not exist")
        
        # Extract nested data
        approval_steps_data = data.pop('approval_steps', [])
        
        # Create main request setup
        request_setup = RequestSetUp.objects.create(Department_ID=department, **data)
        
        # Create approval steps and approvers
        for step_data in approval_steps_data:
            approvers_data = step_data.pop('user_approval', [])
            step = ApproverSetupStep.objects.create(Setup_ID=request_setup, **step_data)
            
            for approver_data in approvers_data:
                UserApproval.objects.create(
                    Setup_Step_ID=step,
                    User_ID=approver_data['User_ID']
                )
        
        return request_setup

    @transaction.atomic
    def update_request_setup(self, instance, data):
        # Handle department if provided
        if 'Department_ID' in data:
            department_id = data.pop('Department_ID')
            try:
                department = Department.objects.get(pk=department_id)
                instance.Department_ID = department
            except Department.DoesNotExist:
                raise ValueError("Department does not exist")
        
        approval_steps_data = data.pop('approval_steps', None)
        
        # Update main fields
        for attr, value in data.items():
            setattr(instance, attr, value)
        instance.save()
        
        if approval_steps_data is not None:
            self._update_approval_steps(instance, approval_steps_data)
        
        return instance