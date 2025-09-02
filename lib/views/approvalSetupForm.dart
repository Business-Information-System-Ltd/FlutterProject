import 'package:advance_budget_request_system/views/data.dart';
import 'package:advance_budget_request_system/views/pagination.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class ApprovalSetup extends StatefulWidget {
  final bool readOnly;
  final bool isEditMode;
  final bool isViewMode;

  ApprovalSetup({
    Key? key,
    this.readOnly = false,
    this.isEditMode = false,
    this.isViewMode = false,
  }) : super(key: key);

  @override
  State<ApprovalSetup> createState() => _ApprovalSetupState();
}

class _ApprovalSetupState extends State<ApprovalSetup> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  List<PlutoColumn> _columns = [];
  List<PlutoRow> _rows = [];
  List<PlutoRow> _pagedRows = [];
  PlutoGridStateManager? _stateManager;

  final flowNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final approverNameController = TextEditingController();
  final maxAmountController = TextEditingController();

  String? selectedRequestType;
  String? selectedCurrency;
  String? selectedDepartment;
  int? approvalSteps;

  bool isManagementApprover = false;
  List<StepData> stepsData = [];
  List<Map<String, dynamic>> allApprovers = [];
  List<String> approverEmails = [
    'age@gmail.com',
    'myo@gmail.com',
    'Idnin@gmail.com'
  ];
  Map<String, String> emailToNameMap = {
    'age@gmail.com': 'age',
    'myo@gmail.com': 'rage',
    'Idnin@gmail.com': 'Idnin'
  };
  final requestTypes = ["Project", "Trip", "Operation"];
  final currencies = ["USD", "MMK"];
  final departments = ["HR", "Finance", "IT"];
  final steps = [1, 2, 3, 4, 5];

  String? selectedApproverEmail;

  @override
  void initState() {
    super.initState();
    _isLoading = false;
    _columns = _buildColumns();
    _rows = [];
  }

  void _clearForm() {
    flowNameController.clear();
    descriptionController.clear();
    selectedRequestType;
    selectedCurrency;
    selectedDepartment;
  }

  Future<void> _submitForm() async {}

  void _initializeSteps(int numberOfSteps) {
    setState(() {
      stepsData = List.generate(
          numberOfSteps,
          (index) => StepData(
              stepNo: index + 1, approvers: [ApproverData(maxAmount: 0)]));
      _updateRows();
    });
  }

  void _syncGridToSteps() {
    if (_stateManager == null) return;

    for (var row in _stateManager!.rows) {
      final stepNo = int.tryParse(row.cells['step_no']?.value.toString() ?? '');
      if (stepNo == null || row.cells['approver_email']?.value == null)
        continue;

      final stepIndex = stepsData.indexWhere((s) => s.stepNo == stepNo);
      if (stepIndex == -1) continue;

      final approverIndex = stepsData[stepIndex].approvers.indexWhere(
            (a) => a.approverEmail == row.cells['approver_email']?.value,
          );

      if (approverIndex != -1) {
        stepsData[stepIndex].approvers[approverIndex]
          ..approverEmail = row.cells['approver_email']?.value
          ..approverName = row.cells['approver_name']?.value
          ..maxAmount = double.tryParse(
                  row.cells['max_amount']?.value.toString() ?? '0') ??
              0;
      }
    }
  }
  


  void _updateRows() {
    final newRows = <PlutoRow>[];

    for (var step in stepsData) {
      for (var approver in step.approvers) {
        newRows.add(PlutoRow(cells: {
          "step_no": PlutoCell(value: step.stepNo),
          "approver_email": PlutoCell(value: approver.approverEmail),
          "approver_name": PlutoCell(value: approver.approverName),
          "max_amount": PlutoCell(value: approver.maxAmount),
          "action": PlutoCell(value: ''),
        }));
      }

      newRows.add(PlutoRow(cells: {
        "step_no": PlutoCell(value: 'add_${step.stepNo}'),
        "approver_email": PlutoCell(value: null),
        "approver_name": PlutoCell(value: null),
        "max_amount": PlutoCell(value: null),
        "action": PlutoCell(value: null),
      }));
    }

    if (_stateManager != null) {
      _stateManager!.removeAllRows();
      _stateManager!.appendRows(newRows);
    }

    setState(() {
      _rows = newRows;
    });
  }

  void _addApprover(int stepNo) {
    setState(() {
      _syncGridToSteps();

      final stepIndex = stepsData.indexWhere((s) => s.stepNo == stepNo);
      if (stepIndex != -1) {
        stepsData[stepIndex].approvers.add(ApproverData(
              approverEmail: null,
              approverName: null,
              maxAmount: 0,
            ));
        _updateRows();
      }
    });
  }




  void _removeApprover(int stepNo, int approverIndex) {
    setState(() {
      _syncGridToSteps();

      final stepIndex = stepsData.indexWhere((s) => s.stepNo == stepNo);
      if (stepIndex != -1 && stepsData[stepIndex].approvers.length > 1) {
        stepsData[stepIndex].approvers.removeAt(approverIndex);
        _updateRows();
      }
    });
  }

  List<PlutoColumn> _buildColumns() {
    return [
      PlutoColumn(
        title: 'Step No',
        field: 'step_no',
        type: PlutoColumnType.text(),
        readOnly: true,
        width: 110,
        renderer: (rendererContext) {
          final value = rendererContext.row.cells['step_no']!.value.toString();

          if (value.startsWith('add_')) {
            final stepNo = int.parse(value.split('_')[1]);
            return ElevatedButton(
              onPressed: () => _addApprover(stepNo),
              child: const Text('Add '),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.black,
              ),
            );
          }

          return Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold));
        },
      ),
      PlutoColumn(
        title: "Approver's Email",
        field: 'approver_email',
        type: PlutoColumnType.text(),
        width: 250,
        renderer: (rendererContext) {
          final stepValue =
              rendererContext.row.cells['step_no']!.value.toString();
          if (stepValue.startsWith('add_')) return Container();

          return DropdownButtonFormField<String>(
            value: rendererContext.row.cells['approver_email']!.value,
            items: approverEmails
                .map((email) =>
                    DropdownMenuItem(value: email, child: Text(email)))
                .toList(),
            onChanged: (newValue) {
              rendererContext.stateManager.changeCellValue(
                rendererContext.row.cells['approver_email']!,
                newValue,
              );

              if (newValue != null && emailToNameMap.containsKey(newValue)) {
                final approverName = emailToNameMap[newValue];

                rendererContext.stateManager.changeCellValue(
                  rendererContext.row.cells['approver_name']!,
                  approverName,
                );

                final stepNo = int.tryParse(
                    rendererContext.row.cells['step_no']!.value.toString());
                if (stepNo != null) {
                  final stepIndex =
                      stepsData.indexWhere((s) => s.stepNo == stepNo);
                  if (stepIndex != -1) {
                    final approverIndex = rendererContext.rowIdx -
                        _rows.indexWhere((r) =>
                            r.cells['step_no']!.value.toString() ==
                            stepNo.toString());

                    if (approverIndex >= 0 &&
                        approverIndex < stepsData[stepIndex].approvers.length) {
                      stepsData[stepIndex]
                          .approvers[approverIndex]
                          .approverEmail = newValue;
                      stepsData[stepIndex]
                          .approvers[approverIndex]
                          .approverName = approverName;
                    }
                  }
                }
              }
            },
            decoration: const InputDecoration(border: InputBorder.none),
          );
        },
      ),
      PlutoColumn(
        title: 'Approver Name',
        field: 'approver_name',
        type: PlutoColumnType.text(),
        width: 180,
        renderer: (rendererContext) {
          final stepValue =
              rendererContext.row.cells['step_no']!.value.toString();
          if (stepValue.startsWith('add_')) return Container();

          return Text(
              rendererContext.row.cells['approver_name']!.value?.toString() ??
                  '');
        },
      ),
      PlutoColumn(
        title: 'Maximum Amount',
        field: 'max_amount',
        type: PlutoColumnType.number(),
        width: 170,
        enableEditingMode: true,
        renderer: (rendererContext) {
          final stepValue =
              rendererContext.row.cells['step_no']!.value.toString();
          if (stepValue.startsWith('add_')) return Container();

          return Text(rendererContext.cell.value?.toString() ?? '');
        },
      ),
      PlutoColumn(
        title: "Action",
        field: "action",
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 145,
        renderer: (rendererContext) {
          final stepValue =
              rendererContext.row.cells['step_no']!.value.toString();
          if (stepValue.startsWith('add_')) return Container();

          final stepNo = int.parse(stepValue);
          final rowIndex = rendererContext.rowIdx;

          int approverIndex = 0;
          for (int i = 0; i < rowIndex; i++) {
            final prevStepValue = _rows[i].cells['step_no']!.value.toString();
            if (!prevStepValue.startsWith('add_') &&
                int.parse(prevStepValue) == stepNo) {
              approverIndex++;
            }
          }

          return Row(
            children: [
              IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {}),
              IconButton(
                onPressed: () => _removeApprover(stepNo, approverIndex),
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              ),
              IconButton(
                  icon: const Icon(Icons.more_horiz), onPressed: () => {}),
            ],
          );
        },
      ),
    ];
  }

  List<PlutoRow> _buildRows(List<Map<String, String>> approverlist) {
    return approverlist.map((data) {
      return PlutoRow(cells: {
        "step_no": PlutoCell(value: data['step_No']),
        "approver_email": PlutoCell(value: data['approver_email']),
        "approver_name": PlutoCell(value: data['approver_name']),
        "max_amount": PlutoCell(value: data['max_amount']),
        "Action": PlutoCell(value: data['']),
      });
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        title: Text(widget.isViewMode
            ? 'Approval Setup Details'
            : widget.isEditMode
                ? 'Edit Approval Setup'
                : 'New Approval Setup Request'),
        actions: widget.isViewMode
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ApprovalSetup(
                          isEditMode: true,
                        ),
                      ),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              "Add Approval Setup Form",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          _buildFormWithSubmit(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildFormWithSubmit() {
    return Column(
      children: [
        _buildFormSection(),
        if (!widget.isViewMode)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                  child: Text(widget.isEditMode ? 'Update' : 'Submit'),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: _clearForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: flowNameController,
                    labelText: 'Flow Name',
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
                  ),
                ),
                SizedBox(width: 5.0),
                Expanded(
                  child: _buildTextField(
                    controller: descriptionController,
                    labelText: 'Description',
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildDropdownField(
                    value: selectedRequestType,
                    items: requestTypes,
                    labelText: 'Request Type',
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedRequestType = newValue;
                      });
                    },
                    readOnly: widget.readOnly,
                  ),
                ),
                SizedBox(width: 5.0),
                Expanded(
                  child: _buildDropdownField(
                    value: selectedCurrency,
                    items: currencies,
                    labelText: 'Currency',
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCurrency = newValue;
                      });
                    },
                    readOnly: widget.readOnly,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: _buildDropdownField(
                    value: selectedDepartment,
                    items: departments,
                    labelText: 'Department',
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDepartment = newValue;
                      });
                    },
                    readOnly: widget.readOnly,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _buildApprovalStepsDropdown(),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    children: [
                      Checkbox(
                        value: isManagementApprover,
                        onChanged: widget.readOnly
                            ? null
                            : (val) => setState(
                                () => isManagementApprover = val ?? false),
                      ),
                      const Text("Management Approver"),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildApprovalTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool readOnly = true,
    TextInputType keyboardType = TextInputType.text,
    EdgeInsets padding = const EdgeInsets.all(8),
  }) {
    return Padding(
      padding: padding,
      child: TextField(
        controller: controller,
        readOnly: widget.readOnly,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(fontSize: 14),
          fillColor: Colors.grey[200],
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey, width: 1),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required String labelText,
    required ValueChanged<String?> onChanged,
    EdgeInsets padding = const EdgeInsets.all(8),
    required bool readOnly,
  }) {
    return Padding(
      padding: padding,
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: readOnly ? null : onChanged,
        decoration: InputDecoration(
          labelText: labelText,
          fillColor: Colors.grey[200],
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey, width: 1),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: items.map<DropdownMenuItem<String>>((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        disabledHint: value != null ? Text(value) : null,
      ),
    );
  }

  Widget _buildApprovalStepsDropdown() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
        child: DropdownButtonFormField<int>(
          value: approvalSteps,
          items: List.generate(5, (i) => i + 1)
              .map((e) => DropdownMenuItem<int>(
                    value: e,
                    child: Text("$e"),
                  ))
              .toList(),
          onChanged: widget.readOnly
              ? null
              : (val) {
                  setState(() {
                    approvalSteps = val;
                  });
                  if (val != null) {
                    _initializeSteps(val);
                  }
                },
          decoration: InputDecoration(
            labelText: 'Approval Steps',
            fillColor: Colors.grey[200],
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey, width: 1),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          disabledHint: approvalSteps != null ? Text("$approvalSteps") : null,
        ),
      ),
    );
  }

  Widget _buildApprovalTable() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      child: Container(
        height: 350,
        child: PlutoGrid(
          columns: _columns,
          rows: _rows,
          onLoaded: (event) {
            _stateManager = event.stateManager;
          },
          onChanged: (PlutoGridOnChangedEvent event) {
            if (event.column.field == 'max_amount') {
              final stepNo = int.tryParse(
                  event.row.cells['step_no']?.value.toString() ?? '');
              final newValue = double.tryParse(event.value.toString()) ?? 0;

              if (stepNo != null) {
                final stepIndex =
                    stepsData.indexWhere((s) => s.stepNo == stepNo);
                if (stepIndex != -1) {
                  final approverIndex =
                      stepsData[stepIndex].approvers.indexWhere(
                            (a) =>
                                a.approverEmail ==
                                event.row.cells['approver_email']?.value,
                          );

                  if (approverIndex != -1) {
                    stepsData[stepIndex].approvers[approverIndex].maxAmount =
                        newValue;
                  }
                }
              }
            }
          },
          configuration: const PlutoGridConfiguration(),
        ),
      ),
    );
  }
}
