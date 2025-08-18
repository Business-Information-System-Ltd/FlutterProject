import 'package:advance_budget_request_system/views/advancerequestlist.dart';
import 'package:advance_budget_request_system/views/data.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:intl/intl.dart';
import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:advance_budget_request_system/views/addAdvanceRequestForm.dart';

class AdvanceProjectTripTable extends StatefulWidget {
  @override
  _AdvanceProjectTripTableState createState() =>
      _AdvanceProjectTripTableState();
}

class _AdvanceProjectTripTableState extends State<AdvanceProjectTripTable> {
  bool showProject = true;
  PlutoGridStateManager? _stateManager;

  List<PlutoRow> _rows = [];
  final NumberFormat _formatter = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();
    _updateTable();
  }

  List<PlutoColumn> _columns() {
    return showProject ? _buildProjectColumns() : _buildTripColumns();
  }

  List<PlutoColumn> _buildProjectColumns() {
    return [
      PlutoColumn(
          title: 'Request Date',
          field: 'requestDate',
          type: PlutoColumnType.text()),
      PlutoColumn(
          title: 'Project Code',
          field: 'projectCode',
          type: PlutoColumnType.text()),
      PlutoColumn(
          title: 'Project Description',
          field: 'projectDesc',
          type: PlutoColumnType.text()),
      PlutoColumn(
        title: 'Total Amount',
        field: 'amount',
        type: PlutoColumnType.text(),
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
      ),
      PlutoColumn(
        title: 'Requester',
        field: 'Requester',
        type: PlutoColumnType.text(),
      ),
    ];
  }

  List<PlutoColumn> _buildTripColumns() {
    return [
      PlutoColumn(
          title: 'Request Date',
          field: 'requestDate',
          type: PlutoColumnType.text()),
      PlutoColumn(
          title: 'Trip Code', field: 'tripCode', type: PlutoColumnType.text()),
      PlutoColumn(
          title: 'Trip Description',
          field: 'tripDesc',
          type: PlutoColumnType.text()),
      PlutoColumn(
        title: 'Total Amount',
        field: 'amount',
        type: PlutoColumnType.text(),
        textAlign: PlutoColumnTextAlign.right,
        titleTextAlign: PlutoColumnTextAlign.right,
        renderer: (context) {
          final value = int.tryParse(context.cell.value.toString()) ?? 0;
          return Text(_formatter.format(value), textAlign: TextAlign.right);
        },
      ),
      PlutoColumn(
          title: 'Currency', field: 'currency', type: PlutoColumnType.text()),
      PlutoColumn(
        title: 'Requester',
        field: 'Requester',
        type: PlutoColumnType.text(),
      )
    ];
  }

  //API
  void _updateTable() async {
    if (_stateManager != null) {
      _stateManager!.removeAllRows();
    }

    List<PlutoRow> newRows = [];

    if (showProject) {
      List<Project> projects = await ApiService().fetchProjects();
      newRows = projects.map((project) {
        return PlutoRow(cells: {
          'requestDate':
              PlutoCell(value: DateFormat('yyyy-MM-dd').format(project.date)),
          'projectCode': PlutoCell(value: project.projectCode),
          'projectDesc': PlutoCell(value: project.projectDescription),
          'department': PlutoCell(value: project.departmentName),
          'amount': PlutoCell(value: project.totalAmount.toString()),
          'currency': PlutoCell(value: project.currency),
          'Requester': PlutoCell(value: project.requesterName),
        });
      }).toList();
    } else {
      List<Trips> trips = await ApiService().fetchTrips(); 
      newRows = trips.where((t)=> t.directAdvanceReq==false).map((trip) {
        return PlutoRow(cells: {
          'requestDate':
              PlutoCell(value: DateFormat('yyyy-MM-dd').format(trip.date)),
          'tripCode': PlutoCell(value: trip.tripCode),
          'tripDesc': PlutoCell(value: trip.tripDescription),
          'amount': PlutoCell(value: trip.totalAmount.toString()),
          'currency': PlutoCell(value: trip.currency),
          'Requester':PlutoCell(value: trip.requesterName),
          'department': PlutoCell(value: trip.departmentName),
          'roundTrip': PlutoCell(value: trip.roundTrip== true ? 'Yes' : 'No'),
          'source': PlutoCell(value: trip.source),
          'destination': PlutoCell(value: trip.destination),
          'departureDate': PlutoCell(
              value: DateFormat('yyyy-MM-dd').format(trip.departureDate)),
          'returnDate': PlutoCell(
              value: DateFormat('yyyy-MM-dd').format(trip.returnDate)),
          'expenditureOption':
              PlutoCell(value: trip.expenditureOption==0 ? 'Fix Allowance': 'Claim later'),
        });
      }).toList();
    }

    if (_stateManager != null) {
      _stateManager!.appendRows(newRows);
    } else {
      setState(() {
        _rows = newRows;
      });
    }
  }

  void _navigateAdvanceRequest(
    BuildContext context,
    Map<String, dynamic> advanceRequestData,
  ) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AddAdvanceRequestForm(
          isViewMode: false,
          advanceId: '0',
          requestDate: advanceRequestData['requestDate'],
          projectCode: showProject ? advanceRequestData['projectCode'] : null,
          tripCode: !showProject ? advanceRequestData['tripCode'] : null,
          description: showProject
              ? advanceRequestData['projectDesc']
              : advanceRequestData['tripDesc'],
          totalAmount: advanceRequestData['amount'],
          currency: advanceRequestData['currency'],
          department: advanceRequestData['department'],
          type: showProject ? 'Project' : 'Trip',
          requestType: showProject ? 'Project' : 'Trip',
          tripData: !showProject
              ? {
                  'roundTrip': advanceRequestData['roundTrip'],
                  'source': advanceRequestData['source'],
                  'destination': advanceRequestData['destination'],
                  'deptName': advanceRequestData['department'],
                  'departure': advanceRequestData['departureDate'],
                  'return': advanceRequestData['returnDate'],
                  'expenditure': advanceRequestData['expenditureOption'],
                }
              : null,
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade100,
        title: const Text('Advance Request Form'),
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () {
        //     Navigator.pushReplacement(context,
        //         MaterialPageRoute(builder: (context) => AdvanceRequestPage()));
        //   },
        // ),
      ),
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: Center(
        child: Container(
          width: 1500,
          height: 1000,
          margin: const EdgeInsets.all(25),
          // padding: const EdgeInsets.fromLTRB(100, 20, 100, 20),
          decoration: BoxDecoration(
            //color: Color(0xffeaf3e0),

            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              const Text(
                'Choose Project or Trip',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ToggleButtons(
                isSelected: [showProject, !showProject],
                onPressed: (index) {
                  setState(() {
                    showProject = index == 0;
                    _updateTable();
                  });
                },
                borderRadius: BorderRadius.circular(5),
                selectedColor: Colors.black,
                color: Colors.black,
                fillColor: const Color.fromRGBO(217, 217, 217, 2),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 300),
                    child: Text(
                      'Project',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 300),
                    child: Text(
                      'Trip',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 300,
                width: MediaQuery.of(context).size.width*0.8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: PlutoGrid(
                  key: ValueKey(showProject),
                  columns: _columns(),
                  rows: _rows,
                  onLoaded: (PlutoGridOnLoadedEvent event) {
                    _stateManager = event.stateManager;
                    _stateManager!.setShowColumnFilter(false);
                  },
                  configuration: PlutoGridConfiguration(
                    style: PlutoGridStyleConfig(
                      oddRowColor: Colors.blue[50],
                      rowHeight: 35,
                      activatedColor: Colors.lightBlueAccent.withOpacity(0.2),
                    ),
                  ),
                  onRowDoubleTap: (PlutoGridOnRowDoubleTapEvent event) {
                    final rowData = event.row.cells;

                    _navigateAdvanceRequest(context, {
                      'requestDate': rowData['requestDate']?.value,
                      'projectCode':
                          showProject ? rowData['projectCode']?.value : null,
                      'projectDesc':
                          showProject ? rowData['projectDesc']?.value : null,
                      'tripCode':
                          showProject ? null : rowData['tripCode']?.value,
                      'tripDesc':
                          showProject ? null : rowData['tripDesc']?.value,
                      'amount': rowData['amount']?.value,
                      'currency': rowData['currency']?.value,
                      'Requester': rowData['Requester']?.value,
                      'department': rowData['department']?.value,
                      'roundTrip': rowData['roundTrip']?.value,
                      'source': rowData['source']?.value,
                      'destination': rowData['destination']?.value,
                      'departureDate': rowData['departureDate']?.value,
                      'returnDate': rowData['returnDate']?.value,
                      'expenditureOption': rowData['expenditureOption']?.value,
                      'type': showProject ? 'Project' : 'Trip',
                    });
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
