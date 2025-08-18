import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:advance_budget_request_system/views/data.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pluto_grid/pluto_grid.dart';
import 'package:advance_budget_request_system/views/projecttable.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddProjectForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final bool readOnly;
  final bool isEditMode;
  final bool isViewMode;
  final String projectId;
  final Project? project;

  AddProjectForm({
    Key? key,
    this.initialData,
    this.readOnly = false,
    this.isEditMode = false,
    this.isViewMode = false,
    required this.projectId,
    this.project,
  }) : super(key: key);
//const AddProjectForm({super.key,this.initialData});

  @override
  State<AddProjectForm> createState() => _AddProjectFormState();
}

class _AddProjectFormState extends State<AddProjectForm> {
  List<PlutoColumn> _columns = [];
  List<PlutoRow> _rows = [];
  bool _isLoading = true;
  PlutoGridStateManager? _stateManager;
  PlutoGridStateManager? popupGridManager;
  List<Project> projects = [];
  List<String> attachedFiles = [];
  final List<Map<String, String>> _budgetList = [];
  final TextEditingController _projectCodeController = TextEditingController();
  final TextEditingController _deptController = TextEditingController();
  final TextEditingController _projectDateController = TextEditingController();
  final TextEditingController _requesterNameController =
      TextEditingController();
  final TextEditingController _projectDescriptionController =
      TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _attachFilesController = TextEditingController();

  // String? _selectedDepartment = 'Admin';
  String? _selectedCurrency = 'MMK';
 

Future<String> getProjectById() async {
    try {
      List<Project> existingProject = await ApiService().fetchProjects();

      if (existingProject.isEmpty) {
        return "1";
      }

      int newId = existingProject
          .map((p) => int.tryParse(p.id.toString()) ?? 0)
          .reduce((a, p) => a > p ? a : p);
      return (newId + 1).toString();
    } catch (e) {
      print("Error generating string project ID: $e");
      throw Exception('Failed to generate project ID');
    }
  }


  @override
  void initState() {
    super.initState();
  _initializeForm();
    _initializePlutoGrid();
    _fetchData();
    _isLoading=false;
    _projectDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());

  }

  void _fetchData() async {
    List<Project> project = await ApiService().fetchProjects();
    setState(() {
      projects = project;
    });
  }
  
  void _initializeForm(){
  if (widget.isEditMode || widget.isViewMode){
    final project = widget.project!;
    _projectCodeController.text =project.projectCode;
    _projectDateController.text = DateFormat('yyyy-MM-dd').format(project.date);
    _requesterNameController.text =project.requesterName;
    _deptController.text = project.departmentName;
    _projectDescriptionController.text = project.projectDescription;
    _totalAmountController.text = project.totalAmount.toString();
    _selectedCurrency=project.currency;
    
  }

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
    _deptController.clear();
    _projectDateController.clear();
    _projectDescriptionController.clear();
    _totalAmountController.clear();
    _attachFilesController.clear();
  }

  void _pickFiles() {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.multiple = true;
    uploadInput.accept = '*/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        setState(() {
          attachedFiles = files.map((file) => file.name).toList();
        });

        for (final file in files) {
          print('Selected file: ${file.name}, size: ${file.size}');
        }
      } else {
        print('No files selected.');
      }
    });
  }

  Future<void> _submitForm() async {
    if (_totalAmountController.text.isEmpty ||
        double.tryParse(_totalAmountController.text) == null ||
        double.parse(_totalAmountController.text) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please enter a valid amount greater than zero')),
      );
      return;
    }
    try {
      String newId = widget.isEditMode? widget.projectId: await getProjectById();
      final project = Project(
        id:newId ,
        date: DateFormat('yyyy-MM-dd').parse(_projectDateController.text),
        projectCode: _projectCodeController.text,
        projectDescription: _projectDescriptionController.text,
        requesterName: _requesterNameController.text ?? '',
        totalAmount: double.tryParse(_totalAmountController.text) ?? 0,
        currency: _selectedCurrency ?? 'MMK',
        approvedAmount: 0,
        departmentId: 0,
        departmentName: _deptController.text,
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

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        title: Text(widget.isViewMode
            ? 'Project Details'
            : widget.isEditMode
                ? 'Edit Project'
                : 'New Project Request'),
        actions: widget.isViewMode
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddProjectForm(
                         projectId: widget.projectId,
                          isEditMode: true,
                          project: widget.project,
                         
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
                  color: const Color.fromARGB(255, 77, 218, 246),
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                              child: Text("Add Project Request Form",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold))),
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
            padding: const EdgeInsets.only(top: 10),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _projectCodeController,
                              labelText: 'Project Code',
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 7.0),
                            ),
                          ),
                          SizedBox(width: 5.0),
                          Expanded(
                            child: _buildTextField(
                              controller: _projectDateController,
                              labelText: 'Requested Date',
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 7.0),
                            ),
                          ),
                        ],
                      ),
        
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _requesterNameController,
                              labelText: 'Requester Name',
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 7.0),
                            ),
                          ),
                          SizedBox(width: 5.0),
                          Expanded(
                            child: _buildTextField(
                              controller: _deptController,
                              labelText: 'Department',
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 7.0),
                            ),
                          ),
                        ],
                      ),
        
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _projectDescriptionController,
                              labelText: 'Enter Project Description',
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 7.0),
                            ),
                          ),
                        ],
                      ),
        
                      //]  SizedBox(width: 5.0),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _totalAmountController,
                              labelText: 'Enter Total Amount',
                              keyboardType: TextInputType.number,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 7.0),
                            ),
                          ),
                          SizedBox(width: 5.0),
                          Expanded(
                            child: _buildDropdownField(
                              value: _selectedCurrency,
                              items: ['MMK', 'USD'],
                              labelText: 'Currency',
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 7.0),
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
                      SizedBox(height: 7),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 370,
                          height: 50,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 2, 65, 2),
                            child: ElevatedButton(
                              onPressed: () {
                                if (kIsWeb) {
                                  _pickFiles();
                                } else {
                                  print('File picking is only supported on web.');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  side: const BorderSide(
                                      color: Colors.grey, width: 1),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 7.0),
                                alignment: Alignment.centerLeft,
                              ),
                              child: attachedFiles.isEmpty
                                  ? const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.attach_file,
                                            color: Colors.black),
                                        SizedBox(width: 8),
                                        Text('Attach Files',
                                            style:
                                                TextStyle(color: Colors.black)),
                                      ],
                                    )
                                  : Scrollbar(
                                      thumbVisibility: true,
                                      child: ListView.builder(
                                        itemCount: attachedFiles.length,
                                        itemBuilder: (context, index) {
                                          return Text(
                                            attachedFiles[index],
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            maxLines: 1,
                                          );
                                        },
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
        
                      Center(
                        child: SizedBox(
                            width: 200,
                            height: 45,
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
                                style:
                                    TextStyle(fontSize: 16, color: Colors.black),
                              ),
                            )),
                      ),
                      SizedBox(height: 8),
                      Center(
                        child: Container(
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
                      ),
        
                      
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
              horizontal: 16, vertical: 12), 
        ),
        items: items.map<DropdownMenuItem<String>>((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        disabledHint:
            value != null ? Text(value) : null, 
      ),
    );
  }
}




  