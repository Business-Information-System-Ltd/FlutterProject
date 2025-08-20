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

  List<PlutoColumn> _columns=[];
  List<PlutoRow> _rows=[];
  List<PlutoRow> _pagedRows=[];
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

  final requestTypes = ["Project", "Trip", "Operation"];
  final currencies = ["USD", "MMK"];
  final departments = ["HR", "Finance", "IT"];
  final steps = [1, 2, 3, 4, 5];

  String? selectedApproverEmail;
  final approverEmails = [];

  void _clearForm() {
    flowNameController.clear();
    descriptionController.clear();
    selectedRequestType;
    selectedCurrency;
    selectedDepartment;
  }

  Future<void> _submitForm() async {}

  @override
  void initState() {
    super.initState();
    _isLoading = false;
     _columns = _buildColumns();
    _rows = [];
  }

List<PlutoColumn> _buildColumns(){
  return [
   PlutoColumn(
        title: 'Step No',
        field: 'step_no',
        type: PlutoColumnType.number(),
        readOnly: true,
        width: 100,
      ),
      PlutoColumn(
        title: "Approver's Email",
        field: 'approver_email',
        type: PlutoColumnType.text(),
        width: 200,
      ),
      PlutoColumn(
        title: 'Approver Name',
        field: 'approver_name',
        type: PlutoColumnType.text(),
        width: 200,

      ),
      PlutoColumn(
        title: 'Maximum Amount',
        field: 'max_amount',
        type: PlutoColumnType.number(),
        width: 200,
      ),
     PlutoColumn(
      title: "Action", 
      field: "Action",
      textAlign: PlutoColumnTextAlign.center,
      titleTextAlign: PlutoColumnTextAlign.center,
       type: PlutoColumnType.text(),
       enableEditingMode: false,
       width: 150,
       renderer: (rendererContext) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed:(){}, 
              icon: Icon(Icons.edit, color: Colors.blue),
              ),
              IconButton(
                onPressed: (){},
                 icon: Icon(Icons.delete,color: Colors.red),
                 ),
                 IconButton(
                  onPressed: (){},
                   icon: Icon(Icons.more_horiz, color: Colors.black),
                   ),
          ],
        );
       },
       ),
  ];
  
}
List <PlutoRow> _buildRows (List <Map<String, String>> approverlist){
  return approverlist.map((data){
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
                              child: Text("Add Approval Setup Form",
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
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 3.0),
                  ),
                ),
                SizedBox(width: 5.0),
                Expanded(
                  child: _buildTextField(
                    controller: descriptionController,
                    labelText: 'Description',
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 3.0),
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
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
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
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
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
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
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
                Expanded(
                  child: Padding(
                    
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
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
                          : (val) => 
                          setState((){ approvalSteps = val; _buildRows;}),
                      decoration: InputDecoration(
                        labelText: 'Approval Steps',
                        fillColor: Colors.grey[200],
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      disabledHint: approvalSteps != null ? Text("$approvalSteps") : null,
                    ),
                  ),
                ),
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
                 const SizedBox(height: 10),
             
           
          ],
        ),
        SizedBox(height: 10),
         Container(
               padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 1),
              height: 170,
              width: MediaQuery.of(context).size.width ,
             
              child: PlutoGrid(
                columns: _columns,
                rows: _rows,
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  _stateManager = event.stateManager;
                  _stateManager!.setShowColumnFilter(false);
                },
                configuration: PlutoGridConfiguration(
                  
                  style: PlutoGridStyleConfig(
                    columnHeight: 30,
                    oddRowColor: Colors.blue[50],
                    rowHeight: 35,
                    activatedColor: Colors.lightBlueAccent.withOpacity(0.2),
                  ),
                ),
                mode: PlutoGridMode.readOnly,
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
}
