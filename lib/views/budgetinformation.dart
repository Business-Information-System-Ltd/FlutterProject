import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:advance_budget_request_system/views/data.dart';
import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:http/http.dart' as http;

class BudgetForm extends StatefulWidget {
 
  

  @override
  _BudgetFormState createState() => _BudgetFormState();
}

class _BudgetFormState extends State<BudgetForm> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _descController = TextEditingController();
  final _idController = TextEditingController();
  String _formTitle = 'Add Budget';

  late List<PlutoColumn> columns;
  List<PlutoRow> rows = [];
  PlutoRow? _editingRow;
  List<Budgets> budget = [];
  PlutoGridStateManager? _stateManager;

  late PlutoGridStateManager stateManager;
  

  @override
  void initState() {
    super.initState();
    _fetchBudgetTableRows();
    columns = [
      PlutoColumn(
        title: 'Budget Code',
        field: 'code',
        type: PlutoColumnType.text(),
        width: 220,
      ),
      PlutoColumn(
        title: 'Budget Description',
        field: 'desc',
        type: PlutoColumnType.text(),
        width: 220,
      ),
      PlutoColumn(
        title: 'Action',
        field: 'action',
        width: 250,
        type: PlutoColumnType.text(),
        renderer: (rendererContext) {
          return Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit, size: 18),
                onPressed: () {
                  final row = rendererContext.row;
                  setState(() {
                    _codeController.text = row.cells['code']!.value;
                    _descController.text = row.cells['desc']!.value;
                    _editingRow = row;
                    _formTitle = 'Edit Budget';
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, size: 18, color: Colors.red),
                onPressed: () => _deleteConfirmation(rendererContext.row),
              ),
            ],
          );
        },
      ),
    ];
  }

  Future<void> _deleteConfirmation(PlutoRow row) async {
    final budgetCode = row.cells['code']!.value.toString();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete budget $budgetCode?'),
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
        // Find the corresponding budget object
        final budgetToDelete = budget.firstWhere(
          (b) => b.budgetCode == budgetCode,
          orElse: () => Budgets(
              id: 0,
               budgetCode: '',
                budgetDescription: '',
                 intialAmount: 0),
        );

        if (budgetToDelete.id != 0) {
          await ApiService().deleteBudget(budgetToDelete.id);

          setState(() {
            rows.removeWhere((r) => r.cells['code']?.value == budgetCode);
            budget.removeWhere((b) => b.budgetCode == budgetCode);
            if (_stateManager != null) {
              _stateManager!.removeRows([row]);
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Budget deleted successfully')),
          );
        }
      } catch (e) {
        print('Delete failed: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete budget')),
        );
      }
    }
  }

  void _fetchBudgetTableRows() async {
    try {
      List<Budgets> fetchedBudgets = await ApiService().fetchBudgets();

      List<PlutoRow> newRows = fetchedBudgets.map((budget) {
        return PlutoRow(
          cells: {
            'id': PlutoCell(value: budget.id),
            'code': PlutoCell(value: budget.budgetCode),
            'desc': PlutoCell(value: budget.budgetDescription),
            'action': PlutoCell(value: ''), // or set action if needed
          },
        );
      }).toList();

      setState(() {
        rows = newRows;
        budget = fetchedBudgets;
      });

      if (_stateManager != null) {
        _stateManager!.removeAllRows();
        _stateManager!.appendRows(newRows);
      }

      // print("Rows loaded: ${newRows.length}");
    } catch (e) {
      print('Failed to fetch budgets: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load budgets')),
      );
    }
  }

  Future<int> generateBudgetID() async {
    List<Budgets> existingBudgets = await ApiService().fetchBudgets();
    if (existingBudgets.isEmpty) return 1;
    List<int> ids = existingBudgets
      .map((b) => int.tryParse(b.id.toString()) ?? 0)
      .toList();

  int maxId = ids.reduce((a, b) => a > b ? a : b);
  return maxId + 1;

    
  }
  

  void _saveBudget() async {
    if (_formKey.currentState!.validate()) {
      String code = _codeController.text.trim();
      String desc = _descController.text.trim();

      try {
        final newId = await generateBudgetID();
        final newBudget = Budgets(
          id: newId,
          budgetCode: code,
          budgetDescription: desc,
          intialAmount: 0,
        );
      

        if (_editingRow != null) {
          final existingBudget = budget.firstWhere(
            (b) => b.budgetCode == _editingRow!.cells['code']!.value,
          );

          await ApiService().updateBudgets(existingBudget.id, newBudget);

          _fetchBudgetTableRows(); 

        } 
        else {
          await ApiService().postBudgets(newBudget);
          _fetchBudgetTableRows(); 
        }

        _clearForm();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Budget saved successfully')),
        );
      } catch (e) {
        print('Error saving budget: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save budget')),
        );
      }
    }
  }

  
  void _clearForm() {
  _codeController.clear();
  _descController.clear();
  
    _formTitle = 'Add Budget';
    _editingRow = null;
  
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(50, 20, 250, 250),
        child: Row(
          children: [
            // Form Section
            Expanded(
              flex: 1,
              child: Container(
                height: 300,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                color: Colors.grey.shade300,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _formTitle,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: 250,
                        child: TextFormField(
                          controller: _codeController,
                          decoration: InputDecoration(
                            //labelText: 'Budget Code',
                            hintText: 'Enter Budget Code',
                            filled: true,
                            fillColor: Colors.green.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter budget code';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        width: 250,
                        child: TextFormField(
                          controller: _descController,
                          decoration: InputDecoration(
                            // labelText: 'Budget Description',
                            hintText: 'Enter Budget Description',
                            filled: true,
                            fillColor: Colors.green.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  12), // ✅ rounded corners
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter description';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _saveBudget,
                            child: Text('Save'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _clearForm,
                            child: Text('Clear'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor:
                                  Colors.white, // changed from primary
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(width: 24),

            // PlutoGrid Section
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: () {
                          _fetchBudgetTableRows();
                          // setState(() {});
                        },
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.download),
                        label: Text('Export'),
                        onPressed: () {
                          // TODO: export logic
                        },
                      )
                    ],
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 400,
                      // child:rows.isEmpty
                      // ? Center(child: Text(''))

                      child: PlutoGrid(
                        columns: columns,
                        rows: rows,
                        
                        onLoaded: (PlutoGridOnLoadedEvent event) {
                          _stateManager = event.stateManager;
                          // Add this to ensure proper initialization
                          // event.stateManager.setShowLoading(false);
                        },
                        configuration: PlutoGridConfiguration(
                          style: PlutoGridStyleConfig(
                            oddRowColor: Colors.blue[50],
                            rowHeight: 50,
                            activatedColor:
                                Colors.lightBlueAccent.withOpacity(0.2),
                            gridBorderColor: Colors.black,
                            gridBackgroundColor: Colors.grey.shade300,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
