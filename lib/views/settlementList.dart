import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';


class Settlementlist extends StatefulWidget {
  const Settlementlist({Key? key}) : super(key: key);

  @override
  State<Settlementlist> createState() => _SettlementlistState();
}

class  _SettlementlistState extends State<Settlementlist> {
  late final PlutoGridStateManager stateManager;

  
  final List<String> columnTitles = [
    'SettlementDate',
    'PaymentNo',
    'WithdrawnAmount',
    'SettledAmount',
    'Refund Amount',
    
  ];

  
  late final List<PlutoColumn> columns = columnTitles.map((title) {
    PlutoColumnType type;
    if (title == 'SettlementDate') {
      type = PlutoColumnType.date();
    } else {
      type = PlutoColumnType.number();
    }
    return PlutoColumn(
      title: title,
      field: title,
      type: type,
    );
  }).toList();

  
  final List<Map<String, dynamic>> rowData = [
    {
      'SettlementDate': '2022-01-01',
      'PaymentNo': '10000',
      'WithdrawnAmount': 1500,
      'SettledAmount': 3000,
      'Refund Amount': 4000,
    },
    {
      'SettlementDate': '2022-02-01',
      'PaymentNo': '20000',
      'WithdrawnAmount': 1600,
      'SettledAmount': 4000,
      'Refund Amount': 5000,
    },
    {
      'SettlementDate': '2022-03-01',
      'PaymentNo': '30000',
      'WithdrawnAmount': 1800,
      'SettledAmount': 9000,
      'Refund Amount': 5000,
    },
    {
      'SettlementDate': '2022-04-01',
      'PaymentNo': '80000',
      'WithdrawnAmount': 3800,
      'SettledAmount': 94000,
      'Refund Amount': 52000,
    },
    {
      'SettlementDate': '2022-05-01',
      'PaymentNo': '70000',
      'WithdrawnAmount': 8800,
      'SettledAmount': 44000,
      'Refund Amount': 82000,
    },
  ];

  
  late final List<PlutoRow> rows = []..addAll(rowData.map((data) {
    final Map<String, PlutoCell> cells = {};
    for (var entry in data.entries) {
      cells[entry.key] = PlutoCell(value: entry.value);
    }
    return PlutoRow(cells: cells);
  }));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        //padding: const EdgeInsets.all(50),
        padding: EdgeInsets.fromLTRB(50, 90, 50, 50),

        child: PlutoGrid(
          columns: columns,
          rows: rows,
          onLoaded: (PlutoGridOnLoadedEvent event) {
            stateManager = event.stateManager;
          },
          onChanged: (PlutoGridOnChangedEvent event) {
            print(event);
          },
          configuration: const PlutoGridConfiguration(),
        ),
      ),
    );
  }
}
