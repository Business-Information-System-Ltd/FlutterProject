import 'package:advance_budget_request_system/views/data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:advance_budget_request_system/views/api_service.dart';

class TripRequestForm extends StatefulWidget {
  final Trips? trip;
  final bool isEditMode;
  final bool isViewMode;
  final UserModel currentUser;
  final String tripId;

  const TripRequestForm(
      {Key? key,
      this.trip,
      this.isEditMode = false,
      this.isViewMode = false,
      required this.currentUser,
      required this.tripId})
      : super(key: key);

  @override
  _TripRequestFormState createState() => _TripRequestFormState();
}

class _TripRequestFormState extends State<TripRequestForm> {
  int? _expenditureOption = 0;
  bool _directAdvanceRequest = false;
  PlutoGridStateManager? _stateManager;
  final _formKey = GlobalKey<FormState>();

  late List<PlutoColumn> _columns;
  late List<PlutoRow> _rows;

  final TextEditingController _name = TextEditingController();
  final TextEditingController _tripDescription = TextEditingController();
  final TextEditingController _source = TextEditingController();
  final TextEditingController _destination = TextEditingController();
  final TextEditingController _departureDate = TextEditingController();
  final TextEditingController _returnDate = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _tripCodeController = TextEditingController();

  // Form fields
  bool _isForOtherPerson = false;
  bool _isRoundTrip = false;

  String? _department;
  String _currency = 'MMK';

  // Budget data
  List<Budgets> _budgets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadBudgets();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  void _initializeForm() {
    if (widget.isEditMode || widget.isViewMode) {
      final trip = widget.trip!;
      _isForOtherPerson = trip.departmentName != widget.currentUser.department;
      _name.text =
          _isForOtherPerson ? trip.requesterName : widget.currentUser.name;
      _department = trip.departmentName;
      _tripDescription.text = trip.tripDescription;
      _isRoundTrip = _determineIfRoundTrip(trip);
      _currency = trip.currency;
      // _totalAmount.text = trip.totalAmount; // Remove this line, as _totalAmount is a getter, not a controller
      _budgets = trip.budgets ?? [];
      _dateController.text = DateFormat('yyyy-MM-dd').format(trip.date);
      _tripCodeController.text = trip.tripCode;
      _source.text = trip.source;
      _destination.text = trip.destination;
      _departureDate.text = DateFormat('yyyy-MM-dd').format(trip.departureDate);
      _returnDate.text = DateFormat('yyyy-MM-dd').format(trip.returnDate);
      _isForOtherPerson=trip.otherPerson;
      _isRoundTrip= trip.roundTrip;
      _directAdvanceRequest=trip.directAdvanceReq;
      _expenditureOption=trip.expenditureOption;
    } else {
      _name.text = widget.currentUser.name;
      _department = widget.currentUser.department;
    }

    _initializeTableColumns();
    _initializeTableRows();
  }

  bool _determineIfRoundTrip(Trips trip) {
    return true; // Placeholder
  }


  void _loadBudgets() async {
    try {
      List<Budgets> budgets = await ApiService().fetchBudgets();
      setState(() {
        _budgets = budgets;
        _isLoading = false;
        _updateTableData();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load budgets: $e')),
      );
    }
  }

  void _initializeTableColumns() {
    _columns = [
      PlutoColumn(
        title: 'Expense',
        field: 'expense',
        type: PlutoColumnType.select(
            _budgets.map((b) => b.budgetDescription).toList()),
        width: 150,
        enableEditingMode: !widget.isViewMode,
      ),
      PlutoColumn(
        title: 'Rate',
        field: 'rate',
        type: PlutoColumnType.number(),
        width: 100,
        enableEditingMode: !widget.isViewMode,
      ),
      PlutoColumn(
        title: 'Qty',
        field: 'qty',
        type: PlutoColumnType.number(),
        width: 80,
        enableEditingMode: false,
      ),
      PlutoColumn(
        title: 'Total Amount',
        field: 'total',
        type: PlutoColumnType.number(),
        width: 120,
        enableEditingMode: false,
        textAlign: PlutoColumnTextAlign.right,
        titleTextAlign: PlutoColumnTextAlign.right,
        footerRenderer: (rendererContext) {
          return PlutoAggregateColumnFooter(
            rendererContext: rendererContext,
            type: PlutoAggregateColumnType.sum,
            alignment: Alignment.centerRight,
          );
        },
      ),
    ];
  }


  void _initializeTableRows() {
    _rows = [];

    if (_isRoundTrip) {
      _rows.add(_createExpenseRow('Ticket', qty: 2));
      _rows.add(_createExpenseRow('Local Transport', qty: 4));
    } else {
      _rows.add(_createExpenseRow('Ticket', qty: 1));
      _rows.add(_createExpenseRow('Local Transport', qty: 2));
    }

    _rows.add(_createExpenseRow('Peridium'));

    if (widget.isEditMode || widget.isViewMode) {
      _populateExistingTripData();
    }
  }

  PlutoRow _createExpenseRow(String expense, {int qty = 1}) {
    final budget = _budgets.firstWhere(
      (b) => b.budgetDescription == expense,
      orElse: () => Budgets(
        id: "0",
        budgetCode: '',
        budgetDescription: expense,
        intialAmount: 0,
      ),
    );
    final amount = budget.intialAmount;
    final total = amount * qty;

    return PlutoRow(
      cells: {
        'expense': PlutoCell(value: expense),
        'rate': PlutoCell(
          value: amount,
          // valueFormatted: NumberFormat('#,##0.00').format(amount),
        ),
        'qty': PlutoCell(value: qty),
        'total': PlutoCell(
          value: total,
          // valueFormatted: NumberFormat('#,##0.00').format(total),
        ),
      },
    );
  }

  void _populateExistingTripData() {
    // Implement logic to populate table with existing trip budget data
  }

  int _calculateTripDays() {
    if (_departureDate.text.isEmpty || _returnDate.text.isEmpty) return 1;

    try {
      final departure = DateFormat('yyyy-MM-dd').parse(_departureDate.text);
      final returnDate = DateFormat('yyyy-MM-dd').parse(_returnDate.text);
      return returnDate.difference(departure).inDays +
          1; // +1 to include both start and end days
    } catch (e) {
      return 1;
    }
  }

  // void _updateTableData() {
  //   if (_isRoundTrip) {
  //     _updateRowQuantity('Ticket', 2);
  //     _updateRowQuantity('Local Transport', 4);
  //   } else {
  //     _updateRowQuantity('Ticket', 1);
  //     _updateRowQuantity('Local Transport', 2);
  //   }

  //   // if (_departureDate != null && _returnDate != null) {
  //   //   final days = _returnDate!.difference(_departureDate!).inDays + 1;
  //   //   _updateRowQuantity('Peridium', days);
  //   // }

  //   _recalculateTotals();
  // }
  void _updateTableData() {
    final days = _calculateTripDays();

    // Update Peridium quantity
    final peridiumRow = _rows.firstWhere(
      (r) => r.cells['expense']?.value == 'Peridium',
      orElse: () => PlutoRow(cells: {}),
    );

    if (peridiumRow.cells.isNotEmpty) {
      peridiumRow.cells['qty']?.value = days;
      _recalculateRowTotal(peridiumRow);
    }

    // Update round trip quantities if needed
    if (_isRoundTrip) {
      _updateRowQuantity('Ticket', 2);
      _updateRowQuantity('Local Transport', 4);
    } else {
      _updateRowQuantity('Ticket', 1);
      _updateRowQuantity('Local Transport', 2);
    }

    _recalculateTotals();
  }

  void _updateRowQuantity(String expense, int qty) {
    final row = _rows.firstWhere(
      (r) => r.cells['expense']?.value == expense,
      orElse: () => PlutoRow(cells: {}),
    );

    if (row.cells.isNotEmpty) {
      row.cells['qty']?.value = qty;
      _recalculateRowTotal(row);
    }
  }

  void _recalculateRowTotal(PlutoRow row) {
    final rate = row.cells['rate']?.value ?? 0;
    final qty = row.cells['qty']?.value ?? 0;
    final total = rate * qty;
    row.cells['total']?.value = total;
  

    // If you want to format the display, handle it in the UI when displaying the value.
    // row.cells['total']?.valueFormatted = NumberFormat('#,##0.00').format(total);
  }

  void _recalculateTotals() {
    for (final row in _rows) {
      _recalculateRowTotal(row);
    }
    if (_stateManager?.rows.isNotEmpty ?? false) {
      _stateManager?.notifyListeners();
    }
  }

  double get _totalAmount {
    return _rows.fold(0, (sum, row) => sum + (row.cells['total']?.value ?? 0));
  }

  final ApiService apiService = ApiService();

  // Future<int> generateTripID() async {
  //   List<Trips> existingTrip = await apiService.fetchTrips();

  //   if (existingTrip.isEmpty) {
  //     return 1;
  //   }
  //   int maxId = existingTrip.map((b) => b.id).reduce((a, b) => a > b ? a : b);
  //   return maxId + 1;
  // }
  Future<String> generateStringBudgetID() async {
  try {
    List<Budgets> existingBudgets = await ApiService().fetchBudgets();

    if (existingBudgets.isEmpty) {
      return "1";
    }

    // Get the highest ID
    int maxId = existingBudgets.map((b) => int.tryParse(b.id.toString()) ?? 0).reduce((a, b) => a > b ? a : b);
    return (maxId + 1).toString(); // return as String
  } catch (e) {
    print("Error generating string budget ID: $e");
    throw Exception('Failed to generate budget ID');
  }
}

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    String newId = widget.isEditMode ? widget.trip!.id : await generateStringBudgetID();
    Trips newTrip = Trips(
        id: newId,
        date: DateFormat('yyyy-MM-dd').parse(_dateController.text),
        tripCode: _tripCodeController.text,
        tripDescription: _tripDescription.text,
        source: _source.text,
        destination: _destination.text,
        departureDate: _departureDate.text.isNotEmpty
            ? DateFormat('yyyy-MM-dd').parse(_departureDate.text)
            : DateTime.now(),
        returnDate: _returnDate.text.isNotEmpty
            ? DateFormat('yyyy-MM-dd').parse(_returnDate.text)
            : DateTime.now(),
        otherPerson: _isForOtherPerson,
        roundTrip: _isRoundTrip,
        directAdvanceReq: _directAdvanceRequest,
        expenditureOption: _expenditureOption!,
        requesterName: _name.text,
        totalAmount: _totalAmount,
        currency: _currency,
        approvedAmount: 0,
        status: 'pending',
        departmentId: _getDepartmentId(),
        departmentName: _department!,
        budgets: _getBudgetDetails());

    try {
      if (widget.isEditMode) {
        await ApiService().updateTrip(newTrip);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip updated successfully')),
        );
      } else {
        await ApiService().postTrips(newTrip);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip created successfully')),
        );
      }
    } catch (e) {
      print("Fail to insert trips: $e");
    }

    try {
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }




  int _getDepartmentId() {
    return 1; // Placeholder
  }

  List<Budgets> _getBudgetDetails() {
    return _rows.map((row) {
      return Budgets(
        id: "0",
        budgetCode: '',
        budgetDescription: row.cells['expense']?.value.toString() ?? '',
        intialAmount: row.cells['rate']?.value ?? 0,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        title: Text(widget.isViewMode
            ? 'Trip Details'
            : widget.isEditMode
                ? 'Edit Trip'
                : 'New Trip Request'),
        actions: widget.isViewMode
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TripRequestForm(
                          trip: widget.trip,
                          isEditMode: true,
                          currentUser: widget.currentUser,
                          tripId: widget.tripId,
                        ),
                      ),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                                child: Text("Add Trip Request Form",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold))),
                            _buildFormSection(),
                            if (!widget.isViewMode)
                              Center(child: _buildSubmitButton()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildFormSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _tripCodeController.text,
                    decoration: const InputDecoration(
                      labelText: 'Trip Code',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: widget.isViewMode,
                    onChanged: (value) => _tripCodeController.text = value,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'TripCode is required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Request Date',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onChanged: (value) => _destination.text = value,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Date is required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isForOtherPerson,
                  onChanged: widget.isViewMode
                      ? null
                      : (value) {
                          setState(() {
                            _isForOtherPerson = value ?? false;
                            if (!_isForOtherPerson) {
                              _name.text = widget.currentUser.name;
                              _department = widget.currentUser.department;
                            } else {
                              _name.text = "";
                              _department = null;
                            }
                          });
                        },
                ),
                const Text('Request for Other Person'),
              ],
            ),

            // const SizedBox(width: 20),
            const SizedBox(width: 10),

            // Name and Department in one row
            Row(
              children: [
                Expanded(
                  child: _buildNameField(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDepartmentField(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Trip Description
            _buildDescriptionField(),

            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isRoundTrip,
                  onChanged: widget.isViewMode
                      ? null
                      : (value) {
                          setState(() {
                            _isRoundTrip = value ?? false;
                            _updateTableData();
                          });
                        },
                ),
                const Text('Round Trip'),
              ],
            ),

            // Source and Destination in one row
            Row(
              children: [
                Expanded(
                  child: _buildSourceField(),
                ),
                const SizedBox(width: 16),
                Icon(_isRoundTrip ? Icons.compare_arrows : Icons.arrow_forward),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDestinationField(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDepartureDateField(),
                ),
                if (_isRoundTrip) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildReturnDateField(),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // Expenses Table
            Text('Expenses', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Container(
              height: 200,
              child: PlutoGrid(
                columns: _columns,
                rows: _rows,
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  _stateManager = event.stateManager;
                  _stateManager!.setShowColumnFooter(true);
                  _stateManager!.notifyListeners();
                },
                onChanged: (PlutoGridOnChangedEvent event) {
                  // Recalculate when any cell changes
                  if (event.row.cells.containsKey('rate') ||
                      event.row.cells.containsKey('qty')) {
                    _recalculateRowTotal(event.row);
                    _recalculateTotals();
                    
                  }
                },
                configuration: const PlutoGridConfiguration(
                  style: PlutoGridStyleConfig(
                    enableGridBorderShadow: true,
                    gridBorderColor: Colors.grey,
                  ),
                  columnSize: PlutoGridColumnSizeConfig(
                    autoSizeMode: PlutoAutoSizeMode.scale,
                  ),
                ),
                mode: widget.isViewMode
                    ? PlutoGridMode.readOnly
                    : PlutoGridMode.normal,
              ),
            ),

            const SizedBox(height: 16),

            // Currency and Total Amount
            Row(
              children: [
                SizedBox(
                  width: 150,
                  child: DropdownButtonFormField<String>(
                    value: _currency,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                      border: OutlineInputBorder(),
                    ),
                    items: ['MMK', 'USD']
                        .map((currency) => DropdownMenuItem(
                              value: currency,
                              child: Text(currency),
                            ))
                        .toList(),
                    onChanged: widget.isViewMode
                        ? null
                        : (value) => setState(() => _currency = value ?? 'MMK'),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Currency is required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: _buildTotalAmountField()),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildRadioOption(
                    value: 0,
                    label: 'Fixed Allowance',
                    groupValue: _expenditureOption,
                    onChanged: (value) {
                      setState(() {
                        _expenditureOption = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: _buildRadioOption(
                    value: 1,
                    label: 'Submit Statement of Expenditure Later',
                    groupValue: _expenditureOption,
                    onChanged: (value) {
                      setState(() {
                        _expenditureOption = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Checkbox(
                  value: _directAdvanceRequest,
                  onChanged: (bool? value) {
                    setState(() {
                      _directAdvanceRequest = value ?? false;
                    });
                  },
                ),
                const Text('Directly Advance Request for this trip'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      initialValue: _name.text,
      decoration: const InputDecoration(
        labelText: 'Name',
        border: OutlineInputBorder(),
      ),
      readOnly: widget.isViewMode || !_isForOtherPerson,
      onChanged: (value) => _name.text = value,
      validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
    );
  }

  Widget _buildDepartmentField() {
    if (widget.isViewMode || !_isForOtherPerson) {
      return TextFormField(
        initialValue: _department,
        decoration: const InputDecoration(
          labelText: 'Department',
          border: OutlineInputBorder(),
        ),
        readOnly: true,
      );
    }

    return DropdownButtonFormField<String>(
      value: _department,
      decoration: const InputDecoration(
        labelText: 'Department',
        border: OutlineInputBorder(),
      ),
      items: ['Admin', 'Engineering', 'Finance', 'HR', 'Operations']
          .map((dept) => DropdownMenuItem(
                value: dept,
                child: Text(dept),
              ))
          .toList(),
      onChanged: widget.isViewMode
          ? null
          : (value) => setState(() => _department = value ?? ''),
      validator: (value) =>
          value?.isEmpty ?? true ? 'Department is required' : null,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _tripDescription,
      decoration: const InputDecoration(
        labelText: 'Trip Description',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      readOnly: widget.isViewMode,
      onChanged: (value) => _tripDescription.text = value,
      validator: (value) =>
          value?.isEmpty ?? true ? 'Description is required' : null,
    );
  }

  Widget _buildSourceField() {
    return TextFormField(
      initialValue: _source.text,
      decoration: const InputDecoration(
        labelText: 'Source',
        border: OutlineInputBorder(),
      ),
      readOnly: widget.isViewMode,
      onChanged: (value) => _source.text = value,
      validator: (value) =>
          value?.isEmpty ?? true ? 'Source is required' : null,
    );
  }

  Widget _buildDestinationField() {
    return TextFormField(
      initialValue: _destination.text,
      decoration: const InputDecoration(
        labelText: 'Destination',
        border: OutlineInputBorder(),
      ),
      readOnly: widget.isViewMode,
      onChanged: (value) => _destination.text = value,
      validator: (value) =>
          value?.isEmpty ?? true ? 'Destination is required' : null,
    );
  }

  Widget _buildDepartureDateField() {
    return InkWell(
      onTap: widget.isViewMode
          ? null
          : () => _selectDate(context, isDeparture: true),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Departure Date',
          border: OutlineInputBorder(),
        ),
        child: Text(_departureDate.text.isNotEmpty
            ? '${DateFormat('yyyy-MM-dd').parse(_departureDate.text).toLocal()}'
                .split(' ')[0]
            : 'Select date'),
      ),
    );
  }

  Widget _buildReturnDateField() {
    return InkWell(
      onTap: widget.isViewMode
          ? null
          : () => _selectDate(context, isDeparture: false),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Return Date',
          border: OutlineInputBorder(),
        ),
        child: Text(_returnDate.text.isNotEmpty
            ? '${DateFormat('yyyy-MM-dd').parse(_returnDate.text).toLocal()}'
                .split(' ')[0]
            : 'Select date'),
      ),
    );
  }

  // Future<void> _selectDate(BuildContext context,
  //     {required bool isDeparture}) async {
  //   final picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime.now(),
  //     lastDate: DateTime.now().add(const Duration(days: 365)),
  //   );

  //   if (picked != null) {
  //     setState(() {
  //       if (isDeparture) {
  //         _departureDate.text = DateFormat('yyyy-MM-dd').format(picked);
  //         if (_isRoundTrip &&
  //             (_returnDate.text.isEmpty ||
  //                 DateFormat('yyyy-MM-dd')
  //                     .parse(_returnDate.text)
  //                     .isBefore(picked))) {
  //           final nextDay = picked.add(const Duration(days: 1));
  //           _returnDate.text = DateFormat('yyyy-MM-dd').format(nextDay);
  //         }
  //       } else {
  //         _returnDate.text = DateFormat('yyyy-MM-dd').format(picked);
  //       }
  //       _updateTableData();
  //     });
  //   }
  // }
  Future<void> _selectDate(BuildContext context,
      {required bool isDeparture}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _departureDate.text = DateFormat('yyyy-MM-dd').format(picked);
          if (_isRoundTrip &&
              (_returnDate.text.isEmpty ||
                  DateFormat('yyyy-MM-dd')
                      .parse(_returnDate.text)
                      .isBefore(picked))) {
            final nextDay = picked.add(const Duration(days: 1));
            _returnDate.text = DateFormat('yyyy-MM-dd').format(nextDay);
          }
        } else {
          _returnDate.text = DateFormat('yyyy-MM-dd').format(picked);
        }
        _updateTableData(); // This will recalculate everything
      });
    }
  }

  Widget _buildTotalAmountField() {
    return TextFormField(
      controller: TextEditingController(
        text: NumberFormat('#,##0.00').format(_totalAmount),
      ),
      decoration: const InputDecoration(
        labelText: 'Total Amount',
        border: OutlineInputBorder(),
      ),
      readOnly: true,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget _buildRadioOption({
    required int value,
    required String label,
    required int? groupValue,
    required ValueChanged<int?> onChanged,
  }) {
    return Row(
      children: [
        Radio<int>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
        ),
        Text(label),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(widget.isEditMode ? 'Update' : 'Submit'),
            ),
            ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Clear'),
            ),
          ],
        ),
      ),
    );
  }
}

class UserModel {
  final String name;
  final String department;

  UserModel({required this.name, required this.department});
}