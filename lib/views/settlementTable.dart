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
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:intl/intl.dart';

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

class SettlementTable extends StatefulWidget {
  const SettlementTable({super.key});

  @override
  State<SettlementTable> createState() => _SettlementTableState();
}

class _SettlementTableState extends State<SettlementTable> {
  List<PlutoColumn> columns = [];
  List<PlutoRow> rows = [];
  int _selectedTab = 0;
  final formatter = NumberFormat('#,##0');
  List<Settlement> settles = [];
  List<Settlement> filteredSettle = [];
  List<Payment> payments = [];
  List<Payment> filteredPayment = [];
  List<PlutoRow> _pagedRows = [];
  PlutoGridStateManager? _girdStateManagerSettled;
  PlutoGridStateManager? _gridStateManagerPayment;
  DateTimeRange? _currentDateRange;
  String? _currentFilterTypePayment;
  String? _currentFilterTypeSettle;
  String _searchQuery = '';
  int _currentPage = 1;
  int _currentPagePayment = 1;
  int _rowsPerPage = 10;
  bool _loading = true;
  String? _globalDateFilterType;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      _loading = true;
    });
    try {
      settles = await ApiService().fetchSettlements();
      filteredSettle = List.from(settles);
      payments = (await ApiService().fetchPayments())
          .where((p) => p.status.toLowerCase() == "posted")
          .toList();
      filteredPayment = List.from(payments);
      _applyCurrentTabFilter();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
    setState(() {
      _loading = false;
    });
  }

  List<Payment> get _paginatedPayments {
    final total = filteredPayment.length;
    if (total == 0) return [];
    final start = ((_currentPagePayment - 1) * _rowsPerPage).clamp(0, total);
    final end = (start + _rowsPerPage).clamp(0, total);
    return filteredPayment.sublist(start, end);
  }

  List<Settlement> get _paginatedSettled {
    final total = filteredSettle.length;
    if (total == 0) return [];
    final start = ((_currentPage - 1) * _rowsPerPage).clamp(0, total);
    final end = (start + _rowsPerPage).clamp(0, total);
    return filteredSettle.sublist(start, end);
  }

  void _handleDateRangeChange(DateTimeRange range, String selectedValue) {
    setState(() {
      switch (_selectedTab) {
        case 0:
          _currentDateRange = range;
          _currentFilterTypeSettle = selectedValue;
          _applySettledFilter();
          break;
        case 1:
          _currentDateRange = range;
          _currentFilterTypePayment = selectedValue;
          _applyPaymentFilter();
          break;
      }
    });
  }

  void _applyCurrentTabFilter() {
    switch (_selectedTab) {
      case 0:
        _applySettledFilter();
        break;
      case 1:
        _applyPaymentFilter();
      default:
    }
  }

  void _applySettledFilter() {
    filteredSettle = List.from(settles);

    if (_searchQuery.isNotEmpty) {
      filteredSettle = filteredSettle.where((settle) {
        return SearchUtils.matchesSearchSettlement(settle, _searchQuery);
      }).toList();
    }
    if (_currentDateRange != null) {
      filteredSettle = filteredSettle.where((settle) {
        return settle.settlementDate.isAfter(_currentDateRange!.start) &&
            settle.settlementDate
                .isBefore(_currentDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }
    _currentPage = 1;
    if (_girdStateManagerSettled != null) {
      final rows = _getSettleRows(_paginatedSettled);
      _girdStateManagerSettled!.setPage(1);
      _girdStateManagerSettled!.removeAllRows();
      _girdStateManagerSettled!.appendRows(rows);
      _girdStateManagerSettled!.resetCurrentState();
      _girdStateManagerSettled!.notifyListeners();
    }
  }

  void _applyPaymentFilter() {
    filteredPayment = List.from(payments);
    if (_searchQuery.isNotEmpty) {
      filteredPayment = filteredPayment.where((payment) {
        return SearchUtils.matchesSearchPayment(payment, _searchQuery);
      }).toList();
    }
    if (_currentDateRange != null) {
      filteredPayment = filteredPayment.where((payment) {
        return payment.date.isAfter(_currentDateRange!.start) &&
            payment.date
                .isBefore(_currentDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }
    _currentPagePayment = 1;
    if (_gridStateManagerPayment != null) {
      final rows = _getPaymentRows(_paginatedPayments);
      _gridStateManagerPayment!.setPage(1);
      _gridStateManagerPayment!.removeAllRows();
      _gridStateManagerPayment!.appendRows(rows);
      _gridStateManagerPayment!.resetCurrentState();
      _gridStateManagerPayment!.notifyListeners();
    }
  }

  List<PlutoRow> _getSettleRows(List<Settlement> data) {
    return data
        .map((settled) => PlutoRow(cells: {
              'id': PlutoCell(value: settled.id),
              'Settlement Date': PlutoCell(value: settled.settlementDate),
              'Payment No': PlutoCell(value: settled.paymentNo),
              'Withdrawn Amount':
                  PlutoCell(value: formatter.format(settled.withdrawnAmount)),
              'Settled Amount':
                  PlutoCell(value: formatter.format(settled.settleAmount)),
              'Refund Amount':
                  PlutoCell(value: formatter.format(settled.refundAmount)),
              'Action': PlutoCell(
                  value: const IconButton(
                      onPressed: null, icon: Icon(Icons.more_horiz_outlined)))
            }))
        .toList();
  }

  List<PlutoRow> _getPaymentRows(List<Payment> data) {
    return data
        .map((payment) => PlutoRow(cells: {
              'id': PlutoCell(value: payment.id),
              'paymentdate': PlutoCell(value: payment.date),
              'paymentno': PlutoCell(value: payment.paymentNo),
              'requesttype': PlutoCell(value: payment.requestType),
              'paymentamount': PlutoCell(value: payment.paymentAmount),
              'currency': PlutoCell(value: payment.currency),
              'paymentmethod': PlutoCell(value: payment.paymentMethod),
              'action': PlutoCell(value: '')
            }))
        .toList();
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
      _applyCurrentTabFilter();
    });
  }

  String? _getCurrentFilterType() {
    switch (_selectedTab) {
      case 0:
        return _currentFilterTypeSettle;
      case 1:
        return _currentFilterTypePayment;
      default:
        return null;
    }
  }

  void _clearCurrentFilter() {
    setState(() {
      switch (_selectedTab) {
        case 0:
          _currentDateRange = null;
          _currentFilterTypeSettle = null;
          _searchQuery = '';
          _applySettledFilter();
          break;
        case 1:
          _currentDateRange = null;
          _currentFilterTypePayment = null;
          _searchQuery = '';
          _applyPaymentFilter();
        default:
      }
    });
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
            value: const IconButton(
                onPressed: null, icon: Icon(Icons.more_horiz_outlined)))
      });
    }).toList();
  }

  void _refreshData() async {
    setState(() {

      _searchQuery = '';
      _currentDateRange = null;
      _globalDateFilterType = null;

      // _currentDateRangeAdvance = null;
      // _currentDateRangeProject = null;
      // _currentDateRangeTrip = null;

      _currentFilterTypeSettle = null;
      _currentFilterTypePayment = null;

      _currentPage = 1;
      _currentPagePayment = 1;
    });

    try {
            List<Settlement> settlement = await ApiService().fetchSettlements();
        List<Payment> payment=(await ApiService().fetchPayments())
          .where((p) => p.status.toLowerCase() == "posted")
          .toList();
        

      setState(() {
               settles = settlement;
               payments=payment;
              filteredPayment = List.from(payments); 


        filteredSettle = List.from(settles);
        
        _applyCurrentTabFilter();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to refresh: ${e.toString()}')),
      );
    }
  }

  void _newSettlement(PlutoRow row){
    final paymentId= row.cells['id']?.value;
    if (paymentId!=null) {
      final payment=payments.firstWhere((p)=>p.id==paymentId.toString());

      Navigator.push(context, MaterialPageRoute(builder:(context)=> SettlementForm(
        settleId: '0',
        paymentNo: payment.paymentNo,
        requestCode: 'Req_002',
        withdrawnAmount: payment.paymentAmount,
        
        ) )).then((success){
          if (success==true) {
            _refreshData();
            fetchData();
          }
        });
    }
  }

  void _viewSettlementDetails(Settlement settle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettlementForm(
          paymentNo: settle.paymentNo,
          // requestCode: settle.requestCode,
          withdrawnAmount: settle.withdrawnAmount,
          settle: settle,
          isViewMode: true,
          settleId: settle.id,
        ),
      ),
    );
  }

  //Export button
  Future<void> exportToCSV() async {
    try {
      List<List<dynamic>> csvData = [];
      csvData.add([
        "Settlement Date",
        "Payment No",
        "Payment Date",
        "Withdrawn Amount",
        "Settled Amount",
        "Refund Amount",
      ]);
      for (var settle in settles) {
        csvData.add([
          DateFormat('yyyy-MM-dd').format(settle.settlementDate),
          settle.paymentNo,
          DateFormat('yyyy-MM-dd').format(settle.paymentDate),
          settle.withdrawnAmount,
          settle.settleAmount,
          settle.refundAmount
        ]);
      }
      String csv = const ListToCsvConverter().convert(csvData);
      if (kIsWeb) {
        final bytes = utf8.encode(csv);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "settlement.csv")
          ..click();

        html.Url.revokeObjectUrl(url);
        print("CSV file download in browser");
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final path = "${directory.path}/settlement.csv";
        final file = File(path);
        await file.writeAsString(csv);

        print("CSV file saved to $path");
      }
    } catch (e) {
      print("Error exporting to CSV: $e");
    }
  }

  Widget _buildSettledGrid() {
    final columns = [
      PlutoColumn(
          title: 'id',
          field: 'id',
          type: PlutoColumnType.text(),
          textAlign: PlutoColumnTextAlign.left,
          width: 150,
          hide: true,
          enableAutoEditing: false,
          enableEditingMode: false),
      PlutoColumn(
          title: 'Settlement Date',
          field: 'Settlement Date',
          type: PlutoColumnType.date(),
          textAlign: PlutoColumnTextAlign.left,
          width: 175,
          enableAutoEditing: false,
          enableEditingMode: false),
      PlutoColumn(
          title: 'Payment No',
          field: 'Payment No',
          type: PlutoColumnType.text(),
          width: 211,
          textAlign: PlutoColumnTextAlign.left,
          enableEditingMode: false,
          enableAutoEditing: false),
      PlutoColumn(
          title: 'Withdrawn Amount',
          field: 'Withdrawn Amount',
          width: 211,
          type: PlutoColumnType.text(),
          textAlign: PlutoColumnTextAlign.right,
          titleTextAlign: PlutoColumnTextAlign.right,
          enableAutoEditing: false,
          enableEditingMode: false),
      PlutoColumn(
          title: 'Settled Amount',
          field: 'Settled Amount',
          width: 211,
          type: PlutoColumnType.text(),
          textAlign: PlutoColumnTextAlign.right,
          titleTextAlign: PlutoColumnTextAlign.right,
          enableAutoEditing: false,
          enableEditingMode: false),
      PlutoColumn(
          title: 'Refund Amount',
          field: 'Refund Amount',
          width: 211,
          type: PlutoColumnType.text(),
          textAlign: PlutoColumnTextAlign.right,
          titleTextAlign: PlutoColumnTextAlign.right,
          enableAutoEditing: false,
          enableEditingMode: false),
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
          final row = rendererContext.row;
          final settleId = row.cells['id']!.value;
          final settle = settles.firstWhere((s) => s.id == settleId);

          return IconButton(
            icon: const Icon(Icons.more_horiz_outlined),
            onPressed: () {
              _viewSettlementDetails(settle);
            },
          );
        },
      ),
    ];
    final rows = _paginatedSettled
        .map((settled) => PlutoRow(cells: {
              'id': PlutoCell(value: settled.id),
              'Settlement Date': PlutoCell(value: settled.settlementDate),
              'Payment No': PlutoCell(value: settled.paymentNo),
              'Withdrawn Amount':
                  PlutoCell(value: formatter.format(settled.withdrawnAmount)),
              'Settled Amount':
                  PlutoCell(value: formatter.format(settled.settleAmount)),
              'Refund Amount':
                  PlutoCell(value: formatter.format(settled.refundAmount)),
              'Action': PlutoCell(
                  value: const IconButton(
                      onPressed: null, icon: Icon(Icons.more_horiz_outlined)))
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
            _girdStateManagerSettled = event.stateManager;
            _girdStateManagerSettled!.setPage(1);
            _girdStateManagerSettled!.setPageSize(_rowsPerPage);
            setState(() {});
          },
        )),
        if (_girdStateManagerSettled != null)
          PlutoGridPagination(
              stateManager: _girdStateManagerSettled!,
              totalRows: filteredSettle.length,
              onPageChanged: (page, rowsPerPage) {
                setState(() {
                  _currentPage = page;
                  _rowsPerPage = rowsPerPage;

                  final start = (page - 1) * rowsPerPage;
                  final end = (start + rowsPerPage > filteredSettle.length)
                      ? filteredSettle.length
                      : start + rowsPerPage;
                  final rows = _paginatedSettled
                      .map((settled) => PlutoRow(cells: {
                            'id': PlutoCell(value: settled.id),
                            'Settlement Date':
                                PlutoCell(value: settled.settlementDate),
                            'Payment No': PlutoCell(value: settled.paymentNo),
                            'Withdrawn Amount': PlutoCell(
                                value:
                                    formatter.format(settled.withdrawnAmount)),
                            'Settled Amount': PlutoCell(
                                value: formatter.format(settled.settleAmount)),
                            'Refund Amount': PlutoCell(
                                value: formatter.format(settled.refundAmount)),
                            'Action': PlutoCell(
                                value: const IconButton(
                                    onPressed: null,
                                    icon: Icon(Icons.more_horiz_outlined)))
                          }))
                      .toList();
                  _girdStateManagerSettled!.removeAllRows();
                  _girdStateManagerSettled!.appendRows(rows);
                });
              })
      ],
    );
  }

  Widget _buildPaymentGrid() {
    final columns = [
      PlutoColumn(
        title: 'id',
        field: 'id',
        type: PlutoColumnType.text(),
        hide: true,
        enableEditingMode: false,
        width: 211,
      ),
      PlutoColumn(
        title: 'Payment Date',
        field: 'paymentdate',
        type: PlutoColumnType.date(),
        enableEditingMode: false,
        width: 165,
      ),
      PlutoColumn(
        title: 'Payment No',
        field: 'paymentno',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 165,
      ),
      PlutoColumn(
        title: 'Request Type',
        field: 'requesttype',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 150,
      ),
      PlutoColumn(
        title: 'Payment Amount',
        field: 'paymentamount',
        type: PlutoColumnType.number(),
        enableEditingMode: false,
        width: 211,
        textAlign: PlutoColumnTextAlign.right,
        titleTextAlign: PlutoColumnTextAlign.right,
        renderer: (context) {
          final value = int.tryParse(context.cell.value.toString()) ?? 0;
          return Text(formatter.format(value), textAlign: TextAlign.right);
        },
      ),
      PlutoColumn(
        title: 'Currency',
        field: 'currency',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 120,
        textAlign: PlutoColumnTextAlign.left,
        titleTextAlign: PlutoColumnTextAlign.left,
      ),
      PlutoColumn(
        title: 'Payment Method',
        field: 'paymentmethod',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 165,
      ),
      PlutoColumn(
          title: 'Action',
          field: 'action',
          type: PlutoColumnType.text(),
          enableEditingMode: false,
          width: 211,
          textAlign: PlutoColumnTextAlign.center,
          titleTextAlign: PlutoColumnTextAlign.center,
          renderer: (rendererContext) {
                 final row = rendererContext.row;
        
        return ElevatedButton(
            onPressed: () {
               _newSettlement(row);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB2C8A8),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                ),
            ),
            child: const Text("Settled Payment"),
        );
          }),
    ];
    final rows = _paginatedPayments
        .map((payment) => PlutoRow(cells: {
              'id': PlutoCell(value: payment.id),
              'paymentdate': PlutoCell(value: payment.date),
              'paymentno': PlutoCell(value: payment.paymentNo),
              'requesttype': PlutoCell(value: payment.requestType),
              'paymentamount': PlutoCell(value: payment.paymentAmount),
              'currency': PlutoCell(value: payment.currency),
              'paymentmethod': PlutoCell(value: payment.paymentMethod),
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
            _gridStateManagerPayment = event.stateManager;
            _gridStateManagerPayment!.setPage(1, notify: false);
            _gridStateManagerPayment!.setPageSize(_rowsPerPage, notify: false);
            setState(() {});
          },
        )),
        if (_gridStateManagerPayment != null)
          PlutoGridPagination(
              stateManager: _gridStateManagerPayment!,
              totalRows: filteredPayment.length,
              rowsPerPage: _rowsPerPage,
              onPageChanged: (page, rowsPerPage) {
                setState(() {
                  _currentPagePayment = page;
                  _rowsPerPage = rowsPerPage;
                  final start = (page - 1) * rowsPerPage;
                  final end = (start + rowsPerPage > filteredPayment.length)
                      ? filteredPayment.length
                      : start + rowsPerPage;
                  final paginatedPayments = filteredPayment.sublist(start, end);
                  final rows = paginatedPayments
                      .map((payment) => PlutoRow(cells: {
                            'id': PlutoCell(value: payment.id),
                            'paymentdate': PlutoCell(value: payment.date),
                            'paymentno': PlutoCell(value: payment.paymentNo),
                            'requesttype':
                                PlutoCell(value: payment.requestType),
                            'paymentamount':
                                PlutoCell(value: payment.paymentAmount),
                            'currency': PlutoCell(value: payment.currency),
                            'paymentmethod':
                                PlutoCell(value: payment.paymentMethod),
                            'action': PlutoCell(value: '')
                          }))
                      .toList();
                  _gridStateManagerPayment!.removeAllRows();
                  _gridStateManagerPayment!.appendRows(rows);
                });
              })
      ],
    );
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
                        selectedValue: _globalDateFilterType,
                        customRange: _currentDateRange,
                        onDateRangeChanged: (range, type) {
                          setState(() {
                            _currentDateRange = range;
                            _globalDateFilterType = type;
                          });
                          _applyCurrentTabFilter();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (_globalDateFilterType != null)
                      Chip(
                        label: Text(
                            'Filter: ${_globalDateFilterType!.replaceAll('_', ' ')}'),
                        onDeleted: () {
                          setState(() {
                            _globalDateFilterType = null;
                            _currentDateRange = null;
                          });
                          _applyCurrentTabFilter();
                        },
                      ),
              const SizedBox(width: 20),
              Flexible(
                flex: 3,
                child: CustomSearchBar(
                  onSearch: _handleSearch,
                  initialValue: _searchQuery,
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
                Row(
                  children: [
                    TrapezoidTab(
                        label: "Settlement Lists",
                        isSelected: _selectedTab == 0,
                        onTap: () {
                          setState(() {
                            _selectedTab = 0;
                            _currentPage = 1;
                          });
                          fetchData();
                        }),
                    TrapezoidTab(
                        label: "Posted Cash Payment Lists",
                        isSelected: _selectedTab == 1,
                        onTap: () {
                          setState(() {
                            _selectedTab = 1;
                            _currentPagePayment = 1;
                          });
                          fetchData();
                        })
                  ],
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
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : _selectedTab == 0
                        ? _buildSettledGrid()
                        : _selectedTab == 1
                            ? _buildPaymentGrid()
                            : const SizedBox.shrink())
          ],
        ),
      ),
    );
  }
}
