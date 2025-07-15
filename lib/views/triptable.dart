import 'package:advance_budget_request_system/views/data.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:intl/intl.dart';
import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:advance_budget_request_system/views/tripForm.dart';

class TripInformation extends StatefulWidget {
    final UserModel currentUser;
    final String tripId;
    const TripInformation({Key?key,
    required this.currentUser,
    required this.tripId,
    }):super(key: key);
  
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
    print('Fetching trips...');
    List<Trips> trips = await ApiService().fetchTrips();
    print('Fetched ${trips.length} trips');
    
    // Debug: print first trip's ID and type
    if (trips.isNotEmpty) {
      print('First trip ID: ${trips[0].id}, type: ${trips[0].id.runtimeType}');
    }

    List<PlutoRow> newRows = _buildRows(trips);
    setState(() {
      _rows = newRows;
    });
    if (_stateManager != null) {
      _stateManager!.removeAllRows();
      _stateManager!.appendRows(newRows);
    }
    print("Rows loaded: ${newRows.length}");
  } catch (e) {
    print('Failed to fetch trips: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load trips: ${e.toString()}')),
    );
  }
}
  

void _editTrip(PlutoRow row) async {
    try {
      final tripId = row.cells['id']!.value;
      final trip = await ApiService().getTripById(tripId);
      print("tripID: $tripId");
      
      if (trip != null) {
        final success = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TripRequestForm(
              trip: trip,
              isEditMode: true,
             currentUser: widget.currentUser,
              tripId: tripId,
            ),
          ),
        );

        if (success == true) {
          _fetchTableRows();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to edit trip: $e')),
      );
    }
  }
  void _detailTrip(PlutoRow row) async {
    try {
      final tripId = row.cells['id']!.value;
      final trip = await ApiService().getTripById(tripId);
      
      if (trip != null) {
        final success = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TripRequestForm(
              trip: trip,
              isEditMode: false,
              isViewMode: true,
             currentUser: widget.currentUser,
              tripId: tripId,
            ),
          ),
        );

        if (success == true) {
          _fetchTableRows();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to edit trip: $e')),
      );
    }
  }
void _deleteTrip(PlutoRow row) async {
    final tripId = row.cells['id']!.value;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this trip?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService().deleteTrip(tripId);
        _fetchTableRows();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Trip deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete trip: $e')),
        );
      }
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
                //onPressed: () => _editTrip(context.row),
                 onPressed: () => _editTrip(rendererContext.row),

              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteTrip(rendererContext.row),
              ),
               IconButton(
                icon: Icon(Icons.more_horiz_outlined, color: Colors.black),
                onPressed: () => _detailTrip(rendererContext.row)
              ),
            ],
          );
        },
      ),
    ];
  }

 
  List<PlutoRow> _buildRows(List<Trips> trips) {
    return trips.map((trip) {
      return PlutoRow(cells: {
        'id': PlutoCell(value: trip.id),
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
                      final success = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TripRequestForm(
                            currentUser: widget.currentUser,
                            tripId: "0", // Will generate new ID
                          ),
                        ),
                      );

                      if (success == true) {
                        _fetchTableRows(); // Refresh the table
                      }
                    },
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
                  onLoaded: (event) {
                     _stateManager = event.stateManager;
                    
                     },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
