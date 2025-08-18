import 'package:advance_budget_request_system/views/pagination.dart';
import 'package:advance_budget_request_system/views/searchfunction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';

class ApprovalSetupList extends StatefulWidget {
  final bool readOnly;
  const ApprovalSetupList({
    Key? key,
    this.readOnly = false,
    }) : super(key: key);

  @override
  State<ApprovalSetupList> createState() => _ApprovalSetupListState();

}

class _ApprovalSetupListState extends State<ApprovalSetupList> {

  List <PlutoColumn> _columns = [];
  List<PlutoRow> _rows = [];
  List <PlutoRow> _pagedRows = [];
  String? _currentFilterType;
  PlutoGridStateManager? _stateManager;
  final NumberFormat _formatter =NumberFormat('#,###');
  bool isEditMode = false;
  bool isViewMode = false;
  String _searchQuery = '';
  int _currentPage = 1;
  int _rowsPerPage=10; 
  bool _managementApprover=true;
  String? _selectedDepartmentName;
  String? _selectedType;
  String? _selectedCurrency;
  List<Map<String, String>> approvalData = [
    {
      "Flow Name": "Admin Flow",
      "Department":"Admin",
      "Request Type":"Project",
      "Description":"Admin Flow 1",
      "Currency":"MMK",
      "No Of Steps":"2",
      "Management Approver":"Yes",
    },
     {
      "Flow Name": "Finance Flow",
      "Department":"Finance",
      "Request Type":"Operation",
      "Description":"Finance Flow 1",
      "Currency":"MMK",
      "No Of Steps":"1",
      "Management Approver":"Yes",
    },
     {
      "Flow Name": "IT Flow",
      "Department":"IT",
      "Request Type":"Trip",
      "Description":"IT Flow 1",
      "Currency":"USD",
      "No Of Steps":"2",
      "Management Approver":"No",
    },
  ];

 final  List <String> _curriencies = ["MMK","USD"];
 final List <String> _requestType = ["Project","Tirp","Operation"];
 final List<String> _departments = ["Admin", "IT", "Finance"];

  @override
  void initState(){
    super.initState();
    _columns = _buildColumns();
    _rows = [];
    _fetchData();
  } 


List <PlutoColumn> _buildColumns(){
  return [
    PlutoColumn(
      title: "Flow Name", 
      field: "Flow Name",
       type: PlutoColumnType.text(),
       enableEditingMode: false,
       width: 250,
       ),
       PlutoColumn(
      title: "Department", 
      field: "Department",
       type: PlutoColumnType.text(),
       enableEditingMode: false,
       width: 130,
       ),
       PlutoColumn(
      title: "Request Type", 
      field: "Request Type",
       type: PlutoColumnType.text(),
       enableEditingMode: false,
       width: 130,
       ),
       PlutoColumn(
      title: "Description", 
      field: "Description",
       type: PlutoColumnType.text(),
       enableEditingMode: false,
       width: 280,
       ),
       PlutoColumn(
      title: "Currency", 
      field: "Currency",
       type: PlutoColumnType.text(),
       enableEditingMode: false,
       width: 110,
       ),
       PlutoColumn(
      title: "No Of Steps", 
      field: "No Of Steps",
       type: PlutoColumnType.text(),
       enableEditingMode: false,
       width: 130,
       ),
        PlutoColumn(
      title: "Management Approver", 
      field: "Management Approver",
       type: PlutoColumnType.text(),
       enableEditingMode: false,
       width: 200,
       ),
        PlutoColumn(
      title: "Action", 
      field: "Action",
      textAlign: PlutoColumnTextAlign.center,
      titleTextAlign: PlutoColumnTextAlign.center,
       type: PlutoColumnType.text(),
       enableEditingMode: false,
       width: 140,
       renderer: (rendererContext) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed:(){}, 
              icon: Icon(Icons.edit, color: Colors.blue),
              ),
              IconButton(
                onPressed: (){},
                 icon: Icon(Icons.delete,color: Colors.red),
                 ),
                 IconButton(
                  onPressed: (){},
                   icon: Icon(Icons.more_horiz, color: Colors.black),
                   ),
          ],
        );
       },
       ),
  ];
}

List <PlutoRow> _buildRows (List <Map<String, String>> approvallist){
  return approvallist.map((data){
      return PlutoRow(cells: {
        "Flow Name": PlutoCell(value: data['Flow Name']),
        "Department": PlutoCell(value: data['Department']),
        "Request Type": PlutoCell(value: data['Request Type']),
        "Description": PlutoCell(value: data['Description']),
        "Currency": PlutoCell(value: data['Currency']),
        "No Of Steps": PlutoCell(value: data['No Of Steps']),
        "Management Approver": PlutoCell(value: data['Management Approver']),
        "Action": PlutoCell(value: data['']),
      });
  }).toList();
}

void _fetchData() {
  setState(() {
    _rows = _buildRows(approvalData);
  });
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



void _handleSearch(String query){
  setState(() {
    _searchQuery = query;
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true,
      title: const Text("Approvers List"),),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(80, 20, 80, 20),
        child: Container(
          height: 470,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children:[
                     SizedBox(
                  width: MediaQuery.of(context).size.width / 6,
                  child: CustomSearchBar(
                    onSearch: _handleSearch,
                    hintText: 'Search...',
                    minWidth: 400,
                    maxWidth: 600,
                    
                     ),
                ),
                   SizedBox(
                  width: MediaQuery.of(context).size.width / 6,
                  height: 44,
                  child: DropdownButtonFormField<String>(
                    value: _selectedDepartmentName,
                    decoration: InputDecoration(
                      labelText: "Department",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      )
                    ),
                    items: _departments.map((dept){
                      return DropdownMenuItem(
                        value: dept,
                        child: Text(dept),
                        onTap: () {
                          _selectedDepartmentName = dept;
                        },);
                    }).toList(),
                     onChanged: (value){
                      setState(() {
                        _selectedDepartmentName = value;
                      });
                     }),
                ),
              
              SizedBox(
                width: MediaQuery.of(context).size.width / 6,
                height: 44,
                child: DropdownButtonFormField(
                  decoration:  InputDecoration(
                    labelText: "Request Type",
                    border: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(8),
                    )
                  ),
                  value: _selectedType,
                  items: _requestType.map((type){
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                    );
                  }).toList(),
                   onChanged: (value){
                    setState(() {
                      _selectedType = value!;
                    });
                   },
                   ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 6,
                height: 44,
                child: DropdownButtonFormField(
                  decoration:  InputDecoration(
                    labelText: "Currency",
                    border: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(8),
                    )
                  ),
                  value: _selectedCurrency,
                  items: _curriencies.map((type){
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                    );
                  }).toList(),
                   onChanged: (value){
                    setState(() {
                      _selectedCurrency = value!;
                    });
                   },
                   ),
              ),
            ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    onPressed: (){},
                     label: const Text('New'),
                     style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      )
                     ),
                     ),
                  Row(
                    children: [
                      Container(
                        child: IconButton(
                          onPressed: (){},
                          icon: const Icon(Icons.refresh),
                          color: Colors.black,
                          ),
                      ),
                      ElevatedButton.icon(
                        onPressed: (){},
                         label: const Text('Export'),
                         style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          )
                         ),
                         ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: 
                PlutoGrid(
                  columns: _columns,
                   rows: _rows,
                   mode: PlutoGridMode.normal,
                   configuration: PlutoGridConfiguration(
                    style: PlutoGridStyleConfig(
                      oddRowColor: Colors.blue[50],
                      rowHeight: 35,
                      activatedColor: Colors.lightBlueAccent.withOpacity(0.2),
                    )
                   ),
                   onLoaded: (PlutoGridOnLoadedEvent event) {
                    _stateManager = event.stateManager;
                    _updatePagedRows();
                    // if (_rows.isEmpty){
                    //   _fetchProjects();
                    // }
                   },
                   ),
                   ),
              const SizedBox(height: 10,),
              if (_stateManager != null)
              PlutoGridPagination(
                stateManager: _stateManager!, 
                totalRows: _rows.length,
                rowsPerPage: _rowsPerPage,
                 onPageChanged: (page, limit){
                  _currentPage = page;
                  _rowsPerPage = limit;
                  _updatePagedRows();
                 },
                 )
            ],
          ),
        ),
        
        ),
    );
  }
}