from django.db import models
from django.contrib.contenttypes.fields import GenericForeignKey
from django.contrib.contenttypes.models import ContentType
class Budget(models.Model):
    ID = models.AutoField(primary_key=True)
    Budget_Code = models.CharField(max_length=15, unique=True)
    Budget_Description = models.TextField()
    Status = models.SmallIntegerField(default=1)
    Created_Date = models.DateTimeField(auto_now_add=True)
    Modified_Date = models.DateTimeField(auto_now=True)
    Initial_Amount = models.FloatField()
    Revise_Amount = models.FloatField()
    Total_Amount = models.FloatField()

    class Meta: 
        managed = False
        db_table = 'budget' 

    def __str__(self):
        return self.Budget_Code

class Department(models.Model):
    ID = models.AutoField(primary_key=True)
    Department_Code = models.CharField(max_length=15, unique=True)
    Department_Name = models.CharField(max_length=30)
    class Meta:
        managed = False
        db_table='department'

    def str(self):
        return self.Department_Code 

class User(models.Model):
    ID= models.DecimalField(primary_key=True, max_digits=10,decimal_places=0)
    UserName = models.CharField(max_length=100, unique=True)
    User_Email= models.CharField(max_length=100, unique=True)
    Role= models.CharField(max_length=50)
    Password= models.CharField(max_length=100)
    Department_ID= models.ForeignKey(Department, on_delete=models.CASCADE,db_column='Department_ID')
    # Department = models.ForeignKey(Department, on_delete=models.CASCADE)
    class Meta:
        managed = False
        db_table='user'
    def __str__(self):
        return self.User_Email

class Project(models.Model):
    ID = models.AutoField(primary_key=True)
    Department_ID = models.ForeignKey(Department, on_delete=models.CASCADE, db_column='Department_ID')
    Project_Code = models.CharField(max_length=15, unique=True)
    Project_Description = models.TextField()
    Total_Budget_Amount = models.IntegerField()
    Approved_Amount = models.IntegerField()
    Currency = models.CharField(max_length=5)
    Requestable = models.CharField(max_length=7, choices=[('Pending','Pending'),('Yes','Yes'),('No','No')])
    Folder_Link = models.CharField(max_length=255, null=True, blank=True)
    Created_Date = models.DateTimeField(auto_now_add=True)
    Modified_Date = models.DateTimeField(auto_now=True)
    Budgets = models.ManyToManyField(Budget, through='ProjectBudget')

    class Meta:
        managed = False
        db_table='project_information'

    def save(self, *args, **kwargs):
        if not self.Project_Code:
            # Calculate next project code based on highest existing ID.
            last_project = Project.objects.order_by('-ID').first() 
            next_id = 1 if last_project is None else last_project.ID + 1
            self.Project_Code = f"PRJ-000-{str(next_id).zfill(3)}"
        super().save(*args, **kwargs)

    def __str__(self):
        return self.Project_Code

class ProjectBudget(models.Model):
    ID = models.AutoField(primary_key=True)
    Project_ID = models.ForeignKey(Project, on_delete=models.CASCADE,db_column='Project_ID')
    Budget_ID = models.ForeignKey(Budget, on_delete=models.CASCADE,db_column='Budget_ID')
    class Meta:
        managed = True
        db_table='project_budget'
        unique_together = (('Project_ID', 'Budget_ID'),)

    def __str__(self):
        return str(self.ID)

class Trip(models.Model):
    ID = models.DecimalField(primary_key=True, max_digits=10,decimal_places=0)
    Trip_Code = models.CharField(max_length=20, unique=True)
    Trip_Description = models.TextField()
    Total_Budget_Amount = models.DecimalField(max_digits=12,decimal_places=2)
    Approved_Amount = models.DecimalField(max_digits=12,decimal_places=2)
    Currency=models.CharField(max_length=5)
    Status = models.IntegerField(choices=[(1, 'Yes'), (0, 'No')])
    Budgets=models.ManyToManyField(Budget, through='TripBudget')
    Department_ID = models.ForeignKey(Department, on_delete=models.CASCADE,db_column='Department_ID') 
    Created_Date = models.DateTimeField(auto_now_add=True)
    Modified_Date = models.DateTimeField(auto_now=True)
    Source= models.CharField(max_length=50)
    Destination=models.CharField(max_length=50)
    DepartureDate=models.DateTimeField()
    ReturnDate=models.DateTimeField()
    Other_Person=models.BooleanField(default=False)
    Round_Trip=models.BooleanField(default=True)
    Direct_AdvanceRequest=models.BooleanField(default=False)
    ExpenditureOption=models.BooleanField(default=False)
    Requester_Name=models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table='trip_information'
    
    def save(self, *args, **kwargs):
        if not self.Trip_Code:  
            last_trip = Trip.objects.order_by('-ID').first() 
            next_id = 1 if last_trip is None else last_trip.ID + 1
            self.Trip_Code = f"TRP-000-{str(next_id).zfill(3)}" 
        super().save(*args, **kwargs)
    def __str__(self):
        return self.Trip_Code

class TripBudget(models.Model):
    ID = models.AutoField(primary_key=True)
    Trip_ID=  models.ForeignKey(Trip, on_delete=models.CASCADE,db_column='Trip_ID')
    Budget_ID=models.ForeignKey(Budget, on_delete=models.CASCADE,db_column='Budget_ID')
    class Meta:
        managed = False
        db_table='trip_budget'
        unique_together = (('Trip_ID', 'Budget_ID'),) 

    def __str__(self):
        return str(self.ID)

class Operation(models.Model):
    ID = models.AutoField(primary_key=True)
    Operation_Code=models.CharField(max_length=20, unique=True)
    Operation_Description=models.TextField()
    Total_Budget_Amount=models.DecimalField(max_digits=12,decimal_places=2) 
    Currency=models.CharField(max_length=5)  
    Folder_Link=models.CharField(max_length=255,null=True, blank=True) 
    Budgets=models.ManyToManyField(Budget, through='OperationBudget')
    Department_ID=models.ForeignKey(Department, on_delete=models.CASCADE,db_column='Department_ID') 

    class Meta:
        managed = False
        db_table='operation_information'
    
    def save(self, *args, **kwargs):
        if not self.Operation_Code:  
            last_operation = Operation.objects.order_by('-ID').first() 
            next_id = 1 if last_operation is None else last_operation.ID + 1
            self.Operation_Code = f"OPR-000-{str(next_id).zfill(3)}" 
        super().save(*args, **kwargs)
    def __str__(self):
        return self.Operation_Code

class OperationBudget(models.Model):
    ID = models.AutoField(primary_key=True) 
    Operation_ID=models.ForeignKey(Operation, on_delete=models.CASCADE,db_column='Operation_ID')
    Budget_ID=models.ForeignKey(Budget, on_delete=models.CASCADE,db_column='Budget_ID')
    class Meta:
        managed = False
        db_table='operation_budget'
        unique_together = (('Operation_ID', 'Budget_ID'),) 

    def __str__(self):
        return str(self.ID)
    
class RequestSetUp(models.Model):
    ID = models.AutoField(primary_key=True) 
    Department_ID=models.ForeignKey(Department, on_delete=models.CASCADE,db_column='Department_ID')
    Flow_Name=models.CharField(max_length=50)
    Currency=models.CharField(max_length=5)
    Flow_Type=models.CharField(max_length=50, choices=[('Project','Project'),('Trip','Trip'),('Operation','Operation')])
    Description=models.TextField()
    No_Of_Steps=models.IntegerField()
    Management_Approver=models.CharField(max_length=10, choices=[('Yes','Yes'),('No','No')])
    class Meta:
        managed = False
        db_table='request_setup'
    def str(self):
        return str(self.ID)

class ApproverSetupStep(models.Model):
    ID=models.AutoField(primary_key=True)
    Setup_ID=models.ForeignKey(RequestSetUp, on_delete=models.CASCADE,db_column='Setup_ID',  related_name='approval_steps')
    Step_No=models.IntegerField()
    Maximum_Approval_Amount=models.DecimalField(max_digits=12,decimal_places=2)
    Is_All_Approver= models.CharField(max_length=10, choices=[('One','One'),('All','All')])
    Limited_Time= models.DateTimeField()
    Request_Status= models.BooleanField()

    class Meta:
        managed = False
        db_table='approver_setup_step'
    def __str__(self):
        return str(self.ID)





class AdvanceRequest(models.Model):
    ID = models.AutoField(primary_key=True) 
    Request_No = models.CharField(max_length=20, unique=True)
    Requester = models.CharField(max_length=100)
    Request_Type = models.CharField(max_length=50, choices=[
        ('Project', 'Project'),
        ('Trip', 'Trip'),
        ('Operation', 'Operation')
    ])
    Trip_ID = models.ForeignKey(
        Trip, 
        on_delete=models.CASCADE, 
        db_column='Trip_ID',
        null=True,
        blank=True
    )
    Project_ID = models.ForeignKey(
        Project, 
        on_delete=models.CASCADE, 
        db_column='Project_ID',
        null=True,
        blank=True
    )
    Operation_ID = models.ForeignKey(
        Operation, 
        on_delete=models.CASCADE, 
        db_column='Operation_ID', 
        null=True,
        blank=True
    )
    Request_Amount = models.DecimalField(max_digits=12, decimal_places=2)
    Approved_Amount = models.DecimalField(max_digits=12, decimal_places=2)
    Currency = models.CharField(max_length=5)
    Purpose_Of_Request = models.TextField()
    Requested_Date =  models.DateTimeField(auto_now_add=True)
    Folder_Link = models.CharField(max_length=255, null=True, blank=True)
    Workflow_Status = models.CharField(max_length=20, choices=[('Pending','Pending'),('Approved','Approved'),('Rejected','Rejected')])
    Created_Date = models.DateTimeField(auto_now_add=True)
    Modified_Date = models.DateTimeField(auto_now=True)
    Setup_ID = models.ForeignKey(RequestSetUp, on_delete=models.CASCADE, db_column='Setup_ID',null=True,blank=True)
    class Meta:
        managed = False
        db_table = 'advancerequest'

    def save(self, *args, **kwargs):
        if not self.Request_No:  
            last_request = AdvanceRequest.objects.order_by('-ID').first() 
            next_id = 1 if last_request is None else last_request.ID + 1
            self.Request_No = f"Req-000-{str(next_id).zfill(3)}" 
        super().save(*args, **kwargs)

    def __str__(self):
        return self.Request_No

    @property
    def related_object(self):
        """Returns the related object based on Flow_Type"""
        if self.Request_Type == 'Project':
            return self.Project
        elif self.Request_Type == 'Trip':
            return self.Trip
        elif self.Request_Type == 'Operation':
            return self.Operation
        return None

    @property
    def Request_Code(self):
        if self.Request_Type == 'Project' and self.Project_ID:
            return str(self.Project_ID.Project_Code)
        elif self.Request_Type == 'Trip' and self.Trip_ID:
            return str(self.Trip_ID.Trip_Code)
        elif self.Request_Type == 'Operation' and self.Operation_ID:
            return str(self.Operation_ID.Operation_Code)
        return ''

    @related_object.setter
    def related_object(self, value):
        """Sets the appropriate foreign key based on the object type"""
        if isinstance(value, Project):
            self.Request_Type = 'Project'
            self.Project = value
            self.Trip = None
            self.Operation = None
        elif isinstance(value, Trip):
            self.Request_Type = 'Trip'
            self.Trip = value
            self.Project = None
            self.Operation = None
        elif isinstance(value, Operation):
            self.Request_Type = 'Operation'
            self.Operation_ = value
            self.Project = None
            self.Trip= None
        else:
            raise ValueError("Invalid object type for related_object")
        
class ApprovalStatus(models.Model):
    ID=models.AutoField(primary_key=True)
    Step_ID=models.ForeignKey(ApproverSetupStep, on_delete=models.CASCADE,db_column='Step_ID',  related_name='approval_status')
    Step_No=models.IntegerField()
    Request_ID=models.ForeignKey(AdvanceRequest,on_delete=models.CASCADE, db_column="Request_ID",related_name="approval_status")
    Is_All_Approver= models.CharField(max_length=10, choices=[('One','One'),('All','All')])
    Comment= models.TextField()
    Response_Date= models.DateTimeField()
    Status=models.CharField(max_length=10, choices=[("Pending","Pending"), ("Progress","Progress"),("Approved","Approved"),("Reject","Reject")])

    class Meta:
        managed = False
        db_table='approval_status'
    def __str__(self):
        return str(self.ID) 

class UserApproval(models.Model):
    ID=models.AutoField(primary_key=True)
    User_ID=models.ForeignKey(User, on_delete=models.CASCADE,db_column='User_ID',  related_name='user_approval')
    Setup_Step_ID= models.ForeignKey(ApproverSetupStep,on_delete=models.CASCADE,db_column="Setup_Step_ID", related_name="user_approval")
    class Meta:
        managed = False
        db_table='user_approval'
    def __str__(self):
        return str(self.ID) 


class CashPayment(models.Model):
    ID = models.AutoField(primary_key=True) 
    Request_ID = models.ForeignKey(AdvanceRequest, on_delete=models.CASCADE, db_column='Request_ID')
    Payment_No=models.CharField(max_length=20, unique=True)
    Payment_Date = models.DateTimeField(auto_now_add=True)
    Payment_Amount = models.DecimalField(max_digits=12, decimal_places=2)
    Currency = models.CharField(max_length=5)
    Payment_Method = models.CharField(max_length=20, choices=[('Cash','Cash'),('Bank','Bank'),('Cheque','Cheque')])
    Payment_Note = models.TextField()
    Received_Person=models.CharField(max_length=30)
    Paid_Person= models.CharField(max_length=30)
    Posting_Status = models.IntegerField(choices=[(1, 'Draft'), (0, 'Posted')])
    Settlement_Status=models.IntegerField(choices=[(1, 'Yes'), (0, 'No')])
    Folder_link=models.CharField(max_length=255,null=True, blank=True)

    def save(self, *args, **kwargs):
        if not self.Payment_No:  
            last_request = AdvanceRequest.objects.order_by('-ID').first() 
            next_id = 1 if last_request is None else last_request.ID + 1
            self.Payment_No = f"Pay-000-{str(next_id).zfill(3)}" 
        super().save(*args, **kwargs)
    class Meta:
        managed = True
        db_table='payment'
    def __str__(self):
        return str(self.Payment_No)


class Settlement(models.Model):
    ID = models.AutoField(primary_key=True) 
    Payment_ID = models.ForeignKey(CashPayment, on_delete=models.CASCADE, db_column='Payment_ID')
    Settlement_Date = models.DateTimeField(auto_now_add=True)
    Settlement_Amount = models.DecimalField(max_digits=12, decimal_places=2)
    Currency = models.CharField(max_length=5)
    Withdrawn_Amount = models.DecimalField(max_digits=12, decimal_places=2) 
    Refund_Amount = models.DecimalField(max_digits=12, decimal_places=2) 
    class Meta:
        managed = False
        db_table='settlement'
    def __str__(self):
        return str(self.ID)

class SettlementDetail(models.Model):
    ID= models.AutoField(primary_key=True)
    Settlement_ID= models.ForeignKey(Settlement, on_delete=models.CASCADE, db_column='Settlement_ID', related_name='settlement_details')
    Budget_ID= models.ForeignKey(Budget, on_delete=models.CASCADE, db_column='Budget_ID', related_name="settlement_details")
    Budget_Amount= models.DecimalField(max_digits=12, decimal_places=2)
    class Meta:
        managed = False
        db_table='settlement_details'
        verbose_name='Settlement Detail'
        verbose_name_plural = 'Settlement Details'

    def __str__(self):
        return str(self.ID)


