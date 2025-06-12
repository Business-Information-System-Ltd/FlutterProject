import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'dart:html' as html;
import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:advance_budget_request_system/views/data.dart';
import 'package:advance_budget_request_system/views/projectEntry.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class ProjectInfo extends StatefulWidget {
  @override
  _ProjectInfoState createState() => _ProjectInfoState();
}

class _ProjectInfoState extends State<ProjectInfo> {
  String selectedRequester = '';
  String? selectedDate;
  DateTime? startDate;
  DateTime? endDate;

  dynamic hoverRow;
  String? selectedFilter;
  DateTimeRange? selectedDateRange;
  DateTimeRange? CustomDateRange;
  TextEditingController _searchController = TextEditingController();
  final numberFormat = NumberFormat("#,##0");

  String? sortColumn;
  bool sortAscending = true;
  List<Projects> filterData = [];
  String searchQuery = '';
  int rowsPerPage = 10;
  int currentPage = 1;
  int totalPages = 1;
  String? selectedDepartmentName;

  final List<Budget> chooseBudgetCodes = [];
  // String selectedBudgetCode = "";
  // List<String> selectedBudgetCodes = [];
  //Set<String> selectedBudgetCodes = {};

  List<String> selectedFilters = [];
  List<Projects> projectData = [];
  final List<Budget> BudgetDetails = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    try {
      List<Projects> projects = await ApiService().fetchProjectInfoData();
      setState(() {
        projectData = projects;
        filterData = List.from(projectData);
        print("Fetched Projects: $projectData"); // Log fetched projects
        print("Filter Data: $filterData");
        _updatePagination();
      });
    } catch (e) {
      print("Fail to project: $e");
    }
  }

  // ignore: unused_element
  void _refreshData() {
    setState(() {
      _searchController.clear();
      selectedDateRange = null;
      selectedDate = null;
      startDate = null;
      endDate = null;
      filterData = projectData;
      sortColumn = null;
      _fetchData();
      _updatePagination();
      currentPage = 1;
    });
  }

  void _sortDataColumn(String column) {
    setState(() {
      if (sortColumn == column) {
        sortAscending = !sortAscending;
      } else {
        sortColumn = column;
        sortAscending = true;
      }

      filterData.sort((a, b) {
        dynamic aValue;
        dynamic bValue;

        switch (column) {
          case 'Date':
            aValue = a.date;
            bValue = b.date;
            break;
          case 'Project_Code':
            aValue = a.Project_Code;
            bValue = b.Project_Code;
            break;
          case 'Description':
            aValue = a.description;
            bValue = b.description;
            break;
          case 'Total Budget Amount':
            aValue = a.totalAmount;
            bValue = b.totalAmount;
            break;
          case 'Currency':
            aValue = a.currency;
            bValue = b.currency;
            break;
          case 'Department':
            aValue = a.departmentName;
            bValue = b.departmentName;
            break;
          case 'Requestable':
            aValue = a.requestable;
            bValue = b.requestable;
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

  void _searchData(String query) {
    setState(() {
      List<Projects> sourceData = projectData;
      filterData = sourceData.where((data) {
        final Project_Code = data.Project_Code.toLowerCase();
        final description = data.description.toLowerCase();
        final totalAmt = data.totalAmount.toString();
        final currency = data.currency.toLowerCase();
        final department = data.departmentName.toLowerCase();
        final requestable = data.requestable.toLowerCase();

        final String searchLower = query.toLowerCase();

        return Project_Code.contains(searchLower) ||
            description.contains(searchLower) ||
            totalAmt.contains(searchLower) ||
            currency.contains(searchLower) ||
            requestable.contains(searchLower) ||
            department.contains(searchLower);
      }).toList();
      _updatePagination();
    });
  }

  TextEditingController searchController = TextEditingController();
  // Stores selected values

  final Map<String, List<String>> dropdownOptions = {
    "Currency": ["MMK", "USD"],
    "Department": [
      'HR',
      'IT',
      'Finance',
      'Admin',
      'Production',
      'Engineering',
      'Marketing',
      'Sales'
    ],
    "Status": ["Active", "Inactive"],
  };

// ignore: unused_element

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
      filterData = projectData.where((data) {
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
                  child: const Text('Cancel'))
            ],
          );
        });
  }

  // ignore: unused_element
  void _openAdvancedSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AdvancedSearchDialog(
          dropdownOptions: dropdownOptions,
          onFilterSelected: (selectedValue) {
            setState(() {
              if (!selectedFilters.contains(selectedValue)) {
                selectedFilters.add(selectedValue);
              }
              _updateSearchField(); // Add selected value to the list
            });
          },
        );
      },
    );
  }

  void _updateSearchField() {
    searchController.text = selectedFilters.join(", ");
  }

  // ignore: unused_element
  void _clearSearch() {
    setState(() {
      selectedFilters.clear();
      searchController.clear();
    });
  }

  void _updatePagination() {
    setState(() {
      totalPages = (filterData.length / rowsPerPage).ceil();
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

  List<Projects> get paginatedData {
    int start = (currentPage - 1) * rowsPerPage;
    int end = start + rowsPerPage < filterData.length
        ? start + rowsPerPage
        : filterData.length;
    return filterData.sublist(start, end);
  }

  void _removeFilter(String value) {
    setState(() {
      selectedFilters.remove(value); // Remove the selected value
    });
  }

  void _deleteConfirmation(Projects bg) async {
    bool? confirm = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Delete Confirmation"),
            content: const Text("Are you sure to delete this Project Data?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("Delete")),
            ],
          );
        });

    if (confirm != null && confirm) {
      try {
        await ApiService().deleteProject(bg.id);
        setState(() {
          projectData.removeWhere((item) => item.id == bg.id);
          filterData.remove(bg);
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Project Data is deleted successfully")));
      } catch (e) {
        print('Failed to delete Budgetcode');
      }
    }
  }

  Future<void> exportToCSV() async {
    try {
      // Convert the projectData list to a list of lists (CSV rows)
      List<List<dynamic>> csvData = [];

      //Add the header row
      csvData.add([
        "Request Date",
        "Project Code",
        "Description",
        "Total Amount",
        "Currency",
        "Department",
        "ApprovedAmount",
        "Request Status",
        "Budget Details"
      ]);

      //Add the data rows
      for (var project in projectData) {
        csvData.add([
          DateFormat('yyyy-MM-dd').format(project.date),
          project.Project_Code,
          project.description,
          project.totalAmount,
          project.currency,
          project.departmentName,
          project.approveAmount,
          project.requestable,
          serializeBudgetDetails(project.budgetDetails)
        ]);
      }

      String csv = const ListToCsvConverter().convert(csvData);
      if (kIsWeb) {
        final bytes = utf8.encode(csv);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "project.csv")
          ..click();

        html.Url.revokeObjectUrl(url);
        print("CSV file downloaded in browser");
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final path = "${directory.path}/project.csv";
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

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Project Information",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
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

                const SizedBox(width: 30),
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.black),
                        onPressed: () {},
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _searchData,
                          textAlign: TextAlign.start,
                          decoration: const InputDecoration(
                            hintText: "Search",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(8.0),
                            isCollapsed: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: selectedFilters.map((filter) {
                          return Chip(
                            label: Text(filter),
                            backgroundColor: Colors.blue.shade100,
                            deleteIcon: const Icon(Icons.close,
                                size: 18, color: Colors.red),
                            onDeleted: () => _removeFilter(filter),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // 🏷️ Wrap for Filters

                const SizedBox(
                    width: 10), // Space between search bar and filters button
                // Space between search bar and filters button

                // IconButton(
                // IconButton(
                //   icon: const Icon(Icons.more_vert),
                //   // label: const Text("Filters"),
                //   // label: const Text("Filters"),
                //   onPressed: _openAdvancedSearchDialog,
                // ),

                // SizedBox(width: MediaQuery.of(context).size.width / 3.3),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 150, 212, 234),
                    borderRadius: BorderRadius.circular(10),
                    // border: Border.all(color: Colors.greenAccent),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.black),
                        onPressed: () async {
                          final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      EntryForm(onProjectAdded: (newProject) {
                                        setState(() {
                                          projectData.add(newProject);
                                          filterData = List.from(projectData);
                                        });
                                        _updatePagination();
                                      })));
                          if (result == true) {
                            _fetchData();
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.black),
                        onPressed: () {
                          _refreshData();
                         
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.download, color: Colors.black),
                        onPressed: exportToCSV,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: screenWidth,
                  child: Table(
                    border: const TableBorder.symmetric(
                      inside: BorderSide(color: Colors.grey, width: 1),
                      outside: BorderSide(color: Colors.grey, width: 1),
                    ),
                    columnWidths: const {
                      0: FlexColumnWidth(0.8),
                      1: FlexColumnWidth(0.8),
                      2: FlexColumnWidth(1.5),
                      3: FlexColumnWidth(1.2),
                      4: FlexColumnWidth(0.6),
                      5: FlexColumnWidth(0.7),
                      6: FlexColumnWidth(0.8),
                      7: FlexColumnWidth(0.9),
                      // 8: FlexColumnWidth(0.8),
                    },
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 167, 230, 232)),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildHeaderCell(
                              "Request Date",
                              "Date",
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildHeaderCell(
                              "Project_Code",
                              "Project_Code",
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildHeaderCell(
                              "Description",
                              "Description",
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildHeaderCell(
                              "Total Budget Amount",
                              "Total Budget Amount",
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildHeaderCell(
                              "Currency",
                              "Currency",
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildHeaderCell(
                              "Department",
                              "Department",
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildHeaderCell(
                              "Requestable",
                              "Requestable",
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Action",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  border: const TableBorder.symmetric(
                    inside: BorderSide(color: Colors.grey, width: 1),
                    outside: BorderSide(color: Colors.black, width: 1),
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(0.8),
                      1: FlexColumnWidth(0.8),
                      2: FlexColumnWidth(1.5),
                      3: FlexColumnWidth(1.2),
                      4: FlexColumnWidth(0.6),
                      5: FlexColumnWidth(0.7),
                      6: FlexColumnWidth(0.8),
                      7: FlexColumnWidth(0.9),
                    // 8: FlexColumnWidth(0.8),
                  },
                  children: paginatedData.map(
                    (row) {
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child:
                                Text(DateFormat('yyyy-MM-dd').format(row.date)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(row.Project_Code),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(row.description),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment
                                  .centerRight, // Aligns the text to the right
                              child: Text(row.totalAmount.toString()),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(row.currency),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(row.departmentName),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(row.requestable),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditProject(
                                            projectData: row,
                                            onProjectUpdated: _fetchData,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.edit),
                                    color: Colors.black),
                                IconButton(
                                    onPressed: () {
                                      _deleteConfirmation(row);
                                    },
                                    icon: const Icon(Icons.delete),
                                    color: Colors.black),
                                IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ProjectDetailPage(
                                                    projectData: row)),
                                      );
                                    },
                                    icon: const Icon(Icons.more_horiz_outlined),
                                    color: Colors.black),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ).toList(),
                ),
              ),
            ),
            _buildPaginationControls(),
          ],
        ),
      ),
    );
  }
}

class EditProject extends StatefulWidget {
  final Projects projectData;
  final Function() onProjectUpdated;
  const EditProject(
      {Key? key, required this.projectData, required this.onProjectUpdated})
      : super(key: key);

  @override
  State<EditProject> createState() => _EditProjectState();
}

class _EditProjectState extends State<EditProject> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _projectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  List<Budget> chooseBudgetCodes = [];
  List<Budget> BudgetDetail = [];

  String _selectedCurrency = 'MMK';
  List<Department> departments = [];
  String? _selectedDepartmentName;
  String? selectedDepartmentId;

  @override
  void initState() {
    super.initState();
    _projectController.text = widget.projectData.Project_Code;
    _descriptionController.text = widget.projectData.description;
    _amountController.text = widget.projectData.totalAmount.toString();
    _selectedCurrency = widget.projectData.currency;
    selectedDepartmentId = widget.projectData.departmentId.toString();
    _selectedDepartmentName = widget.projectData.departmentName;
    dateController.text =
        DateFormat('yyyy-MM-dd').format(widget.projectData.date);

    chooseBudgetCodes = List.from(widget.projectData.budgetDetails);
    _fetchData();
  }

  void _fetchData() async {
    try {
      List<Budget> BudgetDetails = await ApiService().fetchBudgetCodeData();
      List<Department> department = await ApiService().fetchDepartment();
      setState(() {
        BudgetDetail = BudgetDetails;
        departments = department;

        print("BudgetDetails: $BudgetDetails.length");
        if (!departments
            .any((dept) => dept.id.toString() == selectedDepartmentId)) {
          selectedDepartmentId = widget.projectData.departmentId.toString();
          _selectedDepartmentName = widget.projectData.departmentName;
        }
      });
    } catch (e) {
      print("Fail to project: $e");
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (selectedDepartmentId == null ||
          selectedDepartmentId!.isEmpty ||
          selectedDepartmentId == "0") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a valid department")),
        );
        return;
      }
      int? departmentId = int.tryParse(selectedDepartmentId!);
      if (departmentId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid department selected")),
        );
        return;
      }
      Projects updatedProject = Projects(
        id: widget.projectData.id,
        date: DateFormat('yyyy-MM-dd').parse(dateController.text),
        Project_Code: _projectController.text,
        description: _descriptionController.text,
        totalAmount: double.parse(_amountController.text),
        currency: _selectedCurrency,
        approveAmount: widget.projectData.approveAmount,
        departmentId: departmentId,
        departmentName:
            _selectedDepartmentName ?? widget.projectData.departmentName,
        requestable: widget.projectData.requestable,
        // budgetDetails: chooseBudgetCodes,
        budgetDetails: chooseBudgetCodes,
      );
      try {
        await ApiService().updateProjectInfo(updatedProject);


        
        widget.onProjectUpdated();

        Navigator.pop(context); // Close the edit form
        _fetchData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Project updated successfully!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update Project: $e')),
        );
      }
    }
  }

  void _clearText() {
    setState(() {
      _projectController.clear();
      _descriptionController.clear();
      _amountController.clear();
      _selectedDepartmentName = null;
      _selectedCurrency = 'MMK';
    });
  }

  void _showBudgetCodeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 20.0, left: 16.0, right: 16.0, bottom: 16.0),
                child: Column(
                  children: [
                    const Text(
                      "Select Budget Code",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.35,
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: SingleChildScrollView(
                          child: DataTable(
                            showCheckboxColumn: false,
                            columns: const [
                              DataColumn(label: Text("")),
                              DataColumn(label: Text("Budget Code")),
                              DataColumn(label: Text("Description")),
                            ],
                            rows: BudgetDetail.map((budgetCode) {
                              bool isSelected = chooseBudgetCodes.any((code) =>
                                  code.BudgetCode == budgetCode.BudgetCode);

                              return DataRow(
                                cells: [
                                  DataCell(
                                    isSelected
                                        ? IconButton(
                                            icon: const Icon(Icons.check_circle,
                                                color: Colors.green),
                                            onPressed: () {
                                              setState(() {
                                                chooseBudgetCodes.removeWhere(
                                                    (code) =>
                                                        code.BudgetCode ==
                                                        budgetCode.BudgetCode);
                                              });
                                              Navigator.pop(context);
                                              _showBudgetCodeDialog();
                                            },
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                  DataCell(Text(budgetCode.BudgetCode)),
                                  DataCell(Text(budgetCode.Description)),
                                ],
                                onSelectChanged: (selected) {
                                  if (selected != null && selected) {
                                    if (isSelected) {
                                      // Show error message if the budget code is already selected
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "This budget code is already selected."),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    } else {
                                      setState(() {
                                        chooseBudgetCodes.add(budgetCode);
                                      });
                                      Navigator.pop(context);
                                    }
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.cancel_outlined, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteBudgetCode(int index) {
    if (index >= 0 && index < chooseBudgetCodes.length) {
      setState(() {
        chooseBudgetCodes.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Project Request"),
      ),
      body: Center(
        child: Container(
          color: const Color.fromARGB(255, 103, 207, 177),
          width: MediaQuery.of(context).size.width * 0.5,
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              'Edit Project Request',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  ListTile(
                                    title: TextFormField(
                                      readOnly: true,
                                      controller: _projectController,
                                      decoration: const InputDecoration(
                                          labelText: "Enter Project Code"),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Enter Project Code";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  ListTile(
                                    title: TextFormField(
                                      controller: _descriptionController,
                                      decoration: const InputDecoration(
                                          labelText:
                                              "Enter Project Description"),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Enter Project Description";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  ListTile(
                                    title: TextFormField(
                                      controller: _amountController,
                                      decoration: const InputDecoration(
                                        labelText: "Enter Total Amount",
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d*\.?\d*')),
                                      ],
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Enter Total Amount";
                                        }
                                        final amount = double.tryParse(value);
                                        if (amount == null) {
                                          return "Enter a valid amount";
                                        }
                                        if (amount <= 0) {
                                          return "Your Request Amount must be greater than 0";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                                child: Column(
                              children: [
                                ListTile(
                                  title: TextFormField(
                                    controller: dateController,
                                    decoration: const InputDecoration(
                                        labelText: "Request Date"),
                                    readOnly: true,
                                  ),
                                ),
                                ListTile(
                                  title: DropdownButtonFormField<String>(
                                    value: _selectedDepartmentName,
                                    decoration: const InputDecoration(
                                        labelText: "Department"),
                                    items: departments.map((dept) {
                                      return DropdownMenuItem<String>(
                                        value: dept.departmentName,
                                        child: Text(dept.departmentName),
                                        onTap: () {
                                          setState(() {
                                            selectedDepartmentId =
                                                dept.id.toString();
                                            _selectedDepartmentName =
                                                dept.departmentName;
                                          });
                                        },
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          _selectedDepartmentName = value;
                                          selectedDepartmentId = departments
                                              .firstWhere((dept) =>
                                                  dept.departmentName == value)
                                              .id
                                              .toString();
                                        });
                                      }
                                    },
                                    validator: (value) => value == null
                                        ? "Select department"
                                        : null,
                                  ),
                                ),
                                ListTile(
                                  title: DropdownButtonFormField(
                                    decoration: const InputDecoration(
                                      labelText: "Currency",
                                    ),
                                    value: _selectedCurrency,
                                    items: ['MMK', 'USD'].map((currency) {
                                      return DropdownMenuItem(
                                          value: currency,
                                          child: Text(currency));
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCurrency = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            )),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              ElevatedButton(
                                  onPressed: _showBudgetCodeDialog,
                                  style: ElevatedButton.styleFrom(
                                    textStyle: const TextStyle(fontSize: 15),
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text("Add Budget Code")),
                              const SizedBox(height: 10),
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: DataTable(
                                    border: TableBorder.all(),
                                    showCheckboxColumn: false,
                                    columns: const [
                                      DataColumn(label: Text("Budget Code")),
                                      DataColumn(label: Text("Description")),
                                      DataColumn(label: Text("Action")),
                                    ],
                                    rows: chooseBudgetCodes.map((budgetCode) {
                                      final index =
                                          chooseBudgetCodes.indexOf(budgetCode);
                                      return DataRow(cells: [
                                        DataCell(Text(budgetCode.BudgetCode)),
                                        DataCell(Text(budgetCode.Description)),
                                        DataCell(IconButton(
                                            onPressed: () {
                                              _deleteBudgetCode(index);
                                            },
                                            icon: const Icon(Icons.delete)))
                                      ]);
                                    }).toList(),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                ),
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text("Update"),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            ElevatedButton(
                              onPressed: _clearText,
                              style: ElevatedButton.styleFrom(
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                ),
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text("Clear"),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdvancedSearchDialog extends StatefulWidget {
  final Map<String, List<String>> dropdownOptions;
  final Function(String) onFilterSelected;

  AdvancedSearchDialog({
    required this.dropdownOptions,
    required this.onFilterSelected,
  });

  @override
  _AdvancedSearchDialogState createState() => _AdvancedSearchDialogState();
}

class _AdvancedSearchDialogState extends State<AdvancedSearchDialog> {
  Map<String, String?> selectedValues = {};
  TextEditingController searchTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Advanced Search"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: searchTextController,
            decoration: const InputDecoration(
              labelText: "Enter search text",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          ...widget.dropdownOptions.keys.map((category) {
            return _buildDropdown(
              title: category,
              options: widget.dropdownOptions[category]!,
              selectedValue: selectedValues[category],
              onChanged: (newValue) {
                setState(() {
                  selectedValues[category] = newValue;
                });
              },
            );
          }).toList(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
        ElevatedButton(
          onPressed: () {
            if (searchTextController.text.isNotEmpty) {
              widget.onFilterSelected(searchTextController.text);
            }

            selectedValues.forEach((key, query) {
              if (query != null) {
                widget.onFilterSelected(query);
              }
            });
            Navigator.pop(context);
          },
          child: const Text("Search"),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String title,
    required List<String> options,
    required String? selectedValue,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            isExpanded: true,
            value: selectedValue,
            hint: Text("Select $title"),
            items: options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class ProjectDetailPage extends StatefulWidget {
  final Projects projectData;
  // final List<Map<String, dynamic>> selectedBudgetCodes;
  //final String selectedBudgetCode;

  const ProjectDetailPage({
    super.key,
    required this.projectData,
  });

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailState();
}

class _ProjectDetailState extends State<ProjectDetailPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // // ignore: unused_local_variable
    // List<Budget> BudgetDetails = [];
    // if (widget.projectData["budgetDetails"] != null) {
    //   if (widget.projectData["BudgetDetails"] is String) {
    //     budgetDetails = _parseBudgetDetails(widget.projectData["BudgetDetails"]);
    //   } else if (widget.projectData["BudgetDetails"] is List) {
    //     budgetDetails =
    //         List<Map<String, String>>.from(widget.projectData["BudgetDetails"]);
    //   }
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Project Details"),
        backgroundColor: const Color.fromRGBO(100, 207, 198, 0.855),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow("Project Code", widget.projectData.Project_Code, "Amount",
                widget.projectData.totalAmount.toString()),
            const SizedBox(height: 10),
            _buildRow("Description", widget.projectData.description, "Currency",
                widget.projectData.currency),
            const SizedBox(height: 10),
            _buildRow(
                "Date",
                DateFormat('yyyy-MM-dd').format(widget.projectData.date),
                '',''),
            const SizedBox(height: 10),
            _buildRow("Department", widget.projectData.departmentName,
                "Requestable", widget.projectData.requestable),
            const SizedBox(height: 10),
            const SizedBox(height: 20),
            const Text("Budget Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(
              height: 40,
            ),
            Center(
              child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: _buildBudgetTable(widget.projectData.budgetDetails)),
            ),
            const SizedBox(height: 40),
            Center(
                child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Back"),
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
          if (label2.isNotEmpty) _buildInlineText(label2, value2 ?? ""),
        ],
      ),
    );
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

  Widget _buildBudgetTable(List<Budget> BudgetDetails) {
    return Table(
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
        ...BudgetDetails.map((budget) => TableRow(
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
    );
  }
}

// ignore: unused_element
Widget _buildTableCell(String text, {bool isHeader = false}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      text,
      style: TextStyle(
        fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        fontSize: 16,
      ),
    ),
  );
}

List<Map<String, String>> _parseBudgetDetails(String budgetDetails) {
  try {
    // Replace single quotes with double quotes for JSON parsing
    String formattedString = budgetDetails.replaceAll("'", '"');
    // Parse the JSON string into a List of Maps
    List<dynamic> parsedList = jsonDecode(formattedString);
    // Convert to List<Map<String, String>>
    return parsedList.map((item) => Map<String, String>.from(item)).toList();
  } catch (e) {
    print("Error parsing BudgetDetails: $e");
    return [];
  }
}
