// import 'dart:convert';
// import 'dart:io';
// import 'dart:html' as html;
// import 'package:advance_budget_request_system/views/api_service.dart';
// import 'package:advance_budget_request_system/views/data.dart';
// import 'package:advance_budget_request_system/views/datefilter.dart';
// import 'package:advance_budget_request_system/views/pagination.dart';
// import 'package:advance_budget_request_system/views/searchfunction.dart';
// import 'package:csv/csv.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pluto_grid/pluto_grid.dart';
// import 'package:intl/intl.dart';
// import 'package:advance_budget_request_system/views/advanceRequestFormOperation.dart';
// import 'package:advance_budget_request_system/views/advanceRequestProjectTripTable.dart.dart';

// class AdvanceRequestPage extends StatefulWidget {
//   @override
//   _AdvanceRequestPageState createState() => _AdvanceRequestPageState();
// }

// class _AdvanceRequestPageState extends State<AdvanceRequestPage> {
//   List<PlutoColumn> _columns = [];
//   List<PlutoRow> _rows = [];
//   List<Advance> advances = [];
//   List<PlutoRow> _pagedRows = [];
//   String _searchQuery = '';
//   DateTimeRange? _currentDateRange;
//   String? _currentFilterType;
//   PlutoGridStateManager? _stateManager;
//   final NumberFormat _formatter = NumberFormat('#,###');
//   bool _isLoading = true;
//   String _errorMessage = '';
//   int _currentPage = 1;
//   int _rowsPerPage = 10;

//   @override
//   void initState() {
//     super.initState();
//     _columns = _buildColumns();
//     // _rows = _buildRows();
//     _fetchAdvanceRequest();
//     print(" Rows loaded: ${_rows.length}");
//   }

//   void _fetchAdvanceRequest() async {
//     try {
//       print('Fetch Advances....');
//       List<Advance> advanceRequest = await ApiService().fetchAdvanceRequests();
//       print('fetch ${advanceRequest.length} advances');
//       setState(() {
//         advances = advanceRequest;
//       });
//       _applyDateFilter();
//     } catch (e) {
//       print('Failed to fetch trips: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to load trips: ${e.toString()}')),
//       );
//     }
//   }

//   void _applyDateFilter() {
//     List<Advance> filteredAdvance = advances;

//     if (_currentDateRange != null) {
//       final startDate = DateTime(
//         _currentDateRange!.start.year,
//         _currentDateRange!.start.month,
//         _currentDateRange!.start.day,
//       );

//       final endDate = DateTime(
//         _currentDateRange!.end.year,
//         _currentDateRange!.end.month,
//         _currentDateRange!.end.day,
//       ).add(const Duration(days: 1)); // Include the entire end day

//       filteredAdvance = advances.where((advance) {
//         // Create date-only object for the trip
//         final tripDate = DateTime(
//           advance.date.year,
//           advance.date.month,
//           advance.date.day,
//         );

//         return tripDate.isAtSameMomentAs(startDate) ||
//             (tripDate.isAfter(startDate) && tripDate.isBefore(endDate));
//       }).toList();
//     }
//     if (_searchQuery.isNotEmpty) {
//       filteredAdvance = filteredAdvance
//           .where((advance) =>
//               SearchUtils.matchesSearchAdvance(advance, _searchQuery))
//           .toList();
//     }

//     final newRows = _buildRows(filteredAdvance);
//     setState(() {
//       _rows = newRows;
//       _currentPage = 1;
//     });
//     _updatePagedRows();

//     // if (_stateManager != null) {
//     //   _stateManager!.removeAllRows();
//     //   _stateManager!.appendRows(newRows);
//     // }
//   }

//   void _updatePagedRows() {
//     final start = (_currentPage - 1) * _rowsPerPage;
//     final end = (_currentPage * _rowsPerPage).clamp(0, _rows.length);
//     setState(() {
//       _pagedRows = _rows.sublist(start, end);
//     });

//     if (_stateManager != null) {
//       _stateManager!.removeAllRows();
//       _stateManager!.appendRows(_pagedRows);
//     }
//   }

//   void _handleDateRangeChange(DateTimeRange range, String selectedValue) {
//     setState(() {
//       _currentDateRange = range;
//       _currentFilterType = selectedValue;
//     });
//     _applyDateFilter();
//   }

//   void _handleSearch(String query) {
//     setState(() {
//       _searchQuery = query;
//     });
//     _applyDateFilter();
//   }

//   List<PlutoColumn> _buildColumns() {
//     return [
//       PlutoColumn(
//         title: 'Request Date',
//         field: 'requestdate',
//         type: PlutoColumnType.text(),
//         enableEditingMode: false,
//         width: 145,
//       ),
//       PlutoColumn(
//         title: 'Request No',
//         field: 'requestno',
//         type: PlutoColumnType.text(),
//         enableEditingMode: false,
//         width: 142,
//       ),
//       PlutoColumn(
//         title: 'Request Type',
//         field: 'requesttype',
//         type: PlutoColumnType.text(),
//         enableEditingMode: false,
//         width: 200,
//       ),
//       PlutoColumn(
//         title: 'Request Code',
//         field: 'requestcode',
//         type: PlutoColumnType.text(),
//         enableEditingMode: false,
//         width: 142,
//         textAlign: PlutoColumnTextAlign.left,
//         titleTextAlign: PlutoColumnTextAlign.left,
//       ),
//       PlutoColumn(
//         title: 'Request Amount',
//         field: 'requestamount',
//         type: PlutoColumnType.number(),
//         enableEditingMode: false,
//         width: 180,
//         textAlign: PlutoColumnTextAlign.right,
//         titleTextAlign: PlutoColumnTextAlign.right,
//         renderer: (context) {
//           final value = int.tryParse(context.cell.value.toString()) ?? 0;
//           return Text(_formatter.format(value), textAlign: TextAlign.right);
//         },
//       ),
//       PlutoColumn(
//         title: 'Currency',
//         field: 'currency',
//         type: PlutoColumnType.text(),
//         enableEditingMode: false,
//         width: 100,
//         textAlign: PlutoColumnTextAlign.left,
//         titleTextAlign: PlutoColumnTextAlign.left,
//       ),
//       PlutoColumn(
//         title: 'Requester',
//         field: 'requester',
//         type: PlutoColumnType.text(),
//         enableEditingMode: false,
//         width: 200,
//         textAlign: PlutoColumnTextAlign.left,
//         titleTextAlign: PlutoColumnTextAlign.left,
//       ),
//       PlutoColumn(
//         title: 'Action',
//         field: 'action',
//         type: PlutoColumnType.text(),
//         width: 150,
//         textAlign: PlutoColumnTextAlign.center,
//         titleTextAlign: PlutoColumnTextAlign.center,
//         enableEditingMode: false,
//         renderer: (rendererContext) {
//           final row = rendererContext.row;
//           final requestType = row.cells['requesttype']?.value.toString() ?? '';

//           return IconButton(
//             icon: const Icon(Icons.more_horiz, color: Colors.black),
//             onPressed: () {
//               if (requestType.toLowerCase().contains('project') ||
//                   requestType.toLowerCase().contains('trip')) {
//                 // Navigate to Project&Trip table
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => AdvanceProjectTripTable(),
//                   ),
//                 );
//               } else if (requestType.toLowerCase().contains('operation')) {
//                 // Navigate to Operation form
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const AdvanceRequestForm(),
//                   ),
//                 );
//               }
//             },
//           );
//         },
//       ),
//     ];
//   }

//   List<PlutoRow> _buildRows(List<Advance> advanceList) {
//   return advanceList.map((advance) {
//     return PlutoRow(cells: {
//       'requestdate': PlutoCell(value: DateFormat('yyyy-MM-dd').format(advance.date)),
//       'requestno': PlutoCell(value: advance.requestNo),
//       'requesttype': PlutoCell(value: advance.requestType),
//       'requestcode': PlutoCell(value: advance.requestCode),
//       'requestamount': PlutoCell(value: advance.requestAmount),
//       'currency': PlutoCell(value: advance.currency),
//       'requester': PlutoCell(value: advance.requester),
//       'action': PlutoCell(value: '')
//     });
//   }).toList();
// }

//   void _refreshData() async{
//     setState(() {
//       _searchQuery = "";
//       _currentDateRange = null;
//       _currentFilterType = null;
//       _currentPage = 1;
//     });
//     try {
//       List<Advance> advance = await ApiService().fetchAdvanceRequests();
//       setState(() {
//         advances = advance;
//       });

//       _applyDateFilter();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to refresh trips: ${e.toString()}')),
//       );
//     }
//   }

//   //Export button
//   Future<void> exportToCSV() async{
//     try {
//       List<List<dynamic>> csvData=[];
//       csvData.add([
//         "Request Date",
//         "Request No",
//         "Request Type",
//         "Request Code",
//         "Request Description",
//         "Request Amount",
//         "Currency",
//         "Approved Amount",
//         "Requester",
//         "Department",
//         "Request Purpose",
//         "Status"
//       ]);
//       for(var advance in advances){
//         csvData.add([
//           DateFormat('yyyy-MM-dd').format(advance.date),
//           advance.requestNo,
//           advance.requestType,
//           advance.requestCode,
//           advance.requestDes,
//           advance.requestAmount,
//           advance.currency,
//           advance.approvedAmount,
//           advance.requester,
//           advance.departmentName,
//           advance.purpose,
//           advance.status
//         ]);
//       }
//       String csv=const ListToCsvConverter().convert(csvData);
//       if (kIsWeb) {
//         final bytes= utf8.encode(csv);
//         final blob=html.Blob([bytes]);
//         final url=html.Url.createObjectUrlFromBlob(blob);
//         final anchor= html.AnchorElement(href: url)
//           ..setAttribute("download", "advance.csv")
//           ..click();

//         html.Url.revokeObjectUrl(url);
//         print("CSV file download in browser");
//       }else{
//         final directory= await getApplicationDocumentsDirectory();
//         final path= "${directory.path}/advance.csv";
//         final file=File(path);
//         await file.writeAsString(csv);

//         print("CSV file saved to $path");
//       }
//     } catch (e) {
//       print("Error exporting to CSV: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar:
//           AppBar(title: const Text('Advance Request List '), centerTitle: true),
//       // body: _rows.isEmpty
//       // ? Center(child: CircularProgressIndicator())
//       body: Padding(
//         padding: const EdgeInsets.fromLTRB(50, 20, 50, 30),
//         child: Container(
//           height: 470,
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   Flexible(
//                     flex: 1,
//                     child: DateFilterDropdown(
//                       onDateRangeChanged: _handleDateRangeChange,
//                       initialValue: _currentFilterType,
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   // Add filter indicator chip
//                   if (_currentFilterType != null)
//                     Chip(
//                       label: Text(
//                         'Filter: ${_currentFilterType!.replaceAll('_', ' ')}',
//                         style: const TextStyle(fontSize: 12),
//                       ),
//                       onDeleted: () {
//                         setState(() {
//                           _currentDateRange = null;
//                           _currentFilterType = null;
//                         });
//                         _applyDateFilter();
//                       },
//                     ),
//                   const SizedBox(
//                     width: 20,
//                   ),
//                   Flexible(
//                     flex: 3,
//                     child: CustomSearchBar(
//                       onSearch: _handleSearch,
//                       hintText: 'Search...',
//                       minWidth: 500,
//                       maxWidth: 800,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         width: 150,
//                         height: 35,
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade300,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: DropdownButtonHideUnderline(
//                           child: DropdownButton<String>(
//                             isExpanded: true,
//                             icon: const Icon(Icons.arrow_drop_down,
//                                 color: Colors.black),
//                             style: const TextStyle(
//                                 color: Colors.black, fontSize: 16),
//                             hint: const Padding(
//                               padding: EdgeInsets.symmetric(horizontal: 12),
//                               child: Row(
//                                 children: [
//                                   Icon(Icons.add, color: Colors.black),
//                                   SizedBox(width: 8),
//                                   Text('New',
//                                       style: TextStyle(color: Colors.black)),
//                                 ],
//                               ),
//                             ),
//                             items: const [
//                               DropdownMenuItem(
//                                 value: 'operation_advance',
//                                 child: Text('Request Operation Advance'),
//                               ),
//                               DropdownMenuItem(
//                                 value: 'project_trip',
//                                 child: Text('Request Project or Trip Request'),
//                               ),
//                             ],
//                             onChanged: (value) {
//                               if (value == 'operation_advance') {
//                                 Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (context) =>
//                                             const AdvanceRequestForm()));
//                               } else if (value == 'project_trip') {
//                                 Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (context) =>
//                                             AdvanceProjectTripTable()));
//                               }
//                             },
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       Container(
//                         child: IconButton(
//                           icon: const Icon(Icons.refresh),
//                           onPressed: _refreshData,
//                           color: Colors.black,
//                         ),
//                       ),
//                       ElevatedButton.icon(
//                         label: const Text('Export'),
//                         onPressed: exportToCSV,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.grey.shade300,
//                           foregroundColor: Colors.black,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 7),
//               Expanded(
//                 child: PlutoGrid(
//                     columns: _columns,
//                     rows: _pagedRows,
//                     configuration: PlutoGridConfiguration(
//                       style: PlutoGridStyleConfig(
//                         oddRowColor: Colors.blue[50],
//                         rowHeight: 35,
//                         activatedColor: Colors.lightBlueAccent.withOpacity(0.2),
//                       ),
//                     ),
//                     onLoaded: (event) {
//                       _stateManager = event.stateManager;
//                       _updatePagedRows();
//                     }),
//               ),
//               const SizedBox(height: 10),
//               if (_stateManager != null)
//                 PlutoGridPagination(
//                   stateManager: _stateManager!,
//                   totalRows: _rows.length,
//                   rowsPerPage: _rowsPerPage,
//                   onPageChanged: (page, limit) {
//                     _currentPage = page;
//                     _rowsPerPage = limit;
//                     _updatePagedRows();
//                   },
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// import 'dart:convert';
// import 'dart:io';
// import 'dart:html' as html;
// import 'package:advance_budget_request_system/views/addAdvanceRequestForm.dart';
// import 'package:advance_budget_request_system/views/api_service.dart';
// import 'package:advance_budget_request_system/views/data.dart';
// import 'package:advance_budget_request_system/views/datefilter.dart';
// import 'package:advance_budget_request_system/views/pagination.dart';
// import 'package:advance_budget_request_system/views/searchfunction.dart';
// import 'package:csv/csv.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pluto_grid/pluto_grid.dart';
// import 'package:intl/intl.dart';
// import 'package:advance_budget_request_system/views/advanceRequestFormOperation.dart';
// import 'package:advance_budget_request_system/views/advanceRequestProjectTripTable.dart.dart';

// class TrapezoidClipper extends CustomClipper<Path> {
//   final double slantHeight;
//   final bool isFirst;
//   final bool isLast;

//   TrapezoidClipper({
//     this.slantHeight = 15,
//     this.isFirst = false,
//     this.isLast = false,
//   });

//   @override
//   Path getClip(Size size) {
//     final path = Path();

//     if (isFirst) {
//       path.lineTo(0, size.height);
//       path.lineTo(size.width - slantHeight, size.height);
//       path.lineTo(size.width, 0);
//     } else if (isLast) {
//       path.moveTo(slantHeight, 0);
//       path.lineTo(0, size.height);
//       path.lineTo(size.width, size.height);
//       path.lineTo(size.width, 0);
//     } else {
//       path.moveTo(slantHeight, 0);
//       path.lineTo(0, size.height);
//       path.lineTo(size.width - slantHeight, size.height);
//       path.lineTo(size.width, 0);
//     }

//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => true;
// }

// class AdvanceRequestPage extends StatefulWidget {
//   @override
//   _AdvanceRequestPageState createState() => _AdvanceRequestPageState();
// }

// class _AdvanceRequestPageState extends State<AdvanceRequestPage> {
//   List<PlutoColumn> _columns = [];
//   List<PlutoRow> _rows = [];
//   List<Advance> advances = [];
//   List<Project> projects = [];
//   List<Trips> trips = [];
//   List<PlutoRow> _pagedRows = [];
// String _searchQuery = '';
// DateTimeRange? _currentDateRange;
// String? _currentFilterType;
//   PlutoGridStateManager? _stateManager;
// final NumberFormat _formatter = NumberFormat('#,###');
//   bool _isLoading = true;
//   String _errorMessage = '';
// int _currentPage = 1;
// int _rowsPerPage = 10;

//   @override
//   void initState() {
//     super.initState();
//     _columns = _buildColumns();
//     // _rows = _buildRows();
//     _fetchAdvanceRequest();
//     print(" Rows loaded: ${_rows.length}");
//   }

//   // void _fetchAdvanceRequest() async {
//   //   try {
//   //     print('Fetch Advances....');
//   //     List<Advance> advanceRequest = await ApiService().fetchAdvanceRequests();
//   //     print('fetch ${advanceRequest.length} advances');
//   //     setState(() {
//   //       advances = advanceRequest;
//   //     });
//   //     _applyDateFilter();
//   //   } catch (e) {
//   //     print('Failed to fetch trips: $e');
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Failed to load trips: ${e.toString()}')),
//   //     );
//   //   }
//   // }

//   void _fetchInitialData() async {
//     try {
//       setState(() => _isLoading = true);
//       await Future.wait<void>([
//         _fetchAdvanceRequest(),
//         _fetchProjects(),
//         _fetchTrips(),
//       ]);
//     } catch (e) {
//       setState(() => _errorMessage = 'Failed to load data: ${e.toString()}');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//  Future<void> _fetchAdvanceRequest() async {
//     try {
//       List<Advance> advanceRequest = await ApiService().fetchAdvanceRequests();
//       setState(() => advances = advanceRequest);
//       // _applyFilter();
//     } catch (e) {
//       setState(
//           () => _errorMessage = 'Failed to fetch advances: ${e.toString()}');
//     }
//   }

//   Future<void> _fetchProjects() async {
//     try {
//       List<Project> projectList = await ApiService().fetchProjects();
//       setState(() =>
//           projects = projectList.where((p) => p.requestable == 'yes').toList());
//     } catch (e) {
//       setState(
//           () => _errorMessage = 'Failed to fetch projects: ${e.toString()}');
//     }
//   }

//   Future<void> _fetchTrips() async {
//     try {
//       List<Trips> tripList = await ApiService().fetchTrips();
//       setState(
//           () => trips = tripList.where((t) => !t.directAdvanceReq).toList());
//     } catch (e) {
//       setState(() => _errorMessage = 'Failed to fetch trips: ${e.toString()}');
//     }
//   }

//   // void _applyDateFilter() {
//     // List<Advance> filteredAdvance = advances;

//     // if (_currentDateRange != null) {
//     //   final startDate = DateTime(
//     //     _currentDateRange!.start.year,
//     //     _currentDateRange!.start.month,
//     //     _currentDateRange!.start.day,
//     //   );

//     //   final endDate = DateTime(
//     //     _currentDateRange!.end.year,
//     //     _currentDateRange!.end.month,
//     //     _currentDateRange!.end.day,
//     //   ).add(const Duration(days: 1)); // Include the entire end day

//     //   filteredAdvance = advances.where((advance) {
//     //     // Create date-only object for the trip
//     //     final tripDate = DateTime(
//     //       advance.date.year,
//     //       advance.date.month,
//     //       advance.date.day,
//     //     );

//     //     return tripDate.isAtSameMomentAs(startDate) ||
//     //         (tripDate.isAfter(startDate) && tripDate.isBefore(endDate));
//     //   }).toList();
//     // }
//     // if (_searchQuery.isNotEmpty) {
//     //   filteredAdvance = filteredAdvance
//     //       .where((advance) =>
//     //           SearchUtils.matchesSearchAdvance(advance, _searchQuery))
//     //       .toList();
//     // }

//     // final newRows = _buildRows(filteredAdvance);
//     // setState(() {
//     //   _rows = newRows;
//     //   _currentPage = 1;
//     // });
//     // _updatePagedRows();

//     // // if (_stateManager != null) {
//     // //   _stateManager!.removeAllRows();
//     // //   _stateManager!.appendRows(newRows);
//     // // }

//   // }
//     void _applyDateFilter() {
//     List<dynamic> filteredData = [];

//     switch (_currentTabIndex) {
//       case 0: // Advance Requests
//         filteredData = advances;
//         break;
//       case 1: // Projects
//         filteredData = projects;
//         break;
//       case 2: // Trips
//         filteredData = trips;
//         break;
//     }

//     if (_currentDateRange != null) {
//       final startDate = DateTime(
//         _currentDateRange!.start.year,
//         _currentDateRange!.start.month,
//         _currentDateRange!.start.day,
//       );

//       final endDate = DateTime(
//         _currentDateRange!.end.year,
//         _currentDateRange!.end.month,
//         _currentDateRange!.end.day,
//       ).add(const Duration(days: 1));

//       filteredData = filteredData.where((item) {
//         final itemDate = DateTime(
//           (item is Advance ? item.date :
//            item is Project ? item.date :
//            item is Trips ? item.date : DateTime.now()).year,
//           (item is Advance ? item.date :
//            item is Project ? item.date :
//            item is Trips ? item.date : DateTime.now()).month,
//           (item is Advance ? item.date :
//            item is Project ? item.date :
//            item is Trips ? item.date : DateTime.now()).day,
//         );
//         return itemDate.isAtSameMomentAs(startDate) ||
//             (itemDate.isAfter(startDate) && itemDate.isBefore(endDate));
//       }).toList();
//     }

//     if (_searchQuery.isNotEmpty) {
//       filteredData = filteredData.where((item) {
//         if (item is Advance) {
//           return SearchUtils.matchesSearchAdvance(item, _searchQuery);
//         } else if (item is Project) {
//           return item.projectCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//                  item.projectDescription.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//                  item.requesterName.toLowerCase().contains(_searchQuery.toLowerCase());
//         } else if (item is Trips) {
//           return item.tripCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//                  item.tripDescription.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//                  item.requesterName.toLowerCase().contains(_searchQuery.toLowerCase());
//         }
//         return false;
//       }).toList();
//     }

//     setState(() {
//       _rows = _buildRows(filteredData);
//       _currentPage = 1;
//     });
//     _updatePagedRows();
//   }

//   void _updatePagedRows() {
//     final start = (_currentPage - 1) * _rowsPerPage;
//     final end = (_currentPage * _rowsPerPage).clamp(0, _rows.length);
//     setState(() {
//       _pagedRows = _rows.sublist(start, end);
//     });

//     if (_stateManager != null) {
//       _stateManager!.removeAllRows();
//       _stateManager!.appendRows(_pagedRows);
//     }
//   }

//   void _handleDateRangeChange(DateTimeRange range, String selectedValue) {
//     setState(() {
//       _currentDateRange = range;
//       _currentFilterType = selectedValue;
//     });
//     _applyDateFilter();
//   }

//   void _handleSearch(String query) {
//     setState(() {
//       _searchQuery = query;
//     });
//     _applyDateFilter();
//   }

// void _detailAdvanceForProjectAndTrip(PlutoRow row) async {
//   final advanceId = row.cells['id']?.value?.toString();
//   if (advanceId == null || advanceId.isEmpty) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Error: Could not find advance ID')),
//     );
//     return;
//   }

//   try {
//     final advance = await ApiService().getAdvanceById(advanceId);
//     if (advance != null) {
//       final success = await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => AddAdvanceRequestForm(
//             advanceId: advanceId,
//             isViewMode: true,
//             advance: advance,
//             requestType: advance.requestType,
//           ),
//         ),
//       );
//       if (success == true) {
//         _fetchAdvanceRequest();
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Advance request not found')),
//       );
//     }
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Error loading advance: ${e.toString()}')),
//     );
//   }
// }

// void _detailAdvanceForOperation(PlutoRow row) async {
//   final advanceId = row.cells['id']?.value?.toString();
//   if (advanceId == null || advanceId.isEmpty) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Error: Could not find advance ID')),
//     );
//     return;
//   }

//   try {
//     final advance = await ApiService().getAdvanceById(advanceId);
//     if (advance != null) {
//       final success = await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => AdvanceRequestForm(
//               advanceId: advanceId,
//               isViewMode: true,
//               readOnly: true,
//               advance: advance),
//         ),
//       );
//       if (success == true) {
//         _fetchAdvanceRequest();
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Advance request not found')),
//       );
//     }
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Error loading advance: ${e.toString()}')),
//     );
//   }
// }

//   List<PlutoColumn> _buildColumns() {
//     return [
// PlutoColumn(
//   title: 'ID',
//   field: 'id',
//   type: PlutoColumnType.text(),
//   enableEditingMode: false,
//   hide: true,
// ),
// PlutoColumn(
//   title: 'Request Date',
//   field: 'requestdate',
//   type: PlutoColumnType.text(),
//   enableEditingMode: false,
//   width: 145,
// ),
// PlutoColumn(
//   title: 'Request No',
//   field: 'requestno',
//   type: PlutoColumnType.text(),
//   enableEditingMode: false,
//   width: 142,
// ),
// PlutoColumn(
//   title: 'Request Type',
//   field: 'requesttype',
//   type: PlutoColumnType.text(),
//   enableEditingMode: false,
//   width: 200,
// ),
// PlutoColumn(
//   title: 'Request Code',
//   field: 'requestcode',
//   type: PlutoColumnType.text(),
//   enableEditingMode: false,
//   width: 142,
//   textAlign: PlutoColumnTextAlign.left,
//   titleTextAlign: PlutoColumnTextAlign.left,
// ),
// PlutoColumn(
//   title: 'Request Amount',
//   field: 'requestamount',
//   type: PlutoColumnType.number(),
//   enableEditingMode: false,
//   width: 180,
//   textAlign: PlutoColumnTextAlign.right,
//   titleTextAlign: PlutoColumnTextAlign.right,
//   renderer: (context) {
//     final value = int.tryParse(context.cell.value.toString()) ?? 0;
//     return Text(_formatter.format(value), textAlign: TextAlign.right);
//   },
// ),
// PlutoColumn(
//   title: 'Currency',
//   field: 'currency',
//   type: PlutoColumnType.text(),
//   enableEditingMode: false,
//   width: 100,
//   textAlign: PlutoColumnTextAlign.left,
//   titleTextAlign: PlutoColumnTextAlign.left,
// ),
// PlutoColumn(
//   title: 'Requester',
//   field: 'requester',
//   type: PlutoColumnType.text(),
//   enableEditingMode: false,
//   width: 200,
//   textAlign: PlutoColumnTextAlign.left,
//   titleTextAlign: PlutoColumnTextAlign.left,
// ),
// PlutoColumn(
//   title: 'Action',
//   field: 'action',
//   type: PlutoColumnType.text(),
//   width: 150,
//   textAlign: PlutoColumnTextAlign.center,
//   titleTextAlign: PlutoColumnTextAlign.center,
//   enableEditingMode: false,
//   renderer: (rendererContext) {
//     final row = rendererContext.row;
//     final requestType = row.cells['requesttype']?.value.toString() ?? '';

//     return IconButton(
//       icon: const Icon(Icons.more_horiz, color: Colors.black),
//       onPressed: () {
//         if (requestType == 'Project' || requestType == 'Trip') {
//           _detailAdvanceForProjectAndTrip(rendererContext.row);
//         } else if (requestType.toLowerCase().contains('operation')) {
//           _detailAdvanceForOperation(rendererContext.row);
//         }
//       },
//     );
//   },
// ),
//     ];
//   }

//   List<PlutoRow> _buildRows(List<Advance> advanceList) {
//     return advanceList.map((advance) {
//       return PlutoRow(cells: {
// 'id': PlutoCell(value: advance.id),
// 'requestdate':
//     PlutoCell(value: DateFormat('yyyy-MM-dd').format(advance.date)),
// 'requestno': PlutoCell(value: advance.requestNo),
// 'requesttype': PlutoCell(value: advance.requestType),
// 'requestcode': PlutoCell(value: advance.requestCode),
// 'requestamount': PlutoCell(value: advance.requestAmount),
// 'currency': PlutoCell(value: advance.currency),
// 'requester': PlutoCell(value: advance.requester),
// 'action': PlutoCell(value: '')
//       });
//     }).toList();
//   }

// void _refreshData() async {
//   setState(() {
//     _searchQuery = "";
//     _currentDateRange = null;
//     _currentFilterType = null;
//     _currentPage = 1;
//   });
//   try {
//     List<Advance> advance = await ApiService().fetchAdvanceRequests();
//     setState(() {
//       advances = advance;
//     });

//     _applyDateFilter();
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Failed to refresh trips: ${e.toString()}')),
//     );
//   }
// }

// //Export button
// Future<void> exportToCSV() async {
//   try {
//     List<List<dynamic>> csvData = [];
//     csvData.add([
//       "Request Date",
//       "Request No",
//       "Request Type",
//       "Request Code",
//       "Request Description",
//       "Request Amount",
//       "Currency",
//       "Approved Amount",
//       "Requester",
//       "Department",
//       "Request Purpose",
//       "Status"
//     ]);
//     for (var advance in advances) {
//       csvData.add([
//         DateFormat('yyyy-MM-dd').format(advance.date),
//         advance.requestNo,
//         advance.requestType,
//         advance.requestCode,
//         advance.requestDes,
//         advance.requestAmount,
//         advance.currency,
//         advance.approvedAmount,
//         advance.requester,
//         advance.departmentName,
//         advance.purpose,
//         advance.status
//       ]);
//     }
//     String csv = const ListToCsvConverter().convert(csvData);
//     if (kIsWeb) {
//       final bytes = utf8.encode(csv);
//       final blob = html.Blob([bytes]);
//       final url = html.Url.createObjectUrlFromBlob(blob);
//       final anchor = html.AnchorElement(href: url)
//         ..setAttribute("download", "advance.csv")
//         ..click();

//       html.Url.revokeObjectUrl(url);
//       print("CSV file download in browser");
//     } else {
//       final directory = await getApplicationDocumentsDirectory();
//       final path = "${directory.path}/advance.csv";
//       final file = File(path);
//       await file.writeAsString(csv);

//       print("CSV file saved to $path");
//     }
//   } catch (e) {
//     print("Error exporting to CSV: $e");
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar:
//           AppBar(title: const Text('Advance Request List '), centerTitle: true),
//       // body: _rows.isEmpty
//       // ? Center(child: CircularProgressIndicator())
//       body: Padding(
//         padding: const EdgeInsets.fromLTRB(50, 20, 50, 30),
//         child: Container(
//           height: 470,
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   Flexible(
//                     flex: 1,
//                     child: DateFilterDropdown(
//                       onDateRangeChanged: _handleDateRangeChange,
//                       initialValue: _currentFilterType,
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   // Add filter indicator chip
//                   if (_currentFilterType != null)
//                     Chip(
//                       label: Text(
//                         'Filter: ${_currentFilterType!.replaceAll('_', ' ')}',
//                         style: const TextStyle(fontSize: 12),
//                       ),
//                       onDeleted: () {
//                         setState(() {
//                           _currentDateRange = null;
//                           _currentFilterType = null;
//                         });
//                         _applyDateFilter();
//                       },
//                     ),
//                   const SizedBox(
//                     width: 20,
//                   ),
//                   Flexible(
//                     flex: 3,
//                     child: CustomSearchBar(
//                       onSearch: _handleSearch,
//                       hintText: 'Search...',
//                       minWidth: 500,
//                       maxWidth: 800,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         width: 150,
//                         height: 35,
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade300,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: DropdownButtonHideUnderline(
//                           child: DropdownButton<String>(
//                             isExpanded: true,
//                             icon: const Icon(Icons.arrow_drop_down,
//                                 color: Colors.black),
//                             style: const TextStyle(
//                                 color: Colors.black, fontSize: 16),
//                             hint: const Padding(
//                               padding: EdgeInsets.symmetric(horizontal: 12),
//                               child: Row(
//                                 children: [
//                                   Icon(Icons.add, color: Colors.black),
//                                   SizedBox(width: 8),
//                                   Text('New',
//                                       style: TextStyle(color: Colors.black)),
//                                 ],
//                               ),
//                             ),
//                             items: const [
//                               DropdownMenuItem(
//                                 value: 'operation_advance',
//                                 child: Text('Request Operation Advance'),
//                               ),
//                               DropdownMenuItem(
//                                 value: 'project_trip',
//                                 child: Text('Request Project or Trip Request'),
//                               ),
//                             ],
//                             onChanged: (value) {
//                               if (value == 'operation_advance') {
//                                 Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (context) =>
//                                             const AdvanceRequestForm(
//                                                 advanceId: '0')));
//                               } else if (value == 'project_trip') {
//                                 Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (context) =>
//                                             AdvanceProjectTripTable()));
//                               }
//                             },
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
// Row(
//   children: [
//     Container(
//       child: IconButton(
//         icon: const Icon(Icons.refresh),
//         onPressed: _refreshData,
//         color: Colors.black,
//       ),
//     ),
//     ElevatedButton.icon(
//       label: const Text('Export'),
//       onPressed: exportToCSV,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.grey.shade300,
//         foregroundColor: Colors.black,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//     ),
//   ],
// ),
//                 ],
//               ),
//               const SizedBox(height: 7),
//               Expanded(
//                 child: PlutoGrid(
//                     columns: _columns,
//                     rows: _pagedRows,
//                     configuration: PlutoGridConfiguration(
//                       style: PlutoGridStyleConfig(
//                         oddRowColor: Colors.blue[50],
//                         rowHeight: 35,
//                         activatedColor: Colors.lightBlueAccent.withOpacity(0.2),
//                       ),
//                     ),
//                     onLoaded: (event) {
//                       _stateManager = event.stateManager;
//                       _updatePagedRows();
//                     }),
//               ),
//               const SizedBox(height: 10),
//               if (_stateManager != null)
//                 PlutoGridPagination(
//                   stateManager: _stateManager!,
//                   totalRows: _rows.length,
//                   rowsPerPage: _rowsPerPage,
//                   onPageChanged: (page, limit) {
//                     _currentPage = page;
//                     _rowsPerPage = limit;
//                     _updatePagedRows();
//                   },
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'dart:html' as html;
import 'package:advance_budget_request_system/views/addAdvanceRequestForm.dart';
import 'package:advance_budget_request_system/views/advanceRequestFormOperation.dart';
import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:advance_budget_request_system/views/data.dart';
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
  List<Project> projects = [];
  List<Trips> trips = [];
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
      projects = (await ApiService().fetchProjects())
          .where((p) => p.requestable.toLowerCase() == 'yes')
          .toList();
      trips = (await ApiService().fetchTrips())
          .where((t) => t.directAdvanceReq == false)
          .toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
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

      // _applyDateFilter();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to refresh trips: ${e.toString()}')),
      );
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
    final total = advances.length;
    if (total == 0) return [];
    final start = ((_currentPageAdvance - 1) * _rowsPerPage).clamp(0, total);
    final end = (start + _rowsPerPage).clamp(0, total);
    return advances.sublist(start, end);
  }

  List<Project> get _paginatedProjects {
    final total = projects.length;
    if (total == 0) return [];
    final start = ((_currentPageProject - 1) * _rowsPerPage).clamp(0, total);
    final end = (start + _rowsPerPage).clamp(0, total);
    return projects.sublist(start, end);
  }

  List<Trips> get _paginatedTrips {
    final total = trips.length;
    if (total == 0) return [];
    final start = ((_currentPageTrip - 1) * _rowsPerPage).clamp(0, total);
    final end = (start + _rowsPerPage).clamp(0, total);
    return trips.sublist(start, end);
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
              totalRows: advances.length,
              rowsPerPage: _rowsPerPage,
              onPageChanged: (page, rowsPerPage) {
                setState(() {
                  _currentPageAdvance = page;
                  _rowsPerPage = rowsPerPage;

                  final start = (page - 1) * rowsPerPage;
                  final end = (start + rowsPerPage > advances.length)
                      ? advances.length
                      : start + rowsPerPage;

                  final _paginatedAdvances = advances.sublist(start, end);

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
              ElevatedButton(onPressed: null, child: Text("Request Advance"))
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
            totalRows: projects.length,
            rowsPerPage: _rowsPerPage,
            onPageChanged: (page, rowsPerPage) {
              setState(() {
                _currentPageProject = page;
                _rowsPerPage = rowsPerPage;
                final start = (page - 1) * rowsPerPage;
                final end = (start + rowsPerPage > projects.length)
                    ? projects.length
                    : start + rowsPerPage;
                final _paginatedProjects = projects.sublist(start, end);
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
              ElevatedButton(onPressed: null, child: Text("Request Advance"))
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
              setState(() {
                
              });
            },
          ),
        ),
        if (_gridStateManagerTrip != null)
          PlutoGridPagination(
            stateManager: _gridStateManagerTrip!,
            totalRows: trips.length,
            rowsPerPage: _rowsPerPage,
            onPageChanged: (page, rowsPerPage) {
              setState(() {
                _currentPageTrip = page;
                _rowsPerPage = rowsPerPage;

                final start = (page - 1) * rowsPerPage;
                final end = (start + rowsPerPage > trips.length)
                    ? trips.length
                    : start + rowsPerPage;

                final _paginatedTrip = trips.sublist(start, end);

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
