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
        readOnly: false,
        width: 211,
      ),
      PlutoColumn(
        title: 'Payment No',
        field: 'paymentno',
        type: PlutoColumnType.text(),
        readOnly: false,
        width: 211,
      ),
      PlutoColumn(
        title: 'Request Type',
        field: 'requesttype',
        type: PlutoColumnType.text(),
        readOnly: false,
        width: 211,
      ),
      PlutoColumn(
        title: 'Payment Amount',
        field: 'paymentamount',
        type: PlutoColumnType.number(),
        readOnly: false,
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
        readOnly: true,
        width: 211,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
      ),
      PlutoColumn(
        title: 'Payment Method',
        field: 'paymentmethod',
        type: PlutoColumnType.text(),
        readOnly: true,
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
