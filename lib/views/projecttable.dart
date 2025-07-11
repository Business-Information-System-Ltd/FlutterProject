import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:intl/intl.dart';
import 'package:advance_budget_request_system/views/projectentryform.dart';
import 'package:advance_budget_request_system/views/data.dart';
import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:http/http.dart' as http;

class ProjectInformation extends StatefulWidget {
  @override
  _ProjectInformationState createState() => _ProjectInformationState();
}

class _ProjectInformationState extends State<ProjectInformation> {
  List<PlutoColumn> _columns = [];
  List<PlutoRow> _rows = [];
  List<Project> projects = [];
  PlutoGridStateManager? _stateManager;
  final NumberFormat _formatter = NumberFormat('#,###');
   bool isEditMode=false;

  @override
  void initState() {
    super.initState();
    _columns = _buildColumns();
    _rows = [];
    _fetchProjects();
    _refreshData();
    print(" Rows loaded: ${_rows.length}");
  }

  void _fetchProjects() async {
    try {
      final projectList = await ApiService().fetchProjects();
      setState(() {
        projects = projectList;
        _rows = _buildRows(projects);
      });
    } catch (e) {
      print('Error fetching projects: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load project data')),
      );
    }
  }

  void _refreshData() {}
  List<PlutoRow> _buildRows(List<Project> projects) {
    return projects.map((p) {
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
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final projectToDelete = projects.firstWhere(
          (p) => p.id == projectId,
        );
        final id = projectToDelete.id; //new
        // await ApiService().deleteProjects(projectToDelete.id);
        await ApiService().deleteProject(id);

        // setState(() {
        //   projects.removeWhere((p) => p.projectCode == projectCode);
        //   _rows = _buildRows(projects);
        // });
        setState(() {
          projects.removeWhere((p) => p.id == id);
          _rows = _buildRows(projects);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Project deleted successfully')),
        );
      } catch (e) {
        print('Delete failed: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete project')),
        );
      }
    }
  }

  final ApiService apiService = ApiService();
  Future<int> getProjectById() async {
    List<Project> existingProject = await apiService.fetchProjects();
    if (existingProject.isEmpty) {
      return 1;
    }
    int maxId =
        existingProject.map((b) => b.id).reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  List<PlutoColumn> _buildColumns() {
    return [
      PlutoColumn(
        title: 'Date',
        field: 'date',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 150,
      ),
      PlutoColumn(
        title: 'Project Code',
        field: 'projectcode',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 150,
      ),
      PlutoColumn(
        title: 'Description',
        field: 'description',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 150,
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
        width: 150,
        textAlign: PlutoColumnTextAlign.left,
        titleTextAlign: PlutoColumnTextAlign.left,
      ),
      PlutoColumn(
        title: 'Department',
        field: 'department',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 150,
      ),
      PlutoColumn(
        title: 'Requestable',
        field: 'requestable',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 150,
      ),
      PlutoColumn(
        title: 'Action',
        field: 'action',
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        width: 153,
        renderer: (rendererContext) {
          final requestable = rendererContext.row.cells['requestable']?.value;
          if (requestable == 'Pending') {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    final row = rendererContext.row;
                    final rowData = {
                      'id': row.cells['id']?.value,
                      'date': row.cells['date']?.value,
                      'projectcode': row.cells['projectcode']?.value,
                      'description': row.cells['description']?.value,
                      'totalamount': row.cells['totalamount']?.value.toString(),
                      'currency': row.cells['currency']?.value,
                      'department': row.cells['department']?.value,
                      'requestable': row.cells['requestable']?.value,
                    };
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddProjectForm(
                            initialData: rowData,
                             readOnly: false,
                             isEditMode: true,
                            projectId: row.cells['id']?.value,
                            //  projectId: row.cells['id']?.value,
                             ),
                      ),

                    )
                    .then((result){
                      if (result==true){
                        _fetchProjects();
                      }
                    });
                   
                
                  },
                ),

               


                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await _deleteConfirmation(rendererContext.row);
                    _stateManager?.removeRows([rendererContext.row]);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.more_horiz, color: Colors.black),
                  onPressed: () {
                    final row = rendererContext.row;
                    final nonEditableData = {
                      'id': row.cells['id']?.value,
                      'date': row.cells['date']?.value,
                      'projectcode': row.cells['projectcode']?.value,
                      'description': row.cells['description']?.value,
                      'totalamount': row.cells['totalamount']?.value.toString(),
                      'currency': row.cells['currency']?.value,
                      'department': row.cells['department']?.value,
                      'requestable': row.cells['requestable']?.value,
                    };
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddProjectForm(
                            initialData: nonEditableData,
                            isEditMode: false,
                            projectId: row.cells['id']?.value,
                             readOnly: true),
                      ),
                    );
                  },
                ),
              ],
            );
          } else {
            return IconButton(
              icon: Icon(Icons.more_horiz, color: Colors.black),
              onPressed: () {},
            );
          }
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Project Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: _rows.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.fromLTRB(80, 50, 80, 30),
              child: Container(
                height: 320,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.add),
                          label: Text('New'),

                          onPressed: () async {
                            final result =
                                await Navigator.of(context).push<Project>(
                              MaterialPageRoute(
                                builder: (context) => AddProjectForm(projectId: 0)
                              ),
                            );

                            // if (result != null) {
                            //   setState(() {
                            //     projects.add(result);

                            //     final newRow = PlutoRow(cells: {
                            //       'date': PlutoCell(
                            //           value: DateFormat('yyyy-MM-dd')
                            //               .format(result.date)),
                            //       'projectcode':
                            //           PlutoCell(value: result.projectCode),
                            //       'description': PlutoCell(
                            //           value: result.projectDescription),
                            //       'totalamount':
                            //           PlutoCell(value: result.totalAmount),
                            //       'currency': PlutoCell(value: result.currency),
                            //       'department':
                            //           PlutoCell(value: result.departmentName),
                            //       'requestable':
                            //           PlutoCell(value: result.requestable),
                            //       'action': PlutoCell(value: ''),
                            //     });

                            //     _rows.add(newRow);
                            //     _stateManager?.appendRows([newRow]);
                            //   });

                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //     SnackBar(content: Text('New project added')),
                            //   );
                            // }
                          },

                          // onPressed: () async {
                          //   final success =
                          //       await Navigator.of(context).push<bool>(
                          //     MaterialPageRoute(
                          //         builder: (context) => AddProjectForm()),
                          //   );

                          //   if (success == true) {
                          //     _fetchProjects();
                          //   }
                          // },
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
                                icon: Icon(Icons.refresh),
                                onPressed: () {},
                                color: Colors.black,
                              ),
                            ),
                            ElevatedButton.icon(
                              label: Text('Export'),
                              onPressed: () {},
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
                    SizedBox(height: 2),
                    Expanded(
                      child: PlutoGrid(
                        columns: _columns,
                        rows: _rows,
                        configuration: PlutoGridConfiguration(
                          style: PlutoGridStyleConfig(
                            oddRowColor: Colors.blue[50],
                            rowHeight: 45,
                            activatedColor:
                                Colors.lightBlueAccent.withOpacity(0.2),
                          ),
                        ),
                        onLoaded: (PlutoGridOnLoadedEvent event) {
                          _stateManager = event.stateManager;
                          if (_rows.isEmpty) {
                            _fetchProjects();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
