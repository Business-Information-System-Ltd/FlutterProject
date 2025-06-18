import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:advance_budget_request_system/views/data.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:intl/intl.dart';

class SettlementTable extends StatefulWidget {
  const SettlementTable({super.key});

  @override
  State<SettlementTable> createState() => _SettlementTableState();
}

class _SettlementTableState extends State<SettlementTable> {
  late List<PlutoColumn> columns;
  late List<PlutoRow> rows;
  List<Settlement> settles = [];
  PlutoGridStateManager? stateManager;

  @override
  void initState() {
    super.initState();
    fetchData();
    initColumn();
  }

  void initColumn() {
    columns = [
      PlutoColumn(
          title: 'Settlement Date',
          field: 'Settlement Date',
          type: PlutoColumnType.text(),
          textAlign: PlutoColumnTextAlign.left,
          enableAutoEditing: false,
          enableEditingMode: false
          ),
      PlutoColumn(
          title: 'Payment No',
          field: 'Payment No',
          type: PlutoColumnType.text(),
          textAlign: PlutoColumnTextAlign.left,
          enableEditingMode: false,
          enableAutoEditing: false),
      PlutoColumn(
          title: 'Withdrawn Amount',
          field: 'Withdrawn Amount',
          type: PlutoColumnType.text(),
          textAlign: PlutoColumnTextAlign.right,
          titleTextAlign: PlutoColumnTextAlign.right,
          enableAutoEditing: false,
          enableEditingMode: false
          ),
      PlutoColumn(
          title: 'Settled Amount',
          field: 'Settled Amount',
          type: PlutoColumnType.number(),
          textAlign: PlutoColumnTextAlign.right,
          titleTextAlign: PlutoColumnTextAlign.right,
          enableAutoEditing: false,
          enableEditingMode: false),
      PlutoColumn(
          title: 'Refund Amount',
          field: 'Refund Amount',
          type: PlutoColumnType.text(),
          textAlign: PlutoColumnTextAlign.right,
          titleTextAlign: PlutoColumnTextAlign.right,
          enableAutoEditing: false,
          enableEditingMode: false),
      // PlutoColumn(
      //     title: 'Action',
      //     field: 'Action',
      //     type: PlutoColumnType.text(),
      //     enableAutoEditing: false),
      PlutoColumn(
        title: 'Action',
        field: 'Action',
        type: PlutoColumnType.text(),
        textAlign: PlutoColumnTextAlign.center,
          titleTextAlign: PlutoColumnTextAlign.center,
        enableAutoEditing: false,
        enableEditingMode: false,
        renderer: (rendererContext) {
          return const IconButton(
            icon: Icon(Icons.more_horiz_outlined),
            onPressed: null
          );
        },
      ),
    ];
  }

  void fetchData() async {
    List<Settlement> settled = await ApiService().fetchSettlements();
      final formatter = NumberFormat('#,##0');
    setState(() {
      settles = settled;
      rows = settles.map((settled) {
        return PlutoRow(cells: {
          'Settlement Date': PlutoCell(value: settled.settlementDate),
          'Payment No': PlutoCell(value: settled.paymentNo),
          'Withdrawn Amount': PlutoCell(value: formatter.format(settled.withdrawnAmount)),
        'Settled Amount': PlutoCell(value: formatter.format(settled.settleAmount)),
        'Refund Amount': PlutoCell(value: formatter.format(settled.refundAmount)),
          'Action': PlutoCell(
              value: IconButton(
                  onPressed: null, icon: Icon(Icons.more_horiz_outlined)))
        });
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settlement Page"),
      ),
      body: Column(
        children: [
          const Center(
            child: Text("Settlement Page",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
          ),
          settles.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 100, left: 100,top: 20),
                      child: Container(
                        height: 300,
                        child: PlutoGrid(
                          columns: columns,
                          rows: rows,
                          onLoaded: (PlutoGridOnLoadedEvent event) {
                            stateManager = event.stateManager;
                     
                          },
                          // onChanged: (PlutoGridOnChangedEvent event){
                        
                          // },
                          configuration: PlutoGridConfiguration(
                              style: PlutoGridStyleConfig(
                                  rowHeight: 30,
                                  oddRowColor: Colors.greenAccent,
                                  activatedColor:
                                      Colors.lightBlueAccent.withOpacity(0.3))),
                        ),
                      ),
                    ),
                  ),
                )
        ],
      ),
    );
  }
}
