// import 'dart:async';

// import 'package:advance_budget_request_system/views/data.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class CustomSearchBar extends StatefulWidget {
//   final Function(String) onSearch;
//   final String hintText;
//   final double? minWidth;
//   final double? maxWidth;
//   final double? flex;

//   const CustomSearchBar({
//     Key? key,
//     required this.onSearch,
//     this.hintText = 'Search...',
//     this.minWidth = 300,
//     this.maxWidth,
//     this.flex,  
//     String? initialValue,
//   }) : super(key: key);

//   @override
//   _CustomSearchBarState createState() => _CustomSearchBarState();
// }

// class _CustomSearchBarState extends State<CustomSearchBar> {
//   final TextEditingController _controller = TextEditingController();
//   Timer? _debounce;

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     _controller.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged(String query) {
//     if (_debounce?.isActive ?? false) _debounce?.cancel();

//     _debounce = Timer(const Duration(milliseconds: 500), () {
//       widget.onSearch(query);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         double responsiveWidth =
//             constraints.maxWidth * 0.5; // Default to 50% of available space

//         if (widget.minWidth != null && responsiveWidth < widget.minWidth!) {
//           responsiveWidth = widget.minWidth!;
//         }
//         if (widget.maxWidth != null && responsiveWidth > widget.maxWidth!) {
//           responsiveWidth = widget.maxWidth!;
//         }

//         return Container(
//           constraints: BoxConstraints(
//             minWidth: widget.minWidth ?? 0,
//             maxWidth: widget.maxWidth ?? double.infinity,
//           ),
//           width: responsiveWidth,
//           child: _buildTextField(),
//         );
//       },
//     );
//   }

//   Widget _buildTextField() {
//     return TextField(
//       controller: _controller,
//       decoration: InputDecoration(
//         hintText: widget.hintText,
//         prefixIcon: const Icon(Icons.search),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         contentPadding: const EdgeInsets.symmetric(
//           vertical: 14,
//           horizontal: 16,
//         ),
//         isDense: true,
//         suffixIcon: _controller.text.isNotEmpty
//             ? IconButton(
//                 icon: const Icon(Icons.clear),
//                 onPressed: () {
//                   _controller.clear();
//                   widget.onSearch('');
//                 },
//               )
//             : null,
//       ),
//       onChanged: _onSearchChanged,
//     );
//   }
// }

// class SearchUtils {
//   static bool matchesSearchProject(Project project, String query) {
//     if (query.isEmpty) return true;

//     final lowerQuery = query.toLowerCase();
//     return project.projectCode.toLowerCase().contains(lowerQuery) ||
//         project.projectDescription.toLowerCase().contains(lowerQuery) ||
//         project.departmentName.toLowerCase().contains(lowerQuery) ||
//         project.currency.toLowerCase().contains(lowerQuery) ||
//         DateFormat('yyyy-MM-dd').format(project.date).contains(lowerQuery) ||
//         project.totalAmount.toString().contains(lowerQuery) ||
//         project.requestable.contains(lowerQuery);
//   }

//   static bool matchesSearchTrip(Trips trip, String query) {
//     if (query.isEmpty) return true;

//     final lowerQuery = query.toLowerCase();
//     return trip.tripCode.toLowerCase().contains(lowerQuery) ||
//         trip.tripDescription.toLowerCase().contains(lowerQuery) ||
//         trip.departmentName.toLowerCase().contains(lowerQuery) ||
//         trip.currency.toLowerCase().contains(lowerQuery) ||
//         DateFormat('yyyy-MM-dd').format(trip.date).contains(lowerQuery) ||
//         trip.totalAmount.toString().contains(lowerQuery);
//   }

//   static bool matchesSearchAdvance(Advance advances, String query) {
//     if (query.isEmpty) return true;

//     final lowerQuery = query.toLowerCase();
//     return (advances.requestNo?.toLowerCase() ?? '').contains(lowerQuery) ||
//         (advances.requestType?.toLowerCase() ?? '').contains(lowerQuery) ||
//         (advances.departmentName?.toLowerCase() ?? '').contains(lowerQuery) ||
//         (advances.currency?.toLowerCase() ?? '').contains(lowerQuery) ||
//         DateFormat('yyyy-MM-dd').format(advances.date).contains(lowerQuery) ||
//         (advances.requestCode?.toLowerCase() ?? '').contains(lowerQuery) ||
//         advances.requestAmount.toString().contains(lowerQuery);
//   }

//   static bool matchesSearchPayment(Payment payments, String query) {
//     if (query.isEmpty) return true;

//     final lowerQuery = query.toLowerCase();
//     return payments.requestNo.toLowerCase().contains(lowerQuery) ||
//         payments.requestType.toLowerCase().contains(lowerQuery) ||
//         payments.paymentNo.toLowerCase().contains(lowerQuery) ||
//         payments.currency.toLowerCase().contains(lowerQuery) ||
//         DateFormat('yyyy-MM-dd').format(payments.date).contains(lowerQuery) ||
//         payments.paymentMethod.toLowerCase().contains(lowerQuery) ||
//         payments.status.toLowerCase().contains(lowerQuery) ||
//         payments.paymentAmount.toString().contains(lowerQuery);
//   }

//   static bool matchesSearchSettlement(Settlement settlements, String query) {
//     if (query.isEmpty) return true;

//     final lowerQuery = query.toLowerCase();
//     return settlements.withdrawnAmount
//             .toString()
//             .toLowerCase()
//             .contains(lowerQuery) ||
//         settlements.paymentNo.toLowerCase().contains(lowerQuery) ||
//         settlements.refundAmount
//             .toString()
//             .toLowerCase()
//             .contains(lowerQuery) ||
//         DateFormat('yyyy-MM-dd')
//             .format(settlements.settlementDate)
//             .contains(lowerQuery) ||
//         settlements.settleAmount
//             .toString()
//             .toLowerCase()
//             .contains(lowerQuery) ||
//         settlements.settled.toString().toLowerCase().contains(lowerQuery);
//   }
// }

import 'dart:async';

import 'package:advance_budget_request_system/views/data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final String hintText;
  final double? minWidth;
  final double? maxWidth;
  final double? flex;
  final String? initialValue;

  const CustomSearchBar({
    Key? key,
    required this.onSearch,
    this.hintText = 'Search...',
    this.minWidth = 300,
    this.maxWidth,
    this.flex, 
    this.initialValue,
  }) : super(key: key);

  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();
 }
  class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void didUpdateWidget(covariant CustomSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller text when parent passes new initialValue
    if (widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearch(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double responsiveWidth = constraints.maxWidth * 0.5;

        if (widget.minWidth != null && responsiveWidth < widget.minWidth!) {
          responsiveWidth = widget.minWidth!;
        }
        if (widget.maxWidth != null && responsiveWidth > widget.maxWidth!) {
          responsiveWidth = widget.maxWidth!;
        }

        return Container(
          constraints: BoxConstraints(
            minWidth: widget.minWidth ?? 0,
            maxWidth: widget.maxWidth ?? double.infinity,
          ),
          width: responsiveWidth,
          child: _buildTextField(),
        );
      },
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        isDense: true,
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  widget.onSearch('');
                },
              )
            : null,
      ),
      onChanged: _onSearchChanged,
    );
  }
}

class SearchUtils {
  static bool matchesSearchProject(Project project, String query) {
    if (query.isEmpty) return true;

    final lowerQuery = query.toLowerCase();
    return project.projectCode.toLowerCase().contains(lowerQuery) ||
        project.projectDescription.toLowerCase().contains(lowerQuery) ||
        project.departmentName.toLowerCase().contains(lowerQuery) ||
        project.currency.toLowerCase().contains(lowerQuery) ||
        DateFormat('yyyy-MM-dd').format(project.date).contains(lowerQuery) ||
        project.totalAmount.toString().contains(lowerQuery) ||
        project.requestable.contains(lowerQuery);
  }

  static bool matchesSearchTrip(Trips trip, String query) {
    if (query.isEmpty) return true;

    final lowerQuery = query.toLowerCase();
    return trip.tripCode.toLowerCase().contains(lowerQuery) ||
        trip.tripDescription.toLowerCase().contains(lowerQuery) ||
        trip.departmentName.toLowerCase().contains(lowerQuery) ||
        trip.currency.toLowerCase().contains(lowerQuery) ||
        DateFormat('yyyy-MM-dd').format(trip.date).contains(lowerQuery) ||
        trip.totalAmount.toString().contains(lowerQuery);
  }

  static bool matchesSearchAdvance(Advance advances, String query) {
    if (query.isEmpty) return true;

    final lowerQuery = query.toLowerCase();
    return (advances.requestNo?.toLowerCase() ?? '').contains(lowerQuery) ||
        (advances.requestType?.toLowerCase() ?? '').contains(lowerQuery) ||
        (advances.departmentName?.toLowerCase() ?? '').contains(lowerQuery) ||
        (advances.currency?.toLowerCase() ?? '').contains(lowerQuery) ||
        DateFormat('yyyy-MM-dd').format(advances.date).contains(lowerQuery) ||
        (advances.requestCode?.toLowerCase() ?? '').contains(lowerQuery) ||
        advances.requestAmount.toString().contains(lowerQuery);
  }

  static bool matchesSearchPayment(Payment payments, String query) {
    if (query.isEmpty) return true;

    final lowerQuery = query.toLowerCase();
    return payments.requestNo.toLowerCase().contains(lowerQuery) ||
        payments.requestType.toLowerCase().contains(lowerQuery) ||
        payments.paymentNo.toLowerCase().contains(lowerQuery) ||
        payments.currency.toLowerCase().contains(lowerQuery) ||
        DateFormat('yyyy-MM-dd').format(payments.date).contains(lowerQuery) ||
        payments.paymentMethod.toLowerCase().contains(lowerQuery) ||
        payments.status.toLowerCase().contains(lowerQuery) ||
        payments.paymentAmount.toString().contains(lowerQuery);
  }

  static bool matchesSearchSettlement(Settlement settlements, String query) {
    if (query.isEmpty) return true;

    final lowerQuery = query.toLowerCase();
    return settlements.withdrawnAmount
            .toString()
            .toLowerCase()
            .contains(lowerQuery) ||
        settlements.paymentNo.toLowerCase().contains(lowerQuery) ||
        settlements.refundAmount
            .toString()
            .toLowerCase()
            .contains(lowerQuery) ||
        DateFormat('yyyy-MM-dd')
            .format(settlements.settlementDate)
            .contains(lowerQuery) ||
        settlements.settleAmount
            .toString()
            .toLowerCase()
            .contains(lowerQuery) ||
        settlements.settled.toString().toLowerCase().contains(lowerQuery);
  }
}
