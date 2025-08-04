import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoGridPagination extends StatefulWidget {
  final PlutoGridStateManager stateManager;
  final int totalRows;
  final int rowsPerPage;
  final Function(int page, int rowsPerPage) onPageChanged;

  const PlutoGridPagination({
    Key? key,
    required this.stateManager,
    required this.totalRows,
    this.rowsPerPage = 10,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  State<PlutoGridPagination> createState() => _PlutoGridPaginationState();
}

class _PlutoGridPaginationState extends State<PlutoGridPagination> {
  late int _currentPage;
  late int _rowsPerPage;

  @override
  void initState() {
    super.initState();
    _currentPage = 1;
    _rowsPerPage = widget.rowsPerPage;
  }

  int get _totalPages => (widget.totalRows / _rowsPerPage).ceil();

  void _goToPage(int page) {
    if (page >= 1 && page <= _totalPages) {
      setState(() {
        _currentPage = page;
      });
      widget.onPageChanged(_currentPage, _rowsPerPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
            ),
            Text('Page $_currentPage of $_totalPages'),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed:
                  _currentPage < _totalPages ? () => _goToPage(_currentPage + 1) : null,
            ),
          ],
        ),
        DropdownButton<int>(
          value: _rowsPerPage,
          items: [10, 20, 50, 100]
              .map((e) => DropdownMenuItem(child: Text('$e rows'), value: e))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _rowsPerPage = value;
                _currentPage = 1;
              });
              widget.onPageChanged(_currentPage, _rowsPerPage);
            }
          },
        ),
        
      ],
    );
  }
}

