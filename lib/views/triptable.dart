import 'dart:convert';
import 'dart:html' as html;
import 'dart:io';
import 'package:advance_budget_request_system/views/data.dart';
import 'package:advance_budget_request_system/views/datefilter.dart';
import 'package:advance_budget_request_system/views/pagination.dart';
import 'package:advance_budget_request_system/views/searchfunction.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:intl/intl.dart';
import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:advance_budget_request_system/views/tripForm.dart';

class TripInformation extends StatefulWidget {
  final UserModel currentUser;
  final String tripId;
  const TripInformation({
    Key? key,
    required this.currentUser,
    required this.tripId,
  }) : super(key: key);

  @override
  _TripInformationState createState() => _TripInformationState();
}

class _TripInformationState extends State<TripInformation> {
  List<PlutoColumn> _columns = [];
  List<PlutoRow> _rows = [];
  List<PlutoRow> _pagedRows = [];
  List<Trips> _allTrips = [];
  DateTimeRange? _currentDateRange;
  String? _currentFilterType;
  PlutoGridStateManager? _stateManager;
  final NumberFormat _formatter = NumberFormat('#,###');
  String _searchQuery = '';
  int _currentPage = 1;
  int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _columns = _buildColumns();
    _fetchTableRows();
  }

  void _fetchTableRows() async {
    try {
      List<Trips> trips = await ApiService().fetchTrips();
      setState(() {
        _allTrips = trips;
      });
      _applyDateFilter();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load trips: ${e.toString()}')),
      );
    }
  }

  void _applyDateFilter() {
    List<Trips> filteredTrips = _allTrips;

    if (_currentDateRange != null) {
      final startDate = DateTime(
        _currentDateRange!.start.year,
        _currentDateRange!.start.month,
        _currentDateRange!.start.day,
      );
      final endDate = DateTime(
        _currentDateRange!.end.year,
        _currentDateRange!.end.month,
        _currentDateRange!.end.day,
      ).add(const Duration(days: 1));

      filteredTrips = _allTrips.where((trip) {
        final tripDate =
            DateTime(trip.date.year, trip.date.month, trip.date.day);
        return tripDate.isAtSameMomentAs(startDate) ||
            (tripDate.isAfter(startDate) && tripDate.isBefore(endDate));
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filteredTrips = filteredTrips
          .where((trip) => SearchUtils.matchesSearchTrip(trip, _searchQuery))
          .toList();
    }

    final newRows = _buildRows(filteredTrips);
    setState(() {
      _rows = newRows;
      _currentPage = 1;
    });

    _updatePagedRows();
  }

  void _updatePagedRows() {
    final start = (_currentPage - 1) * _rowsPerPage;
    final end = (_currentPage * _rowsPerPage).clamp(0, _rows.length);
    setState(() {
      _pagedRows = _rows.sublist(start, end);
    });

    if (_stateManager != null) {
      _stateManager!.removeAllRows();
      _stateManager!.appendRows(_pagedRows);
    }
  }

  void _handleDateRangeChange(DateTimeRange range, String selectedValue) {
    setState(() {
      _currentDateRange = range;
      _currentFilterType = selectedValue;
    });
    _applyDateFilter();
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyDateFilter();
  }

  void _editTrip(PlutoRow row) async {
    final tripId = row.cells['id']!.value;
    final trip = await ApiService().getTripById(tripId);
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
      if (success == true) _fetchTableRows();
    }
  }

  void _detailTrip(PlutoRow row) async {
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
      if (success == true) _fetchTableRows();
    }
  }

  void _deleteTrip(PlutoRow row) async {
    final tripId = row.cells['id']!.value;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this trip?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      await ApiService().deleteTrip(tripId);
      _fetchTableRows();
    }
  }

  List<PlutoColumn> _buildColumns() {
    return [
      PlutoColumn(
          title: 'Date',
          field: 'date',
          type: PlutoColumnType.text(),
          width: 100,
          enableEditingMode: false),
      PlutoColumn(
          title: 'Trip Code',
          field: 'tripcode',
          type: PlutoColumnType.text(),
          width: 142,
          enableEditingMode: false),
      PlutoColumn(
          title: 'Description',
          field: 'description',
          type: PlutoColumnType.text(),
          width: 390,
          enableEditingMode: false),
      PlutoColumn(
        title: 'Total Amount',
        field: 'totalamount',
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
          title: 'Department',
          field: 'department',
          type: PlutoColumnType.text(),
          width: 120,
          enableEditingMode: false),
      PlutoColumn(
        title: 'Action',
        field: 'action',
        type: PlutoColumnType.text(),
        width: 165,
        enableEditingMode: false,
        renderer: (rendererContext) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editTrip(rendererContext.row)),
              IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteTrip(rendererContext.row)),
              IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () => _detailTrip(rendererContext.row)),
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

 

  void _refreshData() async {
    setState(() {
      _searchQuery = "";
      _currentDateRange = null;
      _currentFilterType = null;
      _currentPage = 1;
    });

    try {
      List<Trips> trips = await ApiService().fetchTrips();
      setState(() {
        _allTrips = trips;
      });

      _applyDateFilter(); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to refresh trips: ${e.toString()}')),
      );
    }
  }

  //Export button
  Future<void> exportToCSV() async{
    try {
      List<List<dynamic>> csvData=[];
      csvData.add(
        [
          "Request Date",
          "Trip Code",
          "Trip Description",
          "Round Trip",
          "Source",
          "Destination",
          "DepartureDate",
          "Return Date",
          "Requester Name",
          "Department",
          "Total Amount",
          "Currency",
          "Direct AdvanceRequest",
          "Expenduiture Option"
          
        ]
      );
      for(var trip in _allTrips){
        csvData.add([
          DateFormat('yyyy-MM-dd').format(trip.date),
          trip.tripCode,
          trip.tripDescription,
          trip.roundTrip==true? "Yes" : 'No',
          trip.source,
          trip.destination,
          DateFormat('yyyy-MM-dd').format(trip.departureDate),
          DateFormat('yyyy-MM-dd').format(trip.returnDate),
          trip.requesterName,
          trip.departmentName,
          trip.totalAmount,
          trip.currency,
          trip.directAdvanceReq==true? "Yes": "No",
          trip.expenditureOption == 0 ? 'Fix Allowance' : 'Claim Later',
        ]);
      }
      String csv=const ListToCsvConverter().convert(csvData);
      if (kIsWeb) {
        final bytes= utf8.encode(csv);
        final blob=html.Blob([bytes]);
        final url=html.Url.createObjectUrlFromBlob(blob);
        final anchor= html.AnchorElement(href: url)
          ..setAttribute("download", "tripData.csv")
          ..click();
        
        html.Url.revokeObjectUrl(url);
        print("CSV file download in browser");
      }else{
        final directory= await getApplicationDocumentsDirectory();
        final path= "${directory.path}/tripData.csv";
        final file=File(path);
        await file.writeAsString(csv);

        print("CSV file saved to $path");
      }
    } catch (e) {
      print("Error exporting to CSV: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Trip Information')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(90, 20, 90, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Flexible(
                flex: 1,
                child: DateFilterDropdown(
                  onDateRangeChanged: _handleDateRangeChange,
                  selectedValue: _currentFilterType,
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
                    _applyDateFilter();
                  },
                ),
              const SizedBox(width: 20),
              Flexible(
                flex: 3,
                child: CustomSearchBar(
                  onSearch: _handleSearch,
                  hintText: 'Search...',
                  minWidth: 500,
                  maxWidth: 800,
                ),
              ),
            ]),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('New'),
                  onPressed: () async {
                    final success = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TripRequestForm(
                          currentUser: widget.currentUser,
                          tripId: "0",
                        ),
                      ),
                    );
                    if (success == true) _fetchTableRows();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                ),
                Row(children: [
                  IconButton(
                      icon: const Icon(Icons.refresh), onPressed: _refreshData),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download),
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
                ])
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: PlutoGrid(
                columns: _columns,
                rows: _pagedRows,
                mode: PlutoGridMode.normal,
                configuration: PlutoGridConfiguration(
                  style: PlutoGridStyleConfig(
                    oddRowColor: Colors.blue[50],
                    rowHeight: 35,
                    activatedColor: Colors.lightBlueAccent.withOpacity(0.2),
                  ),
                ),
                onLoaded: (event) {
                  _stateManager = event.stateManager;
                  _updatePagedRows();
                },
              ),
            ),
            const SizedBox(height: 10),
            if (_stateManager != null)
              PlutoGridPagination(
                stateManager: _stateManager!,
                totalRows: _rows.length,
                rowsPerPage: _rowsPerPage,
                onPageChanged: (page, limit) {
                  _currentPage = page;
                  _rowsPerPage = limit;
                  _updatePagedRows();
                },
              ),
          ],
        ),
      ),
    );
  }
}
