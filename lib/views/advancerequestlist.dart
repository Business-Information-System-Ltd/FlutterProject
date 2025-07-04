import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:intl/intl.dart';

class AdvanceRequestPage extends StatefulWidget {
  @override
  _AdvanceRequestPageState createState() => _AdvanceRequestPageState();
}

class _AdvanceRequestPageState extends State<AdvanceRequestPage> {
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
        title: 'Request Date',
        field: 'requestdate',
        type: PlutoColumnType.text(),
          enableEditingMode: false,
        width: 211,
      ),
      PlutoColumn(
        title: 'Request No',
        field: 'requestno',
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
        title: 'Request Code',
        field: 'requestcode',
        type: PlutoColumnType.text(),
          enableEditingMode: false,
        width: 211,
        textAlign: PlutoColumnTextAlign.left,
        titleTextAlign: PlutoColumnTextAlign.left,
       
      ),
      PlutoColumn(
        title: 'Request Amount',
        field: 'requestamount',
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
        title: 'Requester',
        field: 'requester',
        type: PlutoColumnType.text(),
          enableEditingMode: false,
        width: 211,
        textAlign: PlutoColumnTextAlign.left,
        titleTextAlign: PlutoColumnTextAlign.left,


      ),
      PlutoColumn(
        title: 'Action',
        field: 'action',
        type: PlutoColumnType.text(),
        width: 211,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
          enableEditingMode: false,
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
         

               
        
      ),
      
    ];
  }

  List<PlutoRow> _buildRows() {
    final data = [
      {
        'requestdate': '2025-06-01',
        'requestno': 'Pay001',
        'requesttype': 'Project',
        'requestcode': 'PRJ-00',
        'requestamount': 3000000,
        'currency': 'MMK',
        'requester':'Hnin',
        'action':''
      },
       {
        'requestdate': '2025-06-02',
        'requestno': 'Pay002',
        'requesttype': 'Trip',
        'requestcode': 'PRJ-01',
        'requestamount': 3400000,
        'currency': 'USD',
        'requester':'Nway',
        'action':''
      },
      {
        'requestdate': '2025-06-03',
        'requestno': 'Pay003',
        'requesttype': 'Project',
        'requestcode': 'PRJ-01',
        'requestamount': 3200000,
        'currency': 'MMK',
        'requester':'Nway',
        'action':''
      },
      {
        'requestdate': '2025-06-04',
        'requestno': 'Pay004',
        'requesttype': 'Trip',
        'requestcode': 'PRJ-02',
        'requestamount': 3400000,
        'currency': 'USD',
        'requester':'Nway',
        'action':''
      },
      
    ];

  return data.map((s) {
  return PlutoRow(cells: {
    'requestdate': PlutoCell(value: s['requestdate']),
    'requestno': PlutoCell(value: s['requestno']),
    'requesttype': PlutoCell(value: s['requesttype']),
    'requestcode': PlutoCell(value: s['requestcode']),
    'requestamount':PlutoCell(value: s['requestamount']),
    'currency': PlutoCell(value: s['currency']),
    'requester': PlutoCell(value: s['requester']),
    'action':PlutoCell(value:'')
}
);
}).toList(); 
  }

  @override
    Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Advance Request List '), centerTitle: true),
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
