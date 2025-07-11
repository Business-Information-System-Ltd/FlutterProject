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
  List<Budgets> budget = [];
  PlutoRow? _editingRow;
  PlutoGridStateManager? _stateManager;

  late PlutoGridStateManager stateManager;

  @override
  void initState() {
    super.initState();
    _fetchBudgetAmount();
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
                    final row = rendererContext.row;
                    setState(() {
                      _codeController.text = row.cells['code']!.value;
                      _descController.text = row.cells['desc']!.value;
                      _initialAmount.text = row.cells['initial']!.value;
                      _editingRow = row;
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    ];
  }

  void _fetchBudgetAmount() async {
    try {
      List<Budgets> fetchedBudgets = await ApiService().fetchBudgets();

      //List<PlutoRow> newRows = fetchedBudgets.map((budget) {
       rows = fetchedBudgets.map((budget) {
        return PlutoRow(
          cells: {
            'code': PlutoCell(value: budget.budgetCode),
            'desc': PlutoCell(value: budget.budgetDescription),
            'initial': PlutoCell(value: budget.initialAmount),
            'action': PlutoCell(value: ''),
          },
        );
      }).toList();

      setState(() {
        // rows = newRows;
        // budget = fetchedBudgets;
      });

      if (_stateManager != null) {
        _stateManager!.removeAllRows();
       // _stateManager!.appendRows(newRows);
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

   Future<int> generateBudgetID() async {
    List<Budgets> existingBudgets = await ApiService().fetchBudgets();
    if (existingBudgets.isEmpty) return 1;
    int maxId =
        existingBudgets.map((b) => b.id).reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }


  void _saveBudget() async {
    if (_formKey.currentState!.validate()) {
      final newId = await generateBudgetID();
      String code = _codeController.text.trim();
      String desc = _descController.text.trim();
     String initial =_initialAmount.text.trim();
     double initialValue = double.tryParse(initial) ?? 0.0;


      try {
        final newBudget = Budgets(
          id: newId,
          budgetCode: code,
          budgetDescription: desc,
          initialAmount: initialValue,
        );

        if (_editingRow != null) {
          // Update existing budget
          final existingBudget = budget.firstWhere(
            (b) => b.budgetCode == _editingRow!.cells['code']!.value,
          );

          await ApiService().updateBudgets(existingBudget.id, newBudget);
          _fetchBudgetAmount(); // Refresh data
        } else {
          // Add new budget
          await ApiService().postBudgets(newBudget);
          _fetchBudgetAmount(); // Refresh data
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



  // void _saveBudget() {
  //   if (_formKey.currentState!.validate()) {
  //     if (_editingRow != null) {
  //       setState(() {
  //         _editingRow!.cells['code']!.value = _codeController.text;
  //         _editingRow!.cells['desc']!.value = _descController.text;
  //         _editingRow!.cells['initial']!.value = _initialAmount.text;
  //         _editingRow = null;
  //       });
  //     } else {
  //       final newRow = PlutoRow(cells: {
  //         'code': PlutoCell(value: _codeController.text),
  //         'desc': PlutoCell(value: _descController.text),
  //         'initial': PlutoCell(value: _initialAmount.text),
  //         'action': PlutoCell(value: ''),
  //       });

  //       setState(() {
  //         rows.add(newRow);
  //       });
  //     }
  //   }
  // }

  void _clearForm() {
    _codeController.clear();
    _descController.clear();
    _initialAmount.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Add Budget Amount',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: 250,
                        child: TextFormField(
                          controller: _codeController,
                          decoration: InputDecoration(
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
                            //hintText: 'Enter Budget Description',
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
                      SizedBox(height: 12),
                      SizedBox(
                        width: 250,
                        child: TextFormField(
                          controller: _initialAmount,
                          decoration: InputDecoration(
                            //labelText: 'Initial Amount',
                            //hintText: 'Enter initial amount',
                            filled: true,
                            fillColor: Colors.green.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter initial';
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
                              foregroundColor: Colors.black, // ✅ text color
                              backgroundColor:
                                  Colors.white, // button background
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
                        onPressed: () {},
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
