import 'package:advance_budget_request_system/views/advancerequestlist.dart';
import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:advance_budget_request_system/views/cashpaymentEntry.dart';
import 'package:advance_budget_request_system/views/data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:advance_budget_request_system/views/advanceRequestProjectTripTable.dart.dart';
import 'package:pluto_grid/pluto_grid.dart';

class AddAdvanceRequestForm extends StatefulWidget {
  final String? requestNo;
  final String? requestDate;
  final String? projectCode;
  final String? tripCode;
  final String? description;
  final String? totalAmount;
  final String? currency;
  final String? department;
  final String? type;
  final String? requestType;
  final bool isViewMode;
  final String advanceId;
  final Advance? advance;
  final Map<String, dynamic>? tripData;

  const AddAdvanceRequestForm(
      {Key? key,
      this.requestNo,
      this.requestDate,
      this.projectCode,
      this.tripCode,
      this.description,
      this.totalAmount,
      this.currency,
      this.department,
      this.type,
      this.requestType,
      this.tripData,
      this.advance,
      required this.advanceId,
      this.isViewMode = false})
      : super(key: key);

  @override
  State<AddAdvanceRequestForm> createState() => _AddAdvanceRequestFormState();
}

class _AddAdvanceRequestFormState extends State<AddAdvanceRequestForm> {
  final TextEditingController _requestNo = TextEditingController();
  final TextEditingController _requestType = TextEditingController();
  final TextEditingController _requestDate = TextEditingController();
  final TextEditingController _requestCode = TextEditingController();
  final TextEditingController _department = TextEditingController();
  final TextEditingController _requestAmount = TextEditingController();
  final TextEditingController _requester = TextEditingController();
  final TextEditingController _requestPurpose = TextEditingController();
  final TextEditingController _attachFilesController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController();
  final TextEditingController _roundTripController = TextEditingController();
  final TextEditingController _sourceTripController = TextEditingController();
  final TextEditingController _destinationTripController =
      TextEditingController();
  final TextEditingController _deptNameTripController = TextEditingController();
  final TextEditingController _depatureTripController = TextEditingController();
  final TextEditingController _returnTripController = TextEditingController();
  final TextEditingController _expenditureTripController =
      TextEditingController();

  String? _selectedCurrency = 'MMK';
  bool _isProject = true;
  bool _formSubmitted=false;
  bool _showValidationErrors=false;

  @override
  void initState() {
    super.initState();
    _initializeForm();

    print('Received trip data: ${widget.tripData}');
    _isProject = widget.projectCode != null ||
        (widget.requestType ?? '').toLowerCase() == 'project';
    _requestType.text =
        widget.requestType ?? widget.type ?? (_isProject ? 'Project' : 'Trip');
    _requestDate.text =
        widget.requestDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    _requestNo.text = widget.requestNo ?? '';
    _requestCode.text = widget.projectCode ?? widget.tripCode ?? '';
    _descriptionController.text = widget.description ?? '';
    _totalAmountController.text = widget.totalAmount ?? '';
    _selectedCurrency = widget.currency ?? 'MMK';
    _currencyController.text = _selectedCurrency!;
    _department.text = widget.department ?? '';

    if (widget.tripData != null && !_isProject) {
      _roundTripController.text =
          widget.tripData!['roundTrip']?.toString() ?? '';
      _sourceTripController.text = widget.tripData!['source']?.toString() ?? '';
      _destinationTripController.text =
          widget.tripData!['destination']?.toString() ?? '';
      _deptNameTripController.text =
          widget.tripData!['deptName']?.toString() ?? '';
      _depatureTripController.text =
          widget.tripData!['departure']?.toString() ?? '';
      _returnTripController.text = widget.tripData!['return']?.toString() ?? '';
      _expenditureTripController.text =
          widget.tripData!['expenditure']?.toString() ?? '';

      if (_department.text.isEmpty) {
        _department.text = widget.tripData!['deptName']?.toString() ?? '';
      }
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
      _descriptionController.text = advance.requestDes ?? '';
      _requester.text = advance.requester ?? '';
      _currencyController.text = advance.currency ?? 'MMK';
      _department.text = advance.departmentName ?? '';
      _requestPurpose.text = advance.purpose ?? '';
      // _approvedAmountController.text=advance.approvedAmount??0;
    }
  }

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

  // Future<void> _submitFroms() async {
  //   final requestNoError = _validateRequired(_requestNo.text, 'request number');
  //   final requestTypeError =
  //       _validateRequired(_requestType.text, 'request type');
  //   final requestDateError = _validateDate(_requestDate.text);
  //   final requestCodeError = _validateRequestCode(_requestCode.text);
  //   final amountError = _validateAmount(_requestAmount.text);
  //   final requesterError = _validateRequired(_requester.text, 'requester name');
  //   final purposeError = _validateRequired(_requestPurpose.text, 'purpose');

  //   // For trip-specific fields
  //   if (!_isProject) {
  //     final sourceError =
  //         _validateRequired(_sourceTripController.text, 'source');
  //     final destinationError =
  //         _validateRequired(_destinationTripController.text, 'destination');
  //     final departureError = _validateDate(_depatureTripController.text);
  //     final returnError = _validateDate(_returnTripController.text);

  //     if (sourceError != null ||
  //         destinationError != null ||
  //         departureError != null ||
  //         returnError != null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Please fill all required trip fields')),
  //       );
  //       return;
  //     }
  //   }

  //   if (requestNoError != null ||
  //       requestTypeError != null ||
  //       requestDateError != null ||
  //       requestCodeError != null ||
  //       amountError != null ||
  //       requesterError != null ||
  //       purposeError != null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please fill all required fields')),
  //     );
  //     return;
  //   }

  //   String newId = widget.isViewMode
  //       ? widget.advance!.id
  //       : await generateStringAdvanceID();

  //   Advance newAdvance = Advance(
  //       id: newId,
  //       date: DateFormat('yyyy-MM-dd').parse(_requestDate.text),
  //       requestNo: _requestNo.text,
  //       requestCode: _requestCode.text,
  //       requestDes: _descriptionController.text,
  //       requestType: _requestType.text,
  //       requestAmount: double.tryParse(_requestAmount.text) ?? 0,
  //       currency: _currencyController.text,
  //       requester: _requester.text,
  //       departmentName: _department.text,
  //       approvedAmount: 0,
  //       purpose: _requestPurpose.text,
  //       status: 'Pending');

  //   try {
  //     await ApiService().postAdvanceRequests(newAdvance);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //           content: Text('Advance request can be created successfully')),
  //     );
  //     Navigator.of(context).pushReplacement(
  //         MaterialPageRoute(builder: (context) => AdvanceRequestPage()));
  //   } catch (e) {
  //     print("Fail to insert trips: $e");
  //   }
  // }
  
    Future<void> _submitFroms() async {
    setState(() {
    _showValidationErrors = true; 
  });
  
    final requestNoError = _validateRequired(_requestNo.text, 'request number');
    final requestTypeError = _validateRequired(_requestType.text, 'request type');
    final requestDateError = _validateDate(_requestDate.text);
    final requestCodeError = _validateRequestCode(_requestCode.text);
    final amountError = _validateAmount(_requestAmount.text);
    final requesterError = _validateRequired(_requester.text, 'requester name');
    // final purposeError = _validateRequired(_requestPurpose.text, 'purpose');
     final purposeError = _validatePurpose(_requestPurpose.text);
     if (requestNoError != null ||
      requestTypeError != null ||
      requestDateError != null ||
      requestCodeError != null ||
      amountError != null ||
      requesterError != null ||
      purposeError != null) {
    // Keep errors showing
    return;
  }

    if (!_isProject) {
      final sourceError = _validateRequired(_sourceTripController.text, 'source');
      final destinationError = _validateRequired(_destinationTripController.text, 'destination');
      final departureError = _validateDate(_depatureTripController.text);
      final returnError = _validateDate(_returnTripController.text);

      if (sourceError != null || destinationError != null || departureError != null || returnError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required trip fields')),
        );
        return;
      }
    }

    if (requestNoError != null ||
        requestTypeError != null ||
        requestDateError != null ||
        requestCodeError != null ||
        amountError != null ||
        requesterError != null ||
        purposeError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
      setState(() {
    _showValidationErrors = false;
  });

    String newId = widget.isViewMode ? widget.advance!.id : await generateStringAdvanceID();

    Advance newAdvance = Advance(
        id: newId,
        date: DateFormat('yyyy-MM-dd').parse(_requestDate.text),
        requestNo: _requestNo.text,
        requestCode: _requestCode.text,
        requestDes: _descriptionController.text,
        requestType: _requestType.text,
        requestAmount: double.tryParse(_requestAmount.text) ?? 0,
        currency: _currencyController.text,
        requester: _requester.text,
        departmentName: _department.text,
        approvedAmount: 0,
        purpose: _requestPurpose.text,
        status: 'Pending');

    try {
      await ApiService().postAdvanceRequests(newAdvance);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Advance request can be created successfully')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AdvanceRequestPage()));
    } catch (e) {
      print("Fail to insert trips: $e");
    }
  }

  void _submitForm() async {
    // Validate required fields
    if (_requestNo.text.isEmpty ||
        _requestAmount.text.isEmpty ||
        _requester.text.isEmpty ||
        _requestPurpose.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    try {} catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _requestNo.dispose();
    _requestType.dispose();
    _requestDate.dispose();
    _requestCode.dispose();
    _department.dispose();
    _requestAmount.dispose();
    _requester.dispose();
    _requestPurpose.dispose();
    _attachFilesController.dispose();
    _descriptionController.dispose();
    _totalAmountController.dispose();
    _currencyController.dispose();
    _roundTripController.dispose();
    _sourceTripController.dispose();
    _destinationTripController.dispose();
    _deptNameTripController.dispose();
    _depatureTripController.dispose();
    _returnTripController.dispose();
    _expenditureTripController.dispose();
    super.dispose();
  }

  void _clearForm() {
    setState(() {
      _requestNo.clear();
      _requestDate.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _requestCode.clear();
      _department.clear();
      _requestAmount.clear();
      _requester.clear();
      _requestPurpose.clear();
      _attachFilesController.clear();
      // _descriptionController.clear();
      _totalAmountController.clear();
      _currencyController.text = 'MMK';
      _selectedCurrency = 'MMK';
       _formSubmitted = false;
      

      // Reset the form type
      _isProject = widget.projectCode != null ||
          (widget.requestType ?? '').toLowerCase() == 'project';
      _requestType.text = widget.requestType ??
          widget.type ??
          (_isProject ? 'Project' : 'Trip');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade100,
        title: Text(widget.isViewMode
            ? 'Advance Request Details'
            : 'Add Advance Request Form'),
      ),
      body: Center(
        child: Container(
          color: const Color.fromRGBO(255, 255, 255, 1),
          width: MediaQuery.of(context).size.width * 0.5,
          child: Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: SingleChildScrollView(
                  // padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          widget.isViewMode
                              ? 'Advance Request Details'
                              : 'Add Advance Request Form',
                          // ignore: prefer_const_constructors
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTopFormFields(),
                      const SizedBox(height: 5),
                      const SizedBox(height: 10),
                      _isProject ? _buildProjectDetails() : _buildTripDetails(),
                      const SizedBox(height: 15),
                      _buildBottomFormFields(),
                      const SizedBox(height: 20),
                      if (!widget.isViewMode) _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopFormFields() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: _buildtextField(
            readOnly: widget.isViewMode,
            controller: _requestNo,
            labelText: 'Request No',
            validator: (value) => _validateRequired(value, 'request number'),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildtextField(
            controller: _requestType,
            labelText: 'Request Type',
            readOnly: true,
             validator: (value) => _validateRequired(value, 'request type'),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildtextField(
            controller: _requestDate,
            labelText: 'Request Date',
            readOnly: true,
          ),
        ),
      ],
    );
  }

  Widget _buildProjectDetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 650,
          // height: 226,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(242, 235, 235, 1),
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Project Details',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildProjecttextInsideField(
                      controller: _requestCode,
                      labelText: 'Project Code',
                      // padding: const EdgeInsets.fromLTRB(20, 1, 60, 1),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildProjecttextInsideField(
                      controller: _requestDate,
                      labelText: 'Requested Date',
                      // padding: const EdgeInsets.fromLTRB(15, 1, 60, 1),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: TextField(
                        controller: _descriptionController,
                        maxLines: 1,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          fillColor: Color.fromRGBO(217, 217, 217, 1),
                          filled: true,
                          border: OutlineInputBorder(
                              // borderSide: BorderSide.none,
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildProjecttextInsideField(
                          controller: _totalAmountController,
                          labelText: 'Total Amount',

                          // padding: const EdgeInsets.fromLTRB(15, 2, 50, 2),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildProjecttextInsideField(
                          controller: _currencyController,
                          labelText: 'Currency',
                          // padding: const EdgeInsets.fromLTRB(15, 2, 50, 2),
                        ),

                        // _buildDropdownField(
                        //   value: _selectedCurrency,
                        //   items: const ['MMK', 'USD'],
                        //   labelText: 'Currency',
                        //   onChanged: (String? newValue) {
                        //     setState(() {
                        //       _selectedCurrency = newValue;
                        //       _currencyController.text = newValue ?? 'MMK';
                        //     });
                        //   },
                        // ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildProjecttextInsideField(
                          controller: _department,
                          labelText: 'Department',
                          readOnly: widget.isViewMode,
                          // padding: const EdgeInsets.fromLTRB(15, 2, 60, 2),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildTripDetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 650,
          height: 350,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(242, 235, 235, 1),
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Trip Details',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildProjecttextInsideField(
                      controller: _requestCode,
                      labelText: 'Trip Code',
                      // padding: const EdgeInsets.fromLTRB(43, 1, 60, 1),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildProjecttextInsideField(
                      controller: _requestDate,
                      labelText: 'Requested Date',
                      // padding: const EdgeInsets.fromLTRB(43, 1, 60, 1),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: TextField(
                        controller: _descriptionController,
                        maxLines: 1,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          fillColor: Color.fromRGBO(217, 217, 217, 1),
                          filled: true,
                          border: OutlineInputBorder(
                              // borderSide: BorderSide.none,
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: _buildTriptextInsideField(
                    controller: _roundTripController,
                    labelText: 'Round Trip',
                    // padding: const EdgeInsets.fromLTRB(35, 2, 50, 2),
                  )),
                  const SizedBox(width: 15),
                  Expanded(
                      child: _buildTriptextInsideField(
                    controller: _sourceTripController,
                    labelText: 'Source',
                    // padding: const EdgeInsets.fromLTRB(35, 2, 50, 2),
                  )),
                  const SizedBox(width: 15),
                  Expanded(
                      child: _buildTriptextInsideField(
                    controller: _destinationTripController,
                    labelText: 'Destination',
                    // padding: const EdgeInsets.fromLTRB(35, 2, 60, 2),
                  ))
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: _buildTriptextInsideField(
                    controller: _deptNameTripController,
                    labelText: 'Department Name',
                    // padding: const EdgeInsets.fromLTRB(35, 2, 55, 2),
                  )),
                  const SizedBox(width: 15),
                  Expanded(
                      child: _buildTriptextInsideField(
                    controller: _depatureTripController,
                    labelText: 'Depature',
                    // padding: const EdgeInsets.fromLTRB(15, 2, 75, 2),
                  )),
                  const SizedBox(width: 15),
                  Expanded(
                      child: _buildTriptextInsideField(
                    controller: _returnTripController,
                    labelText: 'Return',
                    // padding: const EdgeInsets.fromLTRB(43, 2, 60, 2),
                  ))
                ],
              ),
              const SizedBox(height: 10),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildProjecttextInsideField(
                          controller: _totalAmountController,
                          labelText: 'Total Amount',

                          // padding: const EdgeInsets.fromLTRB(15, 2, 60, 2),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                          child: _buildTriptextInsideField(
                        controller: _currencyController,
                        labelText: 'Currency',
                      )
                          // _buildDropdownField(
                          //   value: _selectedCurrency,
                          //   items: const ['MMK', 'USD'],
                          //   labelText: 'Currency',
                          //   // padding: const EdgeInsets.fromLTRB(15, 2, 60, 2),
                          //   onChanged: (String? newValue) {
                          //     setState(() {
                          //       _selectedCurrency = newValue;
                          //       _currencyController.text = newValue ?? 'MMK';
                          //     });
                          //   },
                          // ),
                          ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildProjecttextInsideField(
                          controller: _expenditureTripController,
                          labelText: 'Expenditure',
                          // padding: const EdgeInsets.fromLTRB(25, 2, 60, 2),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildBottomFormFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildtextField(
                controller: _requestAmount,
                labelText: 'Request Amount',
                readOnly: widget.isViewMode,
                keyboardType: TextInputType.number,
                validator: _validateAmount,
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
                child: _buildtextField(
              controller: _requester,
              readOnly: widget.isViewMode,
              labelText: 'Requester',
              validator: (value) => _validateRequired(value, 'requester name'),
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            ))
          ],
        ),
        const SizedBox(height: 10),
        Row(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: _buildtextField(
                readOnly: widget.isViewMode,
                controller: _attachFilesController,
                labelText: 'Attach File',
                // padding: const EdgeInsets.fromLTRB(54, 1, 525, 1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: TextFormField(
                  controller: _requestPurpose,
                  readOnly: widget.isViewMode,
                  validator: _validatePurpose,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      fillColor: Color.fromRGBO(217, 217, 217, 1),
                      filled: true,
                      labelText: 'Request Purpose',

                      border: OutlineInputBorder(
                          // borderSide: BorderSide.none,
                          )),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _submitFroms,
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
          onPressed: _clearForm,
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
    );
  }

  // Widget _buildtextField({
  //   required TextEditingController controller,
  //   required String labelText,
  //   required readOnly,
  //   TextInputType keyboardType = TextInputType.text,
  //   EdgeInsets padding = const EdgeInsets.all(0),
  //   TextAlign textAlign = TextAlign.left,
  //   String? Function(String?)? validator,
  // }) {
  //   String? error;
  //   if (validator != null) {
  //     error = validator(controller.text);
  //   }
  //   return Padding(
  //     padding: padding,
  //     child: TextField(
  //       controller: controller,
  //       readOnly: readOnly,
  //       keyboardType: keyboardType,
  //       style: const TextStyle(fontSize: 14),
  //       textAlign: textAlign,
  //       decoration: InputDecoration(
  //         labelText: labelText,
  //         fillColor: const Color.fromRGBO(217, 217, 217, 1),
  //         filled: true,
  //         border: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(2.0),
  //           // borderSide: BorderSide.none,
  //         ),

  //       ),
  //     ),
  //   );
  // }
  Widget _buildtextField({
    required TextEditingController controller,
    required String labelText,
    required bool readOnly,
    TextInputType keyboardType = TextInputType.text,
    EdgeInsets padding = const EdgeInsets.all(0),
    TextAlign textAlign = TextAlign.left,
    String? Function(String?)? validator,
  }) {
    String? error;
    if (validator != null) {
      error = validator(controller.text);
    }

    return Padding(
      padding: padding,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14),
        textAlign: textAlign,
        decoration: InputDecoration(
          labelText: labelText,
          fillColor: const Color.fromRGBO(217, 217, 217, 1),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2.0),
          ),
          errorText: error,
          errorStyle: const TextStyle(fontSize: 12),
        ),
        onChanged: (value) {
          if (validator != null) {
            setState(() {}); 
          }
        },
      ),
    );
  }

  Widget _buildProjecttextInsideField({
    required TextEditingController controller,
    required String labelText,
    bool readOnly = true,
    TextInputType keyboardType = TextInputType.text,
    EdgeInsets padding = const EdgeInsets.all(0),
    TextAlign textAlign = TextAlign.left,
  }) {
    return Padding(
      padding: padding,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14),
        textAlign: textAlign,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(fontSize: 14),
          fillColor: const Color.fromRGBO(217, 217, 217, 1),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2.0),
            // borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTriptextInsideField({
    required TextEditingController controller,
    required String labelText,
    bool readOnly = true,
    TextInputType keyboardType = TextInputType.text,
    EdgeInsets padding = const EdgeInsets.all(0),
    TextAlign textAlign = TextAlign.left,
  }) {
    return Padding(
      padding: padding,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14),
        textAlign: textAlign,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(fontSize: 14),
          fillColor: const Color.fromRGBO(217, 217, 217, 1),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2.0),
            // borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // Validation methods
  String? _validateRequired(String? value, String fieldName) {
     if (!_showValidationErrors) return null;
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  String? _validateAmount(String? value) {
      if (!_showValidationErrors) return null;
    if (value == null || value.isEmpty) {
      return 'Please enter amount';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    if (double.parse(value) <= 0) {
      return 'Amount must be greater than 0';
    }
    return null;
  }

  String? _validateDate(String? value) {
      if (!_showValidationErrors) return null;
    if (value == null || value.isEmpty) {
      return 'Please select a date';
    }
    try {
      DateFormat('yyyy-MM-dd').parse(value);
      return null;
    } catch (e) {
      return 'Invalid date format';
    }
  }

  String? _validateRequestCode(String? value) {
      if (!_showValidationErrors) return null;
    if (value == null || value.isEmpty) {
      return 'Please select a project/trip';
    }
    return null;
  }
  String? _validatePurpose(String? value) {
  if (!_showValidationErrors) return null;
  if (value == null || value.isEmpty) {
    return 'Please enter request purpose';
  }
  if (value.length < 10) {
    return 'Purpose should be at least 10 characters';
  }
  return null;
}

  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required String labelText,
    required ValueChanged<String?> onChanged,
    EdgeInsets padding = const EdgeInsets.all(0),
  }) {
    return Padding(
      padding: padding,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          fillColor: const Color.fromRGBO(217, 217, 217, 1),
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
