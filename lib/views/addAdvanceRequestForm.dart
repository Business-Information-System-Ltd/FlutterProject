import 'package:advance_budget_request_system/views/advancerequestlist.dart';
import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:advance_budget_request_system/views/cashpaymentEntry.dart';
import 'package:advance_budget_request_system/views/data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:advance_budget_request_system/views/advanceRequestProjectTripTable.dart.dart';

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
  final Map<String, dynamic>? tripData;

  const AddAdvanceRequestForm({
    Key? key,
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
  }) : super(key: key);

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

  @override
  void initState() {
    super.initState();

    print('Received trip data: ${widget.tripData}');
    _isProject = widget.projectCode != null ||
        (widget.requestType ?? '').toLowerCase() == 'project';
    _requestType.text =
        widget.requestType ?? widget.type ?? (_isProject ? 'Project' : 'Trip');
    _requestDate.text =
        widget.requestDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    _requestNo.text = widget.requestNo ?? '';

    // Set the request code based on project or trip
    _requestCode.text = widget.projectCode ?? widget.tripCode ?? '';
    _descriptionController.text = widget.description ?? '';
    _totalAmountController.text = widget.totalAmount ?? '';

    // Initialize currency properly
    _selectedCurrency = widget.currency ?? 'MMK';
    _currencyController.text = _selectedCurrency!;

    // Department should come from either project or trip data
    _department.text = widget.department ?? '';

    // Initialize trip-specific fields if trip data exists
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

      // Make sure department is set from trip data if not already set
      if (_department.text.isEmpty) {
        _department.text = widget.tripData!['deptName']?.toString() ?? '';
      }
    }
  }


  // void _submitForm() async {
  //   // Validate required fields
  //   if (_requestNo.text.isEmpty ||
  //       _requestAmount.text.isEmpty ||
  //       _requester.text.isEmpty ||
  //       _requestPurpose.text.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Please fill all required fields')),
  //     );
  //     return;
  //   }
  //   try {
  //     final newRequest = AdvanceRequest(
  //       requestNo: _requestNo.text,
  //       requestType: _requestType.text,
  //       requestDate: _requestDate.text,
  //       projectCode: _isProject ? _requestCode.text : null,
  //       tripCode: !_isProject ? _requestCode.text : null,
  //       requestAmount: double.parse(_requestAmount.text),
  //       requester: _requester.text,
  //       requestPurpose: _requestPurpose.text,
  //       description: _descriptionController.text,
  //       totalAmount: _totalAmountController.text.isNotEmpty
  //           ? double.parse(_totalAmountController.text)
  //           : null,
  //       currency: _selectedCurrency ?? 'MMK',
  //       department: _department.text,
  //       attachFiles: _attachFilesController.text,
  //     );

  //     final success = await ApiService().postAdvanceRequest(newRequest);

  //     if (success) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Request submitted successfully!')),
  //       );
  //       _clearForm();
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to submit request')),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: ${e.toString()}')),
  //     );
  //   }
  // }

  // final ApiService apiService = ApiService();

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

  Future<void> _submitFroms() async{
    String newId= await generateStringAdvanceID();

    Advance newAdvance= Advance(
      id: newId, 
      date: DateFormat('yyyy-MM-dd').parse(_requestDate.text), 
      requestNo: _requestNo.text, 
      requestCode: _requestCode.text, 
      requestDes: _descriptionController.text, 
      requestType: _requestType.text, 
      requestAmount: double.tryParse(_requestAmount.text)??0, 
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
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>  AdvanceRequestPage()));
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

  try {
    // final newRequested = Advance(
    //   date: DateTime.now(), // Add current date
    //   requestCode: _requestNo.text, // Use requestNo as requestCode or generate one
    //   requestNo: _requestNo.text,
    //   requestType: _requestType.text,
    //   requestDate: _requestDate.text,
    //   requestAmount: double.parse(_requestAmount.text)??0.0,
    //   requester: _requester.text,
    //   requestPurpose: _requestPurpose.text,
    //   purpose: _requestPurpose.text, // Using same as requestPurpose
    //   projectCode: _isProject ? _requestCode.text : null,
    //   tripCode: !_isProject ? _requestCode.text : null,
    //   description: _descriptionController.text,
    //   totalAmount: _totalAmountController.text.isNotEmpty
    //       ? double.tryParse(_totalAmountController.text)
    //       : null,
    //   currency: _selectedCurrency ?? 'MMK',
    //   department: _department.text,
    //   attachFiles: _attachFilesController.text,
    //   roundTrip: _roundTripController.text.isNotEmpty 
    //       ? int.tryParse(_roundTripController.text) 
    //       : null,
    //   source: _sourceTripController.text,
    //   destination: _destinationTripController.text,
    //   departureDate: _depatureTripController.text,
    //   returnDate: _returnTripController.text,
    //   expenditure: _expenditureTripController.text.isNotEmpty
    //       ? int.tryParse(_expenditureTripController.text)
    //       : null,
    // );
    

    // final success = await ApiService().postAdvanceRequested(newRequested);

    // if (success) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Request submitted successfully!')),
    //   );
    //   _clearForm();
    // } else {
    //   // debugPrint('API returned failure for: ${newRequested.toJson()}');
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Failed to submit request')),
    //   );
    // }
  } catch (e) {
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
      _requestType.clear();
      _requestDate.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _requestCode.clear();
      _department.clear();
      _requestAmount.clear();
      _requester.clear();
      _requestPurpose.clear();
      _attachFilesController.clear();
      _descriptionController.clear();
      _totalAmountController.clear();
      _currencyController.text = 'MMK';
      _selectedCurrency = 'MMK';

      // Clear trip-specific fields
      _roundTripController.clear();
      _sourceTripController.clear();
      _destinationTripController.clear();
      _deptNameTripController.clear();
      _depatureTripController.clear();
      _returnTripController.clear();
      _expenditureTripController.clear();

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
        title: Text('Advance Request Form'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Custom icon
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AdvanceProjectTripTable())); // Manually go back
          },
        ),
      ),
      body: Container(
        color: Color.fromRGBO(255, 255, 255, 1),
        padding: const EdgeInsets.fromLTRB(150, 20, 150, 20),
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 30, 10, 30),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
                child: Column(
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
                    _buildTopFormFields(),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdvanceProjectTripTable(),
                              ),
                            );

                            if (result != null) {
                              setState(() {
                                _isProject = result['type'] == 'Project';
                                _requestType.text = result['type'] ?? '';
                                _requestDate.text = result['requestDate'] ?? '';
                                _requestCode.text = _isProject
                                    ? result['projectCode'] ?? ''
                                    : result['tripCode'] ?? '';
                                _descriptionController.text = _isProject
                                    ? result['projectDesc'] ?? ''
                                    : result['tripDesc'] ?? '';
                                _totalAmountController.text =
                                    result['amount'] ?? '';
                                _selectedCurrency = result['currency'] ?? 'MMK';
                                _currencyController.text = _selectedCurrency!;
                                _department.text = result['department'] ?? '';

                                if (!_isProject) {
                                  _roundTripController.text =
                                      result['roundTrip']?.toString() ?? '';
                                  _sourceTripController.text =
                                      result['source'] ?? '';
                                  _destinationTripController.text =
                                      result['destination'] ?? '';
                                  _deptNameTripController.text =
                                      result['deptName'] ?? '';
                                  _depatureTripController.text =
                                      result['departure'] ?? '';
                                  _returnTripController.text =
                                      result['return'] ?? '';
                                  _expenditureTripController.text =
                                      result['expenditure']?.toString() ?? '';
                                }
                              });
                            }
                          },
                          child: Container(
                            child: Row(
                              children: [
                                Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    _isProject ? _buildProjectDetails() : _buildTripDetails(),
                    SizedBox(height: 15),
                    _buildBottomFormFields(),
                    SizedBox(height: 20),
                    _buildActionButtons(),
                  ],
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Request No'),
        const SizedBox(width: 14),
        Expanded(
          child: _buildtextField(
            controller: _requestNo,
            labelText: '',
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 15),
        const Text('Request Type'),
        const SizedBox(width: 14),
        Expanded(
          child: _buildtextField(
            controller: _requestType,
            labelText: '',
            readOnly: true,
          ),
        ),
        const SizedBox(width: 15),
        const Text('Request Date'),
        const SizedBox(width: 14),
        Expanded(
          child: _buildtextField(
            controller: _requestDate,
            labelText: '',
            readOnly: true,
          ),
        ),
      ],
    );
  }

  Widget _buildProjectDetails() {
    return Row(
      children: [
        Container(
          width: 925,
          height: 226,
          decoration: BoxDecoration(
            color: Color.fromRGBO(242, 235, 235, 1),
            borderRadius: BorderRadius.circular(5),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Project Details',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('Project Code'),
                  SizedBox(width: 3),
                  Expanded(
                    child: _buildProjecttextInsideField(
                      controller: _requestCode,
                      labelText: '',
                      padding: EdgeInsets.fromLTRB(20, 1, 60, 1),
                    ),
                  ),
                  SizedBox(width: 5),
                  Text('Requested Date'),
                  SizedBox(width: 3),
                  Expanded(
                    child: _buildProjecttextInsideField(
                      controller: _requestDate,
                      labelText: '',
                      padding: EdgeInsets.fromLTRB(15, 1, 60, 1),
                    ),
                  )
                ],
              ),
              SizedBox(height: 1.5),
              Row(
                children: [
                  Text('Description'),
                  SizedBox(width: 3),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(30, 1, 60, 1),
                      child: TextField(
                        controller: _descriptionController,
                        maxLines: 1,
                        decoration: InputDecoration(
                          fillColor: const Color.fromRGBO(217, 217, 217, 1),
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.5),
              Column(
                children: [
                  Row(
                    children: [
                      Text('Total Amount'),
                      SizedBox(width: 5),
                      Expanded(
                        child: _buildProjecttextInsideField(
                          controller: _totalAmountController,
                          labelText: '',
                          padding: EdgeInsets.fromLTRB(15, 2, 50, 2),
                        ),
                      ),
                      SizedBox(width: 3),
                      Text('Currency'),
                      SizedBox(width: 3),
                      Expanded(
                        child: _buildDropdownField(
                          value: _selectedCurrency,
                          items: const ['MMK', 'USD'],
                          labelText: 'Currency',
                          padding: EdgeInsets.fromLTRB(15, 2, 50, 2),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCurrency = newValue;
                              _currencyController.text = newValue ?? 'MMK';
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 3),
                      Text('Department'),
                      SizedBox(width: 3),
                      Expanded(
                        child: _buildProjecttextInsideField(
                          controller: _department,
                          labelText: '',
                          padding: EdgeInsets.fromLTRB(15, 2, 60, 2),
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
      children: [
        Container(
          width: 925,
          height: 350,
          decoration: BoxDecoration(
            color: Color.fromRGBO(242, 235, 235, 1),
            borderRadius: BorderRadius.circular(5),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trip Details',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('Trip Code'),
                  SizedBox(width: 3),
                  Expanded(
                    child: _buildProjecttextInsideField(
                      controller: _requestCode,
                      labelText: '',
                      padding: EdgeInsets.fromLTRB(43, 1, 60, 1),
                    ),
                  ),
                  SizedBox(width: 5),
                  Text('Requested Date'),
                  SizedBox(width: 3),
                  Expanded(
                    child: _buildProjecttextInsideField(
                      controller: _requestDate,
                      labelText: '',
                      padding: EdgeInsets.fromLTRB(43, 1, 60, 1),
                    ),
                  )
                ],
              ),
              SizedBox(height: 1.5),
              Row(
                children: [
                  Text('Description'),
                  SizedBox(width: 3),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(32, 1, 60, 1),
                      child: TextField(
                        controller: _descriptionController,
                        maxLines: 1,
                        decoration: InputDecoration(
                          fillColor: const Color.fromRGBO(217, 217, 217, 1),
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.5),
              Row(
                children: [
                  Text('Round Trip'),
                  SizedBox(width: 3),
                  Expanded(
                      child: _buildTriptextInsideField(
                    controller: _roundTripController,
                    labelText: '',
                    padding: EdgeInsets.fromLTRB(35, 2, 50, 2),
                  )),
                  SizedBox(width: 5),
                  Text('Source'),
                  SizedBox(width: 3),
                  Expanded(
                      child: _buildTriptextInsideField(
                    controller: _sourceTripController,
                    labelText: '',
                    padding: EdgeInsets.fromLTRB(35, 2, 50, 2),
                  )),
                  SizedBox(width: 5),
                  Text('Destination'),
                  SizedBox(width: 3),
                  Expanded(
                      child: _buildTriptextInsideField(
                    controller: _destinationTripController,
                    labelText: '',
                    padding: EdgeInsets.fromLTRB(35, 2, 60, 2),
                  ))
                ],
              ),
              SizedBox(height: 1.5),
              Row(
                children: [
                  Text('DeptName'),
                  SizedBox(width: 3),
                  Expanded(
                      child: _buildTriptextInsideField(
                    controller: _deptNameTripController,
                    labelText: '',
                    padding: EdgeInsets.fromLTRB(35, 2, 55, 2),
                  )),
                  SizedBox(width: 5),
                  Text('Depature'),
                  SizedBox(width: 3),
                  Expanded(
                      child: _buildTriptextInsideField(
                    controller: _depatureTripController,
                    labelText: '',
                    padding: EdgeInsets.fromLTRB(15, 2, 75, 2),
                  )),
                  SizedBox(width: 5),
                  Text('Return'),
                  SizedBox(width: 3),
                  Expanded(
                      child: _buildTriptextInsideField(
                    controller: _returnTripController,
                    labelText: '',
                    padding: EdgeInsets.fromLTRB(43, 2, 60, 2),
                  ))
                ],
              ),
              SizedBox(height: 1.5),
              Column(
                children: [
                  Row(
                    children: [
                      Text('Total Amount'),
                      SizedBox(width: 5),
                      Expanded(
                        child: _buildProjecttextInsideField(
                          controller: _totalAmountController,
                          labelText: '',
                          padding: EdgeInsets.fromLTRB(15, 2, 60, 2),
                        ),
                      ),
                      SizedBox(width: 3),
                      Text('Currency'),
                      SizedBox(width: 3),
                      Expanded(
                        child: _buildDropdownField(
                          value: _selectedCurrency,
                          items: const ['MMK', 'USD'],
                          labelText: 'Currency',
                          padding: EdgeInsets.fromLTRB(15, 2, 60, 2),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCurrency = newValue;
                              _currencyController.text = newValue ?? 'MMK';
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 3),
                      Text('Expenditure'),
                      SizedBox(width: 3),
                      Expanded(
                        child: _buildProjecttextInsideField(
                          controller: _expenditureTripController,
                          labelText: '',
                          padding: EdgeInsets.fromLTRB(25, 2, 60, 2),
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
            const Text('Request Amount'),
            const SizedBox(width: 3),
            Expanded(
              child: _buildtextField(
                controller: _requestAmount,
                labelText: '',
                keyboardType: TextInputType.number,
                padding: EdgeInsets.fromLTRB(15, 2, 80, 2),
              ),
            ),
            const SizedBox(width: 3),
            const Text('Requester'),
            Expanded(
                child: _buildtextField(
              controller: _requester,
              labelText: '',
              padding: EdgeInsets.fromLTRB(15, 1, 80, 1),
            ))
          ],
        ),
        SizedBox(height: 0.5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Attach File'),
            const SizedBox(width: 3),
            Expanded(
              child: _buildtextField(
                controller: _attachFilesController,
                labelText: '',
                padding: EdgeInsets.fromLTRB(54, 1, 525, 1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Request Purpose'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 6, 0),
                child: TextField(
                  controller: _requestPurpose,
                  maxLines: 2,
                  decoration: InputDecoration(
                      fillColor: const Color.fromRGBO(217, 217, 217, 1),
                      filled: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
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
    );
  }

  Widget _buildtextField({
    required TextEditingController controller,
    required String labelText,
    bool readOnly = false,
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
        style: TextStyle(fontSize: 14),
        textAlign: textAlign,
        decoration: InputDecoration(
          labelText: labelText,
          fillColor: const Color.fromRGBO(217, 217, 217, 1),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2.0),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        ),
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
        style: TextStyle(fontSize: 14),
        textAlign: textAlign,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(fontSize: 14),
          fillColor: const Color.fromRGBO(217, 217, 217, 1),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2.0),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
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
        style: TextStyle(fontSize: 14),
        textAlign: textAlign,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(fontSize: 14),
          fillColor: const Color.fromRGBO(217, 217, 217, 1),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2.0),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        ),
      ),
    );
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
