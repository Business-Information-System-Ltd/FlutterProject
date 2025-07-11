import 'package:advance_budget_request_system/views/data.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:intl/intl.dart';
import 'package:advance_budget_request_system/views/tripentryform.dart';
import 'package:advance_budget_request_system/views/api_service.dart';

class TripInformation extends StatefulWidget {
  @override
  _TripInformationState createState() => _TripInformationState();
}

class _TripInformationState extends State<TripInformation> {
  List<PlutoColumn> _columns = [];
  List<PlutoRow> _rows = [];
  PlutoGridStateManager? _stateManager;
  final NumberFormat _formatter = NumberFormat('#,###');
  @override
  void initState() {
    super.initState();
   _columns = _buildColumns();
   _fetchTableRows();
    
  

  }

  void _fetchTableRows() async {
  try {
    List<Trips> trips = await ApiService(). fetchTrips();
    List<PlutoRow> newRows = _buildRows(trips);
    setState(() {
      _rows = newRows;
    });
    if(_stateManager!=null){
      _stateManager!.removeAllRows();
      _stateManager!.appendRows(newRows);
    }
    print("Rows loaded: ${newRows.length}");
  } catch (e) {
    print('Failed to fetch trips: $e');
  
  }
}

  List<PlutoColumn> _buildColumns() {
    return [
      PlutoColumn(
        title: 'Date',
        field: 'date',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 160,
      ),
      PlutoColumn(
        title: 'Trip Code',
        field: 'tripcode',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 162,
      ),
      PlutoColumn(
        title: 'Description',
        field: 'description',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 200,
      ),
      PlutoColumn(
        title: 'Total Amount',
        field: 'totalamount',
        type: PlutoColumnType.number(),
        enableEditingMode: false,
        width: 165,
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
        width: 165,
        textAlign: PlutoColumnTextAlign.left,
        titleTextAlign: PlutoColumnTextAlign.left,
      ),
      PlutoColumn(
        title: 'Department',
        field: 'department',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 165,
      ),
     
      PlutoColumn(
        title: 'Action',
        field: 'action',
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 165,
        renderer: (rendererContext) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  final row = rendererContext.row;
                  final rowData = {
                    'date': row.cells['date']?.value,
                    'tripcode': row.cells['tripcode']?.value,
                    'description': row.cells['description']?.value,
                    'totalamount': row.cells['totalamount']?.value.toString(),
                    'currency': row.cells['currency']?.value,
                    'department': row.cells['department']?.value,
                  
                  };
                  Navigator.push( context,MaterialPageRoute(builder: (context) => TripEntryForm(initialData: rowData),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  final row = rendererContext.row;
                  setState(() {
                    _rows.remove(row);
                    //_stateManager?.removeRows([row]);
                  });
                  print('Delete row: ${rendererContext.rowIdx}');
                },
              ),
            ],
          );
        },
      ),
    ];
  }

  // List<PlutoRow> _buildRows() {
  //   final data = [
  //     {
  //       'date': '2025-06-01',
  //       'tripcode': 'TRJ-001',
  //       'description': 'Project1',
  //       'totalamount': 150000,
  //       'currency': 'MMK',
  //       'department': 'Admin',
  //       'action': '',
  //     },
  //     {
  //       'date': '2025-06-01',
  //       'tripcode': 'TRJ-002',
  //       'description': 'Project2',
  //       'totalamount': 3000000,
  //       'currency': 'USD',
  //       'department': 'Admin',
  //       'action': '',
  //     },
  //     {
  //       'date': '2025-06-01',
  //       'tripcode': 'TRJ-001',
  //       'description': 'Project3',
  //       'totalamount': 2000000,
  //       'currency': 'USD',
  //       'department': 'Admin',
  //       'action': '',
  //     },
  //     {
  //       'date': '2025-06-01',
  //       'tripcode': 'TRJ-001',
  //       'description': 'Project4',
  //       'totalamount': 2000000,
  //       'currency': 'MMK',
  //       'department': 'Admin',
  //       'action': '',
  //     },
  //     {
  //       'date': '2025-06-01',
  //       'tripcode': 'TRJ-001',
  //       'description': 'Project5',
  //       'totalamount': 3400000,
  //       'currency': 'USD',
  //       'department': 'Admin',
  //       'action': '',
  //     },
  //   ];

  //   return data.map((s) {
  //     return PlutoRow(cells: {
  //       'date': PlutoCell(value: s['date']),
  //       'tripcode': PlutoCell(value: s['tripcode']),
  //       'description': PlutoCell(value: s['description']),
  //       'totalamount': PlutoCell(value: s['totalamount']),
  //       'currency': PlutoCell(value: s['currency']),
  //       'department': PlutoCell(value: s['department']),
  //       //'requestable': PlutoCell(value: s['requestable']),
  //       'action': PlutoCell(),
  //     });
  //   }).toList();
  // }
List<PlutoRow> _buildRows(List<Trips> trips) {
  return trips.map((trip) {
    return PlutoRow(cells: {
      'date': PlutoCell(value: DateFormat('yyyy-MM-dd').format(trip.date)),
      'tripcode': PlutoCell(value: trip.tripCode),
      'description': PlutoCell(value: trip.tripDescription),
      'totalamount': PlutoCell(value: trip.totalAmount),
      'currency': PlutoCell(value: trip.currency),
      'department': PlutoCell(value: trip.departmentName),
      'action': PlutoCell(value: ''), 
    });
  }).toList();
}

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Trip Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(90, 50, 90, 30),
        child: Container(
          height: 320,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('New'),
                    onPressed: () async {
                      final newProject = await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => TripEntryForm()),
                      );
                      if (newProject != null &&
                          newProject is Map<String, dynamic>) {
                        setState(() {
                          final newRow = PlutoRow(cells: {
                            'date': PlutoCell(value: newProject['date']),
                            'tripcode':
                                PlutoCell(value: newProject['tripcode']),
                            'description':
                                PlutoCell(value: newProject['description']),
                            'totalamount':
                                PlutoCell(value: newProject['totalamount']),
                            'currency':
                                PlutoCell(value: newProject['currency']),
                            'department':
                                PlutoCell(value: newProject['department']),
                            'requestable':
                                PlutoCell(value: newProject['requestable']),
                            'action': PlutoCell(),
                          });

                          _rows.add(newRow);
                          //_stateManager?.appendRows([newRow]);
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        child: IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: () {},
                          color: Colors.black,
                        ),
                      ),
                      ElevatedButton.icon(
                        label: Text('Export'),
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 2),
              Expanded(
                child: PlutoGrid(
                  columns: _columns,
                  rows: _rows,
                  configuration: PlutoGridConfiguration(
                    style: PlutoGridStyleConfig(
                      oddRowColor: Colors.blue[50],
                      rowHeight: 50,
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
