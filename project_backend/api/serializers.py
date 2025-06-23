from django.db import IntegrityError
from django.contrib.auth.hashers import check_password, make_password
from rest_framework import serializers
from .models import Budget,Department,User,Project,ProjectBudget,Trip,TripBudget,Operation,OperationBudget,AdvanceRequest,CashPayment,RequestSetUp, ApproverSetupStep,Settlement,SettlementDetail
from django.contrib.contenttypes.models import ContentType


class BudgetSerializer(serializers.ModelSerializer):
    class Meta:
        model = Budget
        fields = [
            'ID', 'Budget_Code', 'Budget_Description',
            'Initial_Amount', 'Revise_Amount', 'Total_Amount',
            'Status', 'Created_Date', 'Modified_Date'
        ]
        extra_kwargs = {
            'Initial_Amount': {'required': False, 'default': 0.0},
            'Revise_Amount': {'required': False, 'default': 0.0},
            'Total_Amount': {'required': False, 'default': 0.0},
            'Status': {'required': False, 'default': 1}
        }


class DepartmentSerializer(serializers.ModelSerializer):
    ID = serializers.IntegerField()  
    class Meta:
        model = Department
        fields = '__all__' 

class UserSerializer(serializers.ModelSerializer):
    Department_Name = serializers.CharField(source='Department_ID.Department_Name', read_only=True)

    
    
    class Meta:
        model = User
        fields = ['ID', 'UserName', 'User_Email', 'Password', 'Role', 'Department_ID', 'Department_Name']
        extra_kwargs = {
            'Password': {'write_only': True},
            'ID': {'read_only': True}  
        }
    
    def create(self, validated_data):
       
        validated_data['Password'] = make_password(validated_data['Password'])
        return super().create(validated_data)

class UserLoginSerializer(serializers.Serializer):
    User_Email = serializers.CharField()
    Password = serializers.CharField(write_only=True)
    Department_ID = serializers.IntegerField()
    
    def validate(self, data):
        user_email = data.get('User_Email')
        password = data.get('Password')
        department_id = data.get('Department_ID')
        
        try:
            user = User.objects.get(User_Email=user_email, Department_ID=department_id)
        except User.DoesNotExist:
            raise serializers.ValidationError("Invalid credentials")
        
        if not check_password(password, user.Password):
            raise serializers.ValidationError("Invalid credentials")
        
        return user


class ProjectSerializer(serializers.ModelSerializer):
    Budget_Details = serializers.SerializerMethodField()
    Department_Name = serializers.CharField(source='Department_ID.Department_Name', read_only=True)
    budgets = serializers.ListField(child=serializers.IntegerField(), write_only=True, required=False)

    class Meta:
        model = Project
        fields = [
            'ID', 'Project_Code', 'Project_Description',
            'Total_Budget_Amount', 'Approved_Amount', 'Currency',
            'Requestable', 'Department_ID', 'Department_Name',
            'Budget_Details', 'budgets', 'Folder_Link',
            'Created_Date', 'Modified_Date'
        ]
        extra_kwargs = {
            'Department_ID': {'write_only': True},
            'Created_Date': {'read_only': True},
            'Modified_Date': {'read_only': True},
            'Project_Code': {'required': False}
        }

    def get_Budget_Details(self, obj):
        project_budgets = ProjectBudget.objects.filter(Project_ID=obj)
        budgets = [pb.Budget_ID for pb in project_budgets]
        return BudgetSerializer(budgets, many=True).data

    def create(self, validated_data):
        budgets_data = validated_data.pop('budgets', [])
       
        # for budget_id in budgets_data:
        #     ProjectBudget.objects.create(Project_ID=project, Budget_ID_id=budget_id)
        # return project
        invalid_budgets = []
        for budget_id in budgets_data:
            if not Budget.objects.filter(id=budget_id).exists():
                invalid_budgets.append(str(budget_id))
        
        if invalid_budgets:
            raise serializers.ValidationError({
                'budgets': f"Invalid budget IDs: {', '.join(invalid_budgets)}"
            })
            
        try:
            project = Project.objects.create(**validated_data)
            
            # Create project-budget relationships
            for budget_id in budgets_data:
                ProjectBudget.objects.get_or_create(
                    Project_ID=project,
                    Budget_ID_id=budget_id
                )
                
            return project
            
        except IntegrityError as e:
            raise serializers.ValidationError(str(e))
   
class ProjectBudgetSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProjectBudget
        fields = ['ID', 'Project_ID', 'Budget_ID']
        extra_kwargs = {
            'ID': {'required': False},
            'Project_ID': {'required': True},
            'Budget_ID': {'required': True}
        }

    def validate(self, data):
        if ProjectBudget.objects.filter(
            Project_ID=data['Project_ID'],
            Budget_ID=data['Budget_ID']
        ).exists():
            raise serializers.ValidationError(
                "This budget is already assigned to the project"
            )
        return data


class TripSerializer(serializers.ModelSerializer):
    
    ID=serializers.IntegerField()
    Total_Budget_Amount=serializers.FloatField()
    Approved_Amount=serializers.FloatField()
    Budget_Details = serializers.SerializerMethodField()
    Department_Name = serializers.CharField(source='Department_ID.Department_Name', read_only=True)
    budgets = serializers.ListField(child=serializers.IntegerField(), write_only=True, required=False)
    class Meta:
        model=Trip
        fields=[
            'ID', 'Trip_Code', 'Trip_Description',
            'Total_Budget_Amount', 'Approved_Amount', 'Currency',
            'Status','budgets','Department_ID','Department_Name','Budget_Details','Created_Date', 'Modified_Date'
        ]
        extra_kwargs = {
            'Department_ID': {'write_only': True},
            'Created_Date': {'read_only': True},
            'Modified_Date': {'read_only': True},
            'Trip_Code': {'required': False}
        } 
    def get_Budget_Details(self, obj):
        trip_budgets = TripBudget.objects.filter(Trip_ID=obj)
        budgets = [tb.Budget_ID for tb in trip_budgets]
        return BudgetSerializer(budgets, many=True).data
    def create(self, validated_data):
        budgets_data = validated_data.pop('budgets', [])
        trip = Trip.objects.create(**validated_data)
        for budget_id in budgets_data:
            TripBudget.objects.create(Trip_ID=trip, Budget_ID_id=budget_id)
        return trip
        

class TripBudgetSerializer(serializers.ModelSerializer):
    class Meta:
        model=TripBudget
        fields = ['ID', 'Trip_ID', 'Budget_ID']
        extra_kwargs = {
            'ID': {'required': False},
            'Trip_ID': {'required': True},
            'Budget_ID': {'required': True}
        }

    def validate(self, data):
        if TripBudget.objects.filter(
            Trip_ID=data['Trip_ID'],
            Budget_ID=data['Budget_ID']
        ).exists():
            raise serializers.ValidationError(
                "This budget is already assigned to the trip"
            )
        return data

class OperationSerializer(serializers.ModelSerializer):
    ID=serializers.IntegerField()
    Total_Budget_Amount=serializers.FloatField()
    Budget_Details = serializers.SerializerMethodField()
    class Meta:
        model=Operation
        fields='__all__'
        
    def get_Budget_Details(self, obj):
        operation_budgets = OperationBudget.objects.filter(Operation_ID=obj)
        budgets = [ob.Budget_ID for ob in operation_budgets]
        return BudgetSerializer(budgets, many=True).data
    def create(self, validated_data):
        budgets_data = validated_data.pop('budgets', [])
        operation = Operation.objects.create(**validated_data)
        for budget_id in budgets_data:
            OperationBudget.objects.create(Operation_ID=operation, Budget_ID_id=budget_id)    
            return operation
    

class OperationBudgetSerializer(serializers.ModelSerializer):
    ID=serializers.IntegerField()
    class Meta:
        model=OperationBudget
        fields = ['ID', 'Operation_ID', 'Budget_ID']
        extra_kwargs = {
            'ID': {'required': False},
            'Operation_ID': {'required': True},
            'Budget_ID': {'required': True}
        }

    def validate(self, data):
        if OperationBudget.objects.filter(
            Operation_ID=data['Operation_ID'],
            Budget_ID=data['Budget_ID']
        ).exists():
            raise serializers.ValidationError(
                "This budget is already assigned to the operation"
            )
        return data

class ApproverSetupStepSerializer(serializers.ModelSerializer):
    ID = serializers.IntegerField()  
    Step_No = serializers.IntegerField()  
    Maximum_Approval_Amount = serializers.FloatField() 
    Approver_Email = serializers.CharField()

    class Meta:
        model = ApproverSetupStep
        fields = ['ID', 'Setup_ID', 'Step_No', 'Maximum_Approval_Amount', 'Approver_Email']


class RequestSetUpSerializer(serializers.ModelSerializer):
    ID = serializers.IntegerField() 

    Department_ID = serializers.PrimaryKeyRelatedField(queryset=Department.objects.all())

    Department_Name = serializers.CharField(source='Department_ID.Department_Name', read_only=True)

    Flow_Name = serializers.CharField()
    Currency = serializers.CharField()
    Description = serializers.CharField()
    No_Of_Steps = serializers.IntegerField()
    Management_Approver = serializers.CharField()

    ApprovalSteps = ApproverSetupStepSerializer(many=True, source='approval_steps',required=False)

    Management_Approver_Bool = serializers.SerializerMethodField()
    Flow_Type_Display = serializers.CharField(source='get_Flow_Type_display', read_only=True)


    class Meta:
        model = RequestSetUp
        fields = [
            'ID', 'Department_ID', 'Department_Name', 'Flow_Name', 'Flow_Type','Flow_Type_Display',
            'Currency', 'Description', 'No_Of_Steps', 'Management_Approver',
            'ApprovalSteps', 'Management_Approver_Bool'
        ]

    def get_Management_Approver_Bool(self, obj):
        return obj.Management_Approver == 'Yes'
    
    def create(self, validated_data):
        approval_steps_data = validated_data.pop('approval_steps', [])
        request_setup = RequestSetUp.objects.create(**validated_data)
        
        for step_data in approval_steps_data:
            ApproverSetupStep.objects.create(Setup_ID=request_setup, **step_data)
        
        return request_setup


class RelatedObjectField(serializers.Field):
    def to_representation(self, value):
        if isinstance(value, Project):
            return {'type': 'project', 'id': value.ID, 'code': value.Project_Code}
        elif isinstance(value, Trip):
            return {'type': 'trip', 'id': value.ID, 'code': value.Trip_Code}
        elif isinstance(value, Operation):
            return {'type': 'operation', 'id': value.ID, 'code': value.Operation_Code}
        return None

    def to_internal_value(self, data):
        if not isinstance(data, dict):
            raise serializers.ValidationError("Expected a dictionary with 'type' and 'id'")
        
        obj_type = data.get('type')
        obj_id = data.get('id')
        
        if obj_type == 'project':
            try:
                return Project.objects.get(ID=obj_id)
            except Project.DoesNotExist:
                raise serializers.ValidationError("Project not found")
        elif obj_type == 'trip':
            try:
                return Trip.objects.get(ID=obj_id)
            except Trip.DoesNotExist:
                raise serializers.ValidationError("Trip not found")
        elif obj_type == 'operation':
            try:
                return Operation.objects.get(ID=obj_id)
            except Operation.DoesNotExist:
                raise serializers.ValidationError("Operation not found")
        else:
            raise serializers.ValidationError("Invalid object type")


class AdvanceRequestSerializer(serializers.ModelSerializer):
    related_object = serializers.SerializerMethodField()  # This will call get_related_object()
    ID = serializers.IntegerField()
    Request_Code=serializers.SerializerMethodField()
    Budget_Details = serializers.SerializerMethodField()

    class Meta:
        model = AdvanceRequest
        fields = '__all__'
        extra_kwargs = {
            'Project_ID': {'write_only': True},
            'Trip_ID': {'write_only': True},
            'Operation_ID': {'write_only': True},
        }

    def get_related_object(self, obj):
        """
        Returns the related object based on Request_Type
        """
        if obj.Request_Type == 'Project' and obj.Project_ID:
            return {
                'type': 'project',
                'id': obj.Project_ID.ID,
                'code': obj.Project_ID.Project_Code,
                'description': obj.Project_ID.Project_Description
            }
        elif obj.Request_Type == 'Trip' and obj.Trip_ID:
            return {
                'type': 'trip',
                'id': obj.Trip_ID.ID,
                'code': obj.Trip_ID.Trip_Code,
                'description': obj.Trip_ID.Trip_Description
            }
        elif obj.Request_Type == 'Operation' and obj.Operation_ID:
            return {
                'type': 'operation',
                'id': obj.Operation_ID.ID,
                'code': obj.Operation_ID.Operation_Code,
                'description': obj.Operation_ID.Operation_Description
            }
        return None
    

    def get_Request_Code(self, obj):
        return obj.Request_Code
    
    def get_Budget_Details(self, obj):
        if obj.Request_Type == 'Project' and obj.Project_ID:
            return [
                {
                    'BudgetCode':b.Budget_ID.Budget_Code,
                    'Description':b.Budget_ID.Budget_Description,
                }
                for b in obj.Project_ID.projectbudget_set.all()
            ]
        elif obj.Request_Type == 'Trip' and obj.Trip_ID:
            return [
                {
                    'BudgetCode': b.Budget_ID.Budget_Code,
                    'Description': b.Budget_ID.Budget_Description
                }
                for b in obj.Trip_ID.tripbudget_set.all()
            ]
        elif obj.Request_Type == 'Operation' and obj.Operation_ID:
            return [
                {
                    'BudgetCode': b.Budget_ID.Budget_Code,
                    'Description': b.Budget_ID.Budget_Description
                }
                for b in obj.Operation_ID.operationbudget_set.all()
            ]
        return []  

    def validate(self, data):
        flow_type = data.get('Request_Type')
        
        if flow_type == 'Project' and not data.get('Project_ID'):
            raise serializers.ValidationError("Project_ID is required when Request_Type is Project")
        elif flow_type == 'Trip' and not data.get('Trip_ID'):
            raise serializers.ValidationError("Trip_ID is required when Request_Type is Trip")
        elif flow_type == 'Operation' and not data.get('Operation_ID'):
            raise serializers.ValidationError("Operation_ID is required when Request_Type is Operation")
        
        return data

    def create(self, validated_data):
        flow_type = validated_data['Request_Type']
        
        if flow_type == 'Project':
            validated_data['related_object'] = validated_data['Project_ID']
        elif flow_type == 'Trip':
            validated_data['related_object'] = validated_data['Trip_ID']
        elif flow_type == 'Operation':
            validated_data['related_object'] = validated_data['Operation_ID']
        
        return super().create(validated_data)



class CashPaymentSerializer(serializers.ModelSerializer):
    ID= serializers.IntegerField()
    Payment_Amount=serializers.FloatField()
    Request_Code = serializers.CharField(source='Request_ID.Request_Code', read_only=True)
    Request_Type = serializers.CharField(source='Request_ID.Request_Type', read_only=True)
    class Meta:
        model=CashPayment
        fields='__all__'
        extra_kwargs={
            'Payment_No': {'required': False}
        }

class SettlementDetailSerializer(serializers.ModelSerializer):
    ID = serializers.IntegerField()  
    Budget_Amount = serializers.FloatField() 
    Budget_Details=BudgetSerializer(many=False, source='Budget_ID', required=False, read_only=True)
    class Meta: 
        model = SettlementDetail
        fields = [
            'ID', 'Budget_Amount', 'Budget_Details','Budget_ID','Settlement_ID'
        ] 
        extra_kwargs={
            'Settlement_ID':{'write_only': True},
            'Budget_ID':{'write_only': True}
        }

class SettlementSerializer(serializers.ModelSerializer): 
    Settlement_Amount = serializers.FloatField()
    Withdrawn_Amount = serializers.FloatField() 
    Refund_Amount = serializers.FloatField() 
    SettlementDetails = SettlementDetailSerializer(many=True, source='settlement_details', required=False)
    class Meta: 
        model = Settlement
        fields = [
            'ID', 'Payment_ID', 'Settlement_Date','Settlement_Amount', 'Withdrawn_Amount','Refund_Amount','Currency','SettlementDetails'
        ]
        extra_kwargs={
            'Payment_ID':{'write_only': True}
        }
        def validate(self,data): 
            withdrawn = data.get('Withdrawn_Amount')
            settlement = data.get('Settlement_Amount')
            refund = data.get('Refund_Amount')
        
            if withdrawn and settlement and refund:
                if abs(withdrawn - (settlement + refund)) > 0.01:  
                    raise serializers.ValidationError(
                    "Withdrawn Amount must equal Settlement Amount plus Refund Amount"
                )
                return data
