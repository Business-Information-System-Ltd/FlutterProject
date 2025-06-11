// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:math';

import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:advance_budget_request_system/views/data.dart';
// ignore: unused_import
import 'package:advance_budget_request_system/views/project.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
//import 'package:universal_html/html.dart' as html;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EntryForm extends StatefulWidget {
  final Function(Projects) onProjectAdded;

  const EntryForm({Key? key, required this.onProjectAdded}) : super(key: key);
  @override
  State<EntryForm> createState() => _EntryFormState();
}

class _EntryFormState extends State<EntryForm> {
  final _formkey = GlobalKey<FormState>();

  final TextEditingController projectController = TextEditingController();

  final TextEditingController desciptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  int lastProjectNumber = 0;
  List<Budget> chooseBudgetCodes = [];
  List<Budget> budget = [];
  List<Projects> project = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _initializeProjectCode();
  }

  void _fetchData() async {
    try {
      List<Budget> budgetDetails = await ApiService().fetchBudgetCodeData();
      List<Projects> projectDetails = await ApiService().fetchProjectInfoData();
      List<Department> depts = await ApiService().fetchDepartment();

      setState(() {
        budget = budgetDetails;
        project = projectDetails;
        _departments = depts;

        print("BudgetDetails: $budgetDetails.length");
      });
    } catch (e) {
      print("Fail to load project& budget: $e");
    }
  }

  String generateRandomId(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random rnd = Random();
    return List.generate(length, (_) => chars[rnd.nextInt(chars.length)])
        .join();
  }

  void _showBudgetCodeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 20.0, left: 16.0, right: 16.0, bottom: 14.0),
                child: Column(
                  children: [
                    const Text(
                      "Select Budget Code",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.35,
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: SingleChildScrollView(
                          child: DataTable(
                            showCheckboxColumn: false,
                            columns: const [
                              DataColumn(label: Text("")),
                              DataColumn(label: Text("Budget Code")),
                              DataColumn(label: Text("Description")),
                            ],
                            rows: budget.map((budgetCode) {
                              bool isSelected = chooseBudgetCodes.any((code) =>
                                  code.BudgetCode == budgetCode.BudgetCode);

                              return DataRow(
                                cells: [
                                  DataCell(
                                    isSelected
                                        ? IconButton(
                                            icon: const Icon(Icons.check_circle,
                                                color: Colors.green),
                                            onPressed: () {
                                              setState(() {
                                                chooseBudgetCodes.removeWhere(
                                                    (code) =>
                                                        code.BudgetCode ==
                                                        budgetCode.BudgetCode);
                                              });
                                              Navigator.pop(context);
                                              _showBudgetCodeDialog();
                                            },
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                  DataCell(Text(budgetCode.BudgetCode)),
                                  DataCell(Text(budgetCode.Description)),
                                ],
                                onSelectChanged: (selected) {
                                  if (selected != null && selected) {
                                    if (isSelected) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "This budget code is already selected."),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    } else {
                                      setState(() {
                                        chooseBudgetCodes.add(budgetCode);
                                      });
                                      Navigator.pop(context);
                                    }
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.cancel_outlined, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteBudgetCode(int index) {
    setState(() {
      chooseBudgetCodes.removeAt(index);
    });
  }

  String? _selectedDepartmentId;
  String? _selectedDepartmentName;
  //String? selectedBudgetCode;
  String _selectedCurrency = "MMK";
  //String? _selectedRequestable='No';
  List<Department> _departments = [];
  // ignore: unused_field
  final List<String> _currencies = ['MMK', 'USD'];
  //final List<String> _requestable=['Yes','No'];

  void _clearText() {
    setState(() {
      projectController.text = "";
      desciptionController.text = "";
      amountController.text = "";
      _selectedDepartmentName = null;
      _selectedCurrency = 'MMK';
    });
  }

// Future<void> _initializeProjectCode() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   setState(() {
//     lastProjectNumber = prefs.getInt('lastProjectNumber') ?? 0;
//     projectController.text = _generateProjectCode(lastProjectNumber + 1);
//     print('Retrieved lastProjectNumber: $lastProjectNumber');
//   });
// }

// String _generateProjectCode(int number) {
//   return 'PRJ-000-${number.toString().padLeft(3, '0')}';
// }

// Future<void> _saveLastProjectNumber() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   await prefs.setInt('lastProjectNumber', lastProjectNumber);
//   print('Saved lastProjectNumber: $lastProjectNumber');
// }
//  Future<int> generateProjectID() async {
//     List<Projects> existingProjects = await ApiService().fetchProjectInfoData();

//     if (existingProjects.isEmpty) {
//       return 1; // Start from 1 if no project exists
//     }

//     // Find the highest existing ID
//     int maxId =
//         existingProjects.map((b) => b.id).reduce((a, b) => a > b ? a : b);
//     return maxId + 1;
//   }
  Future<String> fetchNextProjectCode() async {
    final response = await http
        .get(Uri.parse('https://backendpyth-fxenfvbhadeddxfn.canadacentral-01.azurewebsites.net/api/projects/next-code/'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['next_project_code'];
    } else {
      throw Exception('Failed to fetch project code');
    }
  }

  void _initializeProjectCode() async {
    try {
      String nextCode = await fetchNextProjectCode();
      setState(() {
        projectController.text = nextCode;
      });
    } catch (error) {
      // Handle error appropriately.
      print('Error fetching project code: $error');
    }
  }

  String _generateProjectCode(int number) {
    return 'PRJ-000-${number.toString().padLeft(3, '0')}';
  }

  final apiService=ApiService();
  Future<int> generateProjectCodeID() async {
    List<Projects> existingProjects = await apiService.fetchProjectInfoData();

    if (existingProjects.isEmpty) {
      return 1; // Start from 1 if no budget exists
    }

    // Find the highest existing ID
    int maxId =
        existingProjects.map((b) => b.id).reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }
 bool _isSubmitting = false;
  Future<void> _submitForm() async {
    if (_isSubmitting) return;
    if (!_formkey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // Validate department selection
      if (_selectedDepartmentId == null || _selectedDepartmentName == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a department")),
        );
        return;
      }
      int nextID= await generateProjectCodeID();

      // Create project object
      Projects newProject = Projects(
        id: nextID,
        date: DateFormat('yyyy-MM-dd').parse(dateController.text),
        Project_Code: projectController.text,
        description: desciptionController.text,
        totalAmount: double.tryParse(amountController.text) ?? 0.0,
        currency: _selectedCurrency,
        approveAmount: 0,
        departmentId: int.parse(_selectedDepartmentId!),
        departmentName: _selectedDepartmentName!,
        requestable: 'Pending',
        budgetDetails: chooseBudgetCodes,
      );

      await ApiService().postProjectInfo(newProject);
      for (var budget in chooseBudgetCodes) {
        await ApiService().postProjectBudget(newProject.id, budget.id);
        _fetchData();
         ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text( "Project created successfully!"
              ),
        ),

      );
      }
       Navigator.pop(context, true);

      // Call Logic Apps
      await _callLogicApps(newProject);

      // Show success message
     

      // Clear form and generate new project code
      _clearText();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create project: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }


  Future<void> _callLogicApps(Projects newProject) async {
    final logicAppsUrl =
        'https://prod-74.southeastasia.logic.azure.com:443/workflows/f4cc43a2d7664ecba3243fb9c644c7b0/triggers/When_a_HTTP_request_is_received/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2FWhen_a_HTTP_request_is_received%2Frun&sv=1.0&sig=Pim3bdr0sloQaINg0bnlCAkq4aI3hHGzxZ41yaSwRGc';
    final Map<String, dynamic> logicAppsData = {
      "Date": DateFormat('yyyy-MM-dd').format(newProject.date),
      "Project_Code": newProject.Project_Code,
      "Description": newProject.description,
      "Total Budget Amount": newProject.totalAmount,
      "Currency": newProject.currency,
      "Approved Amount": newProject.approveAmount,
      "Department": newProject.departmentName,
      "Requestable": newProject.requestable,
      "BudgetDetails": newProject.budgetDetails
          .map((budget) => {
                "Budget Code": budget.BudgetCode,
                "Description": budget.Description,
              })
          .toList(),
    };

    final response = await http.post(
      Uri.parse(
          'https://prod-74.southeastasia.logic.azure.com:443/workflows/f4cc43a2d7664ecba3243fb9c644c7b0/triggers/When_a_HTTP_request_is_received/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2FWhen_a_HTTP_request_is_received%2Frun&sv=1.0&sig=Pim3bdr0sloQaINg0bnlCAkq4aI3hHGzxZ41yaSwRGc'),

      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(logicAppsData),
    );

    if (response.statusCode == 200 || response.statusCode == 202) {
      print('Logic Apps request successful');
    } else {
      throw Exception(
          'Failed to send data to Logic Apps. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Project Request Form")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 103, 207, 177),
                  borderRadius: BorderRadius.circular(15), // Rounded corners
                ),
                child: Form(
                    key: _formkey,
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              'Add Project Request',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  ListTile(
                                    title: TextFormField(
                                      controller: projectController,
                                      readOnly: true,
                                      decoration: const InputDecoration(
                                          labelText: "Enter Project Code"),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Enter Project Code";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  ListTile(
                                    title: TextFormField(
                                      controller: desciptionController,
                                      decoration: const InputDecoration(
                                          labelText:
                                              "Enter Project Description"),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Enter Project Description";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  ListTile(
                                    title: TextFormField(
                                      controller: amountController,
                                      decoration: const InputDecoration(
                                        labelText: "Enter Total Amount",
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d*\.?\d*')),
                                      ],
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Enter Total Amount";
                                        }
                                        final amount = double.tryParse(value);
                                        if (amount == null) {
                                          return "Enter a valid amount";
                                        }
                                        if (amount <= 0) {
                                          return "Your Request Amount must be greater than 0";
                                        }

                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  ListTile(
                                    title: TextFormField(
                                      controller: dateController,
                                      decoration: const InputDecoration(
                                          labelText: "Request Date"),
                                      readOnly: true,
                                    ),
                                  ),
                                  ListTile(
                                    title: DropdownButtonFormField<String>(
                                      value: _selectedDepartmentName,
                                      decoration: const InputDecoration(
                                          labelText: "Department"),
                                      items: _departments.map((dept) {
                                        return DropdownMenuItem<String>(
                                          value: dept.departmentName,
                                          child: Text(dept.departmentName),
                                          onTap: () {
                                            _selectedDepartmentId =
                                                dept.id.toString(); // Store ID
                                          },
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedDepartmentName = value;
                                        });
                                      },
                                      validator: (value) => value == null
                                          ? "Select department"
                                          : null,
                                    ),
                                  ),
                                  ListTile(
                                    title: DropdownButtonFormField(
                                      decoration: const InputDecoration(),
                                      value: _selectedCurrency,
                                      items: ['MMK', 'USD'].map((currency) {
                                        return DropdownMenuItem(
                                            value: currency,
                                            child: Text(currency));
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedCurrency = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              ElevatedButton(
                                onPressed: _showBudgetCodeDialog,
                                style: ElevatedButton.styleFrom(
                                  textStyle: const TextStyle(fontSize: 15),
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text("Add Budget Code"),
                              ),
                              const SizedBox(height: 10),
                              // Container(
                              //   height: MediaQuery.of(context).size.height * 0.3,
                              //   child: SingleChildScrollView(
                              //     scrollDirection: Axis.vertical,
                              //     child: DataTable(
                              //       border: TableBorder.all(),
                              //       showCheckboxColumn: false,
                              //       columns: const [
                              //         DataColumn(label: Text("Budget Code")),
                              //         DataColumn(label: Text("Description")),
                              //         DataColumn(label: Text("Action")),
                              //       ],
                              //       rows: chooseBudgetCodes.map((budgetCode) {
                              //         final index =
                              //             chooseBudgetCodes.indexOf(budgetCode);
                              //         return DataRow(
                              //           cells: [
                              //             DataCell(
                              //                 Text(budgetCode.BudgetCode)),
                              //             DataCell(
                              //                 Text(budgetCode.Description)),
                              //             DataCell(
                              //               IconButton(
                              //                 onPressed: () {
                              //                   _deleteBudgetCode(index);
                              //                 },
                              //                 icon: const Icon(Icons.delete),
                              //               ),
                              //             ),
                              //           ],
                              //         );
                              //       }).toList(),
                              //     ),
                              //   ),
                              // ),
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: DataTable(
                                    border: TableBorder.all(),
                                    showCheckboxColumn: false,
                                    columns: const [
                                      DataColumn(label: Text("Budget Code")),
                                      DataColumn(label: Text("Description")),
                                      DataColumn(label: Text("Action")),
                                    ],
                                    rows: chooseBudgetCodes.map((budgetCode) {
                                      final index =
                                          chooseBudgetCodes.indexOf(budgetCode);
                                      return DataRow(
                                        cells: [
                                          DataCell(Text(budgetCode.BudgetCode)),
                                          DataCell(
                                              Text(budgetCode.Description)),
                                          DataCell(
                                            IconButton(
                                              onPressed: () {
                                                _deleteBudgetCode(index);
                                              },
                                              icon: const Icon(Icons.delete),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _submitForm();
                              },
                              style: ElevatedButton.styleFrom(
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                ),
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text("Submit"),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _clearText();
                              },
                              style: ElevatedButton.styleFrom(
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                ),
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text("Clear"),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ))),
          ),
        ),
      ),
    );
  }
}
