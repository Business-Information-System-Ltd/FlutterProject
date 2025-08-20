import 'dart:convert';
import 'dart:io';
import 'dart:html' as html;
import 'package:advance_budget_request_system/views/addAdvanceRequestForm.dart';
import 'package:advance_budget_request_system/views/advanceRequestFormOperation.dart';
import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:advance_budget_request_system/views/data.dart';
import 'package:advance_budget_request_system/views/datefilter.dart';
import 'package:advance_budget_request_system/views/pagination.dart';
import 'package:advance_budget_request_system/views/searchfunction.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pluto_grid/pluto_grid.dart';

class TrapezoidTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const TrapezoidTab({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipPath(
        clipper: _TrapezoidClipper(),
        child: Container(
          color: isSelected ? Colors.blue : Colors.grey.shade400,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _TrapezoidClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(15, 0); // left top
    path.lineTo(size.width - 15, 0); // right top
    path.lineTo(size.width, size.height); // right bottom
    path.lineTo(0, size.height); // left bottom
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class AdvanceRequestPage extends StatefulWidget {
  @override
  _AdvanceRequestPageState createState() => _AdvanceRequestPageState();
}

class _AdvanceRequestPageState extends State<AdvanceRequestPage> {
  int _selectedTab = 0;

  // Data holders
  List<Advance> advances = [];
  List<Advance> filteredAdvances = [];
  List<Project> projects = [];
  List<Project> filteredProjects = [];
  List<Trips> trips = [];
  List<Trips> filteredTrips = [];
  final NumberFormat _formatter = NumberFormat('#,###');
  String _searchQuery = '';
  DateTimeRange? _currentDateRange;
  String? _currentFilterType;
  int _currentPage = 1;
  int _rowsPerPage = 10;
  PlutoGridStateManager? _gridStateManager;
  bool _loading = true;
  int _currentPageAdvance = 1;
  int _currentPageProject = 1;
  int _currentPageTrip = 1;

  PlutoGridStateManager? _gridStateManagerAdvance;
  PlutoGridStateManager? _gridStateManagerProject;
  PlutoGridStateManager? _gridStateManagerTrip;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    setState(() => _loading = true);
    try {
      advances = await ApiService().fetchAdvanceRequests();
      filteredAdvances = List.from(advances);
      projects = (await ApiService().fetchProjects())
          .where((p) => p.requestable.toLowerCase() == 'yes')
          .toList();
      filteredProjects = List.from(projects);
      trips = (await ApiService().fetchTrips())
          .where((t) => t.directAdvanceReq == false)
          .toList();
      filteredTrips = List.from(trips);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
      _applyFilter();
    }
    setState(() => _loading = false);
  }

  void _refreshData() async {
    setState(() {
      _searchQuery = "";
      _currentDateRange = null;
      _currentFilterType = null;
      _currentPage = 1;
    });
    try {
      List<Advance> advance = await ApiService().fetchAdvanceRequests();
      List<Project> project = await ApiService().fetchProjects();
      List<Trips> trip = await ApiService().fetchTrips();
      setState(() {
        advances = advance;
        projects =
            project.where((p) => p.requestable.toLowerCase() == 'yes').toList();
        trips = trip.where((t) => t.directAdvanceReq == false).toList();
      });
      _applyFilter();

      // _applyDateFilter();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to refresh trips: ${e.toString()}')),
      );
    }
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilter();
    });
  }

  void _handleDateRangeChanged(DateTimeRange range, String selectedValue) {
    setState(() {
      _currentDateRange = range;
      _currentFilterType = selectedValue;
      _applyFilter();
    });
  }

  void _applyFilter() {
    filteredAdvances = List.from(advances);
    filteredProjects = List.from(projects);
    filteredTrips = List.from(trips);
    if (_searchQuery.isNotEmpty) {
      filteredAdvances = filteredAdvances.where((advance) {
        return SearchUtils.matchesSearchAdvance(advance, _searchQuery);
      }).toList();

      filteredProjects = filteredProjects.where((project) {
        return SearchUtils.matchesSearchProject(project, _searchQuery);
      }).toList();

      filteredTrips = filteredTrips.where((trip) {
        return SearchUtils.matchesSearchTrip(trip, _searchQuery);
      }).toList();
    } 
    // else {
    //   filteredAdvances = List.from(advances);
    //   filteredProjects = List.from(projects);
    //   filteredTrips = List.from(trips);
    // }
    if (_currentDateRange != null) {
      filteredAdvances = filteredAdvances.where((advance) {
        return advance.date.isAfter(
                _currentDateRange!.start.subtract(const Duration(days: 1))) &&
            advance.date
                .isBefore(_currentDateRange!.end.add(const Duration(days: 1)));
      }).toList();
      filteredProjects = filteredProjects.where((project) {
        return project.date.isAfter(
                _currentDateRange!.start.subtract(const Duration(days: 1))) &&
            project.date
                .isBefore(_currentDateRange!.end.add(const Duration(days: 1)));
      }).toList();

      filteredTrips = filteredTrips.where((trip) {
        return trip.date.isAfter(
                _currentDateRange!.start.subtract(const Duration(days: 1))) &&
            trip.date
                .isBefore(_currentDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }
    _currentPageAdvance = 1;
    _currentPageProject = 1;
    _currentPageTrip = 1;
    if (_gridStateManagerAdvance != null) {
      _gridStateManagerAdvance!.setPage(1);
      _gridStateManagerAdvance!.setPageSize(_rowsPerPage);
      _gridStateManagerAdvance!.resetCurrentState();
      _gridStateManagerAdvance!.notifyListeners();
    }
    if (_gridStateManagerProject != null) {
      _gridStateManagerProject!.setPage(1);
      _gridStateManagerProject!.setPageSize(_rowsPerPage);
      _gridStateManagerProject!.resetCurrentState();
      _gridStateManagerProject!.notifyListeners();
    }
    if (_gridStateManagerTrip != null) {
      _gridStateManagerTrip!.setPage(1);
      _gridStateManagerTrip!.setPageSize(_rowsPerPage);
      _gridStateManagerTrip!.resetCurrentState();
      _gridStateManagerTrip!.notifyListeners();
    }
  }


  //Export button
  Future<void> exportToCSV() async {
    try {
      List<List<dynamic>> csvData = [];
      csvData.add([
        "Request Date",
        "Request No",
        "Request Type",
        "Request Code",
        "Request Description",
        "Request Amount",
        "Currency",
        "Approved Amount",
        "Requester",
        "Department",
        "Request Purpose",
        "Status"
      ]);
      for (var advance in advances) {
        csvData.add([
          DateFormat('yyyy-MM-dd').format(advance.date),
          advance.requestNo,
          advance.requestType,
          advance.requestCode,
          advance.requestDes,
          advance.requestAmount,
          advance.currency,
          advance.approvedAmount,
          advance.requester,
          advance.departmentName,
          advance.purpose,
          advance.status
        ]);
      }
      String csv = const ListToCsvConverter().convert(csvData);
      if (kIsWeb) {
        final bytes = utf8.encode(csv);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "advance.csv")
          ..click();

        html.Url.revokeObjectUrl(url);
        print("CSV file download in browser");
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final path = "${directory.path}/advance.csv";
        final file = File(path);
        await file.writeAsString(csv);

        print("CSV file saved to $path");
      }
    } catch (e) {
      print("Error exporting to CSV: $e");
    }
  }

  //pagination

  List<Advance> get _paginatedAdvances {
    final total = filteredAdvances.length;
    if (total == 0) return [];
    final start = ((_currentPageAdvance - 1) * _rowsPerPage).clamp(0, total);
    final end = (start + _rowsPerPage).clamp(0, total);
    return filteredAdvances.sublist(start, end);
  }

  List<Project> get _paginatedProjects {
    final total = filteredProjects.length;
    if (total == 0) return [];
    final start = ((_currentPageProject - 1) * _rowsPerPage).clamp(0, total);
    final end = (start + _rowsPerPage).clamp(0, total);
    return filteredProjects.sublist(start, end);
  }

  List<Trips> get _paginatedTrips {
    final total = filteredTrips.length;
    if (total == 0) return [];
    final start = ((_currentPageTrip - 1) * _rowsPerPage).clamp(0, total);
    final end = (start + _rowsPerPage).clamp(0, total);
    return filteredTrips.sublist(start, end);
  }

  void _onPageChangedProject(int page, int rowsPerPage) {
    setState(() {
      _currentPageProject = page;
      _rowsPerPage = rowsPerPage;
    });
  }

  void _onPageChangedTrip(int page, int rowsPerPage) {
    setState(() {
      _currentPageTrip = page;
      _rowsPerPage = rowsPerPage;
    });
  }

  void _detailAdvanceForProjectAndTrip(PlutoRow row) async {
    final advanceId = row.cells['id']?.value?.toString();
    if (advanceId == null || advanceId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Could not find advance ID')),
      );
      return;
    }

    try {
      final advance = await ApiService().getAdvanceById(advanceId);
      if (advance != null) {
        final success = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddAdvanceRequestForm(
              advanceId: advanceId,
              isViewMode: true,
              advance: advance,
              requestType: advance.requestType,
            ),
          ),
        );
        if (success == true) {
          _fetchAllData();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Advance request not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading advance: ${e.toString()}')),
      );
    }
  }

  void _detailAdvanceForOperation(PlutoRow row) async {
    final advanceId = row.cells['id']?.value?.toString();
    if (advanceId == null || advanceId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Could not find advance ID')),
      );
      return;
    }

    try {
      final advance = await ApiService().getAdvanceById(advanceId);
      if (advance != null) {
        final success = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdvanceRequestForm(
                advanceId: advanceId,
                isViewMode: true,
                readOnly: true,
                advance: advance),
          ),
        );
        if (success == true) {
          _fetchAllData();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Advance request not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading advance: ${e.toString()}')),
      );
    }
  }

  void _requestAdvanceProject(PlutoRow row){
    final projectId= row.cells['id']?.value;
    if (projectId!=null) {
      final project= projects.firstWhere((p)=> p.id==projectId.toString());

      Navigator.push(context, MaterialPageRoute(builder: (context)=> AddAdvanceRequestForm(advanceId: '0',
      requestType: 'Project',
          projectCode: project.projectCode,
          description: project.projectDescription,
          totalAmount: project.totalAmount.toString(),
          currency: project.currency,
          department: project.departmentName,
          requestDate: DateFormat('yyyy-MM-dd').format(project.date),
      ) ) ).then((success){
        if (success==true) {
          _refreshData();
        }
      });
    }
  }

  void _requestAdvanceTrip(PlutoRow row){
    final tripId= row.cells['id']?.value;
    if (tripId!=null) {
      final trip = trips.firstWhere((t) => t.id == tripId.toString());
      
      final tripData= {
         'roundTrip': trip.roundTrip ? 'Yes' : 'No',
      'source': trip.source,
      'destination': trip.destination,
      'deptName': trip.departmentName,
      'departure': DateFormat('yyyy-MM-dd').format(trip.departureDate),
      'return': DateFormat('yyyy-MM-dd').format(trip.returnDate),
      'expenditure': trip.expenditureOption == 0 ? 'Fix Allowance' : 'Claim later',
      };
      Navigator.push(context, MaterialPageRoute(builder: (context)=> AddAdvanceRequestForm(advanceId: '0',
        requestType: 'Trip',
          tripCode: trip.tripCode,
          description: trip.tripDescription,
          totalAmount: trip.totalAmount.toString(),
          currency: trip.currency,
          department: trip.departmentName,
          requestDate: DateFormat('yyyy-MM-dd').format(trip.date),
          tripData: tripData,
      ))).then((success){
        if (success==true) {
          _refreshData();
        }
      });
    }
  }

  Widget _buildAdvanceGrid() {
    final columns = [
      PlutoColumn(
        title: 'ID',
        field: 'id',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        hide: true,
      ),
      PlutoColumn(
        title: 'Request Date',
        field: 'requestdate',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 145,
      ),
      PlutoColumn(
        title: 'Request No',
        field: 'requestno',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 142,
      ),
      PlutoColumn(
        title: 'Request Type',
        field: 'requesttype',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 200,
      ),
      PlutoColumn(
        title: 'Request Code',
        field: 'requestcode',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 142,
        textAlign: PlutoColumnTextAlign.left,
        titleTextAlign: PlutoColumnTextAlign.left,
      ),
      PlutoColumn(
        title: 'Request Amount',
        field: 'requestamount',
        type: PlutoColumnType.number(),
        enableEditingMode: false,
        width: 180,
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
        width: 100,
        textAlign: PlutoColumnTextAlign.left,
        titleTextAlign: PlutoColumnTextAlign.left,
      ),
      PlutoColumn(
        title: 'Requester',
        field: 'requester',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 200,
        textAlign: PlutoColumnTextAlign.left,
        titleTextAlign: PlutoColumnTextAlign.left,
      ),
      PlutoColumn(
        title: 'Action',
        field: 'action',
        type: PlutoColumnType.text(),
        width: 150,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final row = rendererContext.row;
          final requestType = row.cells['requesttype']?.value.toString() ?? '';

          return IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {
              if (requestType == 'Project' || requestType == 'Trip') {
                _detailAdvanceForProjectAndTrip(rendererContext.row);
              } else if (requestType.toLowerCase().contains('operation')) {
                _detailAdvanceForOperation(rendererContext.row);
              }
            },
          );
        },
      ),
    ];
    final rows = _paginatedAdvances
        .map((advance) => PlutoRow(cells: {
              'id': PlutoCell(value: advance.id),
              'requestdate': PlutoCell(
                  value: DateFormat('yyyy-MM-dd').format(advance.date)),
              'requestno': PlutoCell(value: advance.requestNo),
              'requesttype': PlutoCell(value: advance.requestType),
              'requestcode': PlutoCell(value: advance.requestCode),
              'requestamount': PlutoCell(value: advance.requestAmount),
              'currency': PlutoCell(value: advance.currency),
              'requester': PlutoCell(value: advance.requester),
              'action': PlutoCell(value: '')
            }))
        .toList();

    return Column(
      children: [
        Expanded(
          child: PlutoGrid(
            columns: columns,
            rows: rows,
            configuration: PlutoGridConfiguration(
              style: PlutoGridStyleConfig(
                oddRowColor: Colors.blue[50],
                rowHeight: 35,
                activatedColor: Colors.lightBlueAccent.withOpacity(0.2),
              ),
            ),
            onLoaded: (event) {
              _gridStateManagerAdvance = event.stateManager;
              _gridStateManagerAdvance!.setPage(1);
              _gridStateManagerAdvance!.setPageSize(_rowsPerPage);

              setState(() {});
            },
          ),
        ),
        if (_gridStateManagerAdvance != null)
          PlutoGridPagination(
              stateManager: _gridStateManagerAdvance!,
              totalRows: filteredAdvances.length,
              rowsPerPage: _rowsPerPage,
              onPageChanged: (page, rowsPerPage) {
                setState(() {
                  _currentPageAdvance = page;
                  _rowsPerPage = rowsPerPage;

                  final start = (page - 1) * rowsPerPage;
                  final end = (start + rowsPerPage > filteredAdvances.length)
                      ? filteredAdvances.length
                      : start + rowsPerPage;

                  final _paginatedAdvances = filteredAdvances.sublist(start, end);

                  final rows = _paginatedAdvances
                      .map((advance) => PlutoRow(cells: {
                            'id': PlutoCell(value: advance.id),
                            'requestdate': PlutoCell(
                                value: DateFormat('yyyy-MM-dd')
                                    .format(advance.date)),
                            'requestno': PlutoCell(value: advance.requestNo),
                            'requesttype':
                                PlutoCell(value: advance.requestType),
                            'requestcode':
                                PlutoCell(value: advance.requestCode),
                            'requestamount':
                                PlutoCell(value: advance.requestAmount),
                            'currency': PlutoCell(value: advance.currency),
                            'requester': PlutoCell(value: advance.requester),
                            'action': PlutoCell(value: '')
                          }))
                      .toList();

                  _gridStateManagerAdvance!.removeAllRows();
                  _gridStateManagerAdvance!.appendRows(rows);
                });
              }),
      ],
    );
  }

  Widget _buildProjectGrid() {
    final columns = [
      PlutoColumn(
          title: 'id', field: 'id', type: PlutoColumnType.text(), hide: true),
      PlutoColumn(
          title: 'Request Date',
          field: 'requestDate',
          width: 165,
          enableEditingMode: false,
          type: PlutoColumnType.text()),
      PlutoColumn(
          title: 'Project Code',
          field: 'projectCode',
          enableEditingMode: false,
          width: 142,
          type: PlutoColumnType.text()),
      PlutoColumn(
          title: 'Project Description',
          field: 'projectDesc',
          enableEditingMode: false,
          width: 340,
          type: PlutoColumnType.text()),
      PlutoColumn(
        title: 'Total Amount',
        field: 'amount',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 150,
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
        width: 100,
      ),
      PlutoColumn(
        title: 'Requester',
        field: 'Requester',
        enableEditingMode: false,
        width: 150,
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Action',
        field: 'action',
        type: PlutoColumnType.text(),
        width: 210,
        enableEditingMode: false,
        renderer: (rendererContext) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: ()=> _requestAdvanceProject(rendererContext.row) , 
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB2C8A8),
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Request Advance"))
            ],
          );
        },
      ),
    ];
    final rows = _paginatedProjects
        .map((project) => PlutoRow(cells: {
              'id': PlutoCell(value: project.id),
              'requestDate': PlutoCell(
                  value: DateFormat('yyyy-MM-dd').format(project.date)),
              'projectCode': PlutoCell(value: project.projectCode),
              'projectDesc': PlutoCell(value: project.projectDescription),
              'department': PlutoCell(value: project.departmentName),
              'amount': PlutoCell(value: project.totalAmount.toString()),
              'currency': PlutoCell(value: project.currency),
              'Requester': PlutoCell(value: project.requesterName),
              'action': PlutoCell(value: ''),
            }))
        .toList();

    return Column(
      children: [
        Expanded(
          child: PlutoGrid(
            columns: columns,
            rows: rows,
            configuration: PlutoGridConfiguration(
              style: PlutoGridStyleConfig(
                oddRowColor: Colors.blue[50],
                rowHeight: 35,
                activatedColor: Colors.lightBlueAccent.withOpacity(0.2),
              ),
            ),
            onLoaded: (event) {
              _gridStateManagerProject = event.stateManager;
              _gridStateManagerProject!.setPage(1, notify: false);
              _gridStateManagerProject!
                  .setPageSize(_rowsPerPage, notify: false);
              setState(() {});
            },
          ),
        ),
        if (_gridStateManagerProject != null)
          PlutoGridPagination(
            stateManager: _gridStateManagerProject!,
            totalRows: filteredProjects.length,
            rowsPerPage: _rowsPerPage,
            onPageChanged: (page, rowsPerPage) {
              setState(() {
                _currentPageProject = page;
                _rowsPerPage = rowsPerPage;
                final start = (page - 1) * rowsPerPage;
                final end = (start + rowsPerPage > filteredProjects.length)
                    ? filteredProjects.length
                    : start + rowsPerPage;
                final _paginatedProjects = filteredProjects.sublist(start, end);
                final rows = _paginatedProjects
                    .map((project) => PlutoRow(cells: {
                          'id': PlutoCell(value: project.id),
                          'requestDate': PlutoCell(
                              value: DateFormat('yyyy-MM-dd')
                                  .format(project.date)),
                          'projectCode': PlutoCell(value: project.projectCode),
                          'projectDesc':
                              PlutoCell(value: project.projectDescription),
                          'department':
                              PlutoCell(value: project.departmentName),
                          'amount':
                              PlutoCell(value: project.totalAmount.toString()),
                          'currency': PlutoCell(value: project.currency),
                          'Requester': PlutoCell(value: project.requesterName),
                          'action': PlutoCell(value: ''),
                        }))
                    .toList();
                _gridStateManagerProject!.removeAllRows();
                _gridStateManagerProject!.appendRows(rows);
              });
            },
          ),
      ],
    );
  }

  Widget _buildTripGrid() {
    final columns = [
      PlutoColumn(
          title: 'id', field: 'id', type: PlutoColumnType.text(), hide: true),
      PlutoColumn(
          title: 'Request Date',
          field: 'requestDate',
          width: 165,
          enableEditingMode: false,
          type: PlutoColumnType.text()),
      PlutoColumn(
          title: 'Trip Code',
          field: 'tripCode',
          type: PlutoColumnType.text(),
          width: 142,
          enableEditingMode: false),
      PlutoColumn(
          title: 'Trip Description',
          field: 'tripDesc',
          width: 360,
          enableEditingMode: false,
          type: PlutoColumnType.text()),
      PlutoColumn(
        title: 'Total Amount',
        field: 'amount',
        type: PlutoColumnType.number(),
        width: 165,
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
          width: 100,
          enableEditingMode: false),
      PlutoColumn(
        title: 'Requester',
        field: 'Requester',
        enableEditingMode: false,
        width: 150,
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Action',
        field: 'action',
        type: PlutoColumnType.text(),
        width: 200,
        enableEditingMode: false,
        renderer: (rendererContext) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: ()=>_requestAdvanceTrip(rendererContext.row) , 
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB2C8A8),
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Request Advance"))
            ],
          );
        },
      ),
    ];
    final rows = _paginatedTrips
        .map((trip) => PlutoRow(cells: {
              'id': PlutoCell(value: trip.id),
              'requestDate':
                  PlutoCell(value: DateFormat('yyyy-MM-dd').format(trip.date)),
              'tripCode': PlutoCell(value: trip.tripCode),
              'tripDesc': PlutoCell(value: trip.tripDescription),
              'amount': PlutoCell(value: trip.totalAmount.toString()),
              'currency': PlutoCell(value: trip.currency),
              'Requester': PlutoCell(value: trip.requesterName),
              'action': PlutoCell(value: ''),
              'department': PlutoCell(value: trip.departmentName),
              'roundTrip':
                  PlutoCell(value: trip.roundTrip == true ? 'Yes' : 'No'),
              'source': PlutoCell(value: trip.source),
              'destination': PlutoCell(value: trip.destination),
              'departureDate': PlutoCell(
                  value: DateFormat('yyyy-MM-dd').format(trip.departureDate)),
              'returnDate': PlutoCell(
                  value: DateFormat('yyyy-MM-dd').format(trip.returnDate)),
              'expenditureOption': PlutoCell(
                  value: trip.expenditureOption == 0
                      ? 'Fix Allowance'
                      : 'Claim later'),
            }))
        .toList();

    return Column(
      children: [
        Expanded(
          child: PlutoGrid(
            columns: columns,
            rows: rows,
            configuration: PlutoGridConfiguration(
              style: PlutoGridStyleConfig(
                oddRowColor: Colors.blue[50],
                rowHeight: 35,
                activatedColor: Colors.lightBlueAccent.withOpacity(0.2),
              ),
            ),
            onLoaded: (event) {
              _gridStateManagerTrip = event.stateManager;
              _gridStateManagerTrip!.setPage(1, notify: false);
              _gridStateManagerTrip!.setPageSize(_rowsPerPage, notify: false);
              setState(() {});
            },
          ),
        ),
        if (_gridStateManagerTrip != null)
          PlutoGridPagination(
            stateManager: _gridStateManagerTrip!,
            totalRows: filteredTrips.length,
            rowsPerPage: _rowsPerPage,
            onPageChanged: (page, rowsPerPage) {
              setState(() {
                _currentPageTrip = page;
                _rowsPerPage = rowsPerPage;

                final start = (page - 1) * rowsPerPage;
                final end = (start + rowsPerPage > filteredTrips.length)
                    ? filteredTrips.length
                    : start + rowsPerPage;

                final _paginatedTrip = filteredTrips.sublist(start, end);

                final rows = _paginatedTrip
                    .map((trip) => PlutoRow(cells: {
                          'id': PlutoCell(value: trip.id),
                          'requestDate': PlutoCell(
                              value:
                                  DateFormat('yyyy-MM-dd').format(trip.date)),
                          'tripCode': PlutoCell(value: trip.tripCode),
                          'tripDesc': PlutoCell(value: trip.tripDescription),
                          'amount':
                              PlutoCell(value: trip.totalAmount.toString()),
                          'currency': PlutoCell(value: trip.currency),
                          'Requester': PlutoCell(value: trip.requesterName),
                          'action': PlutoCell(value: ''),
                          'department': PlutoCell(value: trip.departmentName),
                          'roundTrip': PlutoCell(
                              value: trip.roundTrip == true ? 'Yes' : 'No'),
                          'source': PlutoCell(value: trip.source),
                          'destination': PlutoCell(value: trip.destination),
                          'departureDate': PlutoCell(
                              value: DateFormat('yyyy-MM-dd')
                                  .format(trip.departureDate)),
                          'returnDate': PlutoCell(
                              value: DateFormat('yyyy-MM-dd')
                                  .format(trip.returnDate)),
                          'expenditureOption': PlutoCell(
                              value: trip.expenditureOption == 0
                                  ? 'Fix Allowance'
                                  : 'Claim later'),
                        }))
                    .toList();

                _gridStateManagerTrip!.removeAllRows();
                _gridStateManagerTrip!.appendRows(rows);
              });
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Advance Requests Lists"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(50, 20, 50, 30),
        child: Container(
          height: 470,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: DateFilterDropdown(
                        onDateRangeChanged: _handleDateRangeChanged,
                        initialValue: _currentFilterType,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (_currentFilterType != null)
                      Chip(
                        label: Text(
                            'Filter: ${_currentFilterType!.replaceAll('_', ' ')}'),
                        onDeleted: () {
                          setState(() {
                            _currentDateRange = null;
                            _currentFilterType = null;
                          });
                          _applyFilter();
                        },
                      ),
                    const SizedBox(width: 16),
                    Flexible(
                      flex: 3,
                      child: CustomSearchBar(
                        onSearch: _handleSearch,
                        hintText: 'Search...',
                        minWidth: 500,
                        maxWidth: 800,
                      ),
                    ),
                  ],
                ),
              ),
              // Tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      TrapezoidTab(
                        label: "Advance Requests Lists",
                        isSelected: _selectedTab == 0,
                        onTap: () {
                          setState(() {
                            _selectedTab = 0;
                            _currentPage = 1;
                          });
                          _fetchAllData();
                        },
                      ),
                      TrapezoidTab(
                        label: "Approved Project Requests",
                        isSelected: _selectedTab == 1,
                        onTap: () {
                          setState(() {
                            _selectedTab = 1;
                            _currentPage = 1;
                          });
                          _fetchAllData();
                        },
                      ),
                      TrapezoidTab(
                        label: "Approved Trip Requests",
                        isSelected: _selectedTab == 2,
                        onTap: () {
                          setState(() {
                            _selectedTab = 2;
                            _currentPage = 1;
                          });
                          _fetchAllData();
                        },
                      ),
                      TrapezoidTab(
                        label: "New Operation Request",
                        isSelected: _selectedTab == 3,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const AdvanceRequestForm(advanceId: '0'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        child: IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _refreshData,
                          color: Colors.black,
                        ),
                      ),
                      ElevatedButton.icon(
                        label: const Text('Export'),
                        onPressed: exportToCSV,
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
              const SizedBox(height: 10),

              // Content area
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _selectedTab == 0
                        ? _buildAdvanceGrid()
                        : _selectedTab == 1
                            ? _buildProjectGrid()
                            : _selectedTab == 2
                                ? _buildTripGrid()
                                : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
