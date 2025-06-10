import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'dart:html' as html;

import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:advance_budget_request_system/views/approvalentry.dart';
import 'package:advance_budget_request_system/views/data.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ApprovalSetupStep extends StatefulWidget {
  @override
  _ApprovalSetupState createState() => _ApprovalSetupState();
}

class _ApprovalSetupState extends State<ApprovalSetupStep> {
  String? selectedDepartmentId;
  String? selectedDepartmentName;
  String? selectedType;
  String? selectedCurrency;
  dynamic hoverRow;
  String? selectedFilter;
  String? sortColumn;
  bool sortAscending = true;

  int rowsPerPage = 10;
  int currentPage = 1;
  int totalPages = 1;
  String? noOfSteps;
  bool managementApprover = false;
  final TextEditingController flownameController = TextEditingController();
  List<ApprovalSetup> filterData = [];

  List<ApprovalSetup> filterFlows = [];

  List<Department> _departments = [];
  final List<String> _currencies = ['MMK', 'USD'];

  final List<String> _type = ['Project', 'Trip', 'Operation'];
  final List<ApprovalSetup> data = [];
  List<ApprovalSetup> flows = [];

  String boolToYesNo(bool value) {
    return value ? "Yes" : "No";
  }
  // ignore: unused_element

  @override
  void initState() {
    super.initState();
    _fetchData();
    _refreshData();
  }

  void _addApproval(List<ApprovalSetup> newApprovals) {
    print("New Approvals: $newApprovals");
    setState(() {
      flows.addAll(newApprovals);
      _filterData();
    });
  }

  // ignore: unused_element
  void _updateApproval(int index, ApprovalSetup updatedApproval) {
    setState(() {
      flows[index] =
          // ignore: unnecessary_cast
          updatedApproval as ApprovalSetup;
    });
  }

  void _deleteConfirmation(ApprovalSetup as) async {
    bool? confirm = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Delete Confirmation"),
            content: const Text("Are you sure to delete this Approval?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("Delete")),
            ],
          );
        });

    if (confirm == true) {
      try {
        List<ApprovalStep> stepsToDelete = List.from(as.ApprovalSteps);
        for (ApprovalStep step in stepsToDelete) {
          try {
            await ApiService().deleteApprovalStep(step.id);
            print('Deleted step ${step.id} successfully');
          } catch (e) {
            print('Error deleting step ${step.id}: $e');
          }
        }
        await ApiService().deleteApprovalSetup(as.id);
        print('Deleted approval setup ${as.id} successfully');

        setState(() {
          flows.removeWhere((item) => item.id == as.id);
          filterData.removeWhere((item) => item.id == as.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Approval deleted successfully")),
        );
      } catch (e) {
        print('Full delete error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: ${e.toString()}')),
        );
      }
    }
  }

  //Sorting
  void _sortDataColumn(String column) {
    setState(() {
      if (sortColumn == column) {
        sortAscending = !sortAscending;
      } else {
        sortColumn = column;
        sortAscending = true;
      }

      filterData.sort((a, b) {
        dynamic aValue;
        dynamic bValue;

        switch (column) {
          case 'Flow Name':
            aValue = a.FlowName;
            bValue = b.FlowName;
            break;
          case 'Department':
            aValue = a.departmentName;
            bValue = b.departmentName;
            break;
          case 'Request Type':
            aValue = a.RequestType;
            bValue = b.RequestType;
            break;
          case 'Currency':
            aValue = a.Currency;
            bValue = b.Currency;
            break;
          case 'Description':
            aValue = a.Description;
            bValue = b.Description;
            break;
          case 'No of steps':
            aValue = a.No_of_Steps;
            bValue = b.No_of_Steps;
            break;
          case 'Management':
            aValue = a.Management;
            bValue = b.Management;
            break;
          default:
            return 0;
        }

        if (aValue == null || bValue == null) return 0;

        if (sortAscending) {
          return aValue.compareTo(bValue);
        } else {
          return bValue.compareTo(aValue);
        }
      });
      _updatePagination();
    });
  }

  Widget _buildHeaderCell(String label, String column) {
    return InkWell(
      onTap: () {
        _sortDataColumn(column);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (sortColumn == column)
              Icon(
                sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
              )
          ],
        ),
      ),
    );
  }

  Future<void> exportToCSV() async {
    try {
      print("Export to CSV button pressed!");

      List<List<dynamic>> csvData = [];

      csvData.add([
        "FlowName",
        "Department",
        "RequestType",
        "Currency",
        "Description",
        "No_of_Steps",
        "Management",
        "ApprovalSteps"
      ]);

      for (var approval in flows) {
        csvData.add([
          approval.FlowName,
          approval.departmentName,
          approval.RequestType,
          approval.Currency,
          approval.Description,
          approval.No_of_Steps,
          approval.Management == "Yes" ? "Yes" : "No",
          approvalSteps(approval.ApprovalSteps)
        ]);
      }

      String csv = const ListToCsvConverter().convert(csvData);

      if (kIsWeb) {
        final bytes = utf8.encode(csv);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "data.csv")
          ..click();

        html.Url.revokeObjectUrl(url);
        print("CSV file downloaded in browser.");
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final path = "${directory.path}/data.csv";

        final file = File(path);
        await file.writeAsString(csv);

        print("CSV file saved to $path");
      }
    } catch (e) {
      print("Error exporting to CSV: $e");
    }
  }

  String approvalSteps(List<ApprovalStep> ApprovalSteps) {
    return ApprovalSteps.map((steps) {
      return '${steps.approver}: ${steps.maxAmount} : ${steps.approverEmail}';
    }).join('; ');
  }

  void _refreshData() {
    setState(() {
      flownameController.clear();
      selectedDepartmentName = null;
      selectedType = null;
      selectedCurrency = null;
      managementApprover = false;
      filterData = List.from(flows);
      sortColumn = null;
      _updatePagination();
      currentPage = 1;
    });
  }

  void _filterData() {
    setState(() {
      filterData = flows.where((setup) {
        bool matchesDepartment = selectedDepartmentName == null ||
            selectedDepartmentName!.isEmpty ||
            setup.departmentName == selectedDepartmentName;
        bool matchesType = selectedType == null ||
            selectedType!.isEmpty ||
            setup.RequestType == selectedType;
        bool matchesCurrency = selectedCurrency == null ||
            selectedCurrency!.isEmpty ||
            setup.Currency == selectedCurrency;
        bool matchesFlowName = flownameController.text.isEmpty ||
            setup.FlowName!
                .toLowerCase()
                .contains(flownameController.text.toLowerCase());
        bool matchesManagement =
            !managementApprover || (setup.Management?.toLowerCase() == 'yes');

        return matchesDepartment &&
            matchesType &&
            matchesCurrency &&
            matchesFlowName &&
            matchesManagement;
      }).toList();
    });
  }

  void _updatePagination() {
    setState(() {
      totalPages = (filterData.length / rowsPerPage).ceil();
      if (currentPage > totalPages && totalPages != 0) {
        currentPage = totalPages;
      } else if (totalPages == 0) {
        currentPage = 1;
      }
    });
  }

  //Pagination
  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: currentPage > 1
                ? () {
                    setState(() {
                      currentPage--;
                      _updatePagination();
                    });
                  }
                : null,
            icon: const Icon(Icons.arrow_back),
          ),
          Text('Page $currentPage of $totalPages'),
          IconButton(
            onPressed: currentPage < totalPages
                ? () {
                    setState(() {
                      currentPage++;
                      _updatePagination();
                    });
                  }
                : null,
            icon: const Icon(Icons.arrow_forward),
          ),
          const SizedBox(width: 20),
          DropdownButton<int>(
            value: rowsPerPage,
            items: [10, 15, 20].map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text('$value rows'),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  rowsPerPage = value;
                  currentPage = 1;
                  _updatePagination();
                });
              }
            },
          ),
        ],
      ),
    );
  }

  List<ApprovalSetup> get paginatedData {
    int start = (currentPage - 1) * rowsPerPage;
    int end = start + rowsPerPage < filterData.length
        ? start + rowsPerPage
        : filterData.length;
    return filterData.sublist(start, end);
  }

  void _fetchData() async {
    try {
      List<ApprovalSetup> setup = await ApiService().fetchApprovalSetup();
      List<Department> department = await ApiService().fetchDepartment();
      setState(() {
        flows = setup;
        filterData = List.from(flows);
        _departments = department;

        print("Fetched Projects: $flows");
        print("Filter Data: $filterData");
        print("Fetched Departments: $_departments");
        _updatePagination();
      });
    } catch (e) {
      print("Failed to project: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Approval Set Up",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 5,
                  child: DropdownButtonFormField<String>(
                    value: selectedDepartmentName,
                    decoration: const InputDecoration(labelText: "Department"),
                    items: _departments.map((dept) {
                      return DropdownMenuItem<String>(
                        value: dept.departmentName,
                        child: Text(dept.departmentName),
                        onTap: () {
                          selectedDepartmentId = dept.id.toString(); // Store ID
                        },
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDepartmentName = value;
                        _filterData();
                      });
                    },
                    validator: (value) =>
                        value == null ? "Select department" : null,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 5,
                  child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                        labelText: "Request Type",
                        border: OutlineInputBorder()),
                    value: selectedType,
                    items: _type.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedType = value!;
                        _filterData();
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Choose your Request Type";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 5,
                  child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                        labelText: "Currency", border: OutlineInputBorder()),
                    value: selectedCurrency,
                    items: _currencies.map((currency) {
                      return DropdownMenuItem(
                          value: currency, child: Text(currency));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCurrency = value!;
                        _filterData();
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Choose your Currency";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 5,
                  child: TextFormField(
                    controller: flownameController,
                    decoration: const InputDecoration(
                        labelText: 'Flow Name', border: OutlineInputBorder()),
                    onChanged: (value) {
                      _filterData();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: managementApprover,
                  onChanged: (value) {
                    setState(() {
                      managementApprover = value ?? false;
                      _filterData();
                    });
                  },
                ),
                const Text('Management Approver'),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 150, 212, 234),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                          icon: const Icon(Icons.add, color: Colors.black),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ApprovalEntryForm(
                                  approvalAdded: (newProject) {
                                    setState(() {
                                      flows.add(newProject as ApprovalSetup);
                                      filterData = List.from(flows);
                                    });
                                    _updatePagination();
                                  },
                                ),
                              ),
                            );

                            if (result == true) {
                              _fetchData();
                            }
                          }),
                      IconButton(
                        onPressed: _refreshData,
                        icon: const Icon(Icons.refresh,
                            color: Color.fromARGB(255, 21, 21, 21)),
                      ),
                      IconButton(
                        onPressed: exportToCSV,
                        icon: const Icon(Icons.download,
                            color: Color.fromARGB(255, 21, 21, 21)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: screenWidth,
                  child: Table(
                    border: const TableBorder.symmetric(
                      inside: BorderSide(color: Colors.grey, width: 1),
                      outside: BorderSide(color: Colors.grey, width: 1),
                    ),
                    columnWidths: const {
                      0: FlexColumnWidth(1.3),
                      1: FlexColumnWidth(0.9),
                      2: FlexColumnWidth(0.9),
                      3: FlexColumnWidth(0.7),
                      4: FlexColumnWidth(1.5),
                      5: FlexColumnWidth(0.8),
                      6: FlexColumnWidth(0.9),
                      7: FlexColumnWidth(1.0),
                    },
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 167, 230, 232)),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildHeaderCell(
                              "Flow Name",
                              "Flow Name",
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildHeaderCell(
                              "Department",
                              "Department",
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildHeaderCell(
                              "Request Type",
                              "Request Type",
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildHeaderCell(
                              "Currency",
                              "Currency",
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildHeaderCell(
                              "Description",
                              "Description",
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildHeaderCell(
                              "No of steps",
                              "No of steps",
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildHeaderCell(
                              "Management",
                              "Management",
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Action",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  border: const TableBorder.symmetric(
                    inside: BorderSide(color: Colors.grey, width: 1),
                    outside: BorderSide(color: Colors.black, width: 1),
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(1.3),
                    1: FlexColumnWidth(0.9),
                    2: FlexColumnWidth(0.9),
                    3: FlexColumnWidth(0.7),
                    4: FlexColumnWidth(1.5),
                    5: FlexColumnWidth(0.8),
                    6: FlexColumnWidth(0.9),
                    7: FlexColumnWidth(1.0),
                  },
                  children: paginatedData.map(
                    (row) {
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(row.FlowName),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(row.departmentName),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(row.RequestType),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(row.Currency),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(row.Description),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(row.No_of_Steps.toString()),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(row.Management),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // IconButton(
                                //   onPressed: () async {
                                //     final updatedApproval =
                                //         await Navigator.push(
                                //       context,
                                //       MaterialPageRoute(
                                //         builder: (context) => ApprovalEditForm(
                                //           onSave: (updatedApproval) {
                                //             return updatedApproval;
                                //           },
                                //           existingData: row,
                                //         ),
                                //       ),
                                //     );

                                //     if (updatedApproval != null) {
                                //       setState(() {
                                //         int rowIndex = flows.indexOf(row);
                                //         if (rowIndex != -1) {
                                //           flows[rowIndex] = updatedApproval;
                                //         }
                                //       });
                                //     }
                                //   },
                                //   icon: const Icon(Icons.edit),
                                //   color: Colors.black,
                                // ),
                                IconButton(
                                    onPressed: () {
                                      _deleteConfirmation(row);
                                    },
                                    icon: const Icon(Icons.delete),
                                    color: Colors.black),
                                IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                approvalDetailPage(
                                                    onSave: row)),
                                      );
                                    },
                                    icon: const Icon(Icons.more_horiz_outlined),
                                    color: Colors.black),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ).toList(),
                ),
              ),
            ),
            _buildPaginationControls()
          ],
        ),
      ),
    );
  }
}

class ApprovalEditForm extends StatefulWidget {
  final Function(ApprovalSetup) onSave;
  final ApprovalSetup existingData;

  const ApprovalEditForm({
    Key? key,
    required this.onSave,
    required this.existingData,
  }) : super(key: key);

  @override
  State<ApprovalEditForm> createState() => _ApprovalEditFormState();
}

class _ApprovalEditFormState extends State<ApprovalEditForm> {
  final TextEditingController flownameController = TextEditingController();
  final TextEditingController desciptionController = TextEditingController();
  List<TextEditingController> approverControllers = [];
  List<TextEditingController> maxAmountControllers = [];
  List<TextEditingController> emailControllers = [];

  String? selectedDepartmentId;
  String? selectedDepartmentName;
  String? selectedReqType;
  String? selectedCurrencies;
  int? selectedSteps;
  String managementApprover = "No";

  final List<Department> _departments = [];
  final List<String> _currencies = ['MMK', 'USD'];
  final List<String> _type = ['Project', 'Trip', 'Operation'];
  final List<int> _steps = [1, 2, 3, 4, 5];

  final _formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    selectedSteps = widget.existingData.No_of_Steps;
    _initializeControllers();
    _populateExistingData();
    // _refreshData();
  }

  void _initializeControllers() {
    approverControllers =
        List.generate(selectedSteps!, (index) => TextEditingController());
    maxAmountControllers =
        List.generate(selectedSteps!, (index) => TextEditingController());
    emailControllers =
        List.generate(selectedSteps!, (index) => TextEditingController());
  }

  void _refreshData() {
    setState(() {
      flownameController.clear();
      selectedDepartmentName = null;
      selectedReqType = null;
      selectedCurrencies = null;
      managementApprover = "No";
    });
  }

  void _clearText() {
    setState(() {
      flownameController.clear();
      desciptionController.clear();
      selectedCurrencies = null;
      selectedDepartmentName = null;
      selectedReqType = null;
      selectedSteps = null;
    });
  }

  void _populateExistingData() {
    flownameController.text = widget.existingData.FlowName;
    selectedDepartmentId = widget.existingData.departmentId.toString();
    selectedDepartmentName = widget.existingData.departmentName;
    selectedReqType = widget.existingData.RequestType;
    selectedCurrencies = widget.existingData.Currency;
    desciptionController.text = widget.existingData.Description;
    managementApprover = widget.existingData.Management;
    for (int i = 0; i < widget.existingData.ApprovalSteps.length; i++) {
      approverControllers[i].text =
          widget.existingData.ApprovalSteps[i].approver;
      emailControllers[i].text = widget.existingData.ApprovalSteps[i].approver;
      maxAmountControllers[i].text =
          widget.existingData.ApprovalSteps[i].maxAmount.toString();
      emailControllers[i].text =
          widget.existingData.ApprovalSteps[i].approverEmail;
    }
  }

  void _submitForm() async {
    if (_formkey.currentState!.validate()) {
      if (!_validateApprovers()) return;

      try {
        List<ApprovalStep> approvalSteps = await _prepareApprovalSteps();

        ApprovalSetup updatedApproval = ApprovalSetup(
          id: widget.existingData.id,
          FlowName: flownameController.text,
          departmentId: int.parse(selectedDepartmentId!),
          departmentName: selectedDepartmentName!,
          RequestType: selectedReqType!,
          Currency: selectedCurrencies!,
          Description: desciptionController.text,
          No_of_Steps: selectedSteps!,
          Management: managementApprover,
          ApprovalSteps: approvalSteps,
        );

        print('Updating approval: ${updatedApproval.toJson()}');

        await _updateApprovalAndSteps(updatedApproval, approvalSteps);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Approval updated successfully!")),
        );

        widget.onSave(updatedApproval);
        Navigator.pop(context, true);
        _refreshData();
      } catch (e) {
        print('Full error details: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: ${e.toString()}')),
        );
      }
    }
  }

  bool _validateApprovers() {
    for (int i = 0; i < selectedSteps!; i++) {
      if (approverControllers[i].text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all approver fields")),
        );
        return false;
      }
    }
    return true;
  }

  Future<List<ApprovalStep>> _prepareApprovalSteps() async {
    List<ApprovalStep> approvalSteps = [];
    for (int i = 0; i < selectedSteps!; i++) {
      // String stepId = widget.existingData.ApprovalSteps.length > i
      //     ? widget.existingData.ApprovalSteps[i].id
      //     : '${widget.existingData.id}_${DateTime.now().millisecondsSinceEpoch}_$i';
      String stepId = widget.existingData.ApprovalSteps.length > i
          ? widget.existingData.ApprovalSteps[i].id.toString()
          : '${widget.existingData.id}_${DateTime.now().millisecondsSinceEpoch}_$i';

      ApprovalStep step = ApprovalStep(
        id: int.parse(stepId),
        setupid: widget.existingData.id,
        stepNo: i + 1,
        approver: approverControllers[i].text,
        approverEmail: emailControllers[i].text,
        maxAmount: double.tryParse(maxAmountControllers[i].text) ?? 0.0,
      );
      approvalSteps.add(step);
    }
    return approvalSteps;
  }

  Future<void> _updateApprovalAndSteps(
      ApprovalSetup approval, List<ApprovalStep> steps) async {
    final setupResponse = await ApiService.updateApprovalSetup(approval);

    for (final step in steps) {
      try {
        if (widget.existingData.ApprovalSteps.any((s) => s.id == step.id)) {
          await ApiService.updateApprovalStep(step);
        } else {
          await ApiService.postApprovalStep(step);
        }
      } catch (e) {
        print('Error saving step ${step.id}: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Approval Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 103, 207, 177),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.black, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formkey,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        "Add Approval Setup",
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
                                controller: flownameController,
                                decoration: const InputDecoration(
                                  labelText: "Enter Flow Name",
                                ),
                                validator: (value) {
                                  if (value == null) {
                                    return "Please Enter Flow Name";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            ListTile(
                              title: DropdownButtonFormField<String>(
                                value: selectedDepartmentName,
                                decoration: const InputDecoration(
                                    labelText: "Department"),
                                items: _departments.map((dept) {
                                  return DropdownMenuItem<String>(
                                    value: dept.departmentName,
                                    child: Text(dept.departmentName),
                                    onTap: () {
                                      selectedDepartmentId =
                                          dept.id.toString(); // Store ID
                                    },
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedDepartmentName = value;
                                  });
                                },
                                validator: (value) =>
                                    value == null ? "Select department" : null,
                              ),
                            ),
                            ListTile(
                              title: TextFormField(
                                controller: desciptionController,
                                decoration: const InputDecoration(
                                  labelText: "Enter Description",
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please Enter Description";
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
                            title: DropdownButtonFormField(
                              decoration: const InputDecoration(
                                  labelText: "Selected Request Type"),
                              value: selectedReqType,
                              items: _type.map((type) {
                                return DropdownMenuItem(
                                    value: type, child: Text(type));
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedReqType = value!;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please select request type";
                                }
                                return null;
                              },
                            ),
                          ),
                          ListTile(
                            title: DropdownButtonFormField(
                              decoration: const InputDecoration(
                                  labelText: "Selected Currency"),
                              value: selectedCurrencies,
                              items: _currencies.map((currency) {
                                return DropdownMenuItem(
                                    value: currency, child: Text(currency));
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCurrencies = value!;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please select currency";
                                }
                                return null;
                              },
                            ),
                          ),
                          ListTile(
                            title: DropdownButtonFormField<int>(
                              decoration: const InputDecoration(
                                labelText: "Selected Approval Steps",
                              ),
                              value: selectedSteps,
                              items: _steps.map((step) {
                                return DropdownMenuItem<int>(
                                  value: step,
                                  child: Text(step.toString()),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedSteps = value!;
                                  _initializeControllers();
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return "Please select approval steps";
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ))
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (selectedSteps != null)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Table(
                          border: TableBorder.all(color: Colors.grey),
                          columnWidths: const {
                            0: FlexColumnWidth(1),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(2),
                            3: FlexColumnWidth(2),
                          },
                          children: [
                            const TableRow(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Step No',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Approvers',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Maximum Amount',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Approver Email',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            ...List.generate(selectedSteps!, (index) {
                              return TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text((index + 1).toString()),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      controller: approverControllers[index],
                                      onChanged: (value) => setState(() {}),
                                      decoration: const InputDecoration(
                                        // hintText: 'Enter Approver',
                                        border: OutlineInputBorder(),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey, width: 1.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      controller: maxAmountControllers[index],
                                      decoration: const InputDecoration(
                                        //  hintText: 'Enter Maximum Amount',
                                        border: OutlineInputBorder(),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey,
                                              width: 1.0), // Default border
                                        ),
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
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      controller: emailControllers[index],
                                      decoration: const InputDecoration(
                                        //  hintText: 'Enter Maximum Amount',
                                        border: OutlineInputBorder(),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey,
                                              width: 1.0), // Default border
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
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
    );
  }
}

class approvalDetailPage extends StatefulWidget {
  final ApprovalSetup onSave;
  const approvalDetailPage({
    super.key,
    required this.onSave,
  });

  @override
  State<approvalDetailPage> createState() => _ApprovalDetailState();
}

class _ApprovalDetailState extends State<approvalDetailPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Approval Setup Details"),
        backgroundColor: const Color.fromRGBO(100, 207, 198, 0.855),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow("Flow Name", widget.onSave.FlowName, "Request Type",
                widget.onSave.RequestType),
            const SizedBox(height: 10),
            _buildRow("Description", widget.onSave.Description, "Department",
                widget.onSave.departmentName),
            const SizedBox(height: 10),
            _buildRow("Currency", widget.onSave.Currency, "No Of Steps",
                widget.onSave.No_of_Steps.toString()),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  "Management Approver:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Checkbox(
                    value: widget.onSave.Management.toString() == 'Yes',
                    onChanged: (bool? value) {
                      setState(() {
                        widget.onSave.Management = value == true ? 'Yes' : 'No';
                      });
                    })
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Approval Steps:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Table(
              border: TableBorder.all(color: Colors.grey),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Step No",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Maximum Amount",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Approver Email",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                for (var step in widget.onSave.ApprovalSteps)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text((step.stepNo).toString()),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(step.maxAmount.toString()),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(step.approverEmail),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 40),
            Center(
                child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Back"),
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(
                  fontSize: 15,
                ),
                backgroundColor: Colors.green,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
      String label1, String value1, String label2, String? value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInlineText(label1, value1),
          if (label2.isNotEmpty) _buildInlineText(label2, value2 ?? ""),
        ],
      ),
    );
  }

  Widget _buildInlineText(String label, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: RichText(
          text: TextSpan(
              style: const TextStyle(fontSize: 16, color: Colors.black),
              children: [
                TextSpan(
                    text: "$label:",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: value),
              ]),
        ),
      ),
    );
  }
}
