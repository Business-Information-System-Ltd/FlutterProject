import 'dart:convert';
import 'dart:io';
import 'dart:html' as html;
import 'package:advance_budget_request_system/views/cashpaymentEntry.dart';
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

class CashPaymentPage extends StatefulWidget {
  @override
  _CashPaymentPageState createState() => _CashPaymentPageState();
}

class _CashPaymentPageState extends State<CashPaymentPage> {
  List<PlutoColumn> _columns = [];
  List<Payment> _allPayments = [];
  List<Payment> _filteredDraftPayments = [];
  List<Payment> _filteredPostedPayments = [];
  PlutoGridStateManager? _stateManagerDraft;
  PlutoGridStateManager? _stateManagerPosted;

  final NumberFormat _formatter = NumberFormat('#,###');
  bool _isLoading = true;
  String _searchQuery = '';
  DateTimeRange? _currentDateRange;
  String? _currentFilterType;

  int _currentDraftPage = 1;
  int _currentPostedPage = 1;
  int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _columns = _buildColumns();
    _loadPayments();
  }

  void _loadPayments() async {
    try {
      final payments = await ApiService().fetchPayments();
      setState(() {
        _allPayments = payments;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading payments: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    // Apply both date filter and search filter to all payments
    List<Payment> filtered = _allPayments;

    // Apply date filter
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

      filtered = filtered.where((payment) {
        final paymentDate = DateTime(
          payment.date.year,
          payment.date.month,
          payment.date.day,
        );
        return paymentDate.isAtSameMomentAs(startDate) ||
            (paymentDate.isAfter(startDate) && paymentDate.isBefore(endDate));
      }).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((payment) =>
              SearchUtils.matchesSearchPayment(payment, _searchQuery))
          .toList();
    }

    setState(() {
      _filteredDraftPayments =
          filtered.where((p) => p.status == 'Draft').toList();
      _filteredPostedPayments =
          filtered.where((p) => p.status == 'Posted').toList();
      _currentDraftPage = 1; 
      _currentPostedPage = 1;
    });

    if (_stateManagerDraft != null) {
      _stateManagerDraft!.removeAllRows();
      _stateManagerDraft!.appendRows(_mapPaymentsToRows(
          _getPaginatedPayments(_filteredDraftPayments, _currentDraftPage)));
    }
    if (_stateManagerPosted != null) {
      _stateManagerPosted!.removeAllRows();
      _stateManagerPosted!.appendRows(_mapPaymentsToRows(
          _getPaginatedPayments(_filteredPostedPayments, _currentPostedPage)));
    }
  }

  List<Payment> _getPaginatedPayments(List<Payment> payments, int page) {
    final start = (page - 1) * _rowsPerPage;
    final end = start + _rowsPerPage;
    return payments.sublist(
      start,
      end > payments.length ? payments.length : end,
    );
  }

  void _handleDateRangeChange(DateTimeRange range, String selectedValue) {
    setState(() {
      _currentDateRange = range;
      _currentFilterType = selectedValue;
    });
    _applyFilters();
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  List<PlutoRow> _mapPaymentsToRows(List<Payment> payments) {
    return payments.map((p) {
      return PlutoRow(
        cells: {
          'id': PlutoCell(value: p.id),
          'paymentdate': PlutoCell(
              value: DateFormat('yyyy-MM-dd').parse(p.date.toString())),
          'paymentno': PlutoCell(value: p.paymentNo),
          'requestno': PlutoCell(value: p.requestNo),
          'paymentamount': PlutoCell(value: p.paymentAmount),
          'currency': PlutoCell(value: p.currency),
          'paymentmethod': PlutoCell(value: p.paymentMethod),
          'status': PlutoCell(value: p.status),
          'action': PlutoCell(value: ''),
        },
      );
    }).toList();
  }

  List<PlutoColumn> _buildColumns() {
    return [
      PlutoColumn(
        title: 'ID',
        field: 'id',
        type: PlutoColumnType.text(),
        width: 60,
        enableEditingMode: false,
        hide: true, 
      ),
      PlutoColumn(
        title: 'Payment Date',
        field: 'paymentdate',
        type: PlutoColumnType.date(),
        width: 150,
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Payment No',
        field: 'paymentno',
        type: PlutoColumnType.text(),
        width: 150,
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
        width: 160,
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Action',
        field: 'action',
        type: PlutoColumnType.text(),
        width: 170,
        renderer: (rendererContext) {
          final status = rendererContext.row.cells['status']?.value;
          return Row(
            children: [
              // IconButton(
              //   icon: const Icon(Icons.edit, color: Colors.blue),
              //   tooltip: 'Edit',
              //   onPressed: ()=> _editPayment(rendererContext.row),
              // ),
              // IconButton(
              //   icon: const Icon(Icons.more_horiz_outlined, color: Colors.blue),
              //   tooltip: 'Detail',
              //   onPressed: ()=> _detailPayment(rendererContext.row),
              // ),
              
            // Conditionally show Edit and Post icons for 'Draft' status
            if (status == 'Draft') ...[
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                tooltip: 'Edit',
                onPressed: () => _editPayment(rendererContext.row),
              ),
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                tooltip: 'Post',
                onPressed: () => _postedPayment(rendererContext.row),
              ),
            ],
             IconButton(
              icon: const Icon(Icons.more_horiz_outlined),
              tooltip: 'Detail',
              onPressed: () => _detailPayment(rendererContext.row),
            ),
            
            
            ],
          );
        },
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
      ),
    ];
  }

  void _handleDraftPageChange(int page, int rowsPerPage) {
    setState(() {
      _currentDraftPage = page;
      _rowsPerPage = rowsPerPage;
    });
  }

  void _handlePostedPageChange(int page, int rowsPerPage) {
    setState(() {
      _currentPostedPage = page;
      _rowsPerPage = rowsPerPage;
    });
  }

  void _postedPayment(PlutoRow row) async {
  try {
    final cashId = row.cells['id']?.value;
    if (cashId == null) {
      throw Exception('Payment ID not found');
    }
    final paymentToPost = await ApiService().getPaymentById(cashId);

    if (paymentToPost != null) {
      final updatedPayment = paymentToPost.copyWith(status: 'Posted');
    await ApiService().updatePayment(updatedPayment);
      // if (success) _refreshData();
      setState(() {
        _refreshData();
        _loadPayments();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment posted successfully!')),
      );

      _refreshData();
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error posting payment: $e')),
    );
    print('ERROR posting payment: $e');
  }
}

  Widget buildGrid(List<PlutoRow> rows) {
    return PlutoGrid(
      columns: _columns,
      rows: rows,
      configuration: PlutoGridConfiguration(
        style: PlutoGridStyleConfig(
          oddRowColor: Colors.blue[50],
          rowHeight: 35,
          activatedColor: Colors.lightBlueAccent.withOpacity(0.2),
        ),
      ),
      onLoaded: (event) {
        _stateManagerDraft = event.stateManager;
        _stateManagerPosted = event.stateManager;
      },
    );
  }

  void _refreshData() async{
    setState(() {
      _searchQuery = "";
      _currentDateRange = null;
      _currentFilterType = null;
      _currentDraftPage = 1;
      _currentPostedPage=1;
    });
    try {
      List<Payment> payments=await ApiService().fetchPayments();
      setState(() {
        payments=payments;
      });
      _applyFilters();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to refresh payments: ${e.toString()}')),
      );
    }
  }

  //Export button
  Future<void> exportToCSV() async{
    try {
      List<List<dynamic>> csvData=[];
      csvData.add([
        "Payment Date",
        "Payment No",
        "Request No",
        "Request Type",
        "Payment Amount",
        "Currency",
        "Payment Method",
        "Paid Person",
        "Received Person",
        "Payment Note"
      ]);
      for(var payment in _allPayments){
        csvData.add([
          DateFormat('yyyy-MM-dd').format(payment.date),
          payment.paymentNo,
          payment.requestNo,
          payment.requestType,
          payment.paymentAmount,
          payment.currency,
          payment.paymentMethod,
          payment.paidPerson,
          payment.receivedPerson,
          payment.paymentNote

        ]);
      }
      String csv=const ListToCsvConverter().convert(csvData);
      if (kIsWeb) {
        final bytes= utf8.encode(csv);
        final blob=html.Blob([bytes]);
        final url=html.Url.createObjectUrlFromBlob(blob);
        final anchor= html.AnchorElement(href: url)
          ..setAttribute("download", "payment.csv")
          ..click();
        
        html.Url.revokeObjectUrl(url);
        print("CSV file download in browser");
      }else{
        final directory= await getApplicationDocumentsDirectory();
        final path= "${directory.path}/payment.csv";
        final file=File(path);
        await file.writeAsString(csv);

        print("CSV file saved to $path");
      }
    } catch (e) {
      print("Error exporting to CSV: $e");
    }
  }

  //edit 
  void _editPayment(PlutoRow row) async{
    try{
   final cashId = row.cells['id']?.value;
    if (cashId == null) {
      throw Exception('Payment ID not found');
    };
    final cash= await ApiService().getPaymentById(cashId);
    
    if (cash!=null) {
      final success= await Navigator.push(context, MaterialPageRoute(builder: (context)=> CashPaymentFormScreen(cashId: cashId,payment: cash, isEditMode: true, )));
      if(success==true) _refreshData();
    }
    }catch(e){
       ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error editing payment: $e')),
    );
    print('ERROR:$e ');
    }
  }

  //detail
  void _detailPayment(PlutoRow row) async{
    final cashId= row.cells['id']!.value;
    final cash= await ApiService().getPaymentById(cashId);

    if (cash!=null) {
      final success= await Navigator.push(context, MaterialPageRoute(builder: (context)=> CashPaymentFormScreen(cashId: cashId,payment: cash, isViewMode: true, )));
      if(success==true) _refreshData();
    }
  }


  @override
  Widget build(BuildContext context) {
    final paginatedDrafts =
        _getPaginatedPayments(_filteredDraftPayments, _currentDraftPage);
    final paginatedPosted =
        _getPaginatedPayments(_filteredPostedPayments, _currentPostedPage);

    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cash Payment Lists'),
          toolbarHeight: 35,
          centerTitle: true,
          bottom: const TabBar(
            labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            indicatorWeight: 4,
            labelColor: Colors.blue,
            tabs: [
              Tab(text: 'Draft'),
              Tab(text: 'Posted'),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
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
                        _applyFilters();
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
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('New'),
                    onPressed: () async {
                      final success = await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => AdvancePage()),
                      );
                      if (success == true) _loadPayments();
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
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _refreshData,
                        color: Colors.black,
                      ),
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
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Expanded(
                child: TabBarView(
                  children: [
                    Column(
                      children: [
                         Expanded(child: buildDraftGrid(_mapPaymentsToRows(paginatedDrafts))),
                        if (_stateManagerDraft != null)
                          PlutoGridPagination(
                            stateManager: _stateManagerDraft!,
                            totalRows: _filteredDraftPayments.length,
                            rowsPerPage: _rowsPerPage,
                            onPageChanged: _handleDraftPageChange,
                          ),
                      ],
                    ),
                    Column(
                      children: [
                        Expanded(child: buildPostedGrid(_mapPaymentsToRows(paginatedPosted))),
                        if (_stateManagerPosted != null)
                          PlutoGridPagination(
                            stateManager: _stateManagerPosted!,
                            totalRows: _filteredPostedPayments.length,
                            rowsPerPage: _rowsPerPage,
                            onPageChanged: _handlePostedPageChange,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget buildDraftGrid(List<PlutoRow> rows) {
  return PlutoGrid(
    columns: _columns,
    rows: rows,
    onLoaded: (event) => _stateManagerDraft = event.stateManager,
    configuration: PlutoGridConfiguration(
      style: PlutoGridStyleConfig(
        oddRowColor: Colors.blue[50],
        rowHeight: 35,
        activatedColor: Colors.lightBlueAccent.withOpacity(0.2),
      ),
    ),
  );
}

Widget buildPostedGrid(List<PlutoRow> rows) {
  return PlutoGrid(
    columns: _columns,
    rows: rows,
    onLoaded: (event) => _stateManagerPosted = event.stateManager,
    configuration: PlutoGridConfiguration(
      style: PlutoGridStyleConfig(
        oddRowColor: Colors.blue[50],
        rowHeight: 35,
        activatedColor: Colors.lightBlueAccent.withOpacity(0.2),
      ),
    ),
  );
}

}
