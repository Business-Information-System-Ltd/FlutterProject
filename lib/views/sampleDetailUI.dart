import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trip Information',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TripInformationPage(),
    );
  }
}

class TripInformationPage extends StatelessWidget {
  const TripInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Trip Information'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Request Date & Department section
            _buildUnderlineTable(
              headers: ['Request Date', 'Department'],
              values: ['2025-06-26', 'Admin'],
            ),
            const SizedBox(height: 16),

            // Project Code & Description section
            _buildUnderlineTable(
              headers: ['Project Code', 'Description'],
              values: ['PRJ_000_001', 'Project - 1'],
            ),
            const SizedBox(height: 16),

            // Total Amount & Currency section
            _buildUnderlineTable(
              headers: ['Total Amount', 'Currency'],
              values: ['100,000', 'MMK'],
            ),
            const SizedBox(height: 24),

            // Budget Allocation section
            const Text(
              'Budget Allocation:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildUnderlineTable(
              headers: ['Budget Code', 'Budget Description'],
              values: ['B-1', 'For Expense'],
              showDivider: true,
              isHeader: true,
            ),
            _buildUnderlineTable(
              values: ['B-2', 'For Repair & Maintenance'],
              showDivider: true,
            ),
            _buildUnderlineTable(
              values: ['B-3', 'For Advertising'],
              showDivider: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnderlineTable({
    List<String>? headers,
    required List<String> values,
    bool showDivider = false,
    bool isHeader = false,
  }) {
    return Column(
      children: [
        if (headers != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    headers[0],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    headers[1],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                values[0],
                style: TextStyle(
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                values[1],
                style: TextStyle(
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        if (showDivider)
          const Divider(
            height: 24,
            thickness: 1,
            color: Colors.grey,
          ),
      ],
    );
  }
}