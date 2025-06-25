import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:advance_budget_request_system/views/data.dart';
import 'package:intl/intl.dart';


class SettlementPage extends StatefulWidget {
  @override
  _SettlementPageState createState() => _SettlementPageState();
}

class _SettlementPageState extends State<SettlementPage> {
  List<PlutoColumn> _columns = [];
  List<PlutoRow> _rows = [];
  PlutoGridStateManager? _stateManager;
  final NumberFormat _formatter = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();
    _columns = _buildColumns();
    _fetchData();
  }

  List<PlutoColumn> _buildColumns() {
    return [
     
      PlutoColumn(
        title: 'SettlementDate',
       field: 'SettlementDate',
        type: PlutoColumnType.text(), 
        readOnly: false,
         width: 211,  // width in pixels
         
 ),

      PlutoColumn(
        title: 'PaymentNo', 
      field: 'PaymentNo',
       type: PlutoColumnType.text(),
       readOnly: false,
       width: 211,
       ),

      PlutoColumn(
        title: 'WithdrawnAmount',
       field: 'WithdrawnAmount', 
       type: PlutoColumnType.number(),
       readOnly: false,
       width: 211,
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
        title: 'SettleAmount', 
      field: 'SettleAmount', 
      type: PlutoColumnType.number(),
      readOnly: false,
      width: 211,
      textAlign: PlutoColumnTextAlign.right,
      titleTextAlign: PlutoColumnTextAlign.right,
      renderer: (context) {
    final value = int.tryParse(context.cell.value.toString()) ?? 0;
    return Text(
      _formatter.format(value),
      textAlign: TextAlign.right,
    );
  }, ),

      PlutoColumn(
      title: 'RefundAmount', 
      field: 'RefundAmount',
      type: PlutoColumnType.number(),
      readOnly: false,
      width: 211,
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
      title: "Action", 
      field: "Action", 
      type: PlutoColumnType.text(),
      readOnly: false,
      width: 211,
      titleTextAlign: PlutoColumnTextAlign.center,
      textAlign: PlutoColumnTextAlign.center,
      ),
     
    ];
  }

  void _fetchData() async {
    try {
      List<Settlement> settlements = await ApiService().fetchSettlements();
      setState(() {
        _rows = _buildRows(settlements);
      });
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load settlements')),
      );
    }
  }

  List<PlutoRow> _buildRows(List<Settlement> settlements) {
    return settlements.map((s) {
      return PlutoRow(cells: {
        
        'SettlementDate': PlutoCell(value: s.settlementDate),
        'PaymentNo': PlutoCell(value: s.paymentNo),
        'WithdrawnAmount': PlutoCell(value: s.withdrawnAmount.toString()),
        'SettleAmount': PlutoCell(value: s.settleAmount.toString()),
        'RefundAmount': PlutoCell(value: s.refundAmount.toString()),
       'Action':PlutoCell(value: const IconButton(onPressed: null, icon: Icon(Icons.more_horiz_outlined)))
        
      });
    }).toList();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Settlement '),centerTitle: true,),

    body: _rows.isEmpty
        ? const Center(child: CircularProgressIndicator())
         : Padding( padding: const EdgeInsets.only(left: 50, right: 50, top: 30, bottom: 50), 

        
              child:SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child:Container(
              height: 200,
             
             
              
              child: PlutoGrid(
              columns: _columns,
              rows: _rows,
              configuration:PlutoGridConfiguration(
                style: PlutoGridStyleConfig(
                oddRowColor:Colors.green[50] , rowHeight: 30,
                activatedColor: Colors.lightBlueAccent.withOpacity(0.3) ),),
              onLoaded: (event) => _stateManager = event.stateManager,
              ),
              
              )
              )
         
         
         
         )
  );
  }
}








