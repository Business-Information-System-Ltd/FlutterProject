import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:intl/intl.dart';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  List<PlutoColumn> _columns = [];
  List<PlutoRow> _rows = [];
  PlutoGridStateManager? _stateManager;
  final NumberFormat _formatter = NumberFormat('#,###');

  @override
  void initState() {

    super.initState();
    _columns = _buildColumns();
    _rows = _buildRows(); 
      print(" Rows loaded: ${_rows.length}");
  }

  List<PlutoColumn> _buildColumns() {
    return [
      PlutoColumn(
        title: 'Payment Date',
        field: 'paymentdate',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 211,
      ),
      PlutoColumn(
        title: 'Payment No',
        field: 'paymentno',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 211,
      ),
      PlutoColumn(
        title: 'Request Type',
        field: 'requesttype',
        type: PlutoColumnType.text(),
      enableEditingMode: false,
        width: 211,
      ),
      PlutoColumn(
        title: 'Payment Amount',
        field: 'paymentamount',
        type: PlutoColumnType.number(),
        enableEditingMode: false,
        width: 211,
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
        enableEditingMode: false,
        width: 211,
        textAlign: PlutoColumnTextAlign.left,
        titleTextAlign: PlutoColumnTextAlign.left,
      ),
      PlutoColumn(
        title: 'Payment Method',
        field: 'paymentmethod',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 211,
        
      ),
    ];
  }

  List<PlutoRow> _buildRows() {
    final data = [
      {
        'paymentdate': '2025-06-01',
        'paymentno': 'Pay001',
        'requesttype': 'Project',
        'paymentamount': 150000,
        'currency': 'MMK',
        'paymentmethod': 'Cash',
      },
      {
        'paymentdate': '2025-06-02',
        'paymentno': 'Pay002',
        'requesttype': 'trip',
        'paymentamount': 200000,
        'currency': 'USD',
        'paymentmethod': 'Bank Transfer',
      },
      {
        'paymentdate': '2025-06-03',
        'paymentno': 'Pay003',
        'requesttype': 'project',
        'paymentamount': 175000,
        'currency': 'MMK',
        'paymentmethod': 'Cash',
      },
      {
        'paymentdate': '2025-06-04',
        'paymentno': 'Pay004',
        'requesttype': 'project',
        'paymentamount': 275000,
        'currency': 'MMK',
        'paymentmethod': 'Cash',
      },
    ];

   return data.map((s) {
  return PlutoRow(cells: {
    'paymentdate': PlutoCell(value: s['paymentdate']),
    'paymentno': PlutoCell(value: s['paymentno']),
    'requesttype': PlutoCell(value: s['requesttype']),
    'paymentamount': PlutoCell(value: s['paymentamount']),
    'currency': PlutoCell(value: s['currency']),
    'paymentmethod': PlutoCell(value: s['paymentmethod']),
  });
}).toList(); 
  }
  @override
    Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cash Payment '), centerTitle: true),
      body: _rows.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.fromLTRB(50,20,50,30),
              child:Container(height: 150,
              child: Column(
                children: [
                  Expanded(
                    child: PlutoGrid(
                      columns: _columns,
                      rows: _rows,
                      configuration: PlutoGridConfiguration(
                        style: PlutoGridStyleConfig(
                          oddRowColor: Colors.blue[50],
                          rowHeight: 32,
                          activatedColor: Colors.lightBlueAccent.withOpacity(0.2),
                        ),
                      ),
                      onLoaded: (event) => _stateManager = event.stateManager,
                    ),
                ),
                ],
              ),
          ),
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