import 'dart:convert';
import 'dart:io';
import 'dart:html' as html;
import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:advance_budget_request_system/views/cashpaymentsettlemententry.dart';
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

class SettlementTable extends StatefulWidget {
  const SettlementTable({super.key});

  @override
  State<SettlementTable> createState() => _SettlementTableState();
}

class _SettlementTableState extends State<SettlementTable> {
   List<PlutoColumn> columns=[];
   List<PlutoRow> rows=[];
  final formatter = NumberFormat('#,##0');
  List<Settlement> settles = [];
  List<PlutoRow> _pagedRows = [];
  PlutoGridStateManager? stateManager;
  DateTimeRange? _currentDateRange;
  String? _currentFilterType;
  String _searchQuery = '';
  int _currentPage = 1;
  int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    fetchData();
    initColumn();

  }

  void initColumn() {
    columns = [
      PlutoColumn(
          title: 'Settlement Date',
          field: 'Settlement Date',
          type: PlutoColumnType.date(),
          textAlign: PlutoColumnTextAlign.left,
          width: 150,
          enableAutoEditing: false,
          enableEditingMode: false),
      PlutoColumn(
          title: 'Payment No',
          field: 'Payment No',
          type: PlutoColumnType.text(),
          width: 165,
          textAlign: PlutoColumnTextAlign.left,
          enableEditingMode: false,
          enableAutoEditing: false),
      PlutoColumn(
          title: 'Withdrawn Amount',
          field: 'Withdrawn Amount',
          width: 165,
          type: PlutoColumnType.text(),
          textAlign: PlutoColumnTextAlign.right,
          titleTextAlign: PlutoColumnTextAlign.right,
          enableAutoEditing: false,
          enableEditingMode: false),
      PlutoColumn(
          title: 'Settled Amount',
          field: 'Settled Amount',
          width: 165,
          type: PlutoColumnType.text(),
          textAlign: PlutoColumnTextAlign.right,
          titleTextAlign: PlutoColumnTextAlign.right,
          enableAutoEditing: false,
          enableEditingMode: false),
      PlutoColumn(
          title: 'Refund Amount',
          field: 'Refund Amount',
          width: 165,
          type: PlutoColumnType.text(),
          textAlign: PlutoColumnTextAlign.right,
          titleTextAlign: PlutoColumnTextAlign.right,
          enableAutoEditing: false,
          enableEditingMode: false),
      // PlutoColumn(
      //     title: 'Action',
      //     field: 'Action',
      //     type: PlutoColumnType.text(),
      //     enableAutoEditing: false),
      PlutoColumn(
        title: 'Action',
        field: 'Action',
        width: 165,
        type: PlutoColumnType.text(),
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        enableAutoEditing: false,
        enableEditingMode: false,
        renderer: (rendererContext) {
          return const IconButton(
              icon: Icon(Icons.more_horiz_outlined), onPressed: null);
        },
      ),
    ];
  }

  void fetchData() async {
    List<Settlement> settled = await ApiService().fetchSettlements();
    // final formatter = NumberFormat('#,##0');
    setState(() {
      settles = settled;
    });
    _applyDateFilter();
  }

  void _applyDateFilter() {
    List<Settlement> filteredSettles = settles;

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

      filteredSettles = settles.where((settle) {
        final tripDate = DateTime(settle.settlementDate.year,
            settle.settlementDate.month, settle.settlementDate.day);
        return tripDate.isAtSameMomentAs(startDate) ||
            (tripDate.isAfter(startDate) && tripDate.isBefore(endDate));
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filteredSettles = filteredSettles
          .where((settle) => SearchUtils.matchesSearchSettlement(settle, _searchQuery))
          .toList();
    }

    final newRows = _buildRows(filteredSettles);
    setState(() {
      rows = newRows;
      _currentPage = 1;
    });

    _updatePagedRows();
  }

  void _updatePagedRows() {
    final start = (_currentPage - 1) * _rowsPerPage;
    final end = (_currentPage * _rowsPerPage).clamp(0, rows.length);
    setState(() {
      _pagedRows = rows.sublist(start, end);
    });

    if (stateManager != null) {
      stateManager!.removeAllRows();
      stateManager!.appendRows(_pagedRows);
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

  List<PlutoRow> _buildRows(List<Settlement> settles) {
    return settles.map((settled) {
      return PlutoRow(cells: {
        'Settlement Date': PlutoCell(value: settled.settlementDate),
        'Payment No': PlutoCell(value: settled.paymentNo),
        'Withdrawn Amount':
            PlutoCell(value: formatter.format(settled.withdrawnAmount)),
        'Settled Amount':
            PlutoCell(value: formatter.format(settled.settleAmount)),
        'Refund Amount':
            PlutoCell(value: formatter.format(settled.refundAmount)),
        'Action': PlutoCell(
            value: IconButton(
                onPressed: null, icon: Icon(Icons.more_horiz_outlined)))
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
      List<Settlement> settlement = await ApiService().fetchSettlements();
      setState(() {
        settles = settlement;
      });

      _applyDateFilter(); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to refresh settle: ${e.toString()}')),
      );
    }
  }

  //Export button
  Future<void> exportToCSV() async{
    try {
      List<List<dynamic>> csvData=[];
      csvData.add(
        [
          "Settlement Date",
          "Payment No",
          "Payment Date",
          "Withdrawn Amount",
          "Settled Amount",
          "Refund Amount",
          
        ]
      );
      for(var settle in settles){
        csvData.add([
          DateFormat('yyyy-MM-dd').format(settle.settlementDate),
          settle.paymentNo,
          DateFormat('yyyy-MM-dd').format(settle.paymentDate),
          settle.withdrawnAmount,
          settle.settleAmount,
          settle.refundAmount
        ]);
      }
      String csv=const ListToCsvConverter().convert(csvData);
      if (kIsWeb) {
        final bytes= utf8.encode(csv);
        final blob=html.Blob([bytes]);
        final url=html.Url.createObjectUrlFromBlob(blob);
        final anchor= html.AnchorElement(href: url)
          ..setAttribute("download", "settlement.csv")
          ..click();
        
        html.Url.revokeObjectUrl(url);
        print("CSV file download in browser");
      }else{
        final directory= await getApplicationDocumentsDirectory();
        final path= "${directory.path}/settlement.csv";
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
      // appBar: AppBar(
      //   title: const Text("Settlement Page"),
      // ),
      body: Padding(
         padding: const EdgeInsets.fromLTRB(90, 20, 90, 20),
        child: Column(
          children: [
            const Center(
              child: Text(
                "Settlement Page",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
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
                  label:
                      Text('Filter: ${_currentFilterType!.replaceAll('_', ' ')}'),
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
                      MaterialPageRoute(builder: (context) => PaymentPage()),
                    );
                    if (success == true) fetchData();
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
                  IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
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
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.only(right: 100, left: 100, top: 20),
                  child: Container(
                    height: 300,
                    child: PlutoGrid(
                      columns: columns,
                      rows: _pagedRows,
                      onLoaded: (PlutoGridOnLoadedEvent event) {
                        stateManager = event.stateManager;
                        _updatePagedRows();
                      },
                      configuration: PlutoGridConfiguration(
                          style: PlutoGridStyleConfig(
                              oddRowColor: Colors.blue[50],
                      rowHeight: 35,
                      activatedColor: Colors.lightBlueAccent.withOpacity(0.2),)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
              if (stateManager != null)
                PlutoGridPagination(
                  stateManager: stateManager!,
                  totalRows: rows.length,
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
