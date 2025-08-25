import 'package:advance_budget_request_system/views/data.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:intl/intl.dart';

class SettlementForm extends StatefulWidget {
  final String? paymentNo;
  final String? requestCode;
  final double? withdrawnAmount;
  final Settlement? settle;
  bool isViewMode;
  final String settleId;

  SettlementForm({
    this.paymentNo,
    this.requestCode,
    this.withdrawnAmount,
    this.settle,
    this.isViewMode = false,
    required this.settleId,
    Key? key,
  }) : super(key: key);

  @override
  _SettlementFormState createState() => _SettlementFormState();
}

class _SettlementFormState extends State<SettlementForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _paymentNoController = TextEditingController();
  final TextEditingController _requestCodeController = TextEditingController();
  final TextEditingController _withdrawnAmountController =
      TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final NumberFormat _formatter = NumberFormat('#,###');

  final List<Map<String, String>> budgetData = [
    {"code": "B-1", "desc": "For Expense"},
    {"code": "B-2", "desc": "For Employees"},
    {"code": "B-3", "desc": "For Repair and Maintenance"},
  ];

  final List<TextEditingController> _controllers = List.generate(
    3,
    (index) => TextEditingController(text: '0'),
  );

  int get totalSettled {
    return _controllers.fold(
        0, (sum, ctrl) => sum + (int.tryParse(ctrl.text) ?? 0));
  }

  @override
  void initState() {
    super.initState();
    if (widget.isViewMode) {
      _initializeForm();
    }
    // Initialize form fields with passed data
    _paymentNoController.text = widget.paymentNo ?? '';
    _requestCodeController.text = widget.requestCode ?? '';
    _withdrawnAmountController.text = widget.withdrawnAmount.toString();
    if (!widget.isViewMode)
      _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  void _initializeForm() {
    if (widget.isViewMode) {
      final settle = widget.settle!;
      _paymentNoController.text = settle.paymentNo;
      _requestCodeController.text = widget.requestCode ?? '';
      _withdrawnAmountController.text = settle.withdrawnAmount.toString();
      _dateController.text = settle.paymentDate.toString();
    }
  }

  void _clearForm() {
    setState(() {
      for (var ctrl in _controllers) {
        ctrl.text = '0';
      }
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Prepare settlement data
      final settlementData = {
        'paymentNo': _paymentNoController.text,
        'requestCode': _requestCodeController.text,
        'settlementDate': _dateController.text,
        'withdrawnAmount': int.parse(_withdrawnAmountController.text),
        'settledAmount': totalSettled,
        'refundAmount':
            int.parse(_withdrawnAmountController.text) - totalSettled,
      };

      // Prepare settlement details
      final settlementDetails = budgetData.asMap().entries.map((entry) {
        final index = entry.key;
        final budget = entry.value;
        return {
          'budgetCode': budget['code'],
          'settledAmount': int.tryParse(_controllers[index].text) ?? 0,
        };
      }).toList();

      // Here you would normally save to database
      print('Saving to database:');
      print('Settlement Data: $settlementData');
      print('Settlement Details: $settlementDetails');

      // Show success message and close the form
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settlement saved successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    double refundAmount = widget.withdrawnAmount! - totalSettled;

    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        title: Text(
                    widget.isViewMode
                        ? 'Settlement Detail'
                        : 'Add Settlement Form',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
      ),
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
                Text(
                    widget.isViewMode
                        ? 'Settlement Detail'
                        : 'Add Settlement Form',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
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
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _requestCodeController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Request Code",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Settled Date",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Claim Expenses:",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                const SizedBox(height: 8),
                _buildTableHeader(),
                ...List.generate(
                    budgetData.length, (index) => _buildTableRow(index)),
                const Divider(thickness: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                            "Withdrawn Amount: ${_formatter.format(widget.withdrawnAmount)}"),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                            "Settled Amount: ${_formatter.format(totalSettled)}"),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                            "Refund Amount: ${_formatter.format(refundAmount)}"),
                      ),
                    ],
                  ),
                ),
                const Divider(thickness: 1),
                const SizedBox(height: 15),
                if (!widget.isViewMode)
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      // color: const Color(0xFFB2C8A8),

      child: const Row(
        children: [
          Expanded(
              child: Text("Budget Code",
                  style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 3,
              child: Text("Budget Description",
                  style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              child: Text("Settled Amount",
                  style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildTableRow(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(budgetData[index]['code']!)),
          Expanded(flex: 2, child: Text(budgetData[index]['desc']!)),
          Expanded(
            child: TextFormField(
              controller: _controllers[index],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter amount';
                if (int.tryParse(value) == null) return 'Invalid number';
                return null;
              },
              onChanged: (value) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }
}














/*
class SettlementForm extends StatefulWidget {
  @override
  _SettlementFormState createState() => _SettlementFormState();
}

class _SettlementFormState extends State<SettlementForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _paymentNoController = TextEditingController();
  final TextEditingController _requestCodeController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
DateTime? _selectedDate;
Future<void> _pickDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: _selectedDate ?? DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );


  if (picked != null) {
    setState(() {
      _selectedDate = picked;
      _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    });
  }
}



  final List<Map<String, String>> budgetData = [
    {"code": "B-1", "desc": "For Expense"},
    {"code": "B-2", "desc": "For Employees"},
    {"code": "B-3", "desc": "For Repair and Maintenance"},
  ];


  final List<TextEditingController> _controllers = List.generate(3,
    (index) => TextEditingController(text: '0'),
  );

  int get totalSettled {
    return _controllers.fold(0, (sum, ctrl) => sum + (int.tryParse(ctrl.text) ?? 0));
  }

  int withdrawnAmount = 70000;


  void _clearForm() {
    setState(() {
      for (var ctrl in _controllers) {
        ctrl.text = '0';
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    int refundAmount = withdrawnAmount - totalSettled;

    return Scaffold(
      backgroundColor: Colors.green[100],
      body: Center(
        child: Container(
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(16),
          width: 800,
          color: Colors.white,
          child: Form(
            key: _formKey,
            child: Column(
             mainAxisSize: MainAxisSize.min,
              children: [ Text('Settlement Form',style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),

Row(
  children: [
    Expanded(
      child: TextFormField(
        controller: _paymentNoController,
        decoration: InputDecoration(
          labelText: "Payment No",
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(),
        ),
      ),
    ),

    SizedBox(width: 10),
    Expanded(
      child: TextFormField(
        controller: _requestCodeController,
        decoration: InputDecoration(
          labelText: "Request Code",
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(),
        ),
      ),
    ),

    SizedBox(width: 10),
    Expanded(
      child: TextFormField(
        controller: _dateController,
        readOnly: true,
        onTap: () => _pickDate(context),
        decoration: InputDecoration(
          labelText: "Settled Date",
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
      ),
    ),
  ],
),
 SizedBox(height: 25),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text( "Claim Expenses:",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
                  ),

                SizedBox(height: 8),

                _buildTableHeader(),

...List.generate(budgetData.length, (index) => _buildTableRow(index)),
                Divider(thickness: 1),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  
                  child:Row(
  children: [
    Expanded(
      flex: 4,
      child: Text("Withdrawn Amount: $withdrawnAmount"),
    ),
    Expanded(
      flex: 3,
      child: Text("Settled Amount: $totalSettled"),
    ),
    Expanded(
      flex: 2,
      child: Text("Refund Amount: $refundAmount"),
    ),
  ],
),

                  //  Row(
                  //   children: [
                  //     Expanded(child: Text("Withdrawn Amount: $withdrawnAmount")),
                  //     Expanded(child: Text("Settled Amount: $totalSettled")),
                  //     Expanded(child: Text("Refund Amount: $refundAmount")),
                  //   ],
                  // ),
                  
                



                ),

                Divider(thickness: 1),
                SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {});
                        }
                      },
                      child: Text("Submit"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFB2C8A8),
                        
                        
                        

                      ),
                    ),
                    SizedBox(width: 20),

                    ElevatedButton(
                      onPressed: _clearForm,
                      child: Text("Clear"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFB2C8A8),
                        
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBox(String text) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(

          border: Border.all(color: Colors.white),
         color: Colors.grey.shade200,
        ),
        child: Center(child: Text(text, style: TextStyle(fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4),
      color: Color(0xFFB2C8A8),
      child: Row(
        children: const [
          Expanded(child: Text("Budget Code", style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text("Budget Description", style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text("Settled Amount", style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildTableRow(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),

      child: Row(
        children: [
          Expanded(child: Text(budgetData[index]['code']!)),
          Expanded(flex: 2, child: Text(budgetData[index]['desc']!)),
          Expanded(
            child: TextFormField(
              controller: _controllers[index],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                border: OutlineInputBorder(),
              ),
              
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter amount';
                if (int.tryParse(value) == null) return 'Invalid number';
                return null;
              },
              onChanged: (value) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }





  
}
*/