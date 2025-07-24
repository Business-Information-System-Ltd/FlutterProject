import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class BudgetUI extends StatefulWidget {
  const BudgetUI({super.key});

  @override
  State<BudgetUI> createState() => _BudgetUIState();
}

class _BudgetUIState extends State<BudgetUI> {
  final _codeController = TextEditingController();
  final _descController = TextEditingController();
  final List<PlutoColumn> _columns = [];
  final List<PlutoRow> _rows = [];
  PlutoGridStateManager? _stateManager;
  bool _isEditing = false;
  int? _editingRowIndex;

  @override
  void initState() {
    super.initState();
    _initializeColumns();
  }

  void _initializeColumns() {
    _columns.addAll([
      PlutoColumn(
        title: 'Budget Code',
        field: 'code',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Budget Description',
        field: 'desc',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Action',
        field: 'action',
        type: PlutoColumnType.text(),
        renderer: (context) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _startEditing(context.rowIdx),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteRow(context.rowIdx),
              ),
            ],
          );
        },
      ),
    ]);
  }

  void _startEditing(int index) {
    final row = _rows[index];
    _codeController.text = row.cells['code']!.value;
    _descController.text = row.cells['desc']!.value;
    setState(() {
      _isEditing = true;
      _editingRowIndex = index;
    });
  }

  void _deleteRow(int index) {
    setState(() {
      _rows.removeAt(index);
      _stateManager?.removeRows([_stateManager!.rows[index]]);
    });
  }

  void _clearForm() {
    _codeController.clear();
    _descController.clear();
    setState(() {
      _isEditing = false;
      _editingRowIndex = null;
    });
  }

  void _saveOrUpdate() {
    final code = _codeController.text;
    final desc = _descController.text;
    if (code.isEmpty || desc.isEmpty) return;

    if (_isEditing && _editingRowIndex != null) {
      final row = _rows[_editingRowIndex!];
      row.cells['code']!.value = code;
      row.cells['desc']!.value = desc;
      _stateManager!.notifyListeners();
    } else {
      final newRow = PlutoRow(cells: {
        'code': PlutoCell(value: code),
        'desc': PlutoCell(value: desc),
        'action': PlutoCell(value: ''),
      });
      setState(() {
        _rows.add(newRow);
      });
    }

    _clearForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            const Text('Budget Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 400,
                    child: Card(
                      elevation: 4,
                      child: Container(
                        width: 400,
                        height: 300,
                        color: Colors.lightBlueAccent,
                        
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_isEditing ? 'Edit Budget' : 'Add Budget', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _codeController,
                                decoration: const InputDecoration(labelText: 'Enter Budget Code'),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _descController,
                                decoration: const InputDecoration(labelText: 'Enter Budget Description'),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: _saveOrUpdate,
                                    child: const Text('Save'),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton(
                                    onPressed: _clearForm,
                                    child: const Text('Clear'),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () => setState(() {}),
                              icon: const Icon(Icons.refresh),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              child: const Text('Export'),
                            ),
                          ],
                        ),
                        Expanded(
                          child: PlutoGrid(
                            columns: _columns,
                            rows: _rows,
                            onLoaded: (event) => _stateManager = event.stateManager,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text('Page 1 of 1'),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text('Footer'),
          ],
        ),
      ),
    );
  }
}
