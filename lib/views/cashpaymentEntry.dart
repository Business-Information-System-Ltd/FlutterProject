import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:advance_budget_request_system/views/data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';

class AdvancePage extends StatefulWidget {
  const AdvancePage({super.key});

  @override
  State<AdvancePage> createState() => _AdvancePageState();
}

class _AdvancePageState extends State<AdvancePage> {
  List<PlutoColumn> _columns = [];
  List<PlutoRow> _rows = [];
  PlutoGridStateManager? stateManager;
  final NumberFormat _formatter = NumberFormat('#,###');

  @override
  void initState() {
    _columns = _buildColumns();
    _rows = _buildRows();
    super.initState();
  }

  List<PlutoColumn> _buildColumns() {
    return [
      PlutoColumn(
          title: 'Request Date',
          field: 'requestDate',
          type: PlutoColumnType.text(),
          width: 211,
          enableEditingMode: false),
      PlutoColumn(
          title: 'Request No',
          field: 'requestNo',
          type: PlutoColumnType.text(),
          width: 211,
          enableEditingMode: false),
      PlutoColumn(
          title: 'Request Type',
          field: 'requestType',
          type: PlutoColumnType.text(),
          width: 211,
          enableEditingMode: false),
      PlutoColumn(
        title: 'Request Amount',
        field: 'requestAmount',
        type: PlutoColumnType.text(),
        width: 211,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.right,
        titleTextAlign: PlutoColumnTextAlign.right,
        renderer: (context) {
          final value = int.tryParse(context.cell.value.toString()) ?? 0;
          return Text(_formatter.format(value), textAlign: TextAlign.right);
        },
      ),
      PlutoColumn(
          title: 'Currency',
          field: 'currency',
          type: PlutoColumnType.text(),
          width: 211,
          enableEditingMode: false),
      PlutoColumn(
          title: 'Requester',
          field: 'requester',
          type: PlutoColumnType.text(),
          width: 211,
          enableEditingMode: false),
    ];
  }

  List<PlutoRow> _buildRows() {
    final data = [
      {
        'requestDate': '2025-05-25',
        'requestNo': 'Req_000_001',
        'requestType': 'Project',
        'requestAmount': 200000,
        'currency': 'USD',
        'requester': 'Kelvin'
      },
      {
        'requestDate': '2025-05-25',
        'requestNo': 'Req_000_001',
        'requestType': 'Project',
        'requestAmount': 200000,
        'currency': 'MMK',
        'requester': 'Kelvin'
      },
      {
        'requestDate': '2025-05-25',
        'requestNo': 'Req_000_001',
        'requestType': 'Project',
        'requestAmount': 200000,
        'currency': 'MMK',
        'requester': 'Kelvin'
      },
      {
        'requestDate': '2025-05-25',
        'requestNo': 'Req_000_001',
        'requestType': 'Project',
        'requestAmount': 200000,
        'currency': 'MMK',
        'requester': 'Kelvin'
      },
      {
        'requestDate': '2025-05-25',
        'requestNo': 'Req_000_001',
        'requestType': 'Project',
        'requestAmount': 200000,
        'currency': 'MMK',
        'requester': 'Kelvin'
      },
      {
        'requestDate': '2025-05-25',
        'requestNo': 'Req_000_001',
        'requestType': 'Project',
        'requestAmount': 200000,
        'currency': 'MMK',
        'requester': 'Kelvin'
      },
    ];
    return data.map((s) {
      return PlutoRow(cells: {
        'requestDate': PlutoCell(value: s['requestDate']),
        'requestNo': PlutoCell(value: s['requestNo']),
        'requestType': PlutoCell(value: s['requestType']),
        'requestAmount': PlutoCell(value: s['requestAmount']),
        'currency': PlutoCell(value: s['currency']),
        'requester': PlutoCell(value: s['requester']),
      });
    }).toList();
  }

  void _navigateToCashpaymentForm(
      BuildContext context, Map<String, dynamic> advanceData) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => CashPaymentFormScreen(
                requestNo: advanceData['requestNo'],
                requestType: advanceData['requestType'],
                currency: advanceData['currency'])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _rows.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.fromLTRB(50, 20, 50, 30),
              child: Container(
                height: 300,
                child: Column(
                  children: [
                    const Center(
                      child: Text(
                        "Available Advance Request List",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Expanded(
                        child: PlutoGrid(
                      columns: _columns,
                      rows: _rows,
                      configuration: PlutoGridConfiguration(
                          style: PlutoGridStyleConfig(
                        oddRowColor: Colors.blue[50],
                        rowHeight: 30,
                        activatedColor: Colors.lightBlueAccent.withOpacity(0.3),
                      )),
                      onLoaded: (event) => stateManager = event.stateManager,
                      onRowDoubleTap: (PlutoGridOnRowDoubleTapEvent event) {
                        final rowData = event.row.cells;
                        _navigateToCashpaymentForm(context, {
                          'requestNo': rowData['requestNo']?.value,
                          'requestType': rowData['requestType']?.value,
                          'currency': rowData['currency']?.value
                        });
                      },
                    ))
                  ],
                ),
              ),
            ),
    );
  }
}

class CashPaymentFormScreen extends StatefulWidget {
  final String requestNo;
  final String requestType;
  final String currency;
  const CashPaymentFormScreen({
    required this.requestNo,
    required this.requestType,
    required this.currency,
    Key? key,
  }) : super(key: key);

  @override
  State<CashPaymentFormScreen> createState() => _CashPaymentFormScreenState();
}

class _CashPaymentFormScreenState extends State<CashPaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _paymentNoController = TextEditingController();
  final TextEditingController _requestNoController = TextEditingController();
  final TextEditingController _paymentDateController = TextEditingController();
  final TextEditingController _requestTypeController = TextEditingController();
  final TextEditingController _paymentAmountController =
      TextEditingController();
  final TextEditingController _paidPersonController = TextEditingController();
  final TextEditingController _receivePersonController =
      TextEditingController();
  final TextEditingController _paymentNoteController = TextEditingController();
  String? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    _generatePaymentNo();

    _requestNoController.text = widget.requestNo;
    _requestTypeController.text = widget.requestType;
    final currency = widget.currency;
    _paymentDateController.text =
        DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  void _clearForm() {
    setState(() {
      _paymentAmountController.text = "";
      _paidPersonController.text = "";
      _receivePersonController.text = "";
      _paymentNoteController.text = "";
    });
  }

  void _generatePaymentNo() {
    int lastPaymentNo = 1;
    _paymentNoController.text =
        'Pay_${lastPaymentNo.toString().padLeft(3, '0')}';
  }
  final ApiService apiService = ApiService();
   
  Future<int> generateCashpaymentID() async {  
    List<Payment> existingCash = await apiService.fetchPayments();

    if (existingCash.isEmpty) {
      return 1; // Start from 1 if no budget exists
    }

    // Find the highest existing ID
    int maxId =
        existingCash.map((b) => b.id).reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  void _submitForm() async{
    if (_formKey.currentState!.validate()) {
      int newId= await generateCashpaymentID();
      try {
        Payment newPayment= Payment(
        id: newId, 
        date: DateFormat('yyyy-MM-dd').parse(_paymentDateController.text), 
        paymentNo: _paymentNoController.text, 
        requestNo: _requestNoController.text, 
        requestType: _requestTypeController.text, 
        paymentAmount: double.tryParse(_paymentAmountController.text)??0, 
        currency: widget.currency, 
        paymentMethod: _selectedPaymentMethod!, 
        paidPerson: _paidPersonController.text, 
        receivedPerson: _receivePersonController.text, 
        paymentNote: _paymentNoteController.text, 
        status: 'Draft', 
        settled: 'No'
        );
        await ApiService().postPayment(newPayment);
      print('Saving to database:');
      print('Settlement Data: $newPayment');
      
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Cashpayment Data saved successfully!!")));
      // Navigator.pop(context);
      } catch (e) {
        print("Fail to load cash $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(16),
          width: 800,
          color: Colors.white,
          child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Add Cashpayment Form',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  IconButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>const AdvancePage()));
                    }, 
                    icon: const Icon(Icons.arrow_drop_down)
                    ),

                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                          child: TextFormField(
                        controller: _paymentNoController,
                        readOnly: true,
                        decoration: InputDecoration(
                            labelText: "Payment No",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: const OutlineInputBorder()),
                      )),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: TextFormField(
                        controller: _requestNoController,
                        readOnly: true,
                        decoration: InputDecoration(
                            labelText: "Request No",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: const OutlineInputBorder()),
                      )),
                      const SizedBox(width: 10),
                      Expanded(
                          child: TextFormField(
                        controller: _paymentDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Payment Date",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: const OutlineInputBorder(),
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(
                    height: 35,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: TextFormField(
                        controller: _requestTypeController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Request Type",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: const OutlineInputBorder(),
                        ),
                      )),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: TextFormField(
                        controller: _paymentAmountController,
                        decoration: InputDecoration(
                          labelText: "Enter Payment Amount",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter Total Amount";
                          }
                          final amount = double.tryParse(value);
                          if (amount == null) {
                            return "Enter a valid amount";
                          }
                          if (amount <= 0) {
                            return "payment Amount must be greater than 0";
                          }
                          return null;
                        },
                      )),
                      Container(
                        decoration: const BoxDecoration(),
                        child: Text(
                          widget.currency,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: DropdownButtonFormField(
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Payment Method"),
                        value: _selectedPaymentMethod,
                        items: ['Cash', 'Bank', 'Cheque']
                            .map((selected) => DropdownMenuItem(
                                value: selected, child: Text(selected)))
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
                      )),
                    ],
                  ),
                  const SizedBox(
                    height: 35,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: TextFormField(
                        controller: _paidPersonController,
                        decoration: InputDecoration(
                          labelText: "Enter Paid Person",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter Paid Person";
                          }
                          return null;
                        },
                      )),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: TextFormField(
                        controller: _receivePersonController,
                        decoration: InputDecoration(
                          labelText: "Enter Receive Person",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter Paid Person";
                          }
                          return null;
                        },
                      )),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: TextFormField(
                        controller: _paymentNoteController,
                        decoration: InputDecoration(
                          labelText: "Enter Payment Note",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter Paid Person";
                          }
                          return null;
                        },
                      )),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(
                            fontSize: 15,
                          ),
                          backgroundColor: const Color(0xFFB2C8A8),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Submit"),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: _clearForm,
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(
                            fontSize: 15,
                          ),
                          backgroundColor: const Color(0xFFB2C8A8),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Clear"),
                      ),
                    ],
                  )
                ],
              )),
        ),
      ),
    );
  }
}
