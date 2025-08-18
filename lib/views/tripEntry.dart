import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:advance_budget_request_system/views/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AddTrip extends StatefulWidget {
  final Function(Trip) onTripAdded;
  const AddTrip({Key? key, required this.onTripAdded}) : super(key: key);

  @override
  State<AddTrip> createState() => _AddTripState();
}

class _AddTripState extends State<AddTrip> {
  final _formkey = GlobalKey<FormState>();

  final TextEditingController _tripCodeController = TextEditingController();
  final TextEditingController _tripDesController = TextEditingController();
  final TextEditingController _totalAmtController = TextEditingController();
  final TextEditingController _dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  final ApiService apiService = ApiService();

  String _selectedCurrency = 'MMK';

  List<Department> departments = [];
  String? _selectedDepartmentId;
  String? _selectedDepartmentName;

  List<Budget> chooseBudgetCodes = [];
  List<Budget> BudgetDetail = [];
  List<Trip> trip = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _initializeTripCode();
  }

  //fetchData
  void _fetchData() async {
    try {
      List<Budget> budgetDetails = await ApiService().fetchBudgetCodeData();
      List<Trip> trips = await ApiService().fetchTripinfoData();
      List<Department> department = await ApiService().fetchDepartment();
      setState(() {
        BudgetDetail = budgetDetails;
        trip = trips;
        departments = department;
      });
    } catch (e) {
      print("Fail to load $e");
    }
  }

  //Budget Alert Dialog
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
                            rows: BudgetDetail.map((budgetCode) {
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
                                      // Show error message if the budget code is already selected
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

  void _initializeTripCode() async {
    try {
      String nextCode = await apiService.fetchNextTripCode();
      setState(() {
        _tripCodeController.text = nextCode;
      });
    } catch (error) {
      // Handle error appropriately.
      print('Error fetching trip code: $error');
    }
  }

  Future<int> generateTripCodeID() async {
    List<Trip> existingTrips = await apiService.fetchTripinfoData();

    if (existingTrips.isEmpty) {
      return 1; // Start from 1 if no budget exists
    }

    // Find the highest existing ID
    int maxId = existingTrips.map((b) => b.id).reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

//Submit Button
  void _submitForm() async {
    if (_formkey.currentState!.validate()) {
      List<Trip> existingTrips = await apiService.fetchTripinfoData();
      int nextId = await generateTripCodeID();
      Trip newTrip = Trip(
        id: nextId,
        date: DateFormat('yyyy-MM-dd').parse(_dateController.text),
        Trip_Code: _tripCodeController.text?? '',
        description: _tripDesController.text??'',
        totalAmount: double.tryParse(_totalAmtController.text) ?? 0.0,
        currency: _selectedCurrency,
        departmentId: int.parse(_selectedDepartmentId.toString()),
        departmentName: _selectedDepartmentName ?? '',
        approveAmount: 0,
        status: 1,
        budgetDetails: chooseBudgetCodes,
      );
      print("Trip object: ${newTrip.toJson()}");
      try {
        await ApiService().postTripInfo(newTrip);
        for (var budget in chooseBudgetCodes) {
          await ApiService().postTripBudget(newTrip.id, budget.id);
          _fetchData();
        }
        Navigator.pop(context, true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Trip data can request successfully!!")),
        );
        _fetchData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add trip: $e')),
        );
      }

      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> TripInfo()));
    }
  }

  //clear Button
  void _clearText() {
    setState(() {
      _tripCodeController.text = "";
      _tripDesController.text = "";
      _totalAmtController.text = "";
      _selectedDepartmentName = null;
      _selectedCurrency = 'MMK';
      chooseBudgetCodes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(100, 207, 198, 0.855),
        title: const Text("Trip Request Form"),
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
              child: Center(
                child: Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Form(
                        key: _formkey,
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Add Trip Request',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
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
                                          controller: _tripCodeController,
                                          decoration: const InputDecoration(
                                              labelText: "Enter Trip Code"),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Enter Trip Code";
                                            }
                                            return null;
                                          },
                                          readOnly: true,
                                        ),
                                      ),
                                      ListTile(
                                        title: TextFormField(
                                          controller: _tripDesController,
                                          decoration: const InputDecoration(
                                              labelText:
                                                  "Enter Trip Description"),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Enter Trip Description";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      ListTile(
                                        title: TextFormField(
                                          controller: _totalAmtController,
                                          decoration: const InputDecoration(
                                            labelText: "Enter Total Amount",
                                          ),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d*')),
                                          ],
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Enter Total Amount";
                                            }
                                            final amount =
                                                double.tryParse(value);
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
                                          controller: _dateController,
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
                                          items: departments.map((dept) {
                                            return DropdownMenuItem<String>(
                                              value: dept.departmentName,
                                              child: Text(dept.departmentName),
                                              onTap: () {
                                                _selectedDepartmentId = dept.id
                                                    .toString(); // Store ID
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
                                  Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.3,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: DataTable(
                                        border: TableBorder.all(),
                                        showCheckboxColumn: false,
                                        columns: const [
                                          DataColumn(
                                              label: Text("Budget Code")),
                                          DataColumn(
                                              label: Text("Description")),
                                          DataColumn(label: Text("Action")),
                                        ],
                                        rows:
                                            chooseBudgetCodes.map((budgetCode) {
                                          final index = chooseBudgetCodes
                                              .indexOf(budgetCode);
                                          return DataRow(
                                            cells: [
                                              DataCell(
                                                  Text(budgetCode.BudgetCode)),
                                              DataCell(
                                                  Text(budgetCode.Description)),
                                              DataCell(
                                                IconButton(
                                                  onPressed: () {
                                                    _deleteBudgetCode(index);
                                                  },
                                                  icon:
                                                      const Icon(Icons.delete),
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
        ),
      ),
    );
  }
}

// Edit Trip Request
class EditTrip extends StatefulWidget {
  final Trip tripData;
  final Function() onTripUpdated;
  const EditTrip(
      {Key? key, required this.onTripUpdated, required this.tripData})
      : super(key: key);

  @override
  State<EditTrip> createState() => _EditTripState();
}

class _EditTripState extends State<EditTrip> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tripCodeController = TextEditingController();
  final TextEditingController _tripDesController = TextEditingController();
  final TextEditingController _totalAmtController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String _selectedCurrency = 'MMK';
  List<Department> departments = [];
  String? _selectedDepartmentName;
  String? _selectedDepartmentId;
  List<Budget> chooseBudgetCodes = [];
  List<Budget> BudgetDetail = [];
  List<Trip> trip = [];

  void _fetchData() async {
    try {
      List<Budget> BudgetDetails = await ApiService().fetchBudgetCodeData();
      List<Trip> trips = await ApiService().fetchTripinfoData();
      List<Department> department = await ApiService().fetchDepartment();
      setState(() {
        BudgetDetail = BudgetDetails;
        trip = trips;
        departments = department;

      //   if (!departments
      //       .any((dept) => dept.id.toString() == _selectedDepartmentId)) {
      //     _selectedDepartmentId = widget.tripData.departmentId.toString();
      //     _selectedDepartmentName = widget.tripData.departmentName;
      //   }
      // });
       if (_selectedDepartmentId == null || 
            !departments.any((dept) => dept.id.toString() == _selectedDepartmentId)) {
          _selectedDepartmentId = widget.tripData.departmentId.toString();
          _selectedDepartmentName = widget.tripData.departmentName;
        }
      });
    } catch (e) {
      print("Failed to load budget data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _tripCodeController.text = widget.tripData.Trip_Code;
    _tripDesController.text = widget.tripData.description;
    _totalAmtController.text = widget.tripData.totalAmount.toString();
    _selectedCurrency = widget.tripData.currency;
    _selectedDepartmentName = widget.tripData.departmentName;
    _dateController.text =
        DateFormat('yyyy-MM-dd').format(widget.tripData.date);

    chooseBudgetCodes = List.from(widget.tripData.budgetDetails);
    _fetchData();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDepartmentId == null || _selectedDepartmentId == '0') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a valid department.")),
        );
        return;
      }
      Trip updatedTrip = Trip(
        id: widget.tripData.id,
        date: DateFormat('yyyy-MM-dd').parse(_dateController.text),
        Trip_Code: _tripCodeController.text,
        description: _tripDesController.text,
        totalAmount: double.tryParse(_totalAmtController.text) ?? 0.0,
        currency: _selectedCurrency,
        departmentId: int.parse(_selectedDepartmentId!),
        departmentName:
            _selectedDepartmentName ?? widget.tripData.departmentName,
        approveAmount: 0,
        status: 1,
        budgetDetails: chooseBudgetCodes,
      );

      try {
        await ApiService().updateTripInfo(updatedTrip);
        widget.onTripUpdated();
        Navigator.pop(context, true); // Close the edit form
        _fetchData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Trip updated successfully!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update trip: $e')),
        );
      }
    }
  }

  void _clearText() {
    setState(() {
      _tripCodeController.clear();
      _tripDesController.clear();
      _totalAmtController.clear();
      _selectedDepartmentName = null;
      _selectedCurrency = 'MMK';
    });
  }

  //Budget Alert Dialog
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
                            rows: BudgetDetail.map((budgetCode) {
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
                                      // Show error message if the budget code is already selected
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
    // setState(() {
    //   chooseBudgetCodes.removeAt(index);
    // });
    if (index >= 0 && index < chooseBudgetCodes.length) {
      setState(() {
        chooseBudgetCodes.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Trip Request"),
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
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              'Edit Trip Request',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  ListTile(
                                    title: TextFormField(
                                      controller: _tripCodeController,
                                      decoration: const InputDecoration(
                                          labelText: "Enter Trip Code"),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Enter Trip Code";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  ListTile(
                                    title: TextFormField(
                                      controller: _tripDesController,
                                      decoration: const InputDecoration(
                                          labelText: "Enter Trip Description"),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Enter Trip Description";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  ListTile(
                                    title: TextFormField(
                                      controller: _totalAmtController,
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
                                    controller: _dateController,
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
                                    items: departments.map((dept) {
                                      return DropdownMenuItem<String>(
                                        value: dept.departmentName,
                                        child: Text(dept.departmentName),
                                        // onTap: () {
                                        //   setState(() {
                                        //     _selectedDepartmentId =
                                        //         dept.id.toString();
                                        //     _selectedDepartmentName =
                                        //         dept.departmentName;
                                        //   });
                                        // },
                                      );
                                    }).toList(),
                                    // onChanged: (value) {
                                    //   setState(() {
                                    //     _selectedDepartmentName = value;
                                    //     // Update the ID when name changes
                                    //     _selectedDepartmentId = departments
                                    //         .firstWhere((dept) =>
                                    //             dept.departmentName == value)
                                    //         .id
                                    //         .toString();
                                    //   });
                                    // },
          //                           onChanged: (value) {
          //                             setState(() {
          //                               _selectedDepartmentName = value;
          //                               final selectedDept =
          //                                   departments.firstWhere(
          //                                 (dept) =>
          //                                     dept.departmentName == value,
          //                                 orElse: () =>  Department(
          //   id: 0,
          //   departmentName: 'Unknown',
          //   departmentCode: '',
          // ),
          //                               );
          //                               _selectedDepartmentId =
          //                                   selectedDept.id.toString();
          //                             });
          //                           },
          //                           validator: (value) => value == null
          //                               ? "Select department"
          //                               : null,
          //                         ),
          //                       ),
         onChanged: (value) {
  if (value != null) {
    final selectedDept = departments.firstWhere(
      (dept) => dept.departmentName == value,
      orElse: () => Department(
        id: 0,
        departmentName: 'Unknown',
        departmentCode: '',
      ),
    );
    
    setState(() {
      _selectedDepartmentName = value;
      _selectedDepartmentId = selectedDept.id.toString();
    });
  }
},
    validator: (value) {
      if (value == null || value.isEmpty) {
        return "Please select a department";
      }
      return null;
    },
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
                                  child: const Text("Add Budget Code")),
                              const SizedBox(height: 10),
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
                                      return DataRow(cells: [
                                        DataCell(Text(budgetCode.BudgetCode)),
                                        DataCell(Text(budgetCode.Description)),
                                        DataCell(IconButton(
                                            onPressed: () {
                                              _deleteBudgetCode(index);
                                            },
                                            icon: const Icon(Icons.delete)))
                                      ]);
                                    }).toList(),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _submitForm,
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
                              child: const Text("Update"),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            ElevatedButton(
                              onPressed: _clearText,
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
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
