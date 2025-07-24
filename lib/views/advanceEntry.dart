import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:advance_budget_request_system/views/data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';

class AdvanceEntry extends StatefulWidget {
  const AdvanceEntry({super.key});

  @override
  State<AdvanceEntry> createState() => _AdvanceEntryState();
}

class _AdvanceEntryState extends State<AdvanceEntry> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _requestNoController = TextEditingController();
  final TextEditingController _requesterController = TextEditingController();
  final TextEditingController _requestDateController = TextEditingController();
  final TextEditingController _requestCodeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _requestPurposeController =
      TextEditingController();
  String? _selectedRequestType;
  String _selectedCurrency = 'MMK';

  List<Project> project = [];
  List<Trips> trip = [];
  List<Advance> advance = [];

  @override
  void initState() {
    super.initState();
    _generateRequestNo();
    fetchData();
    _requestDateController.text =
        DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  void _generateRequestNo() {
    int lastRequestNo = 1;
    _requestNoController.text =
        'Req_000_${lastRequestNo.toString().padLeft(3, '0')}';
  }

  void fetchData() async {
    try {
      List<Project> projects =
          await ApiService().fetchProjects().catchError((e) {
        print("Error fetching projects: $e");
        return <Project>[];
      });

      List<Trips> trips = await ApiService().fetchTrips().catchError((e) {
        print("Error fetching trips: $e");
        return <Trips>[];
      });

      setState(() {
        project = projects;
        trip = trips;
      });
    } catch (e) {
      print("Fail to load $e");
      setState(() {
        project = [];
        trip = [];
      });
    }
  }
  final ApiService apiService = ApiService();
  Future<int> generateAdvanceID() async {  
    List<Advance> existingAvance = await apiService.fetchAdvanceRequests();

    if (existingAvance.isEmpty) {
      return 1; // Start from 1 if no budget exists
    }

    // Find the highest existing ID
    int maxId =
        existingAvance.map((b) => b.id).reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  void _submitForm() async{
    if (_formKey.currentState!.validate()) {
      int newId= await generateAdvanceID();
      Advance newAdvance= Advance(
        id: newId, 
        date: DateTime.parse(_requestDateController.text), 
        requestNo: _requestNoController.text, 
        requestCode: _requestCodeController.text, 
        requestDes: _descriptionController.text, 
        requestType: _selectedRequestType!, 
        requestAmount: double.tryParse(_totalAmountController.text)?? 0, 
        currency: _selectedCurrency, 
        requester: _requesterController.text, 
        departmentName: 'Admin', 
        approvedAmount: 0.0, 
        purpose: _requestPurposeController.text, 
        status: 'Pending'
      );
      try {
        await ApiService().postAdvanceRequests(newAdvance);
        fetchData();
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request added successfully'),
            duration: Duration(seconds: 3),
          ),
        );
        _clearForm();
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

  void _clearForm() {
    setState(() {
      _requesterController.text="";
      _selectedRequestType=null;
      _requestCodeController.text="";
      _descriptionController.text="";
      _selectedCurrency='MMK';
      _totalAmountController.text='';
      _requestPurposeController.text='';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        title: const Text("Advance Request Entry"),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(16),
          width: 800,
          color: Colors.white,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Add Advance Request Form",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _requestNoController,
                        readOnly: true,
                        decoration: InputDecoration(
                            labelText: "Request No",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: const OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _requesterController,
                        // readOnly: true,
                        decoration: InputDecoration(
                            labelText: "Requester",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: const OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _requestDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                            labelText: "Request Date",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: const OutlineInputBorder()),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                        child: DropdownButtonFormField(
                      value: _selectedRequestType,
                      items: ['Project', 'Trip', 'Operation']
                          .map((requestType) => DropdownMenuItem(
                                value: requestType,
                                child: Text(requestType),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRequestType = value!;
                          if (_selectedRequestType == "Project") {
                            showProjectDialog();
                          } else if (_selectedRequestType == "Trip") {
                            showTripDialog();
                          } else if (_selectedRequestType == "Operation") {
                            _descriptionController.text = "No need to filled";
                             _requestCodeController.text = "";
                          }
                        });
                      },
                      decoration: const InputDecoration(
                          labelText: 'Request Type',
                          border: OutlineInputBorder()),
                    )),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: TextFormField(
                      controller: _requestCodeController,
                      decoration: InputDecoration(
                        labelText: "Request Code",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: const OutlineInputBorder(),
                      ),
                      readOnly: true,
                    )),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: "Description",
                        filled: true,
                        // fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ))
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                        child: TextFormField(
                      controller: _totalAmountController,
                      decoration: InputDecoration(
                        labelText: "Enter Request Amount",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter Request Amount";
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
                    )),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: _selectedRequestType == "Operation"
                          ? DropdownButtonFormField<String>(
                              value: _selectedCurrency,
                              decoration: const InputDecoration(
                                labelText: 'Currency',
                                border: OutlineInputBorder(),
                              ),
                              items: ['MMK', 'USD'].map((String currency) {
                                return DropdownMenuItem<String>(
                                  value: currency,
                                  child: Text(currency),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCurrency = value!;
                                });
                              },
                            )
                          : DropdownButtonFormField<String>(
                              value: _selectedCurrency,
                              decoration: InputDecoration(
                                labelText: 'Currency',
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                              items: [_selectedCurrency].map((String currency) {
                                return DropdownMenuItem<String>(
                                  value: currency,
                                  child: Text(currency, style: const TextStyle(color: Colors.black),),
                                );
                              }).toList(),
                              onChanged: null, // Disabled for Project/Trip
                            ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: TextFormField(
                      controller: _requestPurposeController,
                      decoration: InputDecoration(
                        labelText: "Enter Request Purpose",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter Request Purpose";
                        }
                        return null;
                      },
                    ))
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(
                          fontSize: 15,
                        ),
                        backgroundColor: const Color(0xFFB2C8A8),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Submit"),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _clearForm,
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(
                          fontSize: 15,
                        ),
                        backgroundColor: const Color(0xFFB2C8A8),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Clear"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showProjectDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.width * 0.3,
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("Available Project Requests",
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                Expanded(
                  child: ProjectList(
                    projects: project,
                    onRowSelected: (String selectedProjectCode,
                        String selectedDes, String selectedCurrency) {
                      setState(() {
                        _requestCodeController.text = selectedProjectCode;
                        _descriptionController.text = selectedDes;
                        // _selectedCurrency = selectedCurrency;
                         if (_selectedRequestType == "Project") {
                        _selectedCurrency = selectedCurrency;
                      }
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showTripDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.width * 0.3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("Available Trip Requests",
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                Expanded(
                  child: TripList(
                    trips: trip,
                    onRowSelected: (String selectedTripCode, String selectedDes,
                        String selectedCurrency) {
                      setState(() {
                        _requestCodeController.text = selectedTripCode;
                        _descriptionController.text = selectedDes;
                        // _selectedCurrency = selectedCurrency;
                        if (_selectedRequestType == "Trip") {
                        _selectedCurrency = selectedCurrency;
                      }
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProjectList extends StatefulWidget {
  final List<Project> projects;
  final void Function(String, String, String) onRowSelected;
  const ProjectList({
    required this.projects,
    required this.onRowSelected,
    Key? key,
  }) : super(key: key);

  @override
  State<ProjectList> createState() => _ProjectListState();
}

class _ProjectListState extends State<ProjectList> {
  late List<PlutoColumn> columns;
  late List<PlutoRow> rows;
  late PlutoGridStateManager stateManager;

  @override
  void initState() {
    super.initState();
    _initColumns();
    _initRows();
  }

  void _initColumns() {
    columns = [
      PlutoColumn(
          title: 'Project Code',
          field: 'Project Code',
          type: PlutoColumnType.text(),
          enableEditingMode: false,
          width: 200),
      PlutoColumn(
          title: 'Project Description',
          field: 'Project Description',
          type: PlutoColumnType.text(),
          enableEditingMode: false,
          width: 200),
      PlutoColumn(
          title: 'Total Amount',
          field: 'Total Amount',
          type: PlutoColumnType.number(),
          enableEditingMode: false,
          width: 200),
      PlutoColumn(
          title: 'Currency',
          field: 'Currency',
          type: PlutoColumnType.text(),
          enableEditingMode: false,
          width: 200),
      PlutoColumn(
          title: 'Department',
          field: 'Department',
          type: PlutoColumnType.text(),
          enableEditingMode: false,
          width: 200)
    ];
  }

  void _initRows() {
    final filteredProjects =
        widget.projects.where((p) => p.requestable == "Yes").toList();

    rows = filteredProjects.map((project) {
      return PlutoRow(cells: {
        'Project Code': PlutoCell(value: project.projectCode),
        'Project Description': PlutoCell(value: project.projectDescription),
        'Total Amount': PlutoCell(value: project.totalAmount.toString()),
        'Currency': PlutoCell(value: project.currency),
        'Department': PlutoCell(value: project.departmentName),
      });
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // if (rows.isEmpty) {
    //   return const Center(
    //     child: Text("No project"),
    //   );
    // }
    return Scaffold(
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onLoaded: (event) => stateManager = event.stateManager,
        onRowDoubleTap: (PlutoGridOnRowDoubleTapEvent event) {
          final row = event.row;
          final code = row.cells['Project Code']?.value.toString() ?? '';
          final desc = row.cells['Project Description']?.value.toString() ?? '';
          final currency = row.cells['Currency']?.value.toString() ?? 'MMK';
          widget.onRowSelected(code, desc, currency);
        },
        configuration: PlutoGridConfiguration(
            style: PlutoGridStyleConfig(
                rowHeight: 30,
                oddRowColor: Colors.greenAccent,
                activatedColor: Colors.lightBlueAccent.withOpacity(0.3))),
      ),
    );
  }
}

class TripList extends StatefulWidget {
  final List<Trips> trips;
  final void Function(String, String, String) onRowSelected;
  const TripList({required this.trips, required this.onRowSelected, Key? key})
      : super(key: key);

  @override
  State<TripList> createState() => _TripListState();
}

class _TripListState extends State<TripList> {
  late List<PlutoColumn> columns;
  late List<PlutoRow> rows;
  late PlutoGridStateManager stateManager;

  @override
  void initState() {
    super.initState();
    _initColumns();
    _initRows();
  }

  void _initColumns() {
    columns = [
      PlutoColumn(
          title: 'Trip Code', field: 'Trip Code', type: PlutoColumnType.text()),
      PlutoColumn(
          title: 'Trip Description',
          field: 'Trip Description',
          type: PlutoColumnType.text(),
          enableEditingMode: false,
          width: 200),
      PlutoColumn(
          title: 'Total Amount',
          field: 'Total Amount',
          type: PlutoColumnType.number(),
          enableEditingMode: false,
          width: 200),
      PlutoColumn(
          title: 'Currency',
          field: 'Currency',
          type: PlutoColumnType.text(),
          enableEditingMode: false,
          width: 200),
      PlutoColumn(
          title: 'Department',
          field: 'Department',
          type: PlutoColumnType.text(),
          enableEditingMode: false,
          width: 200)
    ];
  }

  void _initRows() {
    rows = widget.trips.map((trip) {
      return PlutoRow(cells: {
        'Trip Code': PlutoCell(value: trip.tripCode),
        'Trip Description': PlutoCell(value: trip.tripDescription),
        'Total Amount': PlutoCell(value: trip.totalAmount.toString()),
        'Currency': PlutoCell(value: trip.currency),
        'Department': PlutoCell(value: trip.departmentName),
      });
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // if (rows.isEmpty) {
    //   return const Center(
    //     child: Text("No trip"),
    //   );
    // }
    return Scaffold(
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onLoaded: (event) => stateManager = event.stateManager,
        onRowDoubleTap: (PlutoGridOnRowDoubleTapEvent event) {
          final row = event.row;
          final code = row.cells['Trip Code']?.value.toString() ?? '';
          final desc = row.cells['Trip Description']?.value.toString() ?? '';
          final currency = row.cells['Currency']?.value.toString() ?? 'MMK';
          widget.onRowSelected(code, desc, currency);
        },
        configuration: PlutoGridConfiguration(
            style: PlutoGridStyleConfig(
                rowHeight: 30,
                oddRowColor: Colors.greenAccent,
                activatedColor: Colors.lightBlueAccent.withOpacity(0.3))),
      ),
    );
  }
}
