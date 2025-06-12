import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Budgetamount extends StatefulWidget {
  const Budgetamount({super.key});

  @override
  State<Budgetamount> createState() => _BudgetamountState();
}

class _BudgetamountState extends State<Budgetamount> {
  List<Map<String, dynamic>> budgetamountInformation =
      List.generate(100, (int index) {
    return {
      'BudgetCode': 'B-$index',
      'Description': 'BudgetDescription $index',
      'InitialAmount': '0',
      'Action': '',
    };
  });
  List<Map<String, dynamic>> filteredBudgetAmount = [];
  String searchQuery = '';

  TextEditingController _searchingController = TextEditingController();

  void initState() {
    super.initState();
    filteredBudgetAmount = List.from(budgetamountInformation);
  }

  // Searchbarfilter fuction
  void _searchFilter(String query) {
    setState(() {
      searchQuery = query;
      filteredBudgetAmount = budgetamountInformation
          .where((item) =>
              item['BudgetCode'].toLowerCase().contains(query.toLowerCase()) ||
              item['Description'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  //Refresh function
  void _refreshbudgetamountTable() {
    setState(() {
      _searchingController.clear();
      filteredBudgetAmount = List.from(budgetamountInformation);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "BudgetAmount",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                SizedBox(
                    height: 40,
                    width: MediaQuery.of(context).size.width / 2,
                    child: SearchBar(
                      controller: _searchingController,
                      hintText: "Search",
                      leading: Icon(Icons.search),
                      onChanged: _searchFilter,
                    )),
                SizedBox(width: 50),
                // IconButton(
                //     onPressed: () {},
                //     icon: Icon(
                //       Icons.add,
                //       color: Colors.blueGrey,
                //     )),
                IconButton(
                    onPressed: () {
                      _refreshbudgetamountTable();
                    },
                    icon: Icon(
                      Icons.refresh,
                      color: Colors.blueGrey,
                    )),
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.download,
                      color: Colors.blueGrey,
                    ))
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Table(
              border: const TableBorder.symmetric(
                inside: BorderSide(color: Colors.grey, width: 1),
                outside: BorderSide(color: Colors.grey, width: 1),
              ),
              columnWidths: const {
                0: FlexColumnWidth(1.5),
                1: FlexColumnWidth(2.5),
                2: FlexColumnWidth(2.5),
                3: FlexColumnWidth(2.5)
              },
              children: [
                TableRow(
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 167, 230, 232)),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("BudgetCode",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Description",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("InitialAmount",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Action",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ])
              ],
            ),
            Expanded(
              child: Table(
                  border: const TableBorder.symmetric(
                    inside: BorderSide(color: Colors.grey, width: 1),
                    outside: BorderSide(color: Colors.grey, width: 1),
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(1.5),
                    1: FlexColumnWidth(2.5),
                    2: FlexColumnWidth(2.5),
                    3: FlexColumnWidth(2.5)
                  },
                  children: filteredBudgetAmount.asMap().entries.map((entry) {
                    int index = entry.key;
                    var row = entry.value;
                    return TableRow(children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(row['BudgetCode'] ?? '1'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(row['Description'] ?? 'no'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(row['InitialAmount'] ?? '0'),
                      ),
                      Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                print(budgetamountInformation);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            BudgetInitialAmount(
                                                budgetamountInformation:
                                                    budgetamountInformation[
                                                        index],
                                                OnBudgetAmountUpdated:
                                                    (UpdatedInitialAmount) {
                                                  setState(() {
                                                    _refreshbudgetamountTable();
                                                    budgetamountInformation[
                                                            index] =
                                                        UpdatedInitialAmount;
                                                  });
                                                })));
                              },
                              icon: Icon(
                                Icons.input,
                                color: Colors.blueGrey,
                              )),
                          IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.edit,
                                color: Colors.blueGrey,
                              )),
                        ],
                      )
                    ]);
                  }).toList()),
            )
          ],
        ),
      ),
    );
  }
}

class BudgetInitialAmount extends StatefulWidget {
  final Map<String, dynamic> budgetamountInformation;
  final Function(Map<String, dynamic>) OnBudgetAmountUpdated;

  const BudgetInitialAmount(
      {Key? key,
      required this.budgetamountInformation,
      required this.OnBudgetAmountUpdated})
      : super(key: key);

  @override
  State<BudgetInitialAmount> createState() => _BudgetInitialAmountState();
}

class _BudgetInitialAmountState extends State<BudgetInitialAmount> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _budgetCodeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _initialamountController =
      TextEditingController();

  void initState() {
    super.initState();
    _budgetCodeController.text = widget.budgetamountInformation['BudgetCode'];
    _descriptionController.text = widget.budgetamountInformation['Description'];
    _initialamountController.text =
        widget.budgetamountInformation['InitialAmount'];
  }

  void _submitInitialAmount() {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> UpdatedInitialAmount = {
        'BudgetCode': _budgetCodeController.text,
        'Description': _descriptionController.text,
        'InitialAmount': _initialamountController.text,
      };

      widget.OnBudgetAmountUpdated(UpdatedInitialAmount);
      Navigator.pop(context);
    }
  }

  void _clearText() {
    setState(() {
      _descriptionController.clear();
      _budgetCodeController.clear();
      _initialamountController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Initial Budget Amount")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Container(
                width: MediaQuery.of(context).size.width / 3,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 149, 239, 233),
                  borderRadius: BorderRadius.circular(15), // Rounded corners
                  border: Border.all(color: Colors.black, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3), // Shadow color
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _budgetCodeController,
                        decoration: InputDecoration(
                          labelText: 'BudgetCode',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter BudgetCode";
                          }
                          return null;
                        },
                        readOnly: true,
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(labelText: 'Description'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter Description";
                          }
                          return null;
                        },
                        readOnly: true,
                      ),
                      TextFormField(
                        controller: _initialamountController,
                        decoration: InputDecoration(labelText: 'InitialAmount'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter InitialAmount";
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                _submitInitialAmount();
                              },

                              //  _submiteditForm,

                              child: Text("Submit")),
                          SizedBox(
                            width: 10,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                _clearText();
                              },
                              child: Text("Cancel"))
                        ],
                      )
                    ],
                  ),
                )),
          ),
        ));
  }
}
