import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';



class BudgetForm extends StatefulWidget {
  @override
  _BudgetFormState createState() => _BudgetFormState();
}

class _BudgetFormState extends State<BudgetForm> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _descController = TextEditingController();
  String _formTitle='Add Budget';

  late List<PlutoColumn> columns;
  List<PlutoRow> rows = [];
  PlutoRow? _editingRow;


  late PlutoGridStateManager stateManager;

  @override
  void initState() {
    super.initState();
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
                  final row=rendererContext.row;
                  setState(() {
                    _codeController.text = row.cells['code']!.value;
                    _descController.text = row.cells['desc']!.value;
                    _editingRow = row;
                    _formTitle='Edit Budget';
                    
                  });

                  // TODO: implement edit
                },
              ),
              IconButton(
        icon: Icon(Icons.delete, size: 18, color: Colors.red),
        onPressed: () {
          setState(() {
            rows.remove(rendererContext.row);
          });
          // TODO: implement delete
        },
      ),
              
            ],
          );
        },
      ),
    ];
  }

 

void _saveBudget() {
  if (_formKey.currentState!.validate()) {
    if (_editingRow != null) {
      // Update existing row
      setState(() {
        _editingRow!.cells['code']!.value = _codeController.text;
        _editingRow!.cells['desc']!.value = _descController.text;
        _editingRow = null;
      });
    } else {
      // Add new row
      final newRow = PlutoRow(cells: {
        'code': PlutoCell(value: _codeController.text),
        'desc': PlutoCell(value: _descController.text),
        'action': PlutoCell(value: ''),
      });

      setState(() {
        rows.add(newRow);
      });
    }
     
    _codeController.clear();
    _descController.clear();
    _formTitle='Add Budget';
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
              child:Container(
              height: 300,
              padding: const EdgeInsets.fromLTRB(20,20,20,20),
              color: Colors.grey.shade300,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(_formTitle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                     SizedBox(height: 16),

                   SizedBox(width: 250,
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

                     SizedBox(width: 250,
                   child:  TextFormField(
                      controller: _descController,
                      decoration: InputDecoration(
                       // labelText: 'Budget Description',
                        hintText: 'Enter Budget Description',
                        filled: true,
                        fillColor: Colors.green.shade100,
                         border: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(12), // ✅ rounded corners
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
                            backgroundColor: Colors.white, // changed from primary
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
                          setState(() {});
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
                  

                    child: PlutoGrid(
                    
                      columns: columns,
                      rows: rows,
                      onLoaded: (event) {
                        stateManager = event.stateManager;
                      },
                      configuration: PlutoGridConfiguration(
                        style: PlutoGridStyleConfig(
                          
                          gridBorderColor: Colors.black,
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
