import 'package:flutter/material.dart';
import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:advance_budget_request_system/views/data.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:advance_budget_request_system/views/projecttable.dart';
import 'package:http/http.dart' as http;

class AdvanceRequestForm extends StatefulWidget {
   final bool readOnly;
  final Map<String, dynamic>? initialRequestData;

  const AdvanceRequestForm({
    Key? key,
    this.readOnly = false,
    this.initialRequestData,
  }) : super(key: key);
  

  @override
  State<AdvanceRequestForm> createState() => _AdvanceRequestFormState();
}

class _AdvanceRequestFormState extends State<AdvanceRequestForm> {
  final TextEditingController _requestNo = TextEditingController();
  final TextEditingController _requestDate = TextEditingController();
  final TextEditingController _requestType =
      TextEditingController(text: "Operation");
  final TextEditingController _requestCode = TextEditingController();
  final TextEditingController _department = TextEditingController();
  final TextEditingController _requestAmount = TextEditingController();
  final TextEditingController _requester = TextEditingController();
  final TextEditingController _requestPurpose = TextEditingController();
  final TextEditingController _attachFilesController = TextEditingController();

  //List<PlutoColumn> _columns = [];
  List<PlutoRow> _rows = [];

  PlutoGridStateManager? _stateManager;
  PlutoGridStateManager? popupGridManager;

  String? _selectedCurrency = 'MMK';
  @override
  void initState() {
    super.initState();
    _requestDate.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  List<PlutoColumn> _columns = [
    PlutoColumn(
      title: 'Budget Code',
      field: 'budgetcode',
      type: PlutoColumnType.text(),
      width: 182,
      textAlign: PlutoColumnTextAlign.center, // Center cell content
      titleTextAlign: PlutoColumnTextAlign.center, // Center header
    ),
    PlutoColumn(
      title: 'Budget Description',
      field: 'budgetdes',
      type: PlutoColumnType.text(),
      width: 182,
      textAlign: PlutoColumnTextAlign.center,
      titleTextAlign: PlutoColumnTextAlign.center,
    ),
    PlutoColumn(
      title: 'Action',
      field: 'action',
      type: PlutoColumnType.text(),
      width: 182,
      textAlign: PlutoColumnTextAlign.center,
      titleTextAlign: PlutoColumnTextAlign.center,
    ),
  ];
  
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromRGBO(255, 255, 255, 1),
        padding: const EdgeInsets.fromLTRB(150, 10, 150, 10),
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 30, 10, 30),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Add Advance Request Form',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Request No',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildtextField(
                            controller: _requestNo,
                            labelText: '',
                            keyboardType: TextInputType.number,
                            // padding: EdgeInsets.fromLTRB(1, 10, 10, 10),
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Text(
                          'Request Type',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildtextField(
                            controller: _requestType,
                            labelText: '',
                            keyboardType: TextInputType.number,
                            // padding: EdgeInsets.fromLTRB(1, 10, 10, 10),
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Text(
                          'Request Date',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildtextField(
                            controller: _requestDate,
                            labelText: '',
                            keyboardType: TextInputType.number,
                            readOnly: false,
                            //padding: EdgeInsets.fromLTRB(1, 10, 10, 10),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Request Code',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildtextField(
                            controller: _requestCode,
                            labelText: '',
                            keyboardType: TextInputType.number,
                            padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Text(
                          'Department',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildtextField(
                            controller: _department,
                            labelText: '',
                            keyboardType: TextInputType.number,
                            padding: EdgeInsets.fromLTRB(10, 10, 46, 10),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Request Amount',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildtextField(
                            controller: _requestAmount,
                            labelText: '',
                            keyboardType: TextInputType.number,
                            padding: EdgeInsets.fromLTRB(10, 10, 46, 10),
                          ),
                        ),
                        const SizedBox(width: 15),
                        
                        const Text(
                          'Currency',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildDropdownField(
                            value: _selectedCurrency,
                            items: const ['MMK', 'USD'],
                            labelText: 'Currency',
                            padding: EdgeInsets.fromLTRB(10, 10, 46, 10),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCurrency = newValue;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Attach File', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildtextField(
                            controller: _attachFilesController,
                            labelText: '',
                            padding: EdgeInsets.fromLTRB(50, 10, 24, 10),
                          ),
                        ),
                        SizedBox(width: 15),
                        Text(
                          'Requester',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildtextField(
                            controller: _requester,
                            labelText: '',
                            keyboardType: TextInputType.number,
                            padding: EdgeInsets.fromLTRB(25, 10, 46, 10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 13),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Request Purpose',
                          style: TextStyle(fontSize: 16),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 40, 0),
                            child: TextField(
                              controller: _requestPurpose,
                              maxLines: 2,
                              decoration: InputDecoration(
                                  fillColor:
                                      const Color.fromRGBO(217, 217, 217, 1),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  )),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    Container(
                      height: 150,
                      width: 550,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Center(
                        // Add this Center widget

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

                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
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
                          onPressed: () {},
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
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildtextField({
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
        // readOnly: widget.readOnly,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 14),

        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(fontSize: 14),
          fillColor: const Color.fromRGBO(217, 217, 217, 1),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2.0),
            borderSide: BorderSide.none,
          ),

          contentPadding: const EdgeInsets.symmetric(
              horizontal: 0, vertical: 0), // internal padding
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
  }) {
    return Padding(
      padding: padding,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          // labelText: labelText,
          fillColor: const Color.fromRGBO(217, 217, 217, 1),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2.0),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
        ),
        items: items.map<DropdownMenuItem<String>>((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
