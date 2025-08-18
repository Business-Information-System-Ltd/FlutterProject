import 'package:advance_budget_request_system/views/advancerequestlist.dart';
import 'package:flutter/material.dart';
import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:advance_budget_request_system/views/data.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:advance_budget_request_system/views/projecttable.dart';
import 'package:http/http.dart' as http;

class AdvanceRequestForm extends StatefulWidget {
  final bool readOnly;
  final bool isViewMode;
  final String advanceId;
  final Advance? advance;
  final Map<String, dynamic>? initialRequestData;

  const AdvanceRequestForm(
      {Key? key,
      this.readOnly = false,
      this.initialRequestData,
      this.advance,
      this.isViewMode = false,
      required this.advanceId})
      : super(key: key);

  @override
  State<AdvanceRequestForm> createState() => _AdvanceRequestFormState();
}

class _AdvanceRequestFormState extends State<AdvanceRequestForm> {
  final _formKey = GlobalKey<FormState>();
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
    _initializeForm();
    super.initState();
    if (!widget.isViewMode) {
      _requestDate.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
  }

  void _initializeForm() {
    if (widget.isViewMode) {
      final advance = widget.advance!;
      _requestNo.text = advance.requestNo ?? '';
      _requestType.text = advance.requestType ?? '';
      _requestDate.text = DateFormat('yyyy-MM-dd').format(advance.date);
      _requestAmount.text = advance.requestAmount.toString();
      _requestCode.text = advance.requestCode ?? '';
      _requester.text = advance.requester ?? '';
      _selectedCurrency = advance.currency ?? 'MMK';
      _department.text = advance.departmentName ?? '';
      _requestPurpose.text = advance.purpose ?? '';
    }
  }

  final List<PlutoColumn> _columns = [
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

  final ApiService apiService = ApiService();

  Future<String> generateStringAdvanceID() async {
    try {
      List<Advance> existingAdvances =
          await ApiService().fetchAdvanceRequests();

      if (existingAdvances.isEmpty) {
        return "1";
      }

      int maxId = existingAdvances
          .map((b) => int.tryParse(b.id.toString()) ?? 0)
          .reduce((a, b) => a > b ? a : b);
      return (maxId + 1).toString();
    } catch (e) {
      print("Error generating string Advance ID: $e");
      throw Exception('Failed to generate Advance ID');
    }
  }

  Future<void> _submitForm() async {
    if(_formKey.currentState!.validate()){
    String newId = widget.isViewMode
        ? widget.advance!.id
        : await generateStringAdvanceID();
    Advance newAdvance = Advance(
        id: newId,
        date: DateFormat('yyyy-MM-dd').parse(_requestDate.text),
        requestNo: _requestNo.text,
        requestCode: _requestCode.text,
        requestDes: '',
        requestType: _requestType.text,
        requestAmount: double.tryParse(_requestAmount.text) ?? 0,
        currency: _selectedCurrency!,
        requester: _requester.text,
        departmentName: _department.text,
        approvedAmount: 0,
        purpose: _requestPurpose.text,
        status: 'Pending');

    try {
      await ApiService().postAdvanceRequests(newAdvance);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Advance Request for operation can be created successfully')),
      );
    } catch (e) {
      print("Fail to insert advance: $e");
    }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isViewMode
            ? 'Operation Advance Request Details'
            : 'Add Operation Advance Request Form'),
      ),
      body: Center(
        child: Container(
          color: const Color.fromRGBO(255, 255, 255, 1),
          width: MediaQuery.of(context).size.width * 0.6,
          child: Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: SingleChildScrollView(
                  // padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            widget.isViewMode
                                ? 'Operation Advance Request Details'
                                : 'Add Operation Advance Request Form',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // const SizedBox(width: 14),
                            Expanded(
                              child: _buildtextField(
                                controller: _requestNo,
                                labelText: 'Request No',
                                readOnly: widget.isViewMode,
                                // keyboardType: TextInputType.number,
                                // padding: EdgeInsets.fromLTRB(1, 10, 10, 10),
                              ),
                            ),
                            const SizedBox(width: 15),
                    
                            Expanded(
                              child: _buildtextField(
                                controller: _requestType,
                                labelText: 'Request Type',
                                readOnly: true,
                                // keyboardType: TextInputType.number,
                                // padding: EdgeInsets.fromLTRB(1, 10, 10, 10),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildtextField(
                                controller: _requestDate,
                                labelText: 'Request Date',
                                // keyboardType: TextInputType.number,
                                readOnly: true,
                                //padding: EdgeInsets.fromLTRB(1, 10, 10, 10),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: _buildtextField(
                                controller: _requestCode,
                                labelText: 'Request Code',
                                readOnly: widget.isViewMode,
                                // keyboardType: TextInputType.number,
                                // padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildtextField(
                                controller: _department,
                                labelText: 'Department',
                                readOnly: widget.isViewMode,
                                // keyboardType: TextInputType.number,
                                // padding: const EdgeInsets.fromLTRB(10, 10, 46, 10),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 0),
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: _buildtextField(
                                controller: _requestAmount,
                                labelText: 'Request Amount',
                                readOnly: widget.isViewMode,
                                // keyboardType: TextInputType.number,
                                // padding: const EdgeInsets.fromLTRB(10, 10, 46, 10),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedCurrency,
                                decoration:  InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(2.0),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 2, vertical: 3),
                                ),
                                items: ['MMK', 'USD']
                                    .map((currency) => DropdownMenuItem(
                                          value: currency,
                                          child: Text(
                                            currency,
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                        ))
                                    .toList(),
                                onChanged: widget.isViewMode
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _selectedCurrency = value ?? 'MMK';
                                        });
                                      },
                                validator: (value) => value?.isEmpty ?? true
                                    ? 'Currency is required'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 0),
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // const SizedBox(width: 15),
                            Expanded(
                              child: _buildtextField(
                                controller: _attachFilesController,
                                labelText: 'Attach File',
                                readOnly: widget.isViewMode,
                                // padding: const EdgeInsets.fromLTRB(50, 10, 24, 10),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildtextField(
                                controller: _requester,
                                labelText: 'Requester',
                                readOnly: widget.isViewMode,
                                // keyboardType: TextInputType.number,
                                // padding: const EdgeInsets.fromLTRB(25, 10, 46, 10),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 13),
                        Row(
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(20, 0, 40, 0),
                                child: TextFormField(
                                  controller: _requestPurpose,
                                  maxLines: 2,
                                  readOnly: widget.isViewMode,
                                  decoration: const InputDecoration(
                                      labelText: 'Request Purpose',
                                      fillColor: Colors.white,
                                      filled: true,
                                      border: OutlineInputBorder(
                                          // borderSide: BorderSide.none,
                                          )),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
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
                        if (!widget.isViewMode)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB2C8A8),
                                  minimumSize: const Size(120, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Submit',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB2C8A8),
                                  minimumSize: const Size(120, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Clear',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }

  Widget _buildtextField({
    required TextEditingController controller,
    required String labelText,
    required bool readOnly, 
    TextInputType keyboardType = TextInputType.text,
    EdgeInsets padding = const EdgeInsets.all(8),
  }) {
    return Padding(
      padding: padding,
      child: TextFormField(
        controller: controller,
        // readOnly: widget.readOnly,
        keyboardType: keyboardType,
        readOnly:readOnly,
        style: const TextStyle(fontSize: 14),

        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(fontSize: 14),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2.0),
          ),
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
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2.0),
            // borderSide: BorderSide.none,
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
