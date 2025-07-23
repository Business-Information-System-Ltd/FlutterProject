import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:advance_budget_request_system/views/data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:advance_budget_request_system/views/projecttable.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddProjectForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final bool readOnly;
  final bool isEditMode;
  final int projectId;

  AddProjectForm({
    Key? key,
    this.initialData,
    this.readOnly = false,
    this.isEditMode = false,
    required this.projectId,
  }) : super(key: key);
//const AddProjectForm({super.key,this.initialData});

  @override
  State<AddProjectForm> createState() => _AddProjectFormState();
}

class _AddProjectFormState extends State<AddProjectForm> {
  List<PlutoColumn> _columns = [];
  List<PlutoRow> _rows = [];

  PlutoGridStateManager? _stateManager;
  PlutoGridStateManager? popupGridManager;
  List<Project> projects = [];

  final List<Map<String, String>> _budgetList = [];
  final TextEditingController _projectCodeController = TextEditingController();
  final TextEditingController _projectAdminController = TextEditingController();
  final TextEditingController _projectDateController = TextEditingController();
  final TextEditingController _projectDescriptionController =
      TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _attachFilesController = TextEditingController();

  // String? _selectedDepartment = 'Admin';
  String? _selectedCurrency = 'MMK';
  Future<int> getProjectById() async {
    final prefs = await SharedPreferences.getInstance();
    int lastId = prefs.getInt('last_project_id') ?? 0;
    int newId = lastId + 1;
    await prefs.setInt('last_project_id', newId);
    return newId;
  }

  @override
  void initState() {
    super.initState();
    _projectDateController.text =
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (widget.initialData != null) {
      final data = widget.initialData!;
      _projectCodeController.text = data['projectcode'] ?? '';
      _projectDescriptionController.text = data['description'] ?? '';
      _totalAmountController.text = data['totalamount'] ?? '';
      _selectedCurrency = data['currency'] ?? 'MMK';
      _projectAdminController.text = data['department'] ?? '';
    }
    _initializePlutoGrid();
    _fetchData();
  }

  void _fetchData() async {
    List<Project> project = await ApiService().fetchProjects();
    setState(() {
      projects = project;
    });
  }

  void _initializePlutoGrid() {
    _columns = [
      PlutoColumn(
        title: 'Budget Code',
        field: 'code',
        type: PlutoColumnType.text(),
        readOnly: true,
        width: 183,
      ),
      PlutoColumn(
        title: 'Budget Description',
        field: 'desc',
        type: PlutoColumnType.text(),
        readOnly: true,
        width: 183,
      ),
      PlutoColumn(
        title: 'Action',
        field: 'action',
        type: PlutoColumnType.text(),
        width: 183,
        renderer: (rendererContext) {
          return IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                _budgetList.removeAt(rendererContext.rowIdx);
                _initializePlutoGrid(); // rebuild rows
                _stateManager?.removeRows([rendererContext.row]);
              });
            },
          );
        },
      ),
    ];

    _rows = _budgetList.map((item) {
      return PlutoRow(cells: {
        'code': PlutoCell(value: item['code']),
        'desc': PlutoCell(value: item['desc']),
        'action': PlutoCell(value: 'delete'),
      });
    }).toList();
  }

  void _showPlutoGridDialog() async {
    try {
      List<Budgets> budgetList = await ApiService().fetchBudgets();

      final List<PlutoRow> rows = budgetList.map((item) {
        return PlutoRow(cells: {
          'select': PlutoCell(value: ''),
          'budgetcode': PlutoCell(value: item.budgetCode),
          'budgetdescription': PlutoCell(value: item.budgetDescription),
        });
      }).toList();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Choose Budget Codes'),
            content: SizedBox(
              width: 600,
              height: 300,
              child: PlutoGrid(
                columns: [
                  PlutoColumn(
                    title: '',
                    field: 'select',
                    type: PlutoColumnType.text(),
                    enableRowChecked: true,
                  ),
                  PlutoColumn(
                    title: 'Budget Code',
                    field: 'budgetcode',
                    type: PlutoColumnType.text(),
                  ),
                  PlutoColumn(
                    title: 'Budget Description',
                    field: 'budgetdescription',
                    type: PlutoColumnType.text(),
                  ),
                ],
                rows: rows,
                mode: PlutoGridMode.multiSelect,
                onLoaded: (event) {
                  popupGridManager = event.stateManager;
                  popupGridManager!.setShowColumnFilter(false);
                  popupGridManager!
                      .setSelectingMode(PlutoGridSelectingMode.row);
                },
                configuration: PlutoGridConfiguration(
                  style: PlutoGridStyleConfig(
                    rowHeight: 36,
                    columnHeight: 40,
                  ),
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  if (popupGridManager != null) {
                    for (var row in popupGridManager!.checkedRows) {
                      final code = row.cells['budgetcode']?.value;
                      final desc = row.cells['budgetdescription']?.value;

                      bool alreadyExists =
                          _budgetList.any((item) => item['code'] == code);
                      if (!alreadyExists) {
                        _budgetList.add({'code': code, 'desc': desc});
                      }
                    }

                    _initializePlutoGrid();
                    _stateManager?.removeAllRows();
                    _stateManager?.appendRows(_rows);
                  }

                  Navigator.pop(context);
                },
                child: const Text('Apply'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading budgets: $e')),
      );
    }
  }

  void _clearForm() {
    _projectCodeController.clear();
    _projectAdminController.clear();
    _projectDateController.clear();
    _projectDescriptionController.clear();
    _totalAmountController.clear();
    _attachFilesController.clear();
  }

 Future<void> _submitForm() async {
  if (_totalAmountController.text.isEmpty || 
      double.tryParse(_totalAmountController.text) == null ||
      double.parse(_totalAmountController.text) <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please enter a valid amount greater than zero')),
    );
    return;
  }
    try {
      int newId = await getProjectById();
      final project = Project(
        id: widget.isEditMode? widget.projectId: newId,
        date: DateFormat('yyyy-MM-dd').parse(_projectDateController.text),
        projectCode: _projectCodeController.text,
        projectDescription: _projectDescriptionController.text,
        totalAmount: double.tryParse(_totalAmountController.text) ?? 0,
        currency: _selectedCurrency ?? 'MMK',
        approvedAmount: 0,
        departmentId: 0,
        departmentName: _projectAdminController.text,
        requestable: 'Pending',
        budgets: [],
      );

       if (widget.isEditMode) {
      await ApiService().updateProject(project);
    } else {
      await ApiService().postProjects(project);
    } // new
      // Navigator.pop(context, true); // Return true to indicate success
      Navigator.pop(context, project);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Project submitted successfully')),
      );
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit project: $e')),
      );
    }

   
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      appBar: AppBar(
        title: Text("Project Entry Form"),
      ),
      // body:_rows.isEmpty
      //? const Center(child: CircularProgressIndicator())
      body: Container(
        // decoration: BoxDecoration( ),
        padding: EdgeInsets.fromLTRB(200, 0, 200, 0),
        child: Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.fromLTRB(10, 30, 10, 35),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                // CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Project Form',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _projectCodeController,
                          labelText: 'Project Code',
                          padding:
                              EdgeInsets.symmetric(horizontal: 1, vertical: 3),
                        ),
                      ),
                      SizedBox(width: 5.0),
                      Expanded(
                        child: _buildTextField(
                          controller: _projectAdminController,
                          labelText: 'Department',
                          padding:
                              EdgeInsets.symmetric(horizontal: 1, vertical: 3),
                        ),
                      ),
                      SizedBox(width: 5.0),
                      Expanded(
                        child: _buildTextField(
                          controller: _projectDateController,
                          labelText: 'Requested Date',
                          padding:
                              EdgeInsets.symmetric(horizontal: 1, vertical: 3),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _projectDescriptionController,
                          labelText: 'Enter Project Description',
                          padding:
                              EdgeInsets.symmetric(horizontal: 1, vertical: 3),
                        ),
                      ),
                      SizedBox(width: 5.0),
                      Expanded(
                        child: _buildTextField(
                          controller: _totalAmountController,
                          labelText: 'Enter total Amount',
                          keyboardType: TextInputType.number,
                          
                          padding:
                              EdgeInsets.symmetric(horizontal: 1, vertical: 3),
                        ),
                      ),
                      SizedBox(width: 5.0),
                      Expanded(
                        child: _buildDropdownField(
                          value: _selectedCurrency,
                          items: ['MMK', 'USD'],
                          labelText: 'Currency',
                          padding:
                              EdgeInsets.symmetric(horizontal: 1, vertical: 3),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCurrency = newValue;
                            });
                          },
                          readOnly: widget.readOnly,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 370,
                      height: 55,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(5, 2, 65, 2),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: BorderSide(color: Colors.grey, width: 1),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                          ), //Text remove
                          child: const Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .start, // Text left, Icon right
                              children: [
                                Icon(Icons.attach_file, color: Colors.black),
                                SizedBox(width: 8),
                                Text(
                                  'Attach Files',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ]),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 0),
                  Center(
                    child: SizedBox(
                        width: 200,
                        height: 35,
                        child: ElevatedButton(
                          onPressed: _showPlutoGridDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFB2C8A8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Add Budget Codes',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        )),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 170,
                    width: 550,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        border: Border.all(color: Colors.grey.shade300)),
                    child: PlutoGrid(
                      columns: _columns,
                      rows: _rows,
                      onLoaded: (PlutoGridOnLoadedEvent event) {
                        _stateManager = event.stateManager;
                        _stateManager!.setShowColumnFilter(false);
                      },
                      configuration: PlutoGridConfiguration(
                        style: PlutoGridStyleConfig(
                          oddRowColor: Colors.blue[50],
                          rowHeight: 35,
                          activatedColor:
                              Colors.lightBlueAccent.withOpacity(0.2),
                        ),
                      ),
                      mode: PlutoGridMode.readOnly,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: Text(
                          'Submit',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFB2C8A8),
                          minimumSize: Size(120, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: _clearForm,
                        child: Text(
                          'Clear',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFB2C8A8),
                          minimumSize: Size(120, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool readOnly = true,
    TextInputType keyboardType = TextInputType.text,
    EdgeInsets padding = const EdgeInsets.all(8), // Optional parameter
    //VoidCallback? onAttachPressed,
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
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 16), // internal padding
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
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12), // 👈 Internal padding
        ),
        items: items.map<DropdownMenuItem<String>>((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        // onChanged: onChanged,
        //   onChanged:
        //       readOnly ? null : onChanged, // 👈 disable selection when readOnly
        disabledHint:
            value != null ? Text(value) : null, // 👈 show value if disabled
      ),
    );
  }
}