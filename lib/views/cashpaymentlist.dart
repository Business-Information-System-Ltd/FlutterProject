import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:intl/intl.dart';

class CashPaymentPage extends StatefulWidget {
  @override
  _CashPaymentPageState createState() => _CashPaymentPageState();
}

class _CashPaymentPageState extends State<CashPaymentPage>
    with SingleTickerProviderStateMixin {
  List<PlutoColumn> _columns = [];
  List<PlutoRow> _draftRows = [];
  List<PlutoRow> _postedRows = [];
  PlutoGridStateManager? _stateManager;
  final NumberFormat _formatter = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();
    _columns = _buildColumns();
    _draftRows = _buildDraftRows();
    _postedRows = _buildPostedRows();
    print("Draft Rows: ${_draftRows.length}");
    print("Posted Rows: ${_postedRows.length}");
  }

  List<PlutoColumn> _buildColumns() {
    return [
      PlutoColumn(
        title: 'Payment Date',
        field: 'paymentdate',
        type: PlutoColumnType.text(),
        width: 150,
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Payment No',
        field: 'paymentno',
        type: PlutoColumnType.text(),
        width: 150,
        readOnly: false,
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Request No',
        field: 'requestno',
        type: PlutoColumnType.text(),
        width: 170,
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Payment Amount',
        field: 'paymentamount',
        type: PlutoColumnType.number(),
        width: 170,
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
        width: 160,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.left,
        titleTextAlign: PlutoColumnTextAlign.left,
      ),
      PlutoColumn(
        title: 'Payment Method',
        field: 'paymentmethod',
        type: PlutoColumnType.text(),
        width: 170,
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Status',
        field: 'status',
        type: PlutoColumnType.text(),
        width: 170,
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Action',
        field: 'action',
        type: PlutoColumnType.text(),
        width: 170,
        renderer: (rendererContext) {
    return IconButton(
      icon: Icon(Icons.edit,color: Colors.blue),
      tooltip: 'Edit',
      onPressed: () {
        print('Action icon pressed on row ${rendererContext.row.key}');
        // You can add your onPressed code here
      },
    );
  },
        
        enableEditingMode: false,
         textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
      ),
    ];
  }

  List<PlutoRow> _buildDraftRows() {
    final data = [
      {
        'paymentdate': '2025-06-01',
        'paymentno': 'Pay001',
        'requestno': 'Req-001',
        'paymentamount': 150000,
        'currency': 'MMK',
        'paymentmethod': 'Cash',
        'status': 'Draft',
        'action': '',
      },
      {
        'paymentdate': '2025-06-02',
        'paymentno': 'Pay002',
        'requestno': 'Req-002',
        'paymentamount': 160000,
        'currency': 'USD',
        'paymentmethod': 'Bank',
        'status': 'Draft',
        'action': '',
      },
      {
        'paymentdate': '2025-06-03',
        'paymentno': 'Pay003',
        'requestno': 'Req-003',
        'paymentamount': 170000,
        'currency': 'MMK',
        'paymentmethod': 'Cash',
        'status': 'Draft',
        'action': '',
      },
      {
        'paymentdate': '2025-06-04',
        'paymentno': 'Pay004',
        'requestno': 'Req-004',
        'paymentamount': 190000,
        'currency': 'USD',
        'paymentmethod': 'Bank',
        'status': 'Draft',
        'action': '',
      },

    ];
    return _mapToRows(data);
  }

  List<PlutoRow> _buildPostedRows() {
    final data = [
      {
        'paymentdate': '2025-06-02',
        'paymentno': 'Pay002',
        'requestno': 'Req-002',
        'paymentamount': 160000,
        'currency': 'USD',
        'paymentmethod': 'Bank',
        'status': 'Post',
        'action': '',
      },
      {
        'paymentdate': '2025-06-02',
        'paymentno': 'Pay002',
        'requestno': 'Req-002',
        'paymentamount': 160000,
        'currency': 'USD',
        'paymentmethod': 'Bank',
        'status': 'Post',
        'action': '',
      },
      {
        'paymentdate': '2025-06-03',
        'paymentno': 'Pay003',
        'requestno': 'Req-003',
        'paymentamount': 170000,
        'currency': 'MMK',
        'paymentmethod': 'Cash',
        'status': 'Post',
        'action': '',
      },
      {
        'paymentdate': '2025-06-04',
        'paymentno': 'Pay004',
        'requestno': 'Req-004',
        'paymentamount': 180000,
        'currency': 'MMK',
        'paymentmethod': 'Cash',
        'status': 'Post',
        'action': '',
      },

    ];
    return _mapToRows(data);
  }

  List<PlutoRow> _mapToRows(List<Map<String, dynamic>> data) {
    return data.map((s) {
      return PlutoRow(cells: {
        'paymentdate': PlutoCell(value: s['paymentdate']),
        'paymentno': PlutoCell(value: s['paymentno']),
        'requestno': PlutoCell(value: s['requestno']),
        'paymentamount': PlutoCell(value: s['paymentamount']),
        'currency': PlutoCell(value: s['currency']),
        'paymentmethod': PlutoCell(value: s['paymentmethod']),
        'status': PlutoCell(value: s['status']),
        'action': PlutoCell(value: '')
      });
    }).toList();
  }

  Widget buildGrid(List<PlutoRow> rows) {
    return PlutoGrid(
      columns: _columns,
      rows: rows,
      configuration: PlutoGridConfiguration(
        style: PlutoGridStyleConfig(
          oddRowColor: Colors.blue[50],
          rowHeight: 32,
          activatedColor: Colors.lightBlueAccent.withOpacity(0.2),
        ),
      ),
      onLoaded: (event) => _stateManager = event.stateManager,
    );
  }

 

@override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, 
      child: Scaffold(
        appBar: AppBar(title: Text('Cash Payment Lists'),
        centerTitle: true,
        bottom: TabBar(labelStyle: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,letterSpacing: 1.2),
        indicatorWeight: 4,unselectedLabelColor: const Color.fromRGBO(19, 18, 18, 0.702),labelColor: Colors.blue,
        tabs: [
              Tab(text: 'Draft'),
              Tab(text: 'Posted'),
            ], ),
        ),
        
        body: Padding(
          padding: const EdgeInsets.fromLTRB(30, 30, 30, 20),
          child: TabBarView(
            children: [
              Column(
                children: [
                  Container(
                    height: 150, 
                    child: buildGrid(_draftRows),
                  ),
                ],
              ),

              Column(
                children: [
                  Container(
                    height: 150, 
                    child: buildGrid(_postedRows),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }


}
