import 'dart:convert';
import 'dart:io';

import 'package:advance_budget_request_system/views/datefilter.dart';
import 'package:advance_budget_request_system/views/pagination.dart';
import 'package:advance_budget_request_system/views/searchfunction.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:intl/intl.dart';
import 'package:advance_budget_request_system/views/projectentryform.dart';
import 'package:advance_budget_request_system/views/data.dart';
import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class ProjectInformation extends StatefulWidget {
  final bool readOnly;
  
  final Map<String, dynamic>? initialRequestData;

  const ProjectInformation({
    Key? key,
    this.readOnly = false,
    this.initialRequestData,
  }) : super(key: key);

  @override
  _ProjectInformationState createState() => _ProjectInformationState();
}

class _ProjectInformationState extends State<ProjectInformation> {
  List<PlutoColumn> _columns = [];
  List<PlutoRow> _rows = [];
  List<Project> projects = [];
  List<PlutoRow> _pagedRows = [];
  List<Project> _allProjects=[];
  DateTimeRange? _currentDateRange;
  String? _currentFilterType;
  PlutoGridStateManager? _stateManager;
  final NumberFormat _formatter = NumberFormat('#,###');
  bool isEditMode = false;
  String _searchQuery = '';
  int _currentPage = 1;
  int _rowsPerPage = 10;
  bool _isLoading=true;

  @override
  void initState() {
    super.initState();
    _columns = _buildColumns();
    _rows = _buildRows(projects);
    _fetchProjects();
   _refreshData();
    _isLoading=false;
    print(" Rows loaded: ${_rows.length}");
  }

  void _fetchProjects() async {
    try {
 
      List<Project> project = await ApiService().fetchProjects();
      setState(() {
        projects = project;
      });

      _applyDateFilter(); 
      
    } catch (e) {
      print('Error fetching projects: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load project data')),
      );
    }
  }

  void _applyDateFilter() {
    List<Project> filteredProjects = projects;
    if (_currentDateRange != null) {
      final startDate = DateTime(
        _currentDateRange!.start.year,
        _currentDateRange!.start.month,
        _currentDateRange!.start.day,
      );
      final endDate = DateTime(_currentDateRange!.end.year,
              _currentDateRange!.end.month, _currentDateRange!.end.day)
          .add(const Duration(days: 1));

      filteredProjects = projects.where((project) {
        final projectDate =
            DateFormat('yyyy-MM-dd').parse(project.date.toString());
        final normalizedProjectDate =
            DateTime(projectDate.year, projectDate.month, projectDate.day);
        return normalizedProjectDate.isAtSameMomentAs(startDate) ||
            (normalizedProjectDate.isAfter(startDate) &&
                normalizedProjectDate.isBefore(endDate));
      }).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filteredProjects = filteredProjects
          .where((project) =>
              SearchUtils.matchesSearchProject(project, _searchQuery))
          .toList();
    }

    final newRows = _buildRows(filteredProjects);

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

  
  List<PlutoRow> _buildRows(List<Project> projects) {
   final validProjects = projects.where((p) => p.id != 0).toList();

    return validProjects.map((p) {
      return PlutoRow(cells: {
        'id': PlutoCell(value: p.id),
        'date': PlutoCell(value: DateFormat('yyyy-MM-dd').format(p.date)),
        'projectcode': PlutoCell(value: p.projectCode),
        'description': PlutoCell(value: p.projectDescription),
        'totalamount': PlutoCell(value: p.totalAmount),
        'currency': PlutoCell(value: p.currency),
        'department': PlutoCell(value: p.departmentName),
        'requestable': PlutoCell(value: p.requestable),
        'action': PlutoCell(value: ''),
      });
    }).toList();
  }

  Future<void> _deleteConfirmation(PlutoRow row) async {
    final projectId = row.cells['id']!.value.toString();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete project $projectId?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final projectToDelete = projects.firstWhere(
          (p) => p.id.toString() == projectId,
          orElse: () => throw Exception('Project not found'),
        );
        
        // await ApiService().deleteProject(projectId.toString());
       
        setState(() {
          projects.removeWhere((p) => p.id.toString() == projectId);
          _rows = _buildRows(projects);
          bool _isLoading=false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          
          SnackBar(content: Text('Project deleted successfully:$projectId')),
        );
      } catch (e) {
        print('Delete failed: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete project:$projectId')),
        );
      }
    }
  }

  final ApiService apiService = ApiService();
  
  List<PlutoColumn> _buildColumns() {
    return [
      PlutoColumn(
        title: 'Date',
        field: 'date',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 100,
      ),
      PlutoColumn(
        title: 'Project Code',
        field: 'projectcode',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 142,
      ),
      PlutoColumn(
        title: 'Description',
        field: 'description',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 330,
      ),
      PlutoColumn(
        title: 'Total Amount',
        field: 'totalamount',
        type: PlutoColumnType.number(),
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
        textAlign: PlutoColumnTextAlign.left,
        titleTextAlign: PlutoColumnTextAlign.left,
      ),
      PlutoColumn(
        title: 'Department',
        field: 'department',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 120,
      ),
      PlutoColumn(
        title: 'Status',
        field: 'requestable',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 120,
      ),
      PlutoColumn(
        title: 'Action',
        field: 'action',
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 143,
        renderer: (rendererContext) {
          final requestable = rendererContext.row.cells['requestable']?.value;
          if (requestable == 'Pending') {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editProject(rendererContext.row)
    

                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await _deleteConfirmation(rendererContext.row);
                    _stateManager?.removeRows([rendererContext.row]);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.black),
                  onPressed: () => _detailProject(rendererContext.row)
                ),
              ],
            );
          } else {
            return IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.black),
             // onPressed: () => _detailProject(rendererContext.row),
             onPressed: () {
  print("Detail button clicked");
  _detailProject(rendererContext.row);
},

            );
          }
        },
      ),
    ];
  }

  void _refreshData() async{
    setState(() {
      _searchQuery = "";
      _currentDateRange = null;
      _currentFilterType = null;
      _currentPage = 1;
    });
    try {
      List<Project> project = await ApiService().fetchProjects();
      setState(() {
        projects = project;
      });

      _applyDateFilter(); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to refresh projects: ${e.toString()}')),
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
          "Project Code",
          "Project Description",
          "Department",
          "Total Amount",
          "Currency",
          "Approved Amount",
          "Requestable Status"
        ]
      );

    for(var project in projects){
      csvData.add([
        DateFormat('yyyy-MM-dd').format(project.date),
        project.projectCode,
        project.projectDescription,
        project.departmentName,
        project.totalAmount,
        project.currency,
        project.approvedAmount,
        project.requestable
      ]);
    }
    String csv= const ListToCsvConverter().convert(csvData);

    if (kIsWeb) {
      final bytes = utf8.encode(csv);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "projectData.csv")
          ..click();

        html.Url.revokeObjectUrl(url);
        print("CSV file downloaded in browser.");
    }else{
      final directory = await getApplicationDocumentsDirectory();
        final path = "${directory.path}/projectData.csv";
        final file = File(path);
        await file.writeAsString(csv);

        print("CSV file saved to $path");
    }
    } catch (e) {
      print("Error exporting to CSV: $e");
    }
  }

   void _editProject(PlutoRow row) async {
    final projectId = row.cells['id']!.value;
    setState(() {
    _isLoading = true;
  });
    final project = await ApiService().getProjectById(projectId);
    if (project != null) {
      final success = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddProjectForm(
           projectId: projectId,
            isEditMode: true,
            isViewMode: false,
            project: project,
          //  project:project,
            
           
          ),
        ),
      );
     
      if (success == true) _fetchProjects();
    }
     setState(() {
        _isLoading =false;
      });
  }

  void _detailProject(PlutoRow row) async {
    final projectId = row.cells['id']!.value;
    setState(() {
    _isLoading = true;
  });
    final project = await ApiService().getProjectById(projectId);
    if (project != null) {
      final success = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddProjectForm(
            projectId: projectId,
            isEditMode: false,
            isViewMode: true,
            project: project,
          ),
        ),
      );
     
      if (success == true) _fetchProjects();
    }
     setState(() {
        _isLoading =false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Project Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(80, 20, 80, 20),
        child: Container(
          height: 470,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: DateFilterDropdown(
                      onDateRangeChanged: _handleDateRangeChange,
                      selectedValue: _currentFilterType,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Add filter indicator chip
                  if (_currentFilterType != null)
                    Chip(
                      label: Text(
                        'Filter: ${_currentFilterType!.replaceAll('_', ' ')}',
                        style: TextStyle(fontSize: 12),
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
                        initialValue: _searchQuery,
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
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('New'),
                    onPressed: () async {
                      final result = await Navigator.of(context).push<Project>(
                        MaterialPageRoute(
                            builder: (context) => AddProjectForm(
                              projectId: '0',
                              isEditMode: false,
                              isViewMode: false,)),
                      );
                      setState(() {
                        _isLoading=false;
                      });
                         if (result == true) _fetchProjects();

                      // if (result != null) {
                      //   setState(() {
                      //     projects.add(result);
                      //     _rows = _buildRows(projects);
                      //   });
                      // }
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
                child:
                    // _rows.isEmpty
                    //     ? const Center(child: CircularProgressIndicator())
                    //     :
                    PlutoGrid(
                  columns: _columns,
                  rows: _rows,
                  mode: PlutoGridMode.normal,
                  configuration: PlutoGridConfiguration(
                    style: PlutoGridStyleConfig(
                      oddRowColor: Colors.blue[50],
                      rowHeight: 35,
                      activatedColor: Colors.lightBlueAccent.withOpacity(0.2),
                    ),
                  ),
                  onLoaded: (PlutoGridOnLoadedEvent event) {
                    _stateManager = event.stateManager;
                    _updatePagedRows();
                    if (_rows.isEmpty) {
                      _fetchProjects();
                    }
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
      ),
    );
  }
}
