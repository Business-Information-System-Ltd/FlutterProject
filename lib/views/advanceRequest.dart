import 'dart:convert';
import 'dart:io';
import 'dart:html' as html;
import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:advance_budget_request_system/views/data.dart';
import 'package:advance_budget_request_system/views/requestEntry.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class Advancerequest extends StatefulWidget {
  final Map<String, dynamic> userData;
  const Advancerequest({super.key, required this.userData});

  @override
  State<Advancerequest> createState() => _AdvancerequestState();
}

class _AdvancerequestState extends State<Advancerequest> {
  List<AdvanceRequest> advanceRequest = [];
  List<AdvanceRequest> filteredData = [];
  final TextEditingController _searchController = TextEditingController();

  String? selectedDate;
  DateTimeRange? CustomDateRange;
  DateTimeRange? selectedDateRange;
  DateTime? startDate;
  DateTime? endDate;

  String? sortColumn;
  bool sortAscending = true;

  int rowsPerPage = 10;
  int currentPage = 1;
  int totalPages = 1;

  @override
  void initState() {
    super.initState();
    // filteredData = List.from(advanceRequest);
    // filteredData= advanceRequest;
    _fetchRequest();
    currentPage = 1;
    _updatePagination();
  }

  void _fetchRequest() async {
    try {
      List<AdvanceRequest> advanceRequests =
          await ApiService().fetchAdvanceRequestData();
      print('Fetched Data: $advanceRequests');
      setState(() {
        advanceRequest = advanceRequests;
        filteredData = List.from(advanceRequest);
        _updatePagination();
      });
    } catch (e) {
      print('Fail to request: $e');
    }
  }

  //Date Filter Function
  // ignore: unused_element
  String _getDateFilterDisplayName(String value) {
    switch (value) {
      case 'today':
        return 'Today';
      case 'this_week':
        return 'This week';
      case 'this_month':
        return 'This month';
      case 'this_year':
        return 'This year';
      case 'custom_date':
        return 'Custom Date';

      default:
        return value;
    }
  }

  String _getThisWeekRange() {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
    return '${DateFormat.yMd().format(startOfWeek)} - ${DateFormat.yMd().format(endOfWeek)}';
  }

  String _getThisMonthRange() {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 0);
    return '${DateFormat.yMd().format(startOfMonth)} - ${DateFormat.yMd().format(endOfMonth)}';
  }

  String _getThisYearRange() {
    DateTime now = DateTime.now();
    DateTime startOfYear = DateTime(now.year, 1, 1);
    DateTime endOfYear = DateTime(now.year, 12, 31);
    return '${DateFormat.yMd().format(startOfYear)} - ${DateFormat.yMd().format(endOfYear)}';
  }

  void _filterByCustomDate(DateTimeRange chooseDateRange) {
    _filterDataByDateRange(chooseDateRange);
  }

  void _filterDataByDateRange(DateTimeRange dateRange) {
    setState(() {
      filteredData = advanceRequest.where((data) {
        return data.date
                .isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
            data.date.isBefore(dateRange.end.add(const Duration(days: 1)));
      }).toList();
      _updatePagination();
    });
  }

  void _filterByPresetDate(String filterType) {
    DateTime now = DateTime.now();
    DateTimeRange? dateRange;

    switch (filterType) {
      case 'today':
        dateRange = DateTimeRange(start: now, end: now);
        break;
      case 'this_week':
        DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
        dateRange = DateTimeRange(start: startOfWeek, end: endOfWeek);
        break;
      case 'this_month':
        DateTime startOfMonth = DateTime(now.year, now.month, 1);
        DateTime endOfMonth = DateTime(now.year, now.month + 1, 0);
        dateRange = DateTimeRange(start: startOfMonth, end: endOfMonth);
        break;
      case 'this_year':
        DateTime startOfYear = DateTime(now.year, 1, 1);
        DateTime endOfYear = DateTime(now.year, 12, 31);
        dateRange = DateTimeRange(start: startOfYear, end: endOfYear);
        break;

      default:
        return;
    }
    // ignore: unnecessary_null_comparison
    if (dateRange != null) {
      setState(() {
        selectedDate = filterType;
      });
      _filterDataByDateRange(dateRange);
    }
  }

  void _showCustomDateRangeDialog(BuildContext context) {
    DateTime initialStartDate = DateTime.now();
    DateTime initialEndDate = DateTime.now();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Choose Custom Date"),
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Select Start Date: "),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        DateTime? chooseStartDate = await showDatePicker(
                            context: context,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(3000));

                        if (chooseStartDate != null) {
                          setState(() {
                            initialStartDate = chooseStartDate;
                          });
                        }
                      },
                      child: Text(DateFormat.yMd().format(initialStartDate))),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text('Select End Date: '),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        DateTime? chooseEndDate = await showDatePicker(
                            context: context,
                            initialDate: initialEndDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(3000));

                        if (chooseEndDate != null) {
                          setState(() {
                            initialEndDate = chooseEndDate;
                          });
                        }
                      },
                      child: Text(DateFormat.yMd().format(initialEndDate)))
                ],
              );
            }),
            actions: [
              TextButton(
                  onPressed: () {
                    if (initialStartDate.isBefore(initialEndDate) ||
                        initialStartDate.isAtSameMomentAs(initialEndDate)) {
                      setState(() {
                        CustomDateRange = DateTimeRange(
                            start: initialStartDate, end: initialEndDate);
                        selectedDate = 'custom_date';
                      });
                      _filterByCustomDate(CustomDateRange!);
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Please choose available Dates.")));
                    }
                  },
                  child: const Text("Apply")),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel')),
            ],
          );
        });
  }

  //Search function
  void _searchData(String query) {
    setState(() {
      List<AdvanceRequest> sourceData = advanceRequest;
      filteredData = sourceData.where((data) {
        final requestNo = data.requestNo.toLowerCase();
        final requestType = data.requestType.toLowerCase();
        final currency = data.currency.toLowerCase();
        final requester = data.requester.toLowerCase();
        final status = data.status.toLowerCase();
        final String searchLower = query.toLowerCase();

        return requestNo.contains(searchLower) ||
            requestType.contains(searchLower) ||
            currency.contains(searchLower) ||
            requester.contains(searchLower) ||
            status.contains(searchLower);
      }).toList();
      _updatePagination();
    });
  }

  //Sorting
  void _sortDataColumn(String column) {
    setState(() {
      if (sortColumn == column) {
        sortAscending = !sortAscending;
      } else {
        sortColumn = column;
        sortAscending = true;
      }

      filteredData.sort((a, b) {
        dynamic aValue;
        dynamic bValue;

        switch (column) {
          case 'Date':
            aValue = a.date;
            bValue = b.date;
            break;
          case 'RequestNo':
            aValue = a.requestNo;
            bValue = b.requestNo;
            break;
          // case 'RequestCode':
          //   aValue = a.requestCode;
          //   bValue = b.requestCode;
          //   break;
          case 'RequestType':
            aValue = a.requestType;
            bValue = b.requestType;
            break;
          case 'RequestAmount':
            aValue = a.requestAmount;
            bValue = b.requestAmount;
            break;
          case 'Currency':
            aValue = a.currency;
            bValue = b.currency;
            break;
          case 'Status':
            aValue = a.status;
            bValue = b.status;
            break;
          case 'Requester':
            aValue = a.requester;
            bValue = b.requester;
            break;
          default:
            return 0;
        }

        if (aValue == null || bValue == null) return 0;

        if (sortAscending) {
          return aValue.compareTo(bValue);
        } else {
          return bValue.compareTo(aValue);
        }
      });
      _updatePagination();
    });
  }

  Widget _buildHeaderCell(String label, String column) {
    return InkWell(
      onTap: () {
        _sortDataColumn(column);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (sortColumn == column)
              Icon(
                sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
              )
          ],
        ),
      ),
    );
  }

  //refresh Data
  void _refreshData() {
    setState(() {
      _searchController.clear();
      selectedDateRange = null;
      selectedDate = null;
      startDate = null;
      endDate = null;
      filteredData = List.from(advanceRequest);
      sortColumn = null;
      sortAscending = true;
      currentPage = 1;
      _updatePagination();
      _fetchRequest();
    });
  }

  //reset pagination
  void _updatePagination() {
    setState(() {
      totalPages = (filteredData.length / rowsPerPage).ceil();
      if (currentPage > totalPages && totalPages != 0) {
        currentPage = totalPages;
      } else if (totalPages == 0) {
        currentPage = 1;
      }
    });
  }

  //Pagination
  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous Button
          IconButton(
            onPressed: currentPage > 1
                ? () {
                    setState(() {
                      currentPage--;
                      _updatePagination();
                    });
                  }
                : null,
            icon: const Icon(Icons.arrow_back),
          ),
          // Page Indicator
          Text('Page $currentPage of $totalPages'),
          // Next Button
          IconButton(
            onPressed: currentPage < totalPages
                ? () {
                    setState(() {
                      currentPage++;
                      _updatePagination();
                    });
                  }
                : null,
            icon: const Icon(Icons.arrow_forward),
          ),
          const SizedBox(width: 20),
          // Rows per page selector
          DropdownButton<int>(
            value: rowsPerPage,
            items: [10, 15, 20].map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text('$value rows'),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  rowsPerPage = value;
                  currentPage =
                      1; // Reset to page 1 when rows per page is changed
                  _updatePagination();
                });
              }
            },
          ),
        ],
      ),
    );
  }

  List<AdvanceRequest> get paginatedData {
    int start = (currentPage - 1) * rowsPerPage;
    int end = start + rowsPerPage < filteredData.length
        ? start + rowsPerPage
        : filteredData.length;
    return filteredData.sublist(start, end);
  }

  //download button to export CSV
  Future<void> exportToCSV() async {
    try {
      // Convert the projectData list to a list of lists (CSV rows)
      List<List<dynamic>> csvData = [];

      //Add the header row
      csvData.add([
        "Request Date",
        "Request No",
        "Request Code",
        "Request Type",
        "Request Amount",
        "Currency",
        "Requester",
        "ApprovedAmount",
        "Purpose",
        "Status",
        // "Budget Details"
      ]);

      //Add the data rows
      for (var advance in advanceRequest) {
        csvData.add([
          DateFormat('yyyy-MM-dd').format(advance.date),
          advance.requestNo,
          advance.requestCode,
          advance.requestType,
          advance.requestAmount,
          advance.currency,
          advance.requester,
          advance.approveAmount,
          advance.purpose,
          advance.status,
          // serializeBudgetDetails(advance.budgetDetails)
        ]);
      }

      String csv = const ListToCsvConverter().convert(csvData);
      if (kIsWeb) {
        final bytes = utf8.encode(csv);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "advanceRequest.csv")
          ..click();

        html.Url.revokeObjectUrl(url);
        print("CSV file downloaded in browser");
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final path = "${directory.path}/advanceRequest.csv";
        final file = File(path);
        await file.writeAsString(csv);
      }
    } catch (e) {
      print("Error exporting to CSV: $e");
    }
  }

  //Budget Details in CSV
  String serializeBudgetDetails(List<Budget> budgetDetails) {
    return budgetDetails.map((budget) {
      return '${budget.BudgetCode}: ${budget.Description}';
    }).join('; ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text(
            "Advance Request Information",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            children: [
              Container(
                // width: MediaQuery.of(context).size.width * 0.2,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: DropdownButton(
                      value: selectedDate,
                      hint: const Text('Filter by Date'),
                      items: [
                        DropdownMenuItem(
                            value: 'today',
                            child: Tooltip(
                              message: DateFormat.yMd().format(DateTime.now()),
                              child: const Text('Today'),
                            )),
                        DropdownMenuItem(
                            value: 'this_week',
                            child: Tooltip(
                              message: _getThisWeekRange(),
                              child: const Text('This Week'),
                            )),
                        DropdownMenuItem(
                            value: 'this_month',
                            child: Tooltip(
                              message: _getThisMonthRange(),
                              child: const Text('This Month'),
                            )),
                        DropdownMenuItem(
                            value: 'this_year',
                            child: Tooltip(
                              message: _getThisYearRange(),
                              child: const Text('This Year'),
                            )),
                        DropdownMenuItem(
                            value: 'custom_date',
                            child: Tooltip(
                              message: CustomDateRange != null
                                  ? '${DateFormat.yMd().format(CustomDateRange!.start)} - ${DateFormat.yMd().format(CustomDateRange!.end)}'
                                  : 'Choose a Custom Date Range',
                              child: const Text('Custom Date'),
                            )),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedDate = newValue;
                          if (newValue == 'custom_date') {
                            _showCustomDateRangeDialog(context);
                          } else if (newValue != null) {
                            _filterByPresetDate(newValue);
                          }
                        });
                      }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 50),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: 50,
                  child: TextField(
                    controller: _searchController,
                    onChanged: _searchData,
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  // width: MediaQuery.of(context).size.width*0.1,
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromARGB(255, 150, 212, 234),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdvanceRequestEntry(
                                      onRequestAdded: (newRequest) {
                                        setState(() {
                                          advanceRequest.add(newRequest);
                                          filteredData =
                                              List.from(advanceRequest);
                                        },
                                        
                                        );
                                        _updatePagination();
                                      },
                                      username: widget.userData['UserName']
                                    )));
                        if (result == true) {
                          _fetchRequest();
                        }
                      },
                      icon: const Icon(Icons.add),
                      color: Colors.black,
                    ),
                    IconButton(
                      onPressed: () {
                        _refreshData();
                      },
                      icon: const Icon(Icons.refresh),
                      color: Colors.black,
                    ),
                    IconButton(
                      onPressed: () {
                        exportToCSV();
                      },
                      icon: const Icon(Icons.download),
                      color: Colors.black,
                    )
                  ],
                ),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(0),
            child: Container(
              child: Table(
                border: const TableBorder.symmetric(
                  inside: BorderSide(color: Colors.grey, width: 1),
                  outside: BorderSide(color: Colors.grey, width: 1),
                ),
                columnWidths: const {
                  0: FlexColumnWidth(0.6),
                  1: FlexColumnWidth(0.5),
                  2: FlexColumnWidth(0.5),
                  3: FlexColumnWidth(0.5),
                  4: FlexColumnWidth(0.6),
                  5: FlexColumnWidth(0.5),
                  6: FlexColumnWidth(0.5),
                  7: FlexColumnWidth(0.5),
                  8: FlexColumnWidth(0.3)
                },
                children: [
                  TableRow(
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 167, 230, 232)),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _buildHeaderCell("Request Date", "Date"),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _buildHeaderCell("Request No", "RequestNo"),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              _buildHeaderCell("Request Code", "Request Code"),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              _buildHeaderCell("Request Type", "RequestType"),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _buildHeaderCell(
                              "Request Amount", "RequestAmount"),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _buildHeaderCell("Currency", "Currency"),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _buildHeaderCell("Status", "Status"),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _buildHeaderCell("Requester", "Requester"),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Action",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ])
                ],
              ),
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              child: Table(
                border: const TableBorder.symmetric(
                  inside: BorderSide(color: Colors.grey, width: 1),
                  outside: BorderSide(color: Colors.black, width: 1),
                ),
                columnWidths: const {
                  0: FlexColumnWidth(0.6),
                  1: FlexColumnWidth(0.5),
                  2: FlexColumnWidth(0.5),
                  3: FlexColumnWidth(0.5),
                  4: FlexColumnWidth(0.6),
                  5: FlexColumnWidth(0.5),
                  6: FlexColumnWidth(0.5),
                  7: FlexColumnWidth(0.5),
                  8: FlexColumnWidth(0.3)
                },
                children: paginatedData.map((row) {
                  
                  return TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(DateFormat('yyyy-MM-dd').format(row.date)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(row.requestNo),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(row.requestCode),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(row.requestType),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(row.requestAmount.toString())),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(row.currency),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(row.status),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(row.requester),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.more_horiz_outlined,
                                color: Colors.black),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      DetailRequest(requests: row)));
                            },
                          ),
                        ],
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          )),
          _buildPaginationControls(),
        ],
      ),
    );
  }
}

class DetailRequest extends StatelessWidget {
  final AdvanceRequest requests;
  const DetailRequest({Key? key, required this.requests}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Advance Request Details",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromRGBO(100, 207, 198, 0.855),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Center(
              child: Text(
                "Advance Request Detail",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
            _buildRow("Request No", requests.requestNo, "Request Date",
                DateFormat('yyyy-MM-dd').format(requests.date)),
            const SizedBox(height: 20),
            _buildRow("Request Code", requests.requestCode, "Request Type",
                requests.requestType),
            const SizedBox(height: 20),
            _buildRow(
                "Request Amount",
                '${requests.requestAmount} ${requests.currency}',
                "Approve Amount",
                '${requests.approveAmount} ${requests.currency}' ),
            const SizedBox(height: 20),
            // _buildRow("Department", requests.requester, "Requester",
            //     requests.requester),
            // const SizedBox(height: 20),
            _buildRow("Purpose", requests.purpose, "Status", requests.status),
            const SizedBox(height: 40),
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              // child: _buildBudgetTable(requests.budgetDetails),
            ),
            const SizedBox(height: 40),
            Center(
                child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(
                  fontSize: 15,
                ),
                backgroundColor: Colors.green,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Back"),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
      String label1, String value1, String label2, String? value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInlineText(label1, value1),
          if (label2.isNotEmpty) _buildInlineText(label2, value2 ?? "N/A"),
        ],
      ),
    );
  }

  Widget _buildBudgetTable(List<Budget> budgetDetails) {
    return Container(
      child: Table(
        border: TableBorder.all(),
        children: [
          const TableRow(
            decoration: BoxDecoration(color: Colors.lightBlueAccent),
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Budget Code",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Description",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          ...budgetDetails.map((budget) => TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(budget.BudgetCode),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(budget.Description),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

Widget _buildInlineText(String label, String value) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black),
          children: [
            TextSpan(
                text: "$label: ",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    ),
  );
}


