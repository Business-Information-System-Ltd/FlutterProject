import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:advance_budget_request_system/views/cashPayment.dart';
import 'package:advance_budget_request_system/views/data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentEntry extends StatefulWidget {
  final AdvanceRequest selectedRequest;
  const PaymentEntry({Key? key, required this.selectedRequest})
      : super(key: key);

  @override
  State<PaymentEntry> createState() => _PaymentEntryState();
}

class _PaymentEntryState extends State<PaymentEntry> {
  final _formkey = GlobalKey<FormState>();
  List<AdvanceRequest> advanceReq = [];
  List<CashPayment> payment=[];
  final Map<String, int> _requestNoCountMap = {};

  @override
  void initState() {
    super.initState();
    _populatedForm(widget.selectedRequest);
    _fetchData();
    _initializePaymentCode();
  }

  void _fetchData() async {
    try {
      List<AdvanceRequest> advanceRequests =
          await ApiService().fetchAdvanceRequestData();
      List<CashPayment> payments= await ApiService().fetchCashPaymentData();
      setState(() {
        advanceReq = advanceRequests;
        payment=payment;
      });
    } catch (e) {
      print('Fail to payment: $e');
    }
  }

  final TextEditingController _dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  final TextEditingController _paymentNoController = TextEditingController();
  final TextEditingController _requestTypeController = TextEditingController();
  final TextEditingController _paymentAmtController = TextEditingController();
  final TextEditingController _currency = TextEditingController();
  final TextEditingController _paidPerson = TextEditingController();
  final TextEditingController _receivePerson = TextEditingController();
  final TextEditingController _paymentNote = TextEditingController();

  String? _paymentMethod;

  AdvanceRequest? _selectedRequest;
  String? _selectedRequestNo;
  String? _selectedRequestCode;

  void _populatedForm(AdvanceRequest request) {
    _requestTypeController.text = request.requestType;
    _currency.text = request.currency;
    _selectedRequestNo = request.id.toString();
    _selectedRequestCode = request.requestNo;
    // _selectedBudgetDetails = request.budgetDetails;

    // //Auto Icrement Id
    // final requestNo = request.requestCode;
    // final count = (_requestNoCountMap[requestNo] ?? 0) + 1;
    // _requestNoCountMap[requestNo] = count + 1;
    // _paymentNoController.text = '${request.requestCode}_$count';
  }

  //generated ID
final ApiService apiService = ApiService();

  Future<int> generateID() async {
    List<CashPayment> existingCash = await apiService.fetchCashPaymentData();

    if (existingCash.isEmpty) {
      return 1; // Start from 1 if no budget exists
    }

    // Find the highest existing ID
    int maxId =
        existingCash.map((b) => b.id).reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  //Payment No AutoIncrement
   void _initializePaymentCode() async {
    try {
      String nextCode = await apiService.fetchNextPaymentCode();
      setState(() {
        _paymentNoController.text = nextCode;
      });
    } catch (error) {
      // Handle error appropriately.
      print('Error fetching advance code: $error');
    }
  }


//submitForm
  void _submitForm() async {
    if (_formkey.currentState!.validate()) {
      int newId = await generateID();
      CashPayment newPayment = CashPayment(
        id: newId,
        date: DateFormat('yyyy-MM-dd').parse(_dateController.text),
        paymentNo: _paymentNoController.text,
        requestNo: int.parse(_selectedRequestNo!),
        requestCode: _selectedRequestCode!,
        requestType: _requestTypeController.text,
        paymentAmount: double.tryParse(_paymentAmtController.text) ?? 0.0,
        currency: _currency.text,
        paymentMethod: _paymentMethod!,
        paidPerson: _paidPerson.text,
        receivePerson: _receivePerson.text,
        paymentNote: _paymentNote.text,
        status: 1,
        settledStatus: 0
      );

      try {
        await ApiService().postCashPayment(newPayment);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cash Payment added successfully!")),
        );
        // Navigator.of(context).push(
        //   MaterialPageRoute(builder: (context) => const Cashpayment()),
        // );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add cash payment: $e")),
        );
      }
    }
  }

  //clear Text
  void _clearText() {
    setState(() {
      _paymentNoController.text = '';
      _requestTypeController.text = '';
      _paymentMethod = null;
      _currency.text = '';
      _paidPerson.text = '';
      _receivePerson.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cash Payment Form"),
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: const Color.fromARGB(255, 103, 207, 177),
          ),
          width: MediaQuery.of(context).size.width * 0.5,
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Form(
                      key: _formkey,
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Add Cash Payment",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Center(
                            child: IconButton(
                              onPressed: () async {
                                final selectedRequest =
                                    await Navigator.push<AdvanceRequest>(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AdvanceRequestTable(
                                                  onRowSelected: (request) {
                                                    return request;
                                                  },
                                                  advance: advanceReq,
                                                  payment: [],
                                                  onRefresh: _fetchData,
                                                )));
                                if (selectedRequest != null) {
                                  setState(() {
                                    _selectedRequest = selectedRequest;
                                    _populatedForm(selectedRequest);
                                  });
                                }
                              },
                              icon: const Icon(Icons.arrow_drop_down),
                              iconSize: 40,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Column(
                                children: [
                                  ListTile(
                                    title: TextFormField(
                                      controller: _paymentNoController,
                                      decoration: const InputDecoration(
                                          labelText: "Payment No"),
                                      // readOnly: true,
                                    ),
                                  ),
                                  ListTile(
                                    title: TextFormField(
                                      controller: _paymentAmtController,
                                      decoration: const InputDecoration(
                                          labelText: "Enter Payment Amount"),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Enter Total Amount";
                                        }
                                        final amount = double.tryParse(value);
                                        if (amount == null) {
                                          return "Enter a valid amount";
                                        }
                                        if (amount <= 0) {
                                          return "Your Request Amount must be greater than 0";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  ListTile(
                                    title: TextFormField(
                                      controller: _paidPerson,
                                      decoration: const InputDecoration(
                                          labelText: "Enter Paid Person"),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Enter Paid Person";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              )),
                              Expanded(
                                  child: Column(
                                children: [
                                  ListTile(
                                    title: TextFormField(
                                      controller: _requestTypeController,
                                      decoration: const InputDecoration(
                                          labelText: "Request Type"),
                                      readOnly: true,
                                    ),
                                  ),
                                  ListTile(
                                    title: TextFormField(
                                      controller: _currency,
                                      decoration: const InputDecoration(
                                          labelText: "Currency"),
                                      readOnly: true,
                                    ),
                                  ),
                                  ListTile(
                                    title: TextFormField(
                                      controller: _receivePerson,
                                      decoration: const InputDecoration(
                                          labelText: "Enter Receive Person"),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Enter Receive Person";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              )),
                              Expanded(
                                  child: Column(
                                children: [
                                  ListTile(
                                    title: TextFormField(
                                      controller: _dateController,
                                      decoration: const InputDecoration(
                                          labelText: "Payment Date"),
                                      readOnly: true,
                                    ),
                                  ),
                                  ListTile(
                                    title: DropdownButtonFormField(
                                        decoration: const InputDecoration(
                                            labelText: 'Choose Payment Method'),
                                        value: _paymentMethod,
                                        items: ['Cash', 'Bank', 'Cheque']
                                            .map((selectedType) =>
                                                DropdownMenuItem(
                                                  value: selectedType,
                                                  child: Text(selectedType),
                                                ))
                                            .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _paymentMethod = value!;
                                          });
                                        }),
                                  ),
                                  ListTile(
                                    title: TextFormField(
                                      controller: _paymentNote,
                                      decoration: const InputDecoration(
                                          labelText: "Enter Payment Note"),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Enter Payment Note";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ))
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _submitForm,
                                style: ElevatedButton.styleFrom(
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                  ),
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text("Submit"),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _clearText();
                                },
                                style: ElevatedButton.styleFrom(
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                  ),
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text("Clear"),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 40,
                          )
                        ],
                      )),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdvanceRequestTable extends StatelessWidget {
  final Function(AdvanceRequest) onRowSelected;
  final List<AdvanceRequest> advance;
  final List<CashPayment> payment;
  final VoidCallback onRefresh;
  const AdvanceRequestTable(
      {Key? key, required this.onRowSelected, required this.advance, required this.payment, required this.onRefresh})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filterAdvance =
        advance.where((advance) => advance.status == "Approved").toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(100, 207, 198, 0.855),
        title: const Text("Choose Advance request"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
            child: Container(
              height: 500,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Choose Advance Request",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            showCheckboxColumn: false,
                            border: TableBorder.all(),
                            headingRowColor: MaterialStateProperty.resolveWith(
                              (Set<MaterialState> states) {
                                return const Color.fromARGB(255, 167, 230, 232);
                              },
                            ),
                            columns: const [
                              DataColumn(
                                  label: Text(
                                "Request No",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                              DataColumn(
                                  label: Text(
                                "Request Type",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                              DataColumn(
                                  label: Text(
                                "Request Amount",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                              DataColumn(
                                  label: Text(
                                "Currency",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                              DataColumn(
                                  label: Text(
                                "Status",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                            ],
                            rows: filterAdvance.map((request) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(request.requestNo)),
                                  DataCell(Text(request.requestType)),
                                  DataCell(Text(request.requestAmount.toString())),
                                  DataCell(Text(request.currency)),
                                  DataCell(Text(request.status)),
                                ],
                                onSelectChanged: (selected) {
                                  if (selected != null) {
                                    onRowSelected(request);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PaymentEntry(selectedRequest: request),
                                      ),
                                    );
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: () {
                          // Navigator.of(context).push(MaterialPageRoute(
                          //     builder: (context) => const Cashpayment()));
                          onRefresh();
                          Navigator.pop(context);
                          
                        },
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(
                            fontSize: 18,
                          ),
                          backgroundColor: const Color.fromARGB(255, 76, 178, 182),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Back",
                          style:
                              TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//Edit Cash Payment
class EditPayment extends StatefulWidget {
  final CashPayment payment;
  const EditPayment({Key? key, required this.payment}) : super(key: key);

  @override
  State<EditPayment> createState() => _EditPaymentState();
}

class _EditPaymentState extends State<EditPayment> {
  final _formkey = GlobalKey<FormState>();
  late TextEditingController _dateController;
  late TextEditingController _paymentNoController;
  late TextEditingController _requestTypeController;
  late TextEditingController _currency;
  late TextEditingController _paymentAmtController;
  late TextEditingController _paidPersonController;
  late TextEditingController _receivePersonController;
  late TextEditingController _paymentNoteController;

  String? _paymentMethod;
  List<AdvanceRequest> advancerequest = [];
  List<CashPayment> payments=[];

  @override
  void initState() {
    super.initState();
    _fetchData();

    _dateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(widget.payment.date));
    _paymentNoController =
        TextEditingController(text: widget.payment.paymentNo);
    _requestTypeController =
        TextEditingController(text: widget.payment.requestType);
    _paymentAmtController =
        TextEditingController(text: widget.payment.paymentAmount.toString());
    _currency = TextEditingController(text: widget.payment.currency);
    _paidPersonController =
        TextEditingController(text: widget.payment.paidPerson);
    _receivePersonController =
        TextEditingController(text: widget.payment.receivePerson);
    _paymentNoteController =
        TextEditingController(text: widget.payment.paymentNote);
    _paymentMethod = widget.payment.paymentMethod;
  }

  void _fetchData() async {
    List<AdvanceRequest> advanceRequests =
        await ApiService().fetchAdvanceRequestData();
    advancerequest = advanceRequests;
  }

  //refresh Cashpayment
  Future<void> refreshCashPayments() async {
  try {
    final updatedPayments = await ApiService().fetchCashPaymentData();
    setState(() {
      payments = updatedPayments;
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to refresh: ${e.toString()}")),
    );
  }
}
  @override
  void dispose() {
    _paymentNoController.dispose();
    _requestTypeController.dispose();
    _paymentAmtController.dispose();
    _currency.dispose();
    _paidPersonController.dispose();
    _receivePersonController.dispose();
    _paymentNoteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  //submitUpdateForm
  void _submitForm() async {
    if (_formkey.currentState!.validate()) {
      CashPayment updateCashPayment = CashPayment(
          id: widget.payment.id,
          date: DateFormat('yyyy-MM-dd').parse(_dateController.text),
          paymentNo: _paymentNoController.text,
          requestNo: widget.payment.requestNo,
          requestCode: widget.payment.requestCode,
          requestType: _requestTypeController.text,
          paymentAmount: double.parse(_paymentAmtController.text),
          currency: _currency.text,
          paymentMethod: _paymentMethod!,
          paidPerson: _paidPersonController.text,
          receivePerson: _receivePersonController.text,
          paymentNote: _paymentNoteController.text,
          status: widget.payment.status,
          settledStatus: widget.payment.settledStatus
          );

      try {
        await ApiService().updateCashPayment(updateCashPayment);
        _fetchData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment updated successfully!")),
        );
        Navigator.of(context)
            .pop(true); // Pop the current screen after updating
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment hasn't updated successfully!")),
        );
      }
    }
  }

  //ClearText
  void _clearText() {
    setState(() {
      _paymentNoController.text = '';
      _requestTypeController.text = '';
      _paymentMethod = null;
      _currency.text = '';
      _paidPersonController.text = '';
      _receivePersonController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Cash Payment"),
      ),
      body: Center(
        child: Container(
          color: const Color.fromARGB(255, 103, 207, 177),
          width: MediaQuery.of(context).size.width * 0.5,
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Form(
                      key: _formkey,
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Edit Cash Payment",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Center(
                            child: IconButton(
                              onPressed: () async {
                                await Navigator.push<AdvanceRequest>(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AdvanceRequestTable(
                                              onRowSelected: (request) {
                                                return request;
                                              },
                                              advance: advancerequest,
                                              payment: [],
                                              onRefresh:refreshCashPayments,
                                            )));
                              },
                              icon: const Icon(Icons.arrow_drop_down),
                              iconSize: 40,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Column(
                                children: [
                                  ListTile(
                                    title: TextFormField(
                                      controller: _paymentNoController,
                                      decoration: const InputDecoration(
                                          labelText: "Payment No"),
                                      // readOnly: true,
                                    ),
                                  ),
                                  ListTile(
                                    title: TextFormField(
                                      controller: _paymentAmtController,
                                      decoration: const InputDecoration(
                                          labelText: "Enter Payment Amount"),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Enter Total Amount";
                                        }
                                        final amount = double.tryParse(value);
                                        if (amount == null) {
                                          return "Enter a valid amount";
                                        }
                                        if (amount <= 0) {
                                          return "Your Request Amount must be greater than 0";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  ListTile(
                                    title: TextFormField(
                                      controller: _paidPersonController,
                                      decoration: const InputDecoration(
                                          labelText: "Enter Paid Person"),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Enter Paid Person";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              )),
                              Expanded(
                                  child: Column(
                                children: [
                                  ListTile(
                                    title: TextFormField(
                                      controller: _requestTypeController,
                                      decoration: const InputDecoration(
                                          labelText: "Request Type"),
                                      readOnly: true,
                                    ),
                                  ),
                                  ListTile(
                                    title: TextFormField(
                                      controller: _currency,
                                      decoration: const InputDecoration(
                                          labelText: "Currency"),
                                      readOnly: true,
                                    ),
                                  ),
                                  ListTile(
                                    title: TextFormField(
                                      controller: _receivePersonController,
                                      decoration: const InputDecoration(
                                          labelText: "Enter Receive Person"),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Enter Receive Person";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              )),
                              Expanded(
                                  child: Column(
                                children: [
                                  ListTile(
                                    title: TextFormField(
                                      controller: _dateController,
                                      decoration: const InputDecoration(
                                          labelText: "Payment Date"),
                                      readOnly: true,
                                    ),
                                  ),
                                  ListTile(
                                    title: DropdownButtonFormField(
                                        decoration: const InputDecoration(
                                            labelText: 'Choose Payment Method'),
                                        value: _paymentMethod,
                                        items: ['Cash', 'Bank', 'Cheque']
                                            .map((selectedType) =>
                                                DropdownMenuItem(
                                                  value: selectedType,
                                                  child: Text(selectedType),
                                                ))
                                            .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _paymentMethod = value!;
                                          });
                                        }),
                                  ),
                                  ListTile(
                                    title: TextFormField(
                                      controller: _paymentNoteController,
                                      decoration: const InputDecoration(
                                          labelText: "Enter Payment Note"),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Enter Payment Note";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ))
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _submitForm,
                                style: ElevatedButton.styleFrom(
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                  ),
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text("Submit"),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _clearText();
                                },
                                style: ElevatedButton.styleFrom(
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                  ),
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text("Clear"),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 40,
                          )
                        ],
                      )),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
