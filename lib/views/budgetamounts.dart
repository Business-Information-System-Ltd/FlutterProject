import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:intl/intl.dart';
import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:advance_budget_request_system/views/data.dart';

class BudgetAmount extends StatefulWidget {
  @override
  _BudgetAmountState createState() => _BudgetAmountState();
}

class _BudgetAmountState extends State<BudgetAmount> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _descController = TextEditingController();
  final _initialAmount = TextEditingController();
  final NumberFormat _formatter = NumberFormat('#,###');

  late List<PlutoColumn> columns;
  List<PlutoRow> rows = [];
  List<Budgets> budgets = []; // Store the actual budget data
  PlutoRow? _editingRow;
  PlutoGridStateManager? _stateManager;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _fetchBudgetAmount();
    _initializeColumns();
  }

  void _initializeColumns() {
    columns = [
      PlutoColumn(
        title: 'Budget Code',
        field: 'code',
        type: PlutoColumnType.text(),
        width: 200,
      ),
      PlutoColumn(
        title: 'Budget Description',
        field: 'desc',
        type: PlutoColumnType.text(),
        width: 200,
      ),
      PlutoColumn(
        title: 'Initial Amount',
        field: 'initial',
        type: PlutoColumnType.number(),
        width: 200,
        textAlign: PlutoColumnTextAlign.right,
        titleTextAlign: PlutoColumnTextAlign.right,
        renderer: (context) {
          final value = int.tryParse(context.cell.value.toString()) ?? 0;
          return Text(
            _formatter.format(value),
            textAlign: TextAlign.right,
          );
        },
      ),
      PlutoColumn(
        title: 'Action',
        field: 'action',
        width: 185,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        type: PlutoColumnType.text(),
        renderer: (rendererContext) {
          return Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, size: 18, color: Colors.blue),
                  onPressed: () {
                    _editBudget(rendererContext.row);
                  },
                ),
              ],
            ),
          );
        },
      ),
    ];
  }

  void _editBudget(PlutoRow row) {
    setState(() {
      _codeController.text = row.cells['code']!.value.toString();
      _descController.text = row.cells['desc']!.value.toString();
      _initialAmount.text = row.cells['initial']!.value.toString();
      _editingRow = row;
      _isEditing = true;
    });
  }

  void _fetchBudgetAmount() async {
    try {
      List<Budgets> fetchedBudgets = await ApiService().fetchBudgets();
      
      setState(() {
        budgets = fetchedBudgets;
        rows = fetchedBudgets.map((budget) {
          return PlutoRow(
            cells: {
              'code': PlutoCell(value: budget.budgetCode),
              'desc': PlutoCell(value: budget.budgetDescription),
              'initial': PlutoCell(value: budget.intialAmount),
              'action': PlutoCell(value: ''),
            },
          );
        }).toList();
      });

      if (_stateManager != null) {
        _stateManager!.removeAllRows();
        _stateManager!.appendRows(rows);
      }

      print("Rows loaded: ${rows.length}");
    } catch (e) {
      print('Failed to fetch budgets: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load budgets')),
      );
    }
  }

  void _saveBudget() async {
    if (_formKey.currentState!.validate()) {
      try {
        String code = _codeController.text.trim();
        String desc = _descController.text.trim();
        double initialValue = double.tryParse(_initialAmount.text.trim()) ?? 0.0;

        if (_isEditing && _editingRow != null) {
          final existingBudget = budgets.firstWhere(
            (b) => b.budgetCode == _editingRow!.cells['code']!.value,
          );
          
          final updatedBudget = Budgets(
            id: existingBudget.id,
            budgetCode: code,
            budgetDescription: desc,
            intialAmount: initialValue,
          );

          await ApiService().updateBudgets(updatedBudget);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Initial amount added successfully')),
          );
        } else {
             ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('There is no data in budget!!')),
          );
        }

        _fetchBudgetAmount(); // Refresh data
        _clearForm();
      } catch (e) {
        print('Error saving budget: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save budget: ${e.toString()}')),
        );
      }
    }
  }

  void _clearForm() {
    _codeController.clear();
    _descController.clear();
    _initialAmount.clear();
    setState(() {
      _editingRow = null;
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Amounts'),
        // backgroundColor: Colors.green,
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.home),
        //     onPressed: () {
        //       Navigator.of(context).pop();
        //     },
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(50, 20, 110, 250),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                height: 400,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                color: Colors.grey.shade300,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Add Budget Amount',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 250,
                          child: TextFormField(
                            controller: _codeController,
                            decoration: InputDecoration(
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
                              filled: true,
                              fillColor: Colors.green.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
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
                        SizedBox(height: 12),
                        SizedBox(
                          width: 250,
                          child: TextFormField(
                            controller: _initialAmount,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.green.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter initial amount';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
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
                              child: Text(_isEditing ? 'Update' : 'Save'),
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
                        onPressed: _fetchBudgetAmount,
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.download),
                        label: Text('Export'),
                        onPressed: () {},
                      )
                    ],
                  ),
                  Expanded(
                    child: PlutoGrid(
                      columns: columns,
                      rows: rows,
                      onLoaded: (PlutoGridOnLoadedEvent event) {
                        _stateManager = event.stateManager;
                      },
                      configuration: PlutoGridConfiguration(
                        style: PlutoGridStyleConfig(
                          gridBorderColor: Colors.black,
                          oddRowColor: Colors.blue[50],
                          rowHeight: 40,
                          gridBackgroundColor: Colors.grey.shade300,
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