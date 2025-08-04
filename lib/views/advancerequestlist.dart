import 'dart:convert';
import 'dart:io';
import 'dart:html' as html;
import 'package:advance_budget_request_system/views/api_service.dart';
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
import 'package:advance_budget_request_system/views/advanceRequestFormOperation.dart';
import 'package:advance_budget_request_system/views/advanceRequestProjectTripTable.dart.dart';

class AdvanceRequestPage extends StatefulWidget {
  @override
  _AdvanceRequestPageState createState() => _AdvanceRequestPageState();
}

class _AdvanceRequestPageState extends State<AdvanceRequestPage> {
  List<PlutoColumn> _columns = [];
  List<PlutoRow> _rows = [];
  List<Advance> advances = [];
  List<PlutoRow> _pagedRows = [];
  String _searchQuery = '';
  DateTimeRange? _currentDateRange;
  String? _currentFilterType;
  PlutoGridStateManager? _stateManager;
  final NumberFormat _formatter = NumberFormat('#,###');
  bool _isLoading = true;
  String _errorMessage = '';
  int _currentPage = 1;
  int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _columns = _buildColumns();
    // _rows = _buildRows();
    _fetchAdvanceRequest();
    print(" Rows loaded: ${_rows.length}");
  }

  void _fetchAdvanceRequest() async {
    try {
      print('Fetch Advances....');
      List<Advance> advanceRequest = await ApiService().fetchAdvanceRequests();
      print('fetch ${advanceRequest.length} advances');
      setState(() {
        advances = advanceRequest;
      });
      _applyDateFilter();
    } catch (e) {
      print('Failed to fetch trips: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load trips: ${e.toString()}')),
      );
    }
  }

  void _applyDateFilter() {
    List<Advance> filteredAdvance = advances;

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
      ).add(const Duration(days: 1)); // Include the entire end day

      filteredAdvance = advances.where((advance) {
        // Create date-only object for the trip
        final tripDate = DateTime(
          advance.date.year,
          advance.date.month,
          advance.date.day,
        );

        return tripDate.isAtSameMomentAs(startDate) ||
            (tripDate.isAfter(startDate) && tripDate.isBefore(endDate));
      }).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filteredAdvance = filteredAdvance
          .where((advance) =>
              SearchUtils.matchesSearchAdvance(advance, _searchQuery))
          .toList();
    }

    final newRows = _buildRows(filteredAdvance);
    setState(() {
      _rows = newRows;
      _currentPage = 1;
    });
    _updatePagedRows();

    // if (_stateManager != null) {
    //   _stateManager!.removeAllRows();
    //   _stateManager!.appendRows(newRows);
    // }
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

  List<PlutoColumn> _buildColumns() {
    return [
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
                    builder: (context) => const AdvanceRequestForm(),
                  ),
                );
              }
            },
          );
        },
      ),
    ];
  }

  List<PlutoRow> _buildRows(List<Advance> advanceList) {
  return advanceList.map((advance) {
    return PlutoRow(cells: {
      'requestdate': PlutoCell(value: DateFormat('yyyy-MM-dd').format(advance.date)),
      'requestno': PlutoCell(value: advance.requestNo),
      'requesttype': PlutoCell(value: advance.requestType),
      'requestcode': PlutoCell(value: advance.requestCode),
      'requestamount': PlutoCell(value: advance.requestAmount),
      'currency': PlutoCell(value: advance.currency),
      'requester': PlutoCell(value: advance.requester),
      'action': PlutoCell(value: '')
    });
  }).toList();
}


  void _refreshData() async{
    setState(() {
      _searchQuery = "";
      _currentDateRange = null;
      _currentFilterType = null;
      _currentPage = 1;
    });
    try {
      List<Advance> advance = await ApiService().fetchAdvanceRequests();
      setState(() {
        advances = advance;
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
      for(var advance in advances){
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
      String csv=const ListToCsvConverter().convert(csvData);
      if (kIsWeb) {
        final bytes= utf8.encode(csv);
        final blob=html.Blob([bytes]);
        final url=html.Url.createObjectUrlFromBlob(blob);
        final anchor= html.AnchorElement(href: url)
          ..setAttribute("download", "advance.csv")
          ..click();
        
        html.Url.revokeObjectUrl(url);
        print("CSV file download in browser");
      }else{
        final directory= await getApplicationDocumentsDirectory();
        final path= "${directory.path}/advance.csv";
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
      appBar:
          AppBar(title: const Text('Advance Request List '), centerTitle: true),
      // body: _rows.isEmpty
      // ? Center(child: CircularProgressIndicator())
      body: Padding(
        padding: const EdgeInsets.fromLTRB(50, 20, 50, 30),
        child: Container(
          height: 470,
          child: Column(
            children: [
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: DateFilterDropdown(
                      onDateRangeChanged: _handleDateRangeChange,
                      initialValue: _currentFilterType,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Add filter indicator chip
                  if (_currentFilterType != null)
                    Chip(
                      label: Text(
                        'Filter: ${_currentFilterType!.replaceAll('_', ' ')}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      onDeleted: () {
                        setState(() {
                          _currentDateRange = null;
                          _currentFilterType = null;
                        });
                        _applyDateFilter();
                      },
                    ),
                  const SizedBox(
                    width: 20,
                  ),
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
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 150,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down,
                                color: Colors.black),
                            style: const TextStyle(
                                color: Colors.black, fontSize: 16),
                            hint: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                children: [
                                  Icon(Icons.add, color: Colors.black),
                                  SizedBox(width: 8),
                                  Text('New',
                                      style: TextStyle(color: Colors.black)),
                                ],
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'operation_advance',
                                child: Text('Request Operation Advance'),
                              ),
                              DropdownMenuItem(
                                value: 'project_trip',
                                child: Text('Request Project or Trip Request'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == 'operation_advance') {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AdvanceRequestForm()));
                              } else if (value == 'project_trip') {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AdvanceProjectTripTable()));
                              }
                            },
                          ),
                        ),
                      )
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
              const SizedBox(height: 7),
              Expanded(
                child: PlutoGrid(
                    columns: _columns,
                    rows: _pagedRows,
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
                    }),
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
      ),
    );
  }
}
