import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:advance_budget_request_system/views/data.dart';
import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BudgetForm extends StatefulWidget {
  @override
  _BudgetFormState createState() => _BudgetFormState();
}

class _BudgetFormState extends State<BudgetForm> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _descController = TextEditingController();
  String _formTitle = 'Add Budget';

  late List<PlutoColumn> columns;
  List<PlutoRow> rows = [];
  PlutoRow? _editingRow;
  List<Budgets> budget = [];
  PlutoGridStateManager? _stateManager;

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
        enableEditingMode: false
      ),
      PlutoColumn(
        title: 'Budget Description',
        field: 'desc',
        type: PlutoColumnType.text(),
        width: 220,
         enableEditingMode: false
      ),
      PlutoColumn(
        title: 'Action',
        field: 'action',
         enableEditingMode: false,
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
        final budgetToDelete = budget.firstWhere(
          (b) => b.budgetCode == budgetCode,
          orElse: () => Budgets(id: "0", budgetCode: '', budgetDescription: '', intialAmount: 0),
        );

        if (budgetToDelete.id != 0) {
          await ApiService().deleteBudgets(budgetToDelete.id);

          setState(() {
            rows.removeWhere((r) => r.cells['code']?.value == budgetCode);
            budget.removeWhere((b) => b.budgetCode == budgetCode);
            _stateManager?.removeRows([row]);
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
            'action': PlutoCell(value: ''),
          },
        );
      }).toList();

      setState(() {
        rows = newRows;
        budget = fetchedBudgets;
      });

      _stateManager?.removeAllRows();
      _stateManager?.appendRows(newRows);
    } catch (e) {
      print('Failed to fetch budgets: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load budgets')),
      );
    }
  }

  Future<String> generateStringBudgetID() async {
  try {
    List<Budgets> existingBudgets = await ApiService().fetchBudgets();

    if (existingBudgets.isEmpty) {
      return "1";
    }

    int maxId = existingBudgets.map((b) => int.tryParse(b.id.toString()) ?? 0).reduce((a, b) => a > b ? a : b);
    return (maxId + 1).toString(); // return as String
  } catch (e) {
    print("Error generating string budget ID: $e");
    throw Exception('Failed to generate budget ID');
  }
}


  // Future<int> generateBudgetID() async {
  //   List<Budgets> existingBudgets = await ApiService().fetchBudgets();
  //   if (existingBudgets.isEmpty) return 1;
  //   int maxId = existingBudgets.map((b) => b.id).reduce((a, b) => a > b ? a : b);
  //   return maxId + 1;
  // }

  void _saveBudget() async {
  if (_formKey.currentState!.validate()) {
    String code = _codeController.text.trim();
    String desc = _descController.text.trim();

    try {
      if (_editingRow != null) {
        final existingBudget = budget.firstWhere(
          (b) => b.budgetCode == _editingRow!.cells['code']!.value,
        );

        final updatedBudget = Budgets(
          id: existingBudget.id,
          
          budgetCode: code,
          budgetDescription: desc,
          intialAmount: existingBudget.intialAmount,
        );
        print(updatedBudget.id);

        await ApiService().updateBudgets(updatedBudget);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Budget updated successfully')),
        );
      } else {
        // final newId = await generateBudgetID();
        String generatedId = await generateStringBudgetID();
        final newBudget = Budgets(
          id: generatedId,
          budgetCode: code,
          budgetDescription: desc,
          intialAmount: 0,
        );

        await ApiService().postBudgets(newBudget);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Budget saved successfully')),
        );
      }

      _fetchBudgetTableRows();
      _clearForm();
    } catch (e) {
      print('Error saving/editing budget: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save/edit budget')),
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
            Expanded(
              flex: 1,
              child: Container(
                height: 300,
                padding: const EdgeInsets.all(20),
                color: Colors.grey.shade300,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(_formTitle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      SizedBox(
                        width: 250,
                        child: TextFormField(
                          controller: _codeController,
                          decoration: InputDecoration(
                            hintText: 'Enter Budget Code',
                            filled: true,
                            fillColor: Colors.green.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Please enter budget code' : null,
                        ),
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        width: 250,
                        child: TextFormField(
                          controller: _descController,
                          decoration: InputDecoration(
                            hintText: 'Enter Budget Description',
                            filled: true,
                            fillColor: Colors.green.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Please enter description' : null,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _saveBudget,
                            child: Text(_editingRow != null ? 'Update' : 'Save'),
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
                              backgroundColor: Colors.white,
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
                        onPressed: _fetchBudgetTableRows,
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.download),
                        label: Text('Export'),
                        onPressed: () {
                          // TODO: Export logic
                        },
                      )
                    ],
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 400,
                      child: PlutoGrid(
                        columns: columns,
                        rows: rows,
                        onLoaded: (PlutoGridOnLoadedEvent event) {
                          _stateManager = event.stateManager;
                        },
                        configuration: PlutoGridConfiguration(
                          style: PlutoGridStyleConfig(
                            oddRowColor: Colors.blue[50],
                            rowHeight: 50,
                            activatedColor: Colors.lightBlueAccent.withOpacity(0.2),
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
