import 'dart:convert';
import 'dart:math';
import 'package:advance_budget_request_system/views/advanceRequest.dart';
import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:advance_budget_request_system/views/data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class AdvanceRequestEntry extends StatefulWidget {
  final Function(AdvanceRequest) onRequestAdded;
  final String username;
  const AdvanceRequestEntry({Key? key, required this.onRequestAdded, required this.username})
      : super(key: key);

  @override
  State<AdvanceRequestEntry> createState() => _AdvanceRequestEntryState();
}

class _AdvanceRequestEntryState extends State<AdvanceRequestEntry> {
  final _formkey = GlobalKey<FormState>();

  bool multiselect = false;

  late final TextEditingController _reqNoController=TextEditingController();
  final TextEditingController _requester = TextEditingController();
  final TextEditingController _dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  final TextEditingController _totalAmtController = TextEditingController();
  final TextEditingController _reqPurposeController = TextEditingController();
  final TextEditingController _reqCodeController = TextEditingController();
  final TextEditingController _reqDescriptionController =
      TextEditingController();

  String _selectedCurrency = "MMK";
  String? selectedType;
  int _nextId = 1;
  int operationCounter = 1;
  String _selectedDepartmentName='';

  List<Budget> selectedBudgetCodes = [];
  List<Budget> selectedProjectBudgets = [];
  List<Budget> selectedTripBudgets = [];

  List<AdvanceRequest> advanceRequest = [];
  List<Projects> project = [];
  List<Trip> trip = [];
  List<Budget> budget = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _initializeTripCode();
    _initializeOperationCode();
    _requester.text=widget.username;
  }

  final ApiService apiService = ApiService();

  Future<int> generateBudgetCodeID() async {  
    List<AdvanceRequest> existingAvance = await apiService.fetchAdvanceRequestData();

    if (existingAvance.isEmpty) {
      return 1; // Start from 1 if no budget exists
    }

    // Find the highest existing ID
  //   int maxId = existingAvance.map((b) => b.id).reduce((a, b) => a > b ? a : b);
  //  return maxId + 1;
   // Convert String ids to int and find the max
  int maxId = existingAvance
      .map((b) => int.tryParse(b.id.toString()) ?? 0)
      .reduce((a, b) => a > b ? a : b);

  return maxId + 1;
  }

  //fetch Data
  void _fetchData() async {
    try {
      List<AdvanceRequest> advanceRequests =
          await ApiService().fetchAdvanceRequestData();
      List<Projects> projects = await ApiService().fetchProjectInfoData();
      List<Trip> trips = await ApiService().fetchTripinfoData();
      List<Budget> budgets = await ApiService().fetchBudgetCodeData();
      setState(() {
        advanceRequest = advanceRequests;
        project = projects;
        trip = trips;
        budget = budgets;
        print("Projects: $project");
        print("Trips: $trips");
       
      });
    } catch (e) {
      print("Fail to load $e");
    }
  }

  //Budget Code table
  void _showBudgetCodeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 20.0, left: 16.0, right: 16.0, bottom: 16.0),
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
                              bool isSelected = selectedBudgetCodes.any(
                                  (code) =>
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
                                                selectedBudgetCodes.removeWhere(
                                                    (code) =>
                                                        code.BudgetCode ==
                                                        code.Description);
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
                                        selectedBudgetCodes.add(budgetCode);
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
    if (selectedBudgetCodes.isNotEmpty &&
        index >= 0 &&
        index < selectedBudgetCodes.length) {
      setState(() {
        selectedBudgetCodes.removeAt(index);
      });
    } else {
      print('Cannot delete: Index $index is out of bounds or list is empty.');
    }
  }

  //clear text
  void _clearText() {
    setState(() {
      selectedType = null;
      _reqCodeController.text = '';
      _reqDescriptionController.text = '';
      _totalAmtController.text = '';
      _selectedCurrency = 'MMK';
      _reqPurposeController.text = '';
      selectedBudgetCodes = [];
    });
  }


  void _initializeTripCode() async {
    try {
      String nextCode = await apiService.fetchNextAdvanceCode();
      setState(() {
        _reqNoController.text = nextCode;
      });
    } catch (error) {
      // Handle error appropriately.
      print('Error fetching advance code: $error');
    }
  }

  void _initializeOperationCode() async {
    try {
      String nextCode = await apiService.fetchNextOperationCode();
      setState(() {
        _reqCodeController.text = nextCode;
      });
    } catch (error) {
      // Handle error appropriately.
      print('Error fetching operation code: $error');
    }
  }

  //submit button

  bool _isSubmitting = false;
  void _submitForm() async {
    if (_formkey.currentState!.validate() && !_isSubmitting) {
      setState(() {
        _isSubmitting = true;
      });
      List<Budget> budgetDetails = [];
      int? relatedId; 
      
      int tripId = 0;
      int projectId = 0;
      int operationId=0;
      String requestCode = ''; 
      String departmentName='';
       int newId = await generateBudgetCodeID();
      if (selectedType == "Project") {
        Projects selectedProject = project.firstWhere(
          (project) => project.Project_Code == _reqCodeController.text,
        );
        departmentName = selectedProject.departmentName;
        projectId = selectedProject.id;
        relatedId = selectedProject.id;
        requestCode = selectedProject.Project_Code;
        budgetDetails = selectedProject.budgetDetails;
      } else if (selectedType == "Trip") {
        Trip selectedTrip = trip.firstWhere(
          (trip) => trip.Trip_Code == _reqCodeController.text,
        );
        departmentName = selectedTrip.departmentName;
        relatedId = selectedTrip.id;
        tripId = selectedTrip.id;
        requestCode = selectedTrip.Trip_Code;
        budgetDetails = selectedTrip.budgetDetails;
      } else if (selectedType == "Operation") {
        budgetDetails = selectedBudgetCodes;
        departmentName = _selectedDepartmentName;
        operationId=0;
        relatedId = 0;
        // String operationCode= await apiService.fetchNextOperationCode();
        // requestCode = operationCode;
        //   setState(() {
        //     _reqCodeController.text = operationCode;
        //   });
      }
      
      AdvanceRequest newAdvance = AdvanceRequest(
          id: newId.toString(),
          date: DateTime.now(),
          requestNo: _reqNoController.text,
          requestCode: requestCode, 
           requestDate: _dateController.text,
          requestType: selectedType!, 
          requestAmount: double.tryParse(_totalAmtController.text) ?? 0.0,
          currency: _selectedCurrency,
          requester: _requester.text,
          approveAmount: 0.0, 
          purpose: _reqPurposeController.text,
          status: 'Pending',
          //setupId: 1,
          tripId: selectedType == "Trip" ? int.parse(tripId.toString()) : null,
          projectId: selectedType == "Project" ? int.parse(projectId.toString()) : null,
          operationId: selectedType == "Operation" ? 0 : null,
          budgetDetails: budgetDetails
    
     );

      try { 
        await ApiService().postAdvanceRequest(newAdvance);
        await _callLogicAppsForAdvanceRequest(newAdvance,departmentName);
        _fetchData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request added successfully'),
            duration: Duration(seconds: 3),
          ),
        );
        _clearText();

        Navigator.pop(context, true);
       
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add request: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
        print('Failed to add request: $e');
      }
    }
  }

  Future<void> _callLogicAppsForAdvanceRequest(AdvanceRequest request, String departmentName) async {
  final logicAppsUrl = 'https://prod-92.southeastasia.logic.azure.com:443/workflows/c530932405df40cb905679f249e1997b/triggers/When_a_HTTP_request_is_received/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2FWhen_a_HTTP_request_is_received%2Frun&sv=1.0&sig=HhJbVzWb-eGOf3Cd_YfhhZ777zlksk0Th94wIcoX25o'; // Replace with your actual Logic Apps URL

  final Map<String, dynamic> logicAppsData = {
    "Date": DateFormat('yyyy-MM-dd').format(request.date),
    "Request_No": request.requestNo,
    "Request_Code": request.requestCode,
    "Request_Type": request.requestType,
    "Amount": request.requestAmount,
    "Currency": request.currency,
    "Requester": request.requester,
    "Purpose": request.purpose,
    "Department": departmentName,
    "BudgetDetails": request.budgetDetails.map((budget) => {
      "Budget Code": budget.BudgetCode,
      "Description": budget.Description,
    }).toList(),
  };

  try {
    final response = await http.post(
      Uri.parse('https://prod-92.southeastasia.logic.azure.com:443/workflows/c530932405df40cb905679f249e1997b/triggers/When_a_HTTP_request_is_received/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2FWhen_a_HTTP_request_is_received%2Frun&sv=1.0&sig=HhJbVzWb-eGOf3Cd_YfhhZ777zlksk0Th94wIcoX25o'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(logicAppsData),
    );

    if (response.statusCode == 200 || response.statusCode == 202) {
      print('Logic Apps request successful');
    } else {
      throw Exception('Failed to send data to Logic Apps. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error sending Logic Apps request: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Advance Request Form"),
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              color: const Color.fromARGB(255, 103, 207, 177),
              borderRadius: BorderRadius.circular(15)),
          width: MediaQuery.of(context).size.width * 0.5,
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Form(
                      key: _formkey,
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Add Advance Request',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
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
                                      controller: _reqNoController,
                                      decoration: const InputDecoration(
                                          labelText: "Request Code"),
                                      readOnly: true,
                                    ),
                                  ),
                                  ListTile(
                                      title: DropdownButtonFormField(
                                    value: selectedType,
                                    items: ['Project', 'Trip', 'Operation']
                                        .map((selectedType) => DropdownMenuItem(
                                              value: selectedType,
                                              child: Text(selectedType),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedType = value!;
                                        if (selectedType == "Project") {
                                          showProjectDialog();
                                          selectedBudgetCodes = [];
                                        } else if (selectedType == "Trip") {
                                          showTripDialog();
                                          selectedBudgetCodes = [];
                                        } else if (selectedType ==
                                            "Operation") {
                                          selectedBudgetCodes = [];
                                        //  _initializeOperationCode();
                                        
                                          _reqDescriptionController.text =
                                              'No need to Filled';
                                        }
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'Request Type',
                                    ),
                                  )),
                                  ListTile(
                                    title: TextFormField(
                                      controller: _totalAmtController,
                                      decoration: const InputDecoration(
                                          labelText: "Enter Total Amount"),
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
                              )),
                              Expanded(
                                  child: Column(
                                children: [
                                  ListTile(
                                    title: TextFormField(
                                      controller: _requester,
                                      decoration: const InputDecoration(
                                          labelText: "Requester"),
                                      readOnly: true,
                                    ),
                                  ),
                                  ListTile(
                                    title: TextFormField(
                                      controller: _reqCodeController,
                                      decoration: const InputDecoration(
                                          labelText: "Request Code"),
                                      // readOnly: true,
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
                              )),
                              Expanded(
                                  child: Column(
                                children: [
                                  ListTile(
                                    title: TextFormField(
                                      controller: _dateController,
                                      decoration: const InputDecoration(
                                          labelText: "Request Date"),
                                      readOnly: true,
                                    ),
                                  ),
                                  ListTile(
                                    title: TextFormField(
                                      controller: _reqDescriptionController,
                                      decoration: const InputDecoration(
                                          labelText: "Request Description"),
                                      readOnly: true,
                                      style: TextStyle(
                                        color: selectedType == "operation"
                                            ? Colors.red
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    title: TextFormField(
                                      controller: _reqPurposeController,
                                      decoration: const InputDecoration(
                                          labelText: "Enter Request Purpose"),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Enter Request Purpose";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ))
                            ],
                          ),
                          // if (selectedType != null)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                if (selectedType == "Operation")
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
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                  child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: DataTable(
                                        border: TableBorder.all(),
                                        columns: [
                                          const DataColumn(
                                              label: Text("Budget Code")),
                                          const DataColumn(
                                              label: Text("Description")),
                                          if (selectedType == "Operation")
                                            const DataColumn(
                                                label: Text("Action"))
                                        ],
                                        rows: selectedBudgetCodes
                                            .map((budgetCode) {
                                          final index = selectedBudgetCodes
                                              .indexOf(budgetCode);
                                          return DataRow(cells: [
                                            DataCell(
                                                Text(budgetCode.BudgetCode)),
                                            DataCell(
                                                Text(budgetCode.Description)),
                                            if (selectedType == "Operation")
                                              DataCell(
                                                IconButton(
                                                  onPressed: () {
                                                    _deleteBudgetCode(index);
                                                  },
                                                  icon:
                                                      const Icon(Icons.delete),
                                                ),
                                              ),
                                          ]);
                                        }).toList(),
                                      )),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed:
                                          _isSubmitting ? null : _submitForm,
                                      style: ElevatedButton.styleFrom(
                                        textStyle: const TextStyle(
                                          fontSize: 15,
                                        ),
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text("Clear"),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                )
                              ],
                            ),
                          )
                        ],
                      )),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //Project Dialog
  void showProjectDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text("Project Table"),
              content: SingleChildScrollView(
                child: ProjectTable(
                    projects: project,
                    onRowSelected:
                        (String selectedProjectCode, String selectedDes) {
                      setState(() {
                        _reqCodeController.text = selectedProjectCode;
                        _reqDescriptionController.text = selectedDes;

                        Projects selectedProject = project.firstWhere(
                            (project) =>
                                project.Project_Code == selectedProjectCode);
                        selectedBudgetCodes = selectedProject.budgetDetails;
                      });
                    }),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("OK")),
              ],
            );
          });
        });
  }

  //Trip Dialog
  void showTripDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text("Trip Table"),
              content: SingleChildScrollView(
                child: TripTable(
                    trips: trip,
                    onRowSelected:
                        (String selectedTripCode, String selectedDes) {
                      setState(() {
                        _reqCodeController.text = selectedTripCode;
                        _reqDescriptionController.text = selectedDes;

                        Trip selectedTrip = trip.firstWhere(
                            (trip) => trip.Trip_Code == selectedTripCode);
                        selectedBudgetCodes = selectedTrip.budgetDetails;
                      });
                    }),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                )
              ]);
        });
  }
}

//Project Table
class ProjectTable extends StatelessWidget {
  final List<Projects> projects;
  final void Function(String, String) onRowSelected;
  const ProjectTable(
      {required this.projects, required this.onRowSelected, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //filter projects data (requestable yes only)
    final filteredProjects =
        projects.where((project) => project.requestable == "Yes").toList();

    if (filteredProjects.isEmpty) {
      return const Center(
        child: Text("No project"),
      );
    }

    return Container(
      // width: 400,
      // height: 300,
      child: DataTable(
          showCheckboxColumn: false,
          columns: const [
            DataColumn(
                label: Text(
              "Project Code",
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
            DataColumn(
                label: Text(
              "Project Description",
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
            DataColumn(
                label: Text(
              "Total Amount",
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
            DataColumn(
                label: Text(
              "Currency",
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
            DataColumn(
                label: Text(
              "Requestable",
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
          ],
          rows: filteredProjects.map((project) {
            return DataRow(
                cells: [
                  DataCell(Text(project.Project_Code)),
                  DataCell(Text(project.description)),
                  DataCell(Text(project.totalAmount.toString())),
                  DataCell(Text(project.currency)),
                  DataCell(Text(project.requestable)),
                ],
                onSelectChanged: (bool? selected) {
                  if (selected ?? false) {
                    onRowSelected(project.Project_Code, project.description);
                    Future.delayed(const Duration(milliseconds: 100), () {
                      Navigator.of(context).pop();
                    });
                  }
                });
          }).toList()),
    );
  }
}

// //Trip Table
class TripTable extends StatelessWidget {
  final List<Trip> trips;
  final void Function(String, String) onRowSelected;
  const TripTable({required this.trips, required this.onRowSelected, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 400,
      // height: 400,
      child: DataTable(
        showCheckboxColumn: false,
        columns: const [
          DataColumn(
              label: Text(
            "Trip Code",
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
          DataColumn(
              label: Text(
            "Trip Description",
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
          DataColumn(
              label: Text(
            "Total Amount",
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
          DataColumn(
              label: Text(
            "Currency",
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
        ],
        rows: trips.map((trip) {
          return DataRow(
              cells: [
                DataCell(Text(trip.Trip_Code)),
                DataCell(Text(trip.description)),
                DataCell(Text(trip.totalAmount.toString())),
                DataCell(Text(trip.currency)),
              ],
              onSelectChanged: (bool? selected) {
                if (selected ?? false) {
                  onRowSelected(trip.Trip_Code, trip.description);
                  Future.delayed(const Duration(milliseconds: 100), () {
                    Navigator.of(context).pop();
                  });
                }
              });
        }).toList(),
      ),
    );
  }
}
