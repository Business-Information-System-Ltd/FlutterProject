import 'package:flutter/material.dart';

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
                  child: _buildDropdownField(
                    value: approvalSteps.toString(),
                    items: steps.map((e) => e.toString()).toList(),
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
                  child: DropdownButtonFormField<int>(
                    decoration: InputDecoration(labelText: "Approval Steps"),
                    value: approvalSteps,
                    items: List.generate(10, (i) => i + 1)
                        .map((e) =>
                            DropdownMenuItem(value: e, child: Text("$e")))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => approvalSteps = val ?? 1),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Row(
                    children: [
                      Checkbox(
                        value: isManagementApprover,
                        onChanged: (val) =>
                            setState(() => isManagementApprover = val ?? false),
                      ),
                      Text("Management Approver"),
                    ],
                  ),
                ),
              ],
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
