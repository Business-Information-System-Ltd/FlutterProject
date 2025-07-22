import 'dart:convert';
import 'package:advance_budget_request_system/views/data.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String url = "http://127.0.0.1:8000/api/budget/";
  static const String baseUrl = 'http://localhost:3000';
  static String projectEndPoint = "http://127.0.0.1:8000/api/project/";
  final String projectBudgetEndPoint =
      "http://127.0.0.1:8000/api/projectbudget/";
  final String tripEndPoint = "http://127.0.0.1:8000/api/trip/";
  final String tripBudgetEndPoint = "http://127.0.0.1:8000/api/tripbudget/";
  final String TripCodeAutoIncrementEndPoint =
      "http://127.0.0.1:8000/api/trips/next-code/";
  final String operationEndPoint = "http://127.0.0.1:8000/api/operation/";
  final String operationBudgetEndPoint =
      "http://127.0.0.1:8000/api/operationbudget/";
  final String operationCodeAutoIncrementEndPoint =
      "http://127.0.0.1:8000/api/operations/next-code/";
  final String advanceRequestEndPoint =
      "http://127.0.0.1:8000/api/advancerequest/";
  final String advanceCodeAutoIncrementEndPoint =
      "http://127.0.0.1:8000/api/requests/next-code/";
  final String cashPaymentEndPoint = "http://127.0.0.1:8000/api/cashpayment/";
  final String cashPaymentAutoIncrementEndPoint =
      "http://127.0.0.1:8000/api/requests/next-code/";
  final String settlementEndPoint = "http://127.0.0.1:8000/api/settlement/";
  final String settlementDetailEndPoint =
      "http://127.0.0.1:8000/api/settlementdetail/";
  final String userLoginEndPoint = "http://127.0.0.1:8000/api/user/";
  final String departmentEndPoint = "http://127.0.0.1:8000/api/department/";
  static String approvalsetupEndPoint =
      "http://127.0.0.1:8000/api/requestsetup/";
  static String approvalstepEndPoint =
      "http://127.0.0.1:8000/api/approversetupstep/";

  Future<List<Budget>> fetchBudgetCodeData() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Budget.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<bool> postBudgetCode(Budget newbudgetCode) async {
    //  print("API Call: ${jsonEncode(newbudgetCode .toJson())}");
    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(newbudgetCode.toJson()));
    //print("Response Status Code: ${response.statusCode}");
    // print("Response Body: ${response.body}");
    if (response.statusCode != 201) {
      throw Exception('Failed to insert budget code');
    } else {
      return true;
    }
  }

  Future<bool> updateBudget(Budget budget) async {
    final response = await http.put(
      Uri.parse('$url${budget.id}/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: json.encode(budget.toJson()),
    );

    // Debug: Check the full URL
    // print("Final API URL: ${'$baseUrl$budgetCodeEndpoint/${budget.id}'}");
    // print("Response Status Code: ${response.statusCode}");
    // print("Response Body: ${response.body}");
    if (response.statusCode != 200) {
      throw Exception('Failed to update budget');
    } else {
      return true;
    }
  }

  Future<void> deleteBudget(int id) async {
    final response = await http.delete(Uri.parse('$url$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete BudgetCode');
    }
  }

  //project
  Future<List<Projects>> fetchProjectInfoData() async {
    final response = await http.get(Uri.parse(projectEndPoint));
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      print("Project Data: $body");
      return body.map((dynamic item) => Projects.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load projects');
    }
  }

  Future<void> postProjectInfo(Projects newProject) async {
    final response = await http.post(Uri.parse(projectEndPoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(newProject.toJson()));

    if (response.statusCode != 201) {
      throw Exception('Failed to insert project');
    }
  }

  Future<void> postProjectBudget(int projectId, int budgetId) async {
    try {
      final response = await http.post(
        Uri.parse(projectBudgetEndPoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Project_ID': projectId, 'Budget_ID': budgetId}),
      );

      if (response.statusCode == 201) {
        return;
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        if (error['non_field_errors'] != null &&
            error['non_field_errors'].contains('unique set')) {
          // Relationship already exists - treat as success
          return;
        }
        throw Exception('Validation error: ${response.body}');
      } else {
        throw Exception('Failed to create projectbudget: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> updateProjectInfo(Projects updatedProject) async {
    final jsonData = updatedProject.toJson();
    print("Sending updated JSON data: $jsonData");

    final response = await http.put(
      Uri.parse('$projectEndPoint${updatedProject.id}/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(jsonData), // Send the JSON data
    );

    print("API Response Status: ${response.statusCode}");
    print("API Response Body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception('Failed to update project: ${response.body}');
    }
  }

  Future<http.Response> updateProjectBudget(Projects project, int id) async {
    final response = await http.post(
      Uri.parse('$projectEndPoint$id/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(project.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update project');
    }
    return response;
  }

  Future<void> deleteProject(int id) async {
    final response = await http.delete(Uri.parse('$projectEndPoint$id/'));
    print(response.statusCode);
    print("responsebody${response.body}");
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete ProjectCode');
    }
  }

// trip
  Future<List<Trip>> fetchTripinfoData() async {
    final response = await http.get(Uri.parse(tripEndPoint));
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      print("Status Code: $response.statusCode");
      print("Trip Data:$body");
      return body.map((dynamic item) => Trip.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load Trips');
    }
  }

  Future<String> fetchNextTripCode() async {
    final response = await http.get(Uri.parse(TripCodeAutoIncrementEndPoint));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['next_trip_code'] as String;
    } else {
      throw Exception('Failed to fetch trip code');
    }
  }

  Future<void> postTripInfo(Trip newTrip) async {
    final jsonData = newTrip.toJson();
    print("Sending JSON data: $jsonData");
    final response = await http.post(Uri.parse(tripEndPoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(jsonData));
    print("API Response Status: ${response.statusCode}");
    print("API Response Body: ${response.body}");
    if (response.statusCode != 201) {
      throw Exception('Failed to insert trip');
    }
  }

  Future<void> postTripBudget(int tripId, int budgetId) async {
    final response = await http.post(
      Uri.parse(tripBudgetEndPoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'Trip_ID': tripId, 'Budget_ID': budgetId}),
    );

    if (response.statusCode == 201) {
      return;
    } else if (response.statusCode == 400) {
      final error = jsonDecode(response.body);
      if (error['non_field_errors'] != null &&
          error['non_field_errors'].contains('unique set')) {
        return;
      }
      throw Exception('Validation error: ${response.body}');
    } else {
      throw Exception('Failed to create tripbudget: ${response.body}');
    }
  }

  // Update a trip
  Future<void> updateTripInfo(Trip updatedTrip) async {
    final jsonData = updatedTrip.toJson(); // Convert Trip object to JSON
    print("Sending updated JSON data: $jsonData"); // Debug: Print the JSON data

    final response = await http.put(
      Uri.parse('$tripEndPoint${updatedTrip.id}/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(jsonData), // Send the JSON data
    );

    print("API Response Status: ${response.statusCode}");
    print("API Response Body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception('Failed to update trip: ${response.body}');
    }
  }

  //delete trip
  Future<void> deleteTrip(String tripID) async {
    // Ensure there is no space between baseUrl and tripEndPoint
    final response = await http.delete(Uri.parse('$tripEndPoint$tripID/'));

    // Check if the request was successful
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
          'Failed to delete trip. Status code: ${response.statusCode}');
    }
  }

  //operation
  Future<List<Operation>> fetchOperationData() async {
    final response = await http.get(Uri.parse(operationEndPoint));
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      print("Operation Data: $body");
      return body.map((dynamic item) => Operation.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load operation');
    }
  }

  Future<void> postOperation(Operation newOperation) async {
    final response =
        await http.post(Uri.parse(operationCodeAutoIncrementEndPoint),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(newOperation.toJson()));
    print(response.statusCode);
    print(response.body);
    if (response.statusCode != 201) {
      throw Exception('Failed to insert operation');
    }
  }

  Future<String> fetchNextOperationCode() async {
    final response = await http.get(Uri.parse(operationBudgetEndPoint));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['next_operation_code'] as String;
    } else {
      throw Exception('Failed to fetch operation code');
    }
  }

// advance request
  Future<List<AdvanceRequest>> fetchAdvanceRequestData() async {
    final response = await http.get(Uri.parse(advanceRequestEndPoint));
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => AdvanceRequest.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load Advance Requests');
    }
  }

  Future<void> postAdvanceRequest(AdvanceRequest newAdvance) async {
    print("Posting advance request: ${newAdvance.toJson()}");
    final response = await http.post(Uri.parse(advanceRequestEndPoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(newAdvance.toJson()));
    print(response.statusCode);
    print(response.body);
    if (response.statusCode != 201) {
      throw Exception(
          'Failed to insert Advance Request ${response.statusCode} + ${response.body}');

      // print('Request can create successfully!');
    }
  }

  Future<String> fetchNextAdvanceCode() async {
    final response =
        await http.get(Uri.parse(advanceCodeAutoIncrementEndPoint));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['next_request_code'] as String;
    } else {
      throw Exception('Failed to fetch advance code');
    }
  }

  // Cash Payment
  Future<List<CashPayment>> fetchCashPaymentData() async {
    final response = await http.get(Uri.parse(cashPaymentEndPoint));
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      print(response.body);
      return body.map((dynamic item) => CashPayment.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load Cash Payment');
    }
  }

  Future<String> fetchNextPaymentCode() async {
    final response =
        await http.get(Uri.parse(cashPaymentAutoIncrementEndPoint));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['next_payment_code'] as String;
    } else {
      throw Exception('Failed to fetch payment code');
    }
  }

  Future<void> postCashPayment(CashPayment newPayment) async {
    final response = await http.post(Uri.parse(cashPaymentEndPoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(newPayment.toJson()));
    print(response.statusCode);
    print(response.body);
    if (response.statusCode != 201) {
      throw Exception('Failed to insert Cash Payment');
      // print('Request can create successfully!');
    }
  }

  Future<bool> updateCashPayment(CashPayment cashpayment) async {
    final response = await http.put(
      Uri.parse('$cashPaymentEndPoint${cashpayment.id}/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: json.encode(cashpayment.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to update cashpayment ${response.statusCode} + ${response.body}');
    } else {
      return true;
    }
  }

  //User
  Future<List<User>> fetchUser() async {
    final response = await http.get(Uri.parse(userLoginEndPoint));
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      print(response.body);
      return body.map((dynamic item) => User.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load User');
    }
  }

  Future<void> postUser(User newuser) async {
    final response = await http.post(Uri.parse(userLoginEndPoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newuser.toJson()));
    if (response.statusCode != 201) {
      throw Exception("Fail to add UserLogin");
    }
  }

  Future<void> registerUser(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/user/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'UserName': userData['username'],
        'User_Email': userData['email'],
        'Password': userData['password'],
        'Role': userData['role'],
        'Department_ID': userData['departmentId'],
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print('Registration success: ${data['message']}');
    } else {
      final error = jsonDecode(response.body);
      print('Registration failed: ${error['message']}');
    }
  }

  Future<Map<String, dynamic>?> loginUser(
      String email, String password, String departmentId) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'User_Email': email,
        'Password': password,
        'Department_ID': departmentId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      final error = jsonDecode(response.body);
      print('Login failed: ${error['message']}');
      return null;
    }
  }

  //Department
  Future<List<Department>> fetchDepartment() async {
    final response = await http.get(Uri.parse(departmentEndPoint));
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      print(response.body);
      return body.map((dynamic item) => Department.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load Department');
    }
  }

  //fetch approval steps from the server
  Future<List<ApprovalStep>> fetchApprovalSteps() async {
    final response = await http.get(Uri.parse(approvalstepEndPoint));

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((json) => ApprovalStep.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load approval steps ${response.statusCode} + ${response.body}');
    }
  }

  //Insert new approval step
  static Future<void> postApprovalStep(ApprovalStep step) async {
    final response = await http.post(Uri.parse(approvalstepEndPoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(step.toJson()));
    print(" Step statuscode : ${response.statusCode} + ${response.body}");
    if (response.statusCode != 201) {
      throw Exception(
          'Failed to insert approval step ${response.statusCode} + ${response.body}');
    }
  }

  //Update an existing approval step
  static Future<void> updateApprovalStep(ApprovalStep step) async {
    final response = await http.put(
        Uri.parse('$approvalstepEndPoint/${step.id}/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(step.toJson()));
    print(" Stepupdate statuscode : ${response.statusCode} + ${response.body}");
    if (response.statusCode != 200) {
      throw Exception('Failed to update approval step');
    }
  }

  Future<void> deleteApprovalStep(int id) async {
    final response = await http.delete(Uri.parse('$approvalstepEndPoint$id/'));
    print(response.statusCode);
    print("responsebody${response.body}");
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to delete approval step ${response.statusCode} + ${response.body}');
    }
  }

  //fetch approvalsetup from server
  Future<List<ApprovalSetup>> fetchApprovalSetup() async {
    final response = await http.get(Uri.parse(approvalsetupEndPoint));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => ApprovalSetup.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load ApprovalSetup ${response.statusCode} + ${response.body}');
    }
  }

  static Future<ApprovalSetup> postApprovalSetup(ApprovalSetup newSetup) async {
    final response = await http.post(
      Uri.parse(approvalsetupEndPoint),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newSetup.toJson()),
    );

    if (response.statusCode == 201) {
      return ApprovalSetup.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create setup: ${response.body}');
    }
  }

  static Future<void> updateApprovalSetup(ApprovalSetup updatesetup) async {
    final response = await http.put(
        Uri.parse('$approvalsetupEndPoint${updatesetup.id}/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatesetup.toJson()));
    if (response.statusCode != 200) {
      throw Exception(
          "Failed to update Approval Setup ${response.statusCode} + ${response.body}");
    }
  }

  Future<void> deleteApprovalSetup(int id) async {
    final response = await http.delete(Uri.parse('$approvalsetupEndPoint$id/'));
    print(response.statusCode);
    print("responsebody${response.body}");
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
          'Failed to delete approval setup ${response.statusCode}  ${response.body}');
    }
  }




  //testing
  //budget
  //Budgets
  Future<List<Budgets>> fetchBudgets() async {
    final response = await http.get(Uri.parse('$baseUrl/budgets'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((e) => Budgets.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load budgets');
    }
  }

  Future<void> postBudgets(Budgets budget) async {
    final response=await http.post(
      Uri.parse('$baseUrl/budgets'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(budget.toJson()),
    );
    print(response.statusCode);
    print(response.body);
    if (response.statusCode!=201) {
      throw Exception('Fail to insert budget');
    }
  }

   Future<bool> updateBudgets(Budgets budget) async {
  final response = await http.put(
    Uri.parse('$baseUrl/budgets/${budget.id}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: json.encode(budget.toJson()),
  );

  print("Response Status Code: ${response.statusCode}");
  print("Response Body: ${response.body}");

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception('Failed to update budget: ${response.statusCode} - ${response.body}');
  }
}



  Future<void> deleteBudgets(String budgetId) async {
    final response = await http.delete(Uri.parse('$baseUrl/budgets/$budgetId'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
          'Failed to delete budget. Status code: ${response.statusCode}- ${response.body}');
    }
  }


  //Projects
  Future<List<Project>> fetchProjects() async {
    final response = await http.get(Uri.parse('$baseUrl/projects'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((e) => Project.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load projects');
    }
  }

  Future<void> postProjects(Project project) async {
    final response = await http.post(
      Uri.parse('$baseUrl/projects'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(project.toJson()),
    );
    print(response.statusCode);
    print(response.body);
    if (response.statusCode != 201) {
      throw Exception('Fail to insert Project');
    }
  }

  //updateProject

  Future<void> updateProject(Project updatedProject) async {
    final jsonData = updatedProject.toJson();
    print("Sending updated JSON data: $jsonData");

    final response = await http.put(
      Uri.parse('$baseUrl/projects/${updatedProject.id}/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(jsonData), // Send the JSON data
    );

    print("API Response Status: ${response.statusCode}");
    print("API Response Body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception('Failed to update project: ${response.body}');
    }
  }

  


//  GetProjectByID
  Future<List<Project>> getProjectById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/projects/$id'));
    return jsonDecode(response.body);
    
  }
 


 Future<void> deleteProjects(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/projects/$id'),
       headers: {'Content-Type': 'application/json'},
      );

    if (response.statusCode != 200 && response.statusCode!=204) {
      throw Exception('Failed to delete budget:${response.body}');
    }
  }



  //Trips

  Future<List<Trips>> fetchTrips() async {
    final response = await http.get(Uri.parse('$baseUrl/trips'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((e) => Trips.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load trips');
    }
  }


  Future<void> postTrips(Trips trips) async {
final response= await http.post( Uri.parse('$baseUrl/trips'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(trips.toJson()),
    );
     print(response.statusCode);
    print(response.body);
    if(response.statusCode!=201){
      throw Exception('Fail to insert Trip');
    }

  }


  //updateTrip
   Future<void> updateTrip(Trips trip) async {
    try {
      // First verify the trip exists
      final existingTrip = await getTripById(trip.id);
      if (existingTrip == null) {
        throw Exception('Trip with ID ${trip.id} does not exist');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/trips/${trip.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(trip.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to update trip ${trip.id}: ${response.statusCode}\n${response.body}'
        );
      }
    } catch (e) {
      print('Error updating trip ${trip.id}: $e');
      rethrow;
    }
  }

  // Future<List<Trip>> updateTrip(
  //     int id, Map<String, dynamic> updatedData) async {
  //   final response = await http.put(
  //     Uri.parse('$baseUrl/trips/$id'),
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode(updatedData),
  //   );

  //   if (response.statusCode == 200) {
  //     print('Trip updated successfully');
  //     return jsonDecode(response.body); // Return the full response
  //   } else {
  //     throw Exception('Failed to update trips: ${response.statusCode}');
  //   }
  // }


  //GetTripByID
  // Future<List<Trips>> getTripById(int id) async {
  //   final response = await http.get(Uri.parse('$baseUrl/trips/$id'));
  //   return jsonDecode(response.body);
  // }
  Future<Trips?> getTripById(String id) async {
  final response = await http.get(Uri.parse('$baseUrl/trips/$id'));
  if (response.statusCode == 200) {
    return Trips.fromJson(json.decode(response.body));
  }
  return null;
}


 Future<void> deleteTrips(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/trips/$id'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
          'Failed to delete trip. Status code: ${response.statusCode}');
    }
  }




  // Advance Requests
  Future<List<Advance>> fetchAdvanceRequests() async {
    final response = await http.get(Uri.parse('$baseUrl/advanceRequests'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((e) => Advance.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load Advance Requests');
    }
  }

  Future<void> postAdvanceRequests(AdvanceRequest request) async {
    await http.post(
      Uri.parse('$baseUrl/advanceRequests'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );
  }

Future<List<AdvanceRequest>> fetchAdvanceRequest() async {
  final response = await http.get(Uri.parse('$baseUrl/advanceRequests'));

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return data.map((e) => AdvanceRequest.fromJson(e)).toList();
  } else {
    throw Exception('Failed to load Advance Requests');
  }
}





//AdvanceRequested
 Future<bool> postAdvanceRequested(AdvanceRequested request) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/advanceRequested'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      print('Failed with status: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Error posting advance request: $e');
    return false;
  }
}



  // Payments
  Future<List<Payment>> fetchPayments() async {
    final response = await http.get(Uri.parse('$baseUrl/payments'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((e) => Payment.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load Payments');
    }
  }

  Future<void> postPayments(Payment newPayment) async {
    final response = await http.post(Uri.parse('$baseUrl/payments'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(newPayment.toJson()));
    print(response.statusCode);
    print(response.body);
    if (response.statusCode != 201) {
      throw Exception('Failed to insert Cash Payment');
    }
  }

  //updatePayment
  Future<List<Payment>> updatePayment(
      int id, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/payments/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 200) {
      print('Payment updated successfully');
      return jsonDecode(response.body); // Return the full response
    } else {
      throw Exception('Failed to update payment: ${response.statusCode}');
    }
  }

  //GetPaymentByID
  Future<List<Payment>> getPaymentById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/payments/$id'));
    return jsonDecode(response.body);
  }

  // Settlements
  Future<List<Settlement>> fetchSettlements() async {
    final response = await http.get(Uri.parse('$baseUrl/settlements'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((e) => Settlement.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load Settlements');
    }
  }

  Future<void> postSettlement(Settlement settlement) async {
    await http.post(
      Uri.parse('$baseUrl/settlements'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(settlement.toJson()),
    );
  }

  //getSettlementbyID
  Future<List<Settlement>> getSettlementById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/settlements/$id'));
    return jsonDecode(response.body);
  }

  //paginatedDataForPayment
  Future<List<Payment>> getPaginatedPayments(int page, int limit) async {
    final response = await http
        .get(Uri.parse('$baseUrl/payments?_page=$page&_limit=$limit'));

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Payment.fromJson(item)).toList();
    } else {
      throw Exception(
          'Failed to load paginated payments: ${response.statusCode}');
    }
  }

  //paginatedDataForSettlement
  Future<List<Settlement>> getPaginatedSettlements(int page, int limit) async {
    final response = await http
        .get(Uri.parse('$baseUrl/settlements?_page=$page&_limit=$limit'));

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Settlement.fromJson(item)).toList();
    } else {
      throw Exception(
          'Failed to load paginated settlements: ${response.statusCode}');
    }
  }
}

 
 
