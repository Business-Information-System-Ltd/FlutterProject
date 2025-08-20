import 'package:advance_budget_request_system/views/api_service.dart';
import 'package:advance_budget_request_system/views/cashpaymentpage.dart';
import 'package:advance_budget_request_system/views/data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';

class AdvancePage extends StatefulWidget {
  const AdvancePage({super.key});

  @override
  State<AdvancePage> createState() => _AdvancePageState();
}

class _AdvancePageState extends State<AdvancePage> {
  List<PlutoColumn> _columns = [];
  List<PlutoRow> _rows = [];
  PlutoGridStateManager? stateManager;
  final NumberFormat _formatter = NumberFormat('#,###');
  final dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    _columns = _buildColumns();
    // _rows = _buildRows();
    super.initState();
    _fetchAdvanceRequests();
  }

  void _fetchAdvanceRequests() async {
    try {
      List<Advance> advanceList = await ApiService().fetchAdvanceRequests();
      setState(() {
        _rows = advanceList
            .where((advance) => advance.status == 'Approve')
            .map((advance) {
          return PlutoRow(cells: {
            'requestDate': PlutoCell(
              value:
                  advance.date != null ? dateFormat.format(advance.date) : "",
            ),
            'requestNo': PlutoCell(value: advance.requestNo ?? ""),
            'requestType': PlutoCell(value: advance.requestType ?? ""),
            'requestCode': PlutoCell(value: advance.requestCode ?? ""),
            'requestAmount': PlutoCell(value: advance.requestAmount ?? 0),
            'currency': PlutoCell(value: advance.currency ?? ""),
            'requester': PlutoCell(value: advance.requester ?? ""),
            'description': PlutoCell(value: advance.requestDes ?? ""),
            'requestPurpose': PlutoCell(value: advance.purpose ?? ""),
            'approvedAmount': PlutoCell(value: advance.approvedAmount ?? 0)
          });
        }).toList();
      });
    } catch (e) {
      print("Error fetching advance requests: $e");
    }
  }

  List<PlutoColumn> _buildColumns() {
    return [
      PlutoColumn(
          title: 'Request Date',
          field: 'requestDate',
          type: PlutoColumnType.date(),
          width: 211,
          enableEditingMode: false),
      PlutoColumn(
          title: 'Request No',
          field: 'requestNo',
          type: PlutoColumnType.text(),
          width: 211,
          enableEditingMode: false),
      PlutoColumn(
          title: 'Request Type',
          field: 'requestType',
          type: PlutoColumnType.text(),
          width: 211,
          enableEditingMode: false),
      PlutoColumn(
          title: 'Request Code',
          field: 'requestCode',
          type: PlutoColumnType.text(),
          width: 211,
          enableEditingMode: false),
      PlutoColumn(
        title: 'Request Amount',
        field: 'requestAmount',
        type: PlutoColumnType.text(),
        width: 211,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.right,
        titleTextAlign: PlutoColumnTextAlign.right,
        renderer: (context) {
          final value = int.tryParse(context.cell.value.toString()) ?? 0;
          return Text(_formatter.format(value), textAlign: TextAlign.right);
        },
      ),
      PlutoColumn(
          title: 'Currency',
          field: 'currency',
          type: PlutoColumnType.text(),
          width: 211,
          enableEditingMode: false),
      PlutoColumn(
          title: 'Requester',
          field: 'requester',
          type: PlutoColumnType.text(),
          width: 211,
          enableEditingMode: false),
    ];
  }

  void _navigateToCashpaymentForm(
      BuildContext context, Map<String, dynamic> advanceData) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CashPaymentFormScreen(
            requestDate: advanceData['requestDate'] != null
                ? dateFormat.parse(advanceData['requestDate'])
                : DateTime.now(),
            requestNo: advanceData['requestNo'] ?? "",
            requestCode: advanceData['requestCode'] ?? "",
            requestType: advanceData['requestType'] ?? "",
            currency: advanceData['currency'] ?? "",
            requestAmount: advanceData['requestAmount'] ?? 0.0,
            description: advanceData['description'] ?? "",
            purpose: advanceData['requestPurpose'] ?? "",
            requester: advanceData['requester'] ?? "",
            approveAmount: advanceData['approvedAmount'] ?? 0.0,
            isEditMode: false,
            isViewMode: false,
            cashId: "0",
            // totalWithdrawn: 0,
            // remainingAmount: 0
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _rows.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.fromLTRB(50, 20, 50, 30),
              child: Container(
                height: 300,
                child: Column(
                  children: [
                    const Center(
                      child: Text(
                        "Available Advance Request List",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Expanded(
                        child: PlutoGrid(
                      columns: _columns,
                      rows: _rows,
                      configuration: PlutoGridConfiguration(
                          style: PlutoGridStyleConfig(
                        oddRowColor: Colors.blue[50],
                        rowHeight: 30,
                        activatedColor: Colors.lightBlueAccent.withOpacity(0.3),
                      )),
                      onLoaded: (event) => stateManager = event.stateManager,
                      onRowDoubleTap: (PlutoGridOnRowDoubleTapEvent event) {
                        final rowData = event.row.cells;
                        _navigateToCashpaymentForm(context, {
                          'requestDate': rowData['requestDate']?.value,
                          'requestNo': rowData['requestNo']?.value,
                          'requestCode': rowData['requestCode']?.value,
                          'requestType': rowData['requestType']?.value,
                          'currency': rowData['currency']?.value,
                          'requestAmount': rowData['requestAmount']?.value,
                          'description': rowData['description']?.value,
                          'requestPurpose': rowData['requestPurpose']?.value,
                          'requester': rowData['requester']?.value,
                          'approvedAmount': rowData['approvedAmount']?.value,
                          // 'totalWithdrawn': rowData['totalWithdrawn']?.value,
                          // 'remainingAmount': rowData['remainingAmount']?.value
                        });
                      },
                    ))
                  ],
                ),
              ),
            ),
    );
  }
}

class CashPaymentFormScreen extends StatefulWidget {
  final String? requestNo;
  final String? requestType;
  final String? currency;
  final String? requestCode;
  final String? description;
  final double? requestAmount;
  final String? purpose;
  final String? requester;
  final DateTime? requestDate;
  final double? approveAmount;
  final bool isEditMode;
  final bool isViewMode;
  final String cashId;
  final Payment? payment;

  const CashPaymentFormScreen({
    this.requestNo,
    this.requestType,
    this.currency,
    this.requestCode,
    this.description,
    this.requestAmount,
    this.purpose,
    this.requester,
    this.requestDate,
    this.approveAmount,
    this.isEditMode = false,
    this.isViewMode = false,
    required this.cashId,
    this.payment,
    Key? key,
  }) : super(key: key);

  @override
  State<CashPaymentFormScreen> createState() => _CashPaymentFormScreenState();
}

class _CashPaymentFormScreenState extends State<CashPaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _paymentNoController = TextEditingController();
  final TextEditingController _requestDateController = TextEditingController();
  final TextEditingController _requestCodeController = TextEditingController();
  final TextEditingController _requestAmountController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _requesterController = TextEditingController();
  final TextEditingController _approvedAmountController =
      TextEditingController();
  final TextEditingController _requestNoController = TextEditingController();
  final TextEditingController _paymentDateController = TextEditingController();
  final TextEditingController _requestTypeController = TextEditingController();
  final TextEditingController _paymentAmountController =
      TextEditingController();
  final TextEditingController _paidPersonController = TextEditingController();
  final TextEditingController _receivePersonController =
      TextEditingController();
  final TextEditingController _paymentNoteController = TextEditingController();
  final TextEditingController _totalWithdrawnController =
      TextEditingController();
  final TextEditingController _remainingAmountController =
      TextEditingController();
  String? _selectedPaymentMethod;

  String currency = "MMK";

  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    try {
      _initializeForm();
      _generatePaymentNo();

      // _requestNoController.text = widget.requestNo!;
      // _requestTypeController.text = widget.requestType!;
      // _requestDateController.text =
      //     DateFormat('yyyy-MM-dd').format(widget.requestDate!);
      // _requestCodeController.text = widget.requestCode!;
      // _requestAmountController.text = widget.requestAmount.toString();
      // _descriptionController.text = widget.description!;
      // _purposeController.text = widget.purpose!;
      // _requesterController.text = widget.requester!;
      // _approvedAmountController.text = widget.approveAmount.toString();
      _requestNoController.text = widget.requestNo ?? "";
      _requestTypeController.text = widget.requestType ?? "project";
      _requestDateController.text = widget.requestDate != null
          ? DateFormat('yyyy-MM-dd').format(widget.requestDate!)
          : DateFormat('yyyy-MM-dd').format(DateTime.now());
      _requestCodeController.text = widget.requestCode ?? "";
      _requestAmountController.text = widget.requestAmount?.toString() ?? "0";
      _descriptionController.text = widget.description ?? "";
      _purposeController.text = widget.purpose ?? "";
      _requesterController.text = widget.requester ?? "";
      _approvedAmountController.text = widget.approveAmount?.toString() ?? "0";
      double totalWithdrawn = 0.0;
      double remainingAmount = (widget.approveAmount ?? 0.0) - totalWithdrawn;
      _totalWithdrawnController.text = totalWithdrawn.toString() ?? '0';
      _remainingAmountController.text = remainingAmount.toString() ?? '0';

      currency = widget.currency ?? 'MMK';
      _paymentDateController.text =
          DateFormat('yyyy-MM-dd').format(DateTime.now());
    } catch (e) {
      print('Error initializing form: $e s');
    }
  }

  void _clearForm() {
    setState(() {
      _paymentAmountController.clear();
      _paidPersonController.clear();
      _receivePersonController.clear();
      _paymentNoteController.clear();
      _selectedPaymentMethod = null;
    });
  }

  void _initializeForm() async {
    
    _paymentDateController.text =
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Populate fields from the advance request or payment object
    if (widget.isEditMode || widget.isViewMode) {
      // Logic for editing/viewing existing payments
      final cash = widget.payment!;
      _paymentDateController.text = DateFormat('yyyy-MM-dd').format(cash.date);
      _paymentNoController.text = cash.paymentNo;
      _requestNoController.text = cash.requestNo;
      _requestTypeController.text = cash.requestType;
      _paymentAmountController.text = cash.paymentAmount.toString();
      _selectedPaymentMethod = cash.paymentMethod;
      _paidPersonController.text = cash.paidPerson;
      _receivePersonController.text = cash.receivedPerson;
      _paymentNoteController.text = cash.paymentNote;
      // You would also need to fetch and set the other request-related fields here
      // For this example, we'll assume they are part of the `payment` object or fetched separately.
    } else {
      // Logic for a new payment from an advance request
      _requestNoController.text = widget.requestNo ?? "";
      _requestTypeController.text = widget.requestType ?? "";
      _requestDateController.text = widget.requestDate != null
          ? DateFormat('yyyy-MM-dd').format(widget.requestDate!)
          : "";
      _requestCodeController.text = widget.requestCode ?? "";
      _requestAmountController.text = widget.requestAmount?.toString() ?? "0";
      _descriptionController.text = widget.description ?? "";
      _purposeController.text = widget.purpose ?? "";
      _requesterController.text = widget.requester ?? "";
      _approvedAmountController.text = widget.approveAmount?.toString() ?? "0";

      double totalWithdrawn = 0.0;
      double remainingAmount = (widget.approveAmount ?? 0.0) - totalWithdrawn;
      _totalWithdrawnController.text = totalWithdrawn.toString();
      _remainingAmountController.text = remainingAmount.toString();
    }
  }

  void _generatePaymentNo() {
    int lastPaymentNo = 1;
    _paymentNoController.text =
        'Pay_${lastPaymentNo.toString().padLeft(3, '0')}';
  }

  Future<String> generateCashpaymentID() async {
    try {
      List<Payment> existingPayment = await ApiService().fetchPayments();

      if (existingPayment.isEmpty) {
        return "1";
      }

      int maxId = existingPayment
          .map((b) => int.tryParse(b.id.toString()) ?? 0)
          .reduce((a, b) => a > b ? a : b);
      return (maxId + 1).toString();
    } catch (e) {
      print("Error generating string Payment ID: $e");
      throw Exception('Failed to generate Payment ID');
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String newId = widget.isEditMode
          ? widget.payment!.id
          : await generateCashpaymentID();
      try {
        Payment newPayment = Payment(
          id: newId,
          date: DateFormat('yyyy-MM-dd').parse(_paymentDateController.text),
          paymentNo: _paymentNoController.text,
          requestNo: _requestNoController.text,
          requestType: _requestTypeController.text,
          paymentAmount: double.tryParse(_paymentAmountController.text) ?? 0,
          currency: currency,
          paymentMethod: _selectedPaymentMethod!,
          paidPerson: _paidPersonController.text,
          receivedPerson: _receivePersonController.text,
          paymentNote: _paymentNoteController.text,
          status: 'Draft',
          settled: 'No',
        );

        if (widget.isEditMode) {
          await apiService.updatePayment(newPayment);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment updated successfully')),
          );
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => CashPaymentPage()));
        } else {
          await apiService.postPayment(newPayment);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Cashpayment Data saved successfully!!")),
          );
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => CashPaymentPage()));
        }
      } catch (e) {
        print("Fail to save cash payment: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        title: Text(widget.isViewMode
            ? 'Cash Payment Details'
            : widget.isEditMode
                ? 'Edit Cash Payment'
                : 'Add Cash Payment'),
        // toolbarHeight: 35,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(16),
          width: 800,
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      widget.isViewMode
                          ? 'Cash Payment Details'
                          : widget.isEditMode
                              ? 'Edit Cash Payment'
                              : 'Add Cash Payment',
                      style:
                          const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _paymentNoController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Payment No",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _paymentDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Payment Date",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    color: const Color(0xFFEADCDC),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          "Payment Refrence",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _requestNoController,
                                decoration: const InputDecoration(
                                    labelText: "Request No",
                                    border: OutlineInputBorder()),
                                // readOnly: true,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _requesterController,
                                decoration: const InputDecoration(
                                    labelText: "Requester",
                                    border: OutlineInputBorder()),
                                readOnly: true,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _requestDateController,
                                decoration: const InputDecoration(
                                    labelText: "Request Date",
                                    border: OutlineInputBorder()),
                                readOnly: true,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _requestCodeController,
                                decoration: const InputDecoration(
                                    labelText: "Request Code",
                                    border: OutlineInputBorder()),
                                // readOnly: true,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _descriptionController,
                                decoration: const InputDecoration(
                                    labelText: "Description",
                                    border: OutlineInputBorder()),
                                readOnly: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _purposeController,
                                decoration: const InputDecoration(
                                    labelText: "Request Purpose",
                                    border: OutlineInputBorder()),
                                readOnly: true,
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: _requestTypeController,
                                decoration: const InputDecoration(
                                    labelText: "Request Type",
                                    border: OutlineInputBorder()),
                                readOnly: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _requestAmountController,
                                decoration: const InputDecoration(
                                    labelText: "Approved Amount",
                                    border: OutlineInputBorder()),
                                readOnly: true,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _totalWithdrawnController,
                                decoration: const InputDecoration(
                                    labelText: "Total Withdrawn Amount",
                                    border: OutlineInputBorder()),
                                readOnly: true,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _remainingAmountController,
                                decoration: const InputDecoration(
                                    labelText: "Remaining Amount",
                                    border: OutlineInputBorder()),
                                readOnly: true,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Payment Method",
                          ),
                          value: _selectedPaymentMethod,
                          items: ['Cash', 'Bank', 'Cheque']
                              .map((selected) => DropdownMenuItem(
                                    value: selected,
                                    child: Text(selected),
                                  ))
                              .toList(),
                          onChanged: widget.isViewMode
                              ? null
                              : (value) {
                                  if (value is String) {
                                    setState(() {
                                      _selectedPaymentMethod = value;
                                    });
                                  }
                                },
                          validator: (value) {
                            if (value == null || value.toString().isEmpty) {
                              return "Choose Payment Method";
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _paymentAmountController,
                          readOnly: widget.isViewMode,
                          decoration: InputDecoration(
                            labelText: "Payment Amount",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter Total Amount";
                            }
                            final amount = double.tryParse(value);
                            if (amount == null) {
                              return "Enter a valid amount";
                            }
                            if (amount <= 0) {
                              return "payment Amount must be greater than 0";
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(),
                        child: Text(
                          currency,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _paidPersonController,
                          readOnly: widget.isViewMode,
                          decoration: InputDecoration(
                            labelText: "Paid Person",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value){
                              if (value==null || value.isEmpty) {
                                return "Enter Payment Note";
                              }
                              return null;
                            },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _receivePersonController,
                          readOnly: widget.isViewMode,
                          decoration: InputDecoration(
                            labelText: "Received Person",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value){
                              if (value==null || value.isEmpty) {
                                return "Enter Payment Note";
                              }
                              return null;
                            },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                            controller: _paymentNoteController,
                            readOnly: widget.isViewMode,
                            decoration: InputDecoration(
                              labelText: "Payment Note",
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value){
                              if (value==null || value.isEmpty) {
                                return "Enter Payment Note";
                              }
                              return null;
                            },
                            maxLines: 2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (!widget.isViewMode) Center(child: _buildSubmitButton()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB2C8A8),
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(widget.isEditMode ? 'Update' : 'Submit'),
            ),
            const SizedBox(
              width: 15,
            ),
            ElevatedButton(
              onPressed: _clearForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB2C8A8),
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Clear'),
            ),
          ],
        ),
      ),
    );
  }
}
