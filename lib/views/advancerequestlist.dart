import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:intl/intl.dart';
import 'package:advance_budget_request_system/views/projecttable.dart';
import 'package:advance_budget_request_system/views/projectentryform.dart';
import 'package:advance_budget_request_system/views/triptable.dart';
import 'package:advance_budget_request_system/views/advanceRequestFormOperation.dart';
import 'package:advance_budget_request_system/views/advanceRequestFormOperation.dart';
import 'package:advance_budget_request_system/views/advanceRequestProjectTripTable.dart.dart';
import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:advance_budget_request_system/views/data.dart';

class AdvanceRequestPage extends StatefulWidget {
  @override
  _AdvanceRequestPageState createState() => _AdvanceRequestPageState();
}

class _AdvanceRequestPageState extends State<AdvanceRequestPage> {
  List<PlutoColumn> _columns = [];
  List<PlutoRow> _rows = [];
  PlutoGridStateManager? _stateManager;
  final NumberFormat _formatter = NumberFormat('#,###');
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _columns = _buildColumns();
    _rows = _buildRows();
   // _fetchAdvanceRequest();
    print(" Rows loaded: ${_rows.length}");
  }

  // Future<void> _fetchAdvanceRequest() async {
  //   try {
  //     final requests = await ApiService().fetchAdvanceRequest();

  //     setState(() {
  //       _rows = _buildRowsFromApi(requests);
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _errorMessage = 'Failed to load advance requests: ${e.toString()}';
  //       _isLoading = false;
  //     });
  //   }
  // }

  // List<PlutoRow> _buildRowsFromApi(List<AdvanceRequest> requests) {
  //   return requests.map((request) {
  //     return PlutoRow(cells: {
  //       'requestdate':
  //           PlutoCell(value: DateFormat('yyyy-MM-dd').format(request.date)),
  //       'requestno': PlutoCell(value: request.requestNo),
  //       'requesttype': PlutoCell(value: request.requestType),
  //       'requestcode': PlutoCell(value: request.requestCode),
  //       'requestamount': PlutoCell(value: request.requestAmount),
  //       'currency': PlutoCell(value: request.currency),
  //       'requester': PlutoCell(value: request.requester),
  //       'action': PlutoCell(value: '')
  //     });
  //   }).toList();
  // }

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
          final row = rendererContext.row;
          final requestType = row.cells['requesttype']?.value.toString() ?? '';

          return IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {
              if (requestType.toLowerCase().contains('project') ||
                  requestType.toLowerCase().contains('trip')) {
                // Navigate to Project&Trip table
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdvanceProjectTripTable(),
                  ),
                );
              } else if (requestType.toLowerCase().contains('operation')) {
                // Navigate to Operation form
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdvanceRequestForm(),
                  ),
                );
              }
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
        'requesttype': 'Project&Trip',
        'requestcode': 'PRJ-00',
        'requestamount': 3000000,
        'currency': 'MMK',
        'requester': 'Hnin',
        'action': ''
      },
      {
        'requestdate': '2025-06-02',
        'requestno': 'Pay002',
        'requesttype': 'Operation',
        'requestcode': 'PRJ-01',
        'requestamount': 3400000,
        'currency': 'USD',
        'requester': 'Nway',
        'action': ''
      },
      {
        'requestdate': '2025-06-03',
        'requestno': 'Pay003',
        'requesttype': 'Project&Trip',
        'requestcode': 'PRJ-01',
        'requestamount': 3200000,
        'currency': 'MMK',
        'requester': 'Nway',
        'action': ''
      },
      {
        'requestdate': '2025-06-04',
        'requestno': 'Pay004',
        'requesttype': 'Project&Trip',
        'requestcode': 'PRJ-02',
        'requestamount': 3400000,
        'currency': 'USD',
        'requester': 'Nway',
        'action': ''
      },
    ];

    return data.map((s) {
      return PlutoRow(cells: {
        'requestdate': PlutoCell(value: s['requestdate']),
        'requestno': PlutoCell(value: s['requestno']),
        'requesttype': PlutoCell(value: s['requesttype']),
        'requestcode': PlutoCell(value: s['requestcode']),
        'requestamount': PlutoCell(value: s['requestamount']),
        'currency': PlutoCell(value: s['currency']),
        'requester': PlutoCell(value: s['requester']),
        'action': PlutoCell(value: '')
      });
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Advance Request List '), centerTitle: true),
     // body: _rows.isEmpty
         // ? Center(child: CircularProgressIndicator())
        body  : Padding(
              padding: EdgeInsets.fromLTRB(50, 20, 50, 30),
              child: Container(
                height: 300,
                child: Column(
                  children: [
                    Expanded(
                      child: PlutoGrid(
                        columns: _columns,
                        rows: _rows,
                        configuration: PlutoGridConfiguration(
                          style: PlutoGridStyleConfig(
                            oddRowColor: Colors.blue[50],
                            rowHeight: 50,
                            activatedColor:
                                Colors.lightBlueAccent.withOpacity(0.2),
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
