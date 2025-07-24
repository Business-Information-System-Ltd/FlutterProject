import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';

class TripEntryForm extends StatefulWidget {
final Map<String, dynamic>? initialData;
const TripEntryForm({super.key,this.initialData});

  @override
  State<TripEntryForm> createState() => _TripEntryFormState();
}
class _TripEntryFormState extends State<TripEntryForm> {
  List<PlutoColumn> _columns=[];
  List<PlutoRow> _rows=[];
  PlutoGridStateManager? _stateManager;
  PlutoGridStateManager? popupGridManager;
  final List<Map<String, String>> _budgetList = [];
  final TextEditingController _tripCodeController = TextEditingController();
  final TextEditingController _tripAdminController = TextEditingController();
  final TextEditingController _tripDateController = TextEditingController();
  final TextEditingController _tripDescriptionController = TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _attachFilesController = TextEditingController();
  String? _selectedDepartment = 'Admin';
  String? _selectedCurrency = 'MMK';
  
    @override
  void initState() {
  super.initState();
  if (widget.initialData != null) {
    final data = widget.initialData!;
     print('Editing data: $data');
    _tripCodeController.text = data['tripcode'] ?? '';
    _tripAdminController.text = data['department'] ?? '';
    _tripDescriptionController.text = data['description'] ?? '';
    _totalAmountController.text = data['totalamount'] ?? '';
    _selectedCurrency = data['currency'] ?? 'MMK';
    _tripDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }
   _initializePlutoGrid();
}

   
  void _initializePlutoGrid() {
  _columns = [
    PlutoColumn(
      title: 'Budget Code',
      field: 'code',
      type: PlutoColumnType.text(),
      readOnly: true,
      width: 183,
    ),
    PlutoColumn(
      title: 'Budget Description',
      field: 'desc',
      type: PlutoColumnType.text(),
      readOnly: true,
      width: 183,
    ),
    PlutoColumn(
      title: 'Action',
      field: 'action',
      type: PlutoColumnType.text(),
      width: 183,
      renderer: (rendererContext) {
        return IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            setState(() {
              _budgetList.removeAt(rendererContext.rowIdx);
             _initializePlutoGrid(); // rebuild rows
              _stateManager?.removeRows([rendererContext.row]);
            });
          },
        );
      },
    ),
  ];

  _rows = _budgetList.map((item) {
    return PlutoRow(cells: {
      'code': PlutoCell(value: item['code']),
      'desc': PlutoCell(value: item['desc']),
      'action': PlutoCell(value: 'delete'),
    });
  }).toList();
}

/*
void _showPlutoGridDialog() {
  final List<PlutoRow> rows = [
    PlutoRow(cells: {
       'select': PlutoCell(value: ''),
      'budgetcode': PlutoCell(value: 'B-1'),
      'budgetdescription': PlutoCell(value: 'For Expense'),
    }),
    PlutoRow(cells: {
      'select': PlutoCell(value: ''),
      'budgetcode': PlutoCell(value: 'B-2'),
      'budgetdescription': PlutoCell(value: 'For Marketing'),
    }),
    PlutoRow(cells: {
      'select': PlutoCell(value: ''),
      'budgetcode': PlutoCell(value: 'B-3'),
      'budgetdescription': PlutoCell(value: 'For Advertising'),
    }),
  ];
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Choose Budget Codes', textAlign: TextAlign.center),
        content: SizedBox(
          width: 600,
          height: 300,
          child: PlutoGrid(
            columns: [
              PlutoColumn(
                title: '',
                field: 'select',
                type: PlutoColumnType.text(),
                //enableColumnDrag: false,
                enableRowChecked: true,
              ),
              PlutoColumn(
                title: 'Budget Code',
                field: 'budgetcode',
                type: PlutoColumnType.text(),
              ),
              PlutoColumn(
                title: 'Budget Description',
                field: 'budgetdescription',
                type: PlutoColumnType.text(),
              ),
            ],
            rows: rows,
            mode: PlutoGridMode.multiSelect,
            onLoaded: (PlutoGridOnLoadedEvent event) {
            popupGridManager = event.stateManager;
            popupGridManager!.setShowColumnFilter(false);
            popupGridManager!.setSelectingMode(PlutoGridSelectingMode.row);
            },
            configuration: PlutoGridConfiguration(
              style: PlutoGridStyleConfig(
                rowHeight: 36,
                columnHeight: 40,
              ),
            
            
            ),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (popupGridManager != null) {
                    for (var row in popupGridManager!.checkedRows) {
                      final code = row.cells['budgetcode']?.value;
                      final desc = row.cells['budgetdescription']?.value;
                      bool alreadyExists =_budgetList.any((item) => item['code'] == code);
                      if (!alreadyExists) {
                        _budgetList.add({'code': code, 'desc': desc});
                      }
                    }

                    _initializePlutoGrid(); 
                    _stateManager?.removeAllRows();
                    _stateManager?.appendRows(_rows);
                  }

                  Navigator.pop(context); // Close dialog
                },
                child: const Text('Apply'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          )
        ],
      );
    },
  );
}
*/




void _clearForm() {
    _tripCodeController.clear();
    _tripAdminController.clear();
    _tripDateController.clear();
    _tripDescriptionController.clear();
    _totalAmountController.clear();
    //_attachFilesController.clear();
    
  }

void _submitForm(){
   final projectData = {
   'date': _tripDateController.text,
    'tripcode': _tripCodeController.text,
    'description': _tripDescriptionController.text,
    'totalamount': int.tryParse(_totalAmountController.text) ?? 0,
    'currency': _selectedCurrency ?? 'MMK',
    'department': _tripAdminController.text,
    'action': '',
    };
    Navigator.pop(context, projectData);
    }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      body: Container(
      // decoration: BoxDecoration( ),
      padding:  EdgeInsets.fromLTRB(200, 10, 200, 10), 
      child: Center(
         child: Card(
                  child:Padding(
                  padding:  EdgeInsets.fromLTRB(10,5,10,5),
                      child: Column(
                      mainAxisSize: MainAxisSize.min,
                      // CrossAxisAlignment.start, 
                   children: [
                               Text( 'Add Trip Form', style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,),

                  SizedBox(height: 10), 
              
                  
               
                  Row(
                    children: [
                      Expanded( 
                        child: _buildTextField(
                          controller: _tripCodeController,
                          labelText: 'Trip Code',
                          //readOnly: true, 
                           padding: EdgeInsets.symmetric(horizontal: 2, vertical: 12),
                          
                        ),
                        
                      ),
                      
                       SizedBox(width: 10.0), 

                        Expanded(
                        child: _buildTextField(
                          controller: _tripAdminController,
                          labelText: 'Department',
                          //readOnly: true, 
                          padding: EdgeInsets.symmetric(horizontal: 1, vertical: 12),
                          
                        ),
                      ),
                      
                     SizedBox(width: 10.0),

                      Expanded(
                        child: _buildTextField(
                          controller: _tripDateController,
                          labelText: 'Requested Date',
                          //readOnly: true, 
                          padding: EdgeInsets.symmetric(horizontal: 1, vertical: 12),
                          
                        ),
                      ),
                    ],
                  ),
                


                  SizedBox(height: 1), 

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _tripDescriptionController,
                          labelText: 'Enter Project Description',
                          padding: EdgeInsets.symmetric(horizontal: 1, vertical: 12),
                          
                        ),
                      ),

                       SizedBox(width: 10.0),

                      Expanded(
                        child: _buildTextField(
                          controller: _totalAmountController,
                          labelText: 'Enter total Amount',
                          keyboardType: TextInputType.number,
                          padding: EdgeInsets.symmetric(horizontal: 1, vertical: 12),
                          
                        ),
                      ),

                      SizedBox(width: 10.0),

                      Expanded(
                        child: _buildDropdownField(
                          value: _selectedCurrency,
                          items: ['MMK', 'USD'],
                          labelText: 'Currency',
                           padding: EdgeInsets.symmetric(horizontal: 1, vertical: 12),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCurrency = newValue;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                   SizedBox(height: 1),

                 Align(
                         alignment: Alignment.centerLeft,
                         child: SizedBox(
                         width: 370,
                         height: 50,
                         child: Padding(
                         padding: EdgeInsets.fromLTRB(5, 2, 65, 2),
                         child: ElevatedButton(
                         onPressed: () { },
                         style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.grey[200],
                         shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(8.0),
                         side: BorderSide(color: Colors.grey, width: 1),
                         ),
                         padding: EdgeInsets.symmetric(horizontal: 24), ),
                         child: Row(
                         mainAxisAlignment: MainAxisAlignment.start, // Text left, Icon right
                         children: [
                                Icon(Icons.attach_file, color: Colors.black),
                                SizedBox(width: 8),
                                Text( 'Attach Files',
                                style: TextStyle(color: Colors.black), ), ] ), ), ),),
                       ),

                 SizedBox(height: 1),

                  Center(
                         child:SizedBox(
                         width: 200,
                         height: 35,
                         child: ElevatedButton(
                        // onPressed: _showPlutoGridDialog,
                        onPressed: (){},
                         style: ElevatedButton.styleFrom(
                         backgroundColor:  Color(0xFFB2C8A8),
                         shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(8.0), ),
                         padding: const EdgeInsets.symmetric(vertical: 16),),
                         child:  Text(
                                   'Add Budget Codes',
                                    style: TextStyle(fontSize: 16, color: Colors.black), ),
                          )
                    ),

                  ),

                  SizedBox(height: 8),

                 Container(
                         height: 170,
                         width: 550,
                         decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          border: Border.all(color: Colors.grey.shade300)
                          ),
                         child: PlutoGrid(
                         columns: _columns,
                         rows: _rows,
                         onLoaded: (PlutoGridOnLoadedEvent event) {
                        _stateManager = event.stateManager;
                        _stateManager!.setShowColumnFilter(false); },
                        configuration: PlutoGridConfiguration( 
                         style: PlutoGridStyleConfig(
                          oddRowColor: Colors.blue[50],
                          rowHeight: 50,
                          activatedColor: Colors.lightBlueAccent.withOpacity(0.2),
                        ),
                        ),
                         mode: PlutoGridMode.readOnly,
                                  ),
                                  ),

              SizedBox(height: 100),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                   onPressed: _submitForm,
                    child: Text('Submit',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:  Color(0xFFB2C8A8),
                      minimumSize: Size(120, 48),
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                            ),
                     
                    ),
                  ),

                  SizedBox(width: 20),

                  ElevatedButton(
                    onPressed:_clearForm,
                    child: Text('Clear',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,),),
                    style: ElevatedButton.styleFrom(
                    backgroundColor:  Color(0xFFB2C8A8),
                    minimumSize: Size(120, 48),
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                     ),

                     
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
    );
  }


Widget _buildTextField({
  required TextEditingController controller,
  required String labelText,
  bool readOnly = false,
  TextInputType keyboardType = TextInputType.text,
  EdgeInsets padding = const EdgeInsets.all(8), 
  //VoidCallback? onAttachPressed,
}) {
  return Padding(
    padding: padding,
    child: TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        fillColor: Colors.grey[200],
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // internal padding
      ),
    ),
  );
}
 
  Widget _buildDropdownField({
  required String? value,
  required List<String> items,
  required String labelText,
  required ValueChanged<String?> onChanged,
  EdgeInsets padding = const EdgeInsets.all(8), // 👈 External padding
}) {
  return Padding(
    padding: padding,
    child: DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        fillColor: Colors.grey[200],
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // 👈 Internal padding
      ),
      items: items.map<DropdownMenuItem<String>>((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    ),
  );
}

}










