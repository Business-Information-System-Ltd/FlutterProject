import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:advance_budget_request_system/views/advanceRequestProjectTripTable.dart.dart';
import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:advance_budget_request_system/views/data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddCashpaymentForm extends StatefulWidget {
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

  const AddCashpaymentForm({
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
  State<AddCashpaymentForm> createState() => _AddCashpaymentFormState();
}

class _AddCashpaymentFormState extends State<AddCashpaymentForm> {
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
  final TextEditingController _approvedController = TextEditingController();
  final TextEditingController _receivedPersonController =
      TextEditingController();
  final TextEditingController _approvedAmountController =
      TextEditingController();
  final TextEditingController _expenditureTripController =
      TextEditingController();

  CashPayment? _cashPaymentData;
  String? _selectedCurrency = 'MMK';
  bool _isProject = true;
  bool _isLoading = false;

  List<CashPayment> cashPayments = [];
  String? _selectedPaymentMethod;
  final List<String> paymentMethods = ['Cash', 'Bank', 'Transfer'];

  @override
  void initState() {
    super.initState();
     _initializeEmptyFields();
  // Then try to load data if requestNo is provided
  if (widget.requestNo != null && widget.requestNo!.isNotEmpty) {
    _loadCashPaymentData(widget.requestNo!);
  }
    // print('Received trip data: ${widget.tripData}');
    // _isProject = widget.projectCode != null ||
    //     (widget.requestType ?? '').toLowerCase() == 'project';
    // _requestType.text =
    //     widget.requestType ?? widget.type ?? (_isProject ? 'Project' : 'Trip');
    // _requestDate.text =
    //     widget.requestDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    // _requestNo.text = widget.requestNo ?? '';

    // // Set the request code based on project or trip
    // _requestCode.text = widget.projectCode ?? widget.tripCode ?? '';
    // _descriptionController.text = widget.description ?? '';
    // _totalAmountController.text = widget.totalAmount ?? '';

    // // Initialize currency properly
    // _selectedCurrency = widget.currency ?? 'MMK';
    // _currencyController.text = _selectedCurrency!;

    // // Department should come from either project or trip data
    // _department.text = widget.department ?? '';

    // // Initialize trip-specific fields if trip data exists
    // if (widget.tripData != null && !_isProject) {
    //   _roundTripController.text =
    //       widget.tripData!['roundTrip']?.toString() ?? '';
    //   _sourceTripController.text = widget.tripData!['source']?.toString() ?? '';
    //   _destinationTripController.text =
    //       widget.tripData!['destination']?.toString() ?? '';
    //   _deptNameTripController.text =
    //       widget.tripData!['deptName']?.toString() ?? '';
    //   _depatureTripController.text =
    //       widget.tripData!['departure']?.toString() ?? '';
    //   _returnTripController.text = widget.tripData!['return']?.toString() ?? '';
    //   _approvedController.text =
    //       widget.tripData!['expenditure']?.toString() ?? '';

    //   // Make sure department is set from trip data if not already set
    //   if (_department.text.isEmpty) {
    //     _department.text = widget.tripData!['deptName']?.toString() ?? '';
    //   }
    // }
  }
void _initializeEmptyFields() {
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
}
  
Future<void> _loadCashPaymentData(String requestNo) async {
  setState(() {
    _isLoading = true;
  });
  
  try {
    final cashPayment = await ApiService(). fetchCashPaymentById(requestNo);
    
    setState(() {
      _cashPaymentData = cashPayment;
      // Populate all fields from the fetched data
      _requestNo.text = cashPayment.paymentNo;
      _requestDate.text = DateFormat('yyyy-MM-dd').format(cashPayment.date);
      _requestCode.text = cashPayment.requestCode;
      _requestType.text = cashPayment.requestType;
      _totalAmountController.text = cashPayment.paymentAmount.toString();
      _currencyController.text = cashPayment.currency;
      _selectedPaymentMethod = cashPayment.paymentMethod;
      _requester.text = cashPayment.paidPerson;
      _receivedPersonController.text = cashPayment.receivePerson;
      _requestPurpose.text = cashPayment.paymentNote;
       _approvedAmountController.text = cashPayment.paymentAmount.toString();
      
      // Set other fields as needed
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load payment data: $e')),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
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
    _approvedController.dispose();
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
      _approvedController.clear();

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
      // appBar: AppBar(
      //    backgroundColor: Colors.green.shade100,
      //   title: Text('Add Cashpayment Form'),
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back), // Custom icon
      //     onPressed: () {
      //       // Navigator.pushReplacement(
      //       //     context,
      //       //     MaterialPageRoute(
      //       //         builder: (context) =>
      //       //             AdvanceProjectTripTable())); // Manually go back
      //     },
      //   ),
      // ),
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
                        'Add Cashpayment Form ',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 2),
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
                    _buildTopFormFields(),
                    SizedBox(height: 10),
                    _buildTripDetails(),
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
        const Text(
          'Payment No',
        ),
        const SizedBox(width: 2),
        Expanded(
          child: _buildtextField(
              controller: _requestNo,
              labelText: '',
              keyboardType: TextInputType.number,
              padding: EdgeInsets.fromLTRB(10, 10, 150, 10)), //Outer padding
        ),
        const SizedBox(width: 2),
        const Text('Payment Date'),
        const SizedBox(width: 14),
        Expanded(
          child: _buildtextField(
              controller: _requestDate,
              labelText: '',
              readOnly: true,
              padding: EdgeInsets.fromLTRB(10, 10, 150, 10)),
        ),
      ],
    );
  }

  Widget _buildTripDetails() {
    return Row(
      children: [
        Container(
          width: 925,
          height: 320,
          decoration: BoxDecoration(
            color: Color.fromRGBO(242, 235, 235, 1),
            // color: Color.fromARGB(233, 218, 218, 1),
            borderRadius: BorderRadius.circular(5),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Reference',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('Request No'),
                  SizedBox(width: 2),
                  Expanded(
                    child: _buildTriptextInsideField(
                      controller: _requestNo,
                      keyboardType: TextInputType.number,
                      labelText: '',
                      padding: EdgeInsets.fromLTRB(10, 0, 30, 5),
                    ),
                  ),
                  Text('Requster'),
                  SizedBox(width: 2),
                  Expanded(
                      child: _buildTriptextInsideField(
                    controller: _requester,
                    keyboardType: TextInputType.number,
                    labelText: '',
                    padding: EdgeInsets.fromLTRB(10, 0, 30, 5),
                  )),
                  SizedBox(width: 5),
                  Text('Requested Date'),
                  SizedBox(width: 5),
                  Expanded(
                    child: _buildTriptextInsideField(
                      controller: _requestDate,
                      keyboardType: TextInputType.number,
                      labelText: '',
                      padding: EdgeInsets.fromLTRB(1, 0, 60, 5),
                    ),
                  )
                ],
              ),
              SizedBox(height: 0),
              Row(
                children: [
                  Text('Request Code'),
                  SizedBox(width: 2),
                  Expanded(
                      child: _buildTriptextInsideField(
                    controller: _requestCode,
                    keyboardType: TextInputType.number,
                    labelText: '',
                    padding: EdgeInsets.fromLTRB(25, 0, 60, 5),
                  )),
                  SizedBox(width: 5),
                  Text('Description'),
                  SizedBox(width: 2),
                  Expanded(
                      child: _buildTriptextInsideField(
                    controller: _descriptionController,
                    keyboardType: TextInputType.number,
                    labelText: '',
                    padding: EdgeInsets.fromLTRB(10, 0, 60, 5),
                  ))
                ],
              ),
              Row(
                children: [
                  Text('Request Purpose'),
                  SizedBox(width: 2),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(5, 1, 60, 1),
                      child: _buildTriptextInsideField(
                        controller: _requestPurpose,
                        keyboardType: TextInputType.number,
                        labelText: '',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 80, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Approved Amount',
                          ),
                          const SizedBox(height: 6),
                          _buildTriptextInsideField(
                            controller:
                                _approvedAmountController, // Use appropriate controller
                            labelText: '',
                            padding: EdgeInsets.zero,
                            //readOnly: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 0, 60, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Withdrawn Amount',
                          ),
                          const SizedBox(height: 6),
                          _buildTriptextInsideField(
                            controller:
                                _approvedAmountController, // Use appropriate controller
                            labelText: '',
                            padding: EdgeInsets.zero,
                            //readOnly: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 0, 60, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Remaining Amount',
                          ),
                          const SizedBox(height: 6),
                          _buildTriptextInsideField(
                            controller:
                                _approvedAmountController, // Use appropriate controller
                            labelText: '',
                            padding: EdgeInsets.zero,
                            //readOnly: true,
                          ),
                        ],
                      ),
                    ),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Payment Method',
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color:
                      const Color.fromRGBO(217, 217, 217, 1), // grey background
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 0, vertical: 11), //inner padding

                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: InputBorder.none, // Removes default underline
                    isDense: true, // Reduces height
                  ),
                  value: _selectedPaymentMethod,
                  items: ['Cash', 'Bank', 'Cheque']
                      .map((selected) => DropdownMenuItem(
                            value: selected,
                            child: Text(selected),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Choose Payment Method";
                    }
                    return null;
                  },
                ),
              ),
            ),
            SizedBox(width: 100),
            const Text('Payment Amount'),
            Expanded(
                child: _buildtextField(
              controller: _requester,
              labelText: '',
              padding: EdgeInsets.fromLTRB(10, 0, 4, 5),
            )),
            SizedBox(width: 0),
            Text('MMK')
          ],
        ),
        SizedBox(height: 0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Paid Person'),
            const SizedBox(width: 2),
            Expanded(
              child: _buildtextField(
                controller: _attachFilesController,
                labelText: '',
                padding: EdgeInsets.fromLTRB(40, 2, 0, 5),
              ),
            ),
            SizedBox(width: 100),
            Text('Received Person'),
            SizedBox(width: 2),
            Expanded(
                child: _buildtextField(
              controller: _receivedPersonController,
              labelText: '',
              padding: EdgeInsets.fromLTRB(15, 0, 39, 5),
              // padding: EdgeInsets.fromLTRB(54, 1, 525, 1),
            ))
          ],
        ),
        const SizedBox(height: 0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Payment Note'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(29, 0, 40, 0),
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
    EdgeInsets contentPadding =
        const EdgeInsets.symmetric(horizontal: 0, vertical: 0), // Inner padding
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
              contentPadding, // Inner padding for the text input area
        ),
      ),
    );
  }
 

  Widget _buildTriptextInsideField({
    required TextEditingController controller,
    required String labelText,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    EdgeInsets padding = const EdgeInsets.all(0),
    EdgeInsets contentPadding =
        const EdgeInsets.symmetric(horizontal: 0, vertical: 0), // Inner padding
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
          contentPadding: contentPadding,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required String? Function(String?) validator,
    required void Function(String?) onChanged,
    EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(0, 0, 0, 0),
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(217, 217, 217, 1),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: padding,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
        ),
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}
