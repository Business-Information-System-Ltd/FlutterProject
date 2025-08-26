import 'package:intl/intl.dart';

class Budget {
  final int id;
  final String BudgetCode;
  final String Description;
  final double InitialAmount;
  double ReviseAmount;
  double BudgetAmount;
  double Amount;

  Budget(
      {required this.id,
      required this.BudgetCode,
      required this.Description,
      required this.InitialAmount,
      required this.ReviseAmount,
      required this.BudgetAmount,
      required this.Amount});

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
        id: json['ID'] ?? '',
        BudgetCode: json['Budget_Code'] ?? '',
        Description: json['Budget_Description'] ?? '',
        InitialAmount: json['Initial_Amount'] ?? 0,
        ReviseAmount: json['Revise_Amount'] ?? 0,
        BudgetAmount: json['Total_Amount'] ?? 0,

        // InitialAmount:
        //     (json['Allocation'] != null && json['Allocation'].isNotEmpty)
        //         ? json['Allocation'][0]['InitialAmount'] ?? 0
        //         : 0,
        Amount: json['Amount'] ?? 0.0);
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Budget_Code': BudgetCode,
      'Budget_Description': Description,
      'Initial_Amount': InitialAmount,
      'Revise_Amount': ReviseAmount,
      'Total_Amount': BudgetAmount,
      'Amount': Amount
    };
  }
}

class BudgetAmount {
  final String? id;
  final String? BudgetCode;
  final String? Description;
  final int? InitialAmount;

  BudgetAmount(
      {required this.id,
      required this.BudgetCode,
      required this.Description,
      required this.InitialAmount});

  factory BudgetAmount.fromJson(Map<String, dynamic> json) {
    return BudgetAmount(
        id: json['id'],
        BudgetCode: json['BudgetCode'],
        Description: json['Description'],
        InitialAmount: json['InitialAmount']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'BudgetCode': BudgetCode,
      'Description': Description,
      'InitialAmount': InitialAmount
    };
  }
}

//for project
class Projects {
  final int id;
  final DateTime date;
  final String Project_Code;
  final String description;
  final double totalAmount;
  final String currency;
  final double approveAmount;
  final int departmentId;
  final String departmentName;
  final String requestable;
  final List<Budget> budgetDetails;

  Projects(
      {required this.id,
      required this.date,
      required this.Project_Code,
      required this.description,
      required this.totalAmount,
      required this.currency,
      required this.approveAmount,
      required this.departmentId,
      required this.departmentName,
      required this.requestable,
      required this.budgetDetails});

  factory Projects.fromJson(Map<String, dynamic> json) {
    var budgetList = <Budget>[];
    if (json['Budget_Details'] != null) {
      budgetList = (json['Budget_Details'] as List)
          .map((budgetJson) => Budget.fromJson(budgetJson))
          .toList();
    }

    final departmentId = json['Department_ID'] ?? 0;
    final departmentName = json['Department_Name'] ?? '';

    print("Parsed JSON: $json");

    return Projects(
      id: json['ID'] ?? 0,
      date: json['Created_Date'] != null
          ? DateFormat('yyyy-MM-dd').parse(json['Created_Date'])
          : DateTime.now(),
      Project_Code: json['Project_Code'] ?? '',
      description: json['Project_Description'] ?? '',
      totalAmount:
          double.tryParse(json['Total_Budget_Amount'].toString()) ?? 0.0,
      currency: json['Currency'] ?? '',
      approveAmount: double.tryParse(json['Approved_Amount'].toString()) ?? 0.0,
      departmentId: departmentId,
      departmentName: departmentName,
      requestable: json['Requestable'] ?? '',
      budgetDetails: budgetList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Created_Date': DateFormat('yyyy-MM-dd').format(date),
      'Project_Code': Project_Code,
      'Project_Description': description,
      'Total_Budget_Amount': totalAmount,
      'Currency': currency,
      'Approved_Amount': approveAmount,
      'Department_ID': departmentId,
      'Department_Name': departmentName,
      'Requestable': requestable,
      // 'BudgetDetails': budgetDetails.map((detail) => detail.toJson()).toList(),
      'Budget_Details': budgetDetails.map((budget) => budget.id).toList(),
    };
  }
}

//for trip
class Trip {
  final int id;
  final DateTime date;
  final String Trip_Code;
  final String description;
  final double totalAmount;
  final String currency;
  final double approveAmount;
  final int status;
  final int departmentId;
  final String departmentName;
  //final String requestDate;
  final List<Budget> budgetDetails;

  Trip(
      {required this.id,
      required this.date,
      required this.Trip_Code,
      required this.description,
      required this.totalAmount,
      required this.currency,
      required this.approveAmount,
      required this.status,
      required this.departmentId,
      required this.departmentName,
      // required this.requestDate,
      required this.budgetDetails});

  factory Trip.fromJson(Map<String, dynamic> json) {
    var budgetList = <Budget>[];
    if (json['Budget_Details'] != null) {
      budgetList = (json['Budget_Details'] as List)
          .map((budgetJson) => Budget.fromJson(budgetJson))
          .toList();
    }
    final departmentId = json['Department_ID'] ?? 0;
    final departmentName = json['Department_Name'] ?? '';
    return Trip(
      id: json['ID'],
      date: json['Created_Date'] != null
          ? DateFormat('yyyy-MM-dd').parse(json['Created_Date'])
          : DateTime.now(),
      Trip_Code: json['Trip_Code'],
      description: json['Trip_Description'],
      // requestDate: json['Trip_requestDate'],
      totalAmount:
          double.tryParse(json['Total_Budget_Amount'].toString()) ?? 0.0,
      currency: json['Currency'],
      departmentId: departmentId,
      departmentName: departmentName,
      status: int.tryParse(json['Status'].toString()) ?? 0,

      approveAmount: double.tryParse(json['Approved_Amount'].toString()) ?? 0.0,
      budgetDetails: budgetList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Created_Date': DateFormat('yyyy-MM-dd').format(date),
      'Trip_Code': Trip_Code,
      'Trip_Description': description,
      'Total_Budget_Amount': totalAmount,
      'Currency': currency,
      'Department_ID': departmentId,
      'Department_Name': departmentName,
      'Status': status,
      // 'Trip_requestDate':requestDate,
      'Approved_Amount': approveAmount,
      'Budget_Details': budgetDetails.map((detail) => detail.toJson()).toList(),
      // 'Budget_Details': budgetDetails.map((detail) => detail.toJson()).toList(),
    };
  }
}

//operation
class Operation {
  final int id;
  final DateTime date;
  final String Operation_Code;
  final String description;
  final double totalAmount;
  final String currency;
  final int departmentId;
  final String departmentName;
  final List<Budget> budgetDetails;

  Operation(
      {required this.id,
      required this.date,
      required this.Operation_Code,
      required this.description,
      required this.totalAmount,
      required this.currency,
      required this.departmentId,
      required this.departmentName,
      required this.budgetDetails});

  factory Operation.fromJson(Map<String, dynamic> json) {
    var budgetList = <Budget>[];
    if (json['Budgets'] != null) {
      budgetList = (json['Budget_Details'] as List)
          .map((budgetJson) => Budget.fromJson(budgetJson))
          .toList();
    }
    final departmentId = json['Department_ID'] ?? 0;
    final departmentName = json['Department_Name'] ?? '';
    return Operation(
      id: json['ID'],
      date: json['Date'] != null
          ? DateFormat('yyyy-MM-dd').parse(json['Date'])
          : DateTime.now(),
      Operation_Code: json['Operation_Code'],
      description: json['Operation_Description'],
      totalAmount:
          double.tryParse(json['Total_Budget_Amount'].toString()) ?? 0.0,
      currency: json['Currency'],
      departmentId: departmentId,
      departmentName: departmentName,
      budgetDetails: budgetList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Date': DateFormat('yyyy-MM-dd').format(date),
      'Operation_Code': Operation_Code,
      'Operation_Description': description,
      'Total_Budget_Amount': totalAmount,
      'Currency': currency,
      'Department_ID': departmentId,
      'Department_Name': departmentName,
      'Budget_Details ':
          budgetDetails.map((detail) => detail.toJson()).toList(),
    };
  }
}

//for Advance Request
// class AdvanceRequest {
//   final int id;
//   final DateTime date;
//   final String requestNo;
//   final String requestCode;
//   final String requestType;
//   final double requestAmount;
//   final String currency;
//   final String requester;
//   final double approveAmount;
//   final String purpose;
//   final String status;
//   //final int setupId;
//   final int? tripId;
//   final int? projectId;
//   final int? operationId;
//   final List<Budget> budgetDetails;

//   AdvanceRequest(
//       {required this.id,
//       required this.date,
//       required this.requestNo,
//       required this.requestCode,
//       required this.requestType,
//       required this.requestAmount,
//       required this.currency,
//       required this.requester,
//       required this.approveAmount,
//       required this.purpose,
//       required this.status,
//       //required this.setupId,
//       required this.tripId,
//       required this.projectId,
//       required this.operationId,
//       required this.budgetDetails});

//   factory AdvanceRequest.fromJson(Map<String, dynamic> json) {
//     return AdvanceRequest(
//       id: json['ID'],
//       // setupId: json['Setup_ID'] ?? 1,
//       requestNo: json['Request_No'],
//       requester: json['Requester'],
//       requestCode: json['Request_Code'] ?? '',
//       requestType: json['Request_Type'],
//       tripId: json['Trip_ID'] ?? null,
//       projectId: json['Project_ID'] ?? null,
//       operationId: json['Operation_ID'] ?? null,
//       requestAmount: json['Request_Amount'] != null
//           ? (json['Request_Amount'] is String
//               ? double.tryParse(json['Request_Amount']) ?? 0.0
//               : json['Request_Amount'].toDouble())
//           : 0.0,
//       approveAmount: json['Approved_Amount'] != null
//           ? (json['Approved_Amount'] is String
//               ? double.tryParse(json['Approved_Amount']) ?? 0.0
//               : json['Approved_Amount'].toDouble())
//           : 0.0,
//       currency: json['Currency'],
//       purpose: json['Purpose_Of_Request'],
//       date: DateFormat('yyyy-MM-dd').parse(json['Requested_Date']),
//       status: json['Workflow_Status'],
//       budgetDetails: json['BudgetDetails'] != null
//           ? List<Budget>.from(
//               json['BudgetDetails'].map((detail) => Budget.fromJson(detail)),
//             )
//           : [],
//     );
//   }
//     return AdvanceRequest(
//       id: json['ID'],
//       // setupId: json['Setup_ID'] ?? 1,
//       requestNo: json['Request_No'],
//       requester: json['Requester'],
//       requestCode: json['Request_Code'] ?? '',
//       requestType: json['Request_Type'],
//       tripId: json['Trip_ID'] ?? null,
//       projectId: json['Project_ID'] ?? null,
//       operationId: json['Operation_ID'] ?? null,
//       requestAmount: json['Request_Amount'] != null
//           ? (json['Request_Amount'] is String
//               ? double.tryParse(json['Request_Amount']) ?? 0.0
//               : json['Request_Amount'].toDouble())
//           : 0.0,
//       approveAmount: json['Approved_Amount'] != null
//           ? (json['Approved_Amount'] is String
//               ? double.tryParse(json['Approved_Amount']) ?? 0.0
//               : json['Approved_Amount'].toDouble())
//           : 0.0,
//       currency: json['Currency'],
//       purpose: json['Purpose_Of_Request'],
//       date: DateFormat('yyyy-MM-dd').parse(json['Requested_Date']),
//       status: json['Workflow_Status'],
//       budgetDetails: json['BudgetDetails'] != null
//           ? List<Budget>.from(
//               json['BudgetDetails'].map((detail) => Budget.fromJson(detail)),
//             )
//           : [],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     final data = {
//       'ID': id,
//       //'Setup_ID': setupId,
//       'Request_No': requestNo,
//       'Request_Code': requestCode,
//       'Requester': requester,
//       'Request_Type': requestType,
//       'Request_Amount': requestAmount,
//       'Approved_Amount': approveAmount,
//       'Currency': currency,
//       'Purpose_Of_Request': purpose,
//       'Requested_Date': DateFormat('yyyy-MM-dd').format(date),
//       'Workflow_Status': status,
//       'Budget_Details ': budgetDetails.map((detail) => detail.toJson()).toList()
//     };
//     final data = {
//       'ID': id,
//       //'Setup_ID': setupId,
//       'Request_No': requestNo,
//       'Request_Code': requestCode,
//       'Requester': requester,
//       'Request_Type': requestType,
//       'Request_Amount': requestAmount,
//       'Approved_Amount': approveAmount,
//       'Currency': currency,
//       'Purpose_Of_Request': purpose,
//       'Requested_Date': DateFormat('yyyy-MM-dd').format(date),
//       'Workflow_Status': status,
//       'Budget_Details ': budgetDetails.map((detail) => detail.toJson()).toList()
//     };

//     // Only include the valid one
//     if (tripId != null && requestType == "Trip") {
//       data['Trip_ID'] = int.tryParse(tripId.toString()) ?? 0;
//     } else if (projectId != null && requestType == "Project") {
//       data['Project_ID'] = int.tryParse(projectId.toString()) ?? 0;
//     } else if (operationId != null && requestType == "Operation") {
//       data['Operation_ID'] = int.tryParse(operationId.toString()) ?? 0;
//     }
//     // Only include the valid one
//     if (tripId != null && requestType == "Trip") {
//       data['Trip_ID'] = int.tryParse(tripId.toString()) ?? 0;
//     } else if (projectId != null && requestType == "Project") {
//       data['Project_ID'] = int.tryParse(projectId.toString()) ?? 0;
//     } else if (operationId != null && requestType == "Operation") {
//       data['Operation_ID'] = int.tryParse(operationId.toString()) ?? 0;
//     }

//     return data;
//   }
//     return data;
//   }
// }

//for Cash Payment
class CashPayment {
  final int id;
  final DateTime date;
  final String paymentNo;
  final int requestNo;

  final String requestCode;
  final String requestType;
  final double paymentAmount;
  final String currency;
  final String paymentMethod;
  final String paidPerson;
  final String receivePerson;
  final String paymentNote;
  final int status;
  int settledStatus;

  CashPayment(
      {required this.id,
      required this.date,
      required this.paymentNo,
      required this.requestNo,
      required this.requestCode,
      required this.requestType,
      required this.paymentAmount,
      required this.currency,
      required this.paymentMethod,
      required this.paidPerson,
      required this.receivePerson,
      required this.paymentNote,
      required this.status,
      required this.settledStatus});

  factory CashPayment.fromJson(Map<String, dynamic> json) {
    return CashPayment(
      id: json['ID']??0,
      //date: DateFormat('yyyy-MM-dd').parse(json['Payment_Date']),
       date: json['Payment_Date'] != null 
            ? DateFormat('yyyy-MM-dd').parse(json['Payment_Date'])
            : DateTime.now(),
      paymentNo: json['Payment_No']?.toString()??'',
     // requestNo: json['Request_ID']??'',
     requestNo: json['Request_ID'] is String 
            ? int.tryParse(json['Request_ID']) ?? 0
            : json['Request_ID'] ?? 0,
      requestCode: json['Request_Code']?.toString() ?? '',
      requestType: json['Request_Type']?.toString() ?? '',
      paymentAmount: json['Payment_Amount'] != null
          ? json['Payment_Amount'].toDouble()
          : 0.0,
      
      currency: json['Currency']??'MMK',
      paymentMethod: json['Payment_Method']??'Cash',
      paidPerson: json['Paid_Person']?.toString()??'',
      receivePerson: json['Received_Person']??'',
      paymentNote: json['Payment_Note']?.toString()??'',
      // status: json['Posting_Status']??'',
      // settledStatus: json["Settlement_Status"]??0
      status: json['Posting_Status'] is String
            ? int.tryParse(json['Posting_Status']) ?? 0
            : json['Posting_Status'] ?? 0,
        settledStatus: json['Settlement_Status'] is String
            ? int.tryParse(json['Settlement_Status']) ?? 0
            : json['Settlement_Status'] ?? 0,

     
    );
  }
  

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Payment_Date': DateFormat('yyyy-MM-dd').format(date),
      "Payment_No": paymentNo,
      "Request_ID": requestNo,
      "Request_Code": requestCode,
      "Request_Type": requestType,
      "Payment_Amount": paymentAmount,
      "Currency": currency,
      "Payment_Method": paymentMethod,
      "Paid_Person": paidPerson,
      "Received_Person": receivePerson,
      "Payment_Note": paymentNote,
      "Posting_Status": status,
      "Settlement_Status": settledStatus,
    };
  }
}

//User
class User {
  final String id;
  final String name;
  final String email;
  final List<Department> department;
  final String role;
  final String password;

  const User(
      {required this.id,
      required this.name,
      required this.email,
      required this.department,
      required this.role,
      required this.password});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'department': department.map((dep) => dep.toJson()).toList(),
      'role': role,
      'password': password
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        department: List<Department>.from(
            json['department'].map((dep) => Department.fromJson(dep))),
        role: json['role'],
        password: json['password']);
  }
}

class Department {
  final int id;
  final String departmentCode;
  final String departmentName;

  const Department(
      {required this.id,
      required this.departmentCode,
      required this.departmentName});

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Department_Code': departmentCode,
      'Department_Name': departmentName
    };
  }

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
        //id: json['id'],
        id: json['ID'] is int
            ? json['ID']
            : int.tryParse(json['ID'].toString()) ?? 0,
        departmentCode: json['Department_Code'] ?? '',
        departmentName: json['Department_Name'] ?? '');
  }
}

//for approval
class ApprovalSetup {
  final int id;
  final int departmentId;
  final String departmentName;
  final String FlowName;
  final String RequestType;
  final String Currency;
  final String Description;
  final int No_of_Steps;
  String Management;
  final List<ApprovalStep> ApprovalSteps;

  ApprovalSetup(
      {required this.id,
      required this.FlowName,
      required this.departmentId,
      required this.departmentName,
      required this.RequestType,
      required this.Currency,
      required this.Description,
      required this.No_of_Steps,
      required this.Management,
      required this.ApprovalSteps});

  factory ApprovalSetup.fromJson(Map<String, dynamic> json) {
    final departmentId = json['Department_ID'] ?? 0;
    final departmentName = json['Department_Name'] ?? '';
    return ApprovalSetup(
      id: json['ID'] ?? 0,
      FlowName: json['Flow_Name'] ?? 'Flow Name',
      departmentId: departmentId ?? 0,
      departmentName: departmentName,
      RequestType: json['Flow_Type'],
      Currency: json['Currency'],
      Description: json['Description'] ?? 'Description',
      No_of_Steps: json['No_Of_Steps'] ?? 1,
      Management: json['Management_Approver'] ?? 'No',
      // ApprovalSteps: json ['ApprovalSteps']as List<dynamic>
      ApprovalSteps: (json['ApprovalSteps'] as List<dynamic>)
          .map((step) => ApprovalStep.fromJson(step))
          .toList(),
    );
  }

  ApprovalSetup copyWith({
    int? id,
    int? departmentId,
    String? departmentName,
    String? FlowName,
    String? RequestType,
    String? Currency,
    String? Description,
    int? No_of_Steps,
    String? Management,
    List<ApprovalStep>? ApprovalSteps,
  }) {
    return ApprovalSetup(
      id: id ?? this.id,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      FlowName: FlowName ?? this.FlowName,
      RequestType: RequestType ?? this.RequestType,
      Currency: Currency ?? this.Currency,
      Description: Description ?? this.Description,
      No_of_Steps: No_of_Steps ?? this.No_of_Steps,
      Management: Management ?? this.Management,
      ApprovalSteps: ApprovalSteps ?? this.ApprovalSteps,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Flow_Name': FlowName,
      'Department_ID': departmentId,
      'Department_Name': departmentName,
      'Flow_Type': RequestType,
      'Currency': Currency,
      'Description': Description,
      'No_Of_Steps': No_of_Steps,
      'Management_Approver': Management,
      //'ApprovalSteps':ApprovalSteps.map((step) => step.toFilteredJson()).toList(),
      'ApprovalSteps': ApprovalSteps.map((step) => step.toJson()).toList(),
    };
  }
}

//ApprovalStep
class ApprovalStep {
  final int id;
  final int setupid;
  final int stepNo;
  final String approver;
  final String approverEmail;
  final double maxAmount;

  const ApprovalStep(
      {required this.id,
      required this.setupid,
      required this.stepNo,
      required this.approver,
      required this.approverEmail,
      required this.maxAmount});

  factory ApprovalStep.fromJson(Map<String, dynamic> json) {
    return ApprovalStep(
        id: _parseInt(json['ID']),
        setupid: _parseInt(json['Setup_ID']),
        stepNo: _parseInt(json['Step_No']),
        approver: json['Approvers'] ?? 'Unknown',
        approverEmail: json['Approver_Email'] ?? 'Unknown',
        maxAmount:
            double.tryParse(json['Maximum_Approval_Amount'].toString()) ?? 0.0);
  }
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  ApprovalStep copyWith({
    int? id,
    int? setupid,
    int? stepNo,
    String? approver,
    String? approverEmail,
    double? maxAmount,
  }) {
    return ApprovalStep(
      id: id ?? this.id,
      setupid: setupid ?? this.setupid,
      stepNo: stepNo ?? this.stepNo,
      approver: approver ?? this.approver,
      approverEmail: approverEmail ?? this.approverEmail,
      maxAmount: maxAmount ?? this.maxAmount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Setup_ID': setupid,
      'Step_No': stepNo,
      'Approvers': approver,
      'Approver_Email': approverEmail,
      'Maximum_Approval_Amount': maxAmount
    };
  }
}
// String getApprovers(List<ApprovalStep> approvalStep){
//   return approvalStep.map((step) => step.approver).join(',');
// }

// data.dart
class Budgets {
  final String id;
  final String budgetCode;
  final String budgetDescription;
  final double intialAmount;

  Budgets(
      {required this.id,
      required this.budgetCode,
      required this.budgetDescription,
      required this.intialAmount});

  factory Budgets.fromJson(Map<String, dynamic> json) {
    return Budgets(
        id: json['id'],
        // ? json['id']
        // : int.tryParse(json['id'].toString()) ?? 0,
        budgetCode: json['BudgetCode'],
        budgetDescription: json['BudgetDescription'],
        intialAmount: json['InitialAmount']);
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'BudgetCode': budgetCode,
      'BudgetDescription': budgetDescription,
      'InitialAmount': intialAmount
    };
  }
}

double parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

class Project {
  final String id;
  final DateTime date;
  final String projectCode;
  final DateTime startdate;
  final DateTime enddate;
  final String projectDescription;
  final String requesterName;
  final double totalAmount;
  final String currency;
  final double rate;
  final double homeAmount;
  final double approvedAmount;
  final int departmentId;
  final String departmentName;
  final String requestable;
  final List<Budgets>? budgets;

  Project(
      {required this.id,
      required this.date,
      required this.projectCode,
      required this.startdate,
      required this.enddate,
      required this.projectDescription,
      required this.requesterName,
      required this.totalAmount,
      required this.currency,
      required this.rate,
      required this.homeAmount,
      required this.approvedAmount,
      required this.departmentId,
      required this.departmentName,
      required this.requestable,
      required this.budgets});

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      // is int
      //     ? json['id']
      //     : int.tryParse(json['id'].toString()) ?? 0,
      date: json['Date'] != null
          ? DateFormat('yyyy-MM-dd').parse(json['Date'])
          : DateTime.now(),
      projectCode: json['ProjectCode'],
      startdate: json['StartDate'] != null
          ? DateFormat('yyyy-MM-dd').parse(json['StartDate'])
          : DateTime.now() ,
       enddate: json['EndDate'] != null
          ? DateFormat('yyyy-MM-dd').parse(json['EndDate'])
          : DateTime.now(),
      projectDescription: json['ProjectDescription'],
      requesterName: json['RequesterName'] ?? '',
      totalAmount: json['TotalAmount'],
      currency: json['Currency'],
      rate: parseDouble(json['Rate']),
      homeAmount: parseDouble(json['HomeAmount']),
      approvedAmount: json['ApprovedAmount'],
      departmentId: json['DepartmentID'],
      departmentName: json['DepartmentName'],
      requestable: json['Requestable'],
      budgets: json['BudgetDetails'] != null
          ? (json['BudgetDetails'] as List)
              .map((item) => Budgets.fromJson(item))
              .toList()
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
       'id': id,
      'Date': DateFormat('yyyy-MM-dd').format(date),
      'StartDate': DateFormat('yyyy-MM-dd').format(startdate),
      'EndDate': DateFormat('yyyy-MM-dd').format(enddate),
      'ProjectCode': projectCode,
      'ProjectDescription': projectDescription,
      'RequesterName':requesterName,
      'TotalAmount': totalAmount,
      'Currency': currency,
      'Rate': rate,
      'HomeAmount':homeAmount,
      'ApprovedAmount': approvedAmount,
      'DepartmentID': departmentId,
      'DepartmentName': departmentName,
      'Requestable': requestable,
      'BudgetDetails': budgets?.map((item) => item.toJson()).toList(),
    };
  }
}


class Trips {
  final String id;
  final DateTime date;
  final String tripCode;
  final String tripDescription;
  final String source;
  final String destination;
  final DateTime departureDate;
  final DateTime returnDate;
  final bool otherPerson;
  final bool roundTrip;
  final bool directAdvanceReq;
  final int expenditureOption;
  final String requesterName;
  final double totalAmount;
  final String currency;
  final double approvedAmount;
  final String status;
  final int departmentId;
  final String departmentName;
  final List<Budgets>? budgets;

  Trips(
      {required this.id,
      required this.date,
      required this.tripCode,
      required this.tripDescription,
      required this.source,
      required this.destination,
      required this.departureDate,
      required this.returnDate,
      required this.otherPerson,
      required this.roundTrip,
      required this.directAdvanceReq,
      required this.expenditureOption,
      required this.requesterName,
      required this.totalAmount,
      required this.currency,
      required this.approvedAmount,
      required this.status,
      required this.departmentId,
      required this.departmentName,
      required this.budgets});

  factory Trips.fromJson(Map<String, dynamic> json) {
    return Trips(
      id: json['id'].toString(),
      // ? json['id']
      // : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      date: DateTime.parse(
          json['Date']?.toString() ?? DateTime.now().toIso8601String()),
      tripCode: json['TripCode']?.toString() ?? '',
      tripDescription: json['TripDescription']?.toString() ?? '',
      source: json['Source']?.toString() ?? '',
      destination: json['Destination']?.toString() ?? '',
      departureDate: DateTime.parse(json['DepartureDate']?.toString() ??
          DateTime.now().toIso8601String()),
      returnDate: DateTime.parse(
          json['ReturnDate']?.toString() ?? DateTime.now().toIso8601String()),
      otherPerson: json['OtherPerson'] is bool ? json['OtherPerson'] : false,
      roundTrip: json['RoundTrip'] is bool ? json['RoundTrip'] : false,
      directAdvanceReq:
          json['DirectAdvance'] is bool ? json['DirectAdvance'] : false,
      expenditureOption:
          json['ExpenditureOption'] is int ? json['ExpenditureOption'] : 0,
      requesterName: json['RequesterName']?.toString() ?? '',
      totalAmount: json['TotalAmount'] is double
          ? json['TotalAmount']
          : double.tryParse(json['TotalAmount']?.toString() ?? '0') ?? 0.0,
      currency: json['Currency']?.toString() ?? 'USD',
      approvedAmount: json['ApprovedAmount'] is double
          ? json['ApprovedAmount']
          : double.tryParse(json['ApprovedAmount']?.toString() ?? '0') ?? 0.0,
      status: json['Status']?.toString() ?? 'Active',
      departmentId: json['DepartmentID'] is int ? json['DepartmentID'] : 1,
      departmentName: json['DepartmentName']?.toString() ?? '',
      budgets: json['BudgetDetails'] != null
          ? (json['BudgetDetails'] as List)
              .map((item) => Budgets.fromJson(item))
              .toList()
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Date': date.toIso8601String(),
      'TripCode': tripCode,
      'TripDescription': tripDescription,
      'Source': source,
      'Destination': destination,
      'DepartureDate': departureDate.toIso8601String(),
      'ReturnDate': returnDate.toIso8601String(),
      'OtherPerson': otherPerson,
      'RoundTrip': roundTrip,
      'DirectAdvance': directAdvanceReq,
      'ExpenditureOption': expenditureOption,
      'RequesterName': requesterName,
      'TotalAmount': totalAmount,
      'Currency': currency,
      'ApprovedAmount': approvedAmount,
      'Status': status,
      'DepartmentID': departmentId,
      'DepartmentName': departmentName,
      'BudgetDetails': budgets?.map((item) => item.toJson()).toList(),
    };
  }
}

class Advance {
  final String id;
  final DateTime date;
  final String? requestNo;
  final String? requestCode;
  final String? requestDes;
  final String? requestType;
  final double? requestAmount;
  final String? currency;
  final String? requester;
  // final int departmentID;
  final String? departmentName;
  final double? approvedAmount;
  final String? purpose;
  final String? status;

  Advance({
    required this.id,
    required this.date,
    required this.requestNo,
    required this.requestCode,
    required this.requestDes,
    required this.requestType,
    required this.requestAmount,
    required this.currency,
    required this.requester,
    // required this.departmentID,
    required this.departmentName,
    required this.approvedAmount,
    required this.purpose,
    required this.status,
  });

  factory Advance.fromJson(Map<String, dynamic> json) {
    return Advance(
      id: json['id'],
      // is int
      //     ? json['id']
      //     : int.tryParse(json['id'].toString()) ?? 0,
      date: DateTime.parse(
          json['Date']?.toString() ?? DateTime.now().toIso8601String()),
      requestNo: json['RequestNo'],
      requestCode: json['RequestCode'],
      requestDes: json['RequestDescription'],
      requestType: json['RequestType'],
      requestAmount: json['RequestAmount'],
      currency: json['Currency'],
      requester: json['Requester'],
      // departmentID: json['DepartmentID'],
      departmentName: json['DepartmentName'],
      approvedAmount: json['ApprovedAmount'],
      purpose: json['Purpose'],
      status: json['Status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Date': date.toIso8601String(),
      'RequestNo': requestNo,
      'RequestCode': requestCode,
      'RequestDescription': requestDes,
      'RequestType': requestType,
      'RequestAmount': requestAmount,
      'Currency': currency,
      'Requester': requester,
      'DepartmentName': departmentName,
      'ApprovedAmount': approvedAmount,
      'Purpose': purpose,
      'Status': status,
    };
  }
}

class Payment {
  final String id;
  final DateTime date;
  final String paymentNo;
  final String requestNo;
  final String requestType;
  final double paymentAmount;
  final String currency;
  final String paymentMethod;
  final String paidPerson;
  final String receivedPerson;
  final String paymentNote;
  final String status;
  final String settled;
  

  Payment({
    required this.id,
    required this.date,
    required this.paymentNo,
    required this.requestNo,
    required this.requestType,
    required this.paymentAmount,
    required this.currency,
    required this.paymentMethod,
    required this.paidPerson,
    required this.receivedPerson,
    required this.paymentNote,
    required this.status,
    required this.settled,
  });

  Payment copyWith({
    String? id,
    DateTime? date,
    String? paymentNo,
    String? requestNo,
    String? requestType,
    double? paymentAmount,
    String? currency,
    String? paymentMethod,
    String? paidPerson,
    String? receivedPerson,
    String? paymentNote,
    String? status,
    String?settled
  }) {
    return Payment(
      id: id ?? this.id,
      date: date ?? this.date,
      paymentNo: paymentNo ?? this.paymentNo,
      requestNo: requestNo ?? this.requestNo,
      requestType: requestType ?? this.requestType,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paidPerson: paidPerson ?? this.paidPerson,
      receivedPerson: receivedPerson ?? this.receivedPerson,
      paymentNote: paymentNote ?? this.paymentNote,
      status: status ?? this.status,
      settled: settled?? this.settled
    );
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      //  is int
      //     ? json['id']
      //     : int.tryParse(json['id'].toString()) ?? 0,
      date: DateTime.parse(json['Date']),
      paymentNo: json['PaymentNo'] ?? '',
      requestNo: json['RequestNo'] ?? '',
      requestType: json['RequestType'] ?? '',
      paymentAmount: json['PaymentAmount'] ?? 0,
      currency: json['Currency'] ?? '',
      paymentMethod: json['PaymentMethod'] ?? '',
      paidPerson: json['PaidPerson'] ?? '',
      receivedPerson: json['ReceivedPerson'] ?? '',
      paymentNote: json['PaymentNote'] ?? '',
      status: json['Status'] ?? '',
      settled: json['Settled'] ?? '',
      
    );

    
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Date': date.toIso8601String(),
      'PaymentNo': paymentNo,
      'RequestNo': requestNo,
      'RequestType': requestType,
      'PaymentAmount': paymentAmount,
      'Currency': currency,
      'PaymentMethod': paymentMethod,
      'PaidPerson': paidPerson,
      'ReceivedPerson': receivedPerson,
      'PaymentNote': paymentNote,
      'Status': status,
      'Settled': settled,
      // 'Requests': request?.map((item) => item.toJson()).toList(),
    };
  }
} 

class Settlement {
  final String id;
  final DateTime settlementDate;
  final String paymentNo;
  final DateTime paymentDate;
  final double withdrawnAmount;
  final double settleAmount;
  final double refundAmount;
  final String settled;
  // final int paymentId;
  final List<Payment>? payment;

  Settlement({
    required this.id,
    required this.settlementDate,
    required this.paymentNo,
    required this.paymentDate,
    required this.withdrawnAmount,
    required this.settleAmount,
    required this.refundAmount,
    required this.settled,
    // required this.paymentId,
    this.payment,
  });

  factory Settlement.fromJson(Map<String, dynamic> json) {
    return Settlement(
      id: json['id'],
      // is int
      //     ? json['id']
      //     : int.tryParse(json['id'].toString()) ?? 0,
      settlementDate: DateTime.parse(json['SettlementDate']),
      paymentNo: json['PaymentNo']??'',
      paymentDate: DateTime.parse(json['PaymentDate'])?? DateTime.now(),
      withdrawnAmount: json['WithdrawnAmount']??0,
      settleAmount: json['SettleAmount']??0,
      refundAmount: json['RefundAmount']??0,
      settled: json['Settled'],
      // paymentId: json['PaymentID'],
      payment: json['Payments'] != null
          ? (json['Payments'] is List
              ? (json['Payments'] as List)
                  .map((item) => Payment.fromJson(item))
                  .toList()
              : [Payment.fromJson(json['Payments'])])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'SettlementDate': settlementDate,
      'PaymentNo': paymentNo,
      'PaymentDate': paymentDate,
      'WithdrawnAmount': withdrawnAmount,
      'SettleAmount': settleAmount,
      'RefundAmount': refundAmount,
      'Settled': settled,
      // 'PaymentID': paymentId,
      'Payments': payment?.map((item) => item.toJson()).toList(),
    };
  }
}

class SettlementDetail {
  final int id;
  final String budgetCode;
  final String description;
  final double settledAmount;
  final int settlementId;

  SettlementDetail({
    required this.id,
    required this.budgetCode,
    required this.description,
    required this.settledAmount,
    required this.settlementId,
  });

  factory SettlementDetail.fromJson(Map<String, dynamic> json) {
    return SettlementDetail(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      budgetCode: json['BudgetCode'] ?? '',
      description: json['Description'] ?? '',
      settledAmount: json['SettledAmount'] is double
          ? json['SettledAmount']
          : double.tryParse(json['SettledAmount'].toString()) ?? 0.0,
      settlementId: json['SettlementID'] is int
          ? json['SettlementID']
          : int.tryParse(json['SettlementID'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'BudgetCode': budgetCode,
      'Description': description,
      'SettledAmount': settledAmount,
      'SettlementID': settlementId,
    };
  }
}

class Departments {
  final int id;
  final String departmentCode;
  final String departmentName;

  Departments(
      {required this.id,
      required this.departmentCode,
      required this.departmentName});

  factory Departments.fromJson(Map<String, dynamic> json) {
    return Departments(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      departmentCode: json['DepartmentCode'] ?? '',
      departmentName: json['DepartmentName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'DepartmentCode': departmentCode,
      'DepartmentName': departmentName,
    };
  }
}

class Users {
  final int id;
  final String userName;
  final String userEmail;
  final String role;
  final String password;
  final int departmentID;
  final String departmentName;

  Users(
      {required this.id,
      required this.userName,
      required this.userEmail,
      required this.role,
      required this.password,
      required this.departmentID,
      required this.departmentName});

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      userName: json['UserName'] ?? '',
      userEmail: json['UserEmail'] ?? '',
      role: json['Role'] ?? '',
      password: json['Password'],
      departmentID: json['DepartmentID'],
      departmentName: json['DepartmentName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'UserName': userName,
      'UserEmail': userEmail,
      'Role': role,
      'Password': password,
      'DepartmentID': departmentID,
      'DepartmentName': departmentName
    };
  }
}

// class RequestSetup {
//   final String id;
//   final String departmentID;
//   final String currency;
//   final String flowType;
//   final String description;
//   final int noOfSteps;
//   final int managementApprover;

//   RequestSetup(
//       {required this.id,
//       required this.departmentID,
//       required this.currency,
//       required this.flowType,
//       required this.description,
//       required this.noOfSteps,
//       required this.managementApprover});

//   factory RequestSetup.fromJson(Map<String, dynamic> json) {
//     return RequestSetup(
//       id: json['id'] is int
//           ? json['id']
//           : int.tryParse(json['id'].toString()) ?? 0,
//       departmentID: json['DepartmentID'] ?? '',
//       currency: json['Currency'] ?? '',
//       flowType: json['FlowType'] ?? '',
//       description: json['Description'],
//       noOfSteps: json['NoOfStep'],
//       managementApprover: json['ManagementApprover'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'UserName': departmentID,
//       'UserEmail': currency,
//       'Role': flowType,
//       'Password': description,
//       'DepartmentID': noOfSteps,
//       'DepartmentName': managementApprover
//     };
//   }
// }

class RequestSetup {
  final int id;
  final String flowName;
  final int departmentId;
  final String currency;
  final String flowType;
  final String description;
  final int noOfSteps;
  final bool managementApprover;
  final List<ApprovalStep> approvalSteps;

  RequestSetup({
    required this.id,
    required this.flowName,
    required this.departmentId,
    required this.currency,
    required this.flowType,
    required this.description,
    required this.noOfSteps,
    required this.managementApprover,
    required this.approvalSteps,
  });

  factory RequestSetup.fromJson(Map<String, dynamic> json) {
    return RequestSetup(
      id: json['id'] ?? 0,
      flowName: json['flow_name'] ?? '',
      departmentId: json['department_id'] ?? 0,
      currency: json['currency'] ?? '',
      flowType: json['flow_type'] ?? '',
      description: json['description'] ?? '',
      noOfSteps: json['no_of_steps'] ?? 0,
      managementApprover:json[' managementApprover'] is bool ? json[' managementApprover'] : false,
      approvalSteps: (json['approval_steps'] as List<dynamic>? ?? [])
          .map((e) => ApprovalStep.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'flow_name': flowName,
      'department_id': departmentId,
      'currency': currency,
      'flow_type': flowType,
      'description': description,
      'no_of_steps': noOfSteps,
      'management_approver': managementApprover,
      'approval_steps': approvalSteps.map((e) => e.toJson()).toList(),
    };
  }
}
//RequestSetup
class ApprovalSetupStep {
  final int id;
  final int setupId;
  final int stepNo;
  final double maximumApprovalAmount;
  final String approverEmail;
  final String isAllApprover;
  final DateTime? limitedTime;
  final bool requestStatus;
  final List<UserApproval> userApprovals;

  ApprovalSetupStep({
    required this.id,
    required this.setupId,
    required this.stepNo,
    required this.maximumApprovalAmount,
    required this.approverEmail,
    required this.isAllApprover,
    this.limitedTime,
    required this.requestStatus,
    required this.userApprovals,
  });

  factory ApprovalSetupStep.fromJson(Map<String, dynamic> json) {
    return ApprovalSetupStep(
      id: json['id'] ?? 0,
      setupId: json['setup_id'] ?? 0,
      stepNo: json['step_no'] ?? 0,
      maximumApprovalAmount: (json['maximum_approval_amount'] ?? 0).toDouble(),
      approverEmail: json['approver_email'] ?? '',
      isAllApprover: json['is_all_approver'] ?? 'One approver',
      limitedTime: json['limited_time'] != null
          ? DateTime.tryParse(json['limited_time'])
          : null,
      requestStatus: json['request_status'] ?? false,
      userApprovals: (json['user_approvals'] as List<dynamic>? ?? [])
          .map((e) => UserApproval.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'setup_id': setupId,
      'step_no': stepNo,
      'maximum_approval_amount': maximumApprovalAmount,
      'approver_email': approverEmail,
      'is_all_approver': isAllApprover,
      'limited_time': limitedTime?.toIso8601String(),
      'request_status': requestStatus,
      'user_approvals': userApprovals.map((e) => e.toJson()).toList(),
    };
  }
}

class UserApproval {
  final int id;
  final int userId;
  final int setupStepId;

  UserApproval({
    required this.id,
    required this.userId,
    required this.setupStepId,
  });

  factory UserApproval.fromJson(Map<String, dynamic> json) {
    return UserApproval(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      setupStepId: json['setup_step_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'setup_step_id': setupStepId,
    };
  }
}

class StepData {
  int stepNo;
  List<ApproverData> approvers;
  
  StepData({required this.stepNo, required this.approvers});
}

class ApproverData {
  String? approverEmail;
  String? approverName;
  double maxAmount;
  
  ApproverData({this.approverEmail, this.approverName, required this.maxAmount, });
}