import 'package:flutter/material.dart';

class CommonActionButtons extends StatelessWidget {
  final VoidCallback? onAdd;
  final VoidCallback? onRefresh;
  final VoidCallback? onDownload;

  const CommonActionButtons({
    Key? key,
    this.onAdd,
    this.onRefresh,
    this.onDownload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onAdd != null)
          IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            color: Colors.black,
            tooltip: "Add",
          ),
        if (onRefresh != null)
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            color: Colors.black,
            tooltip: "Refresh",
          ),
        if (onDownload != null)
          IconButton(
            onPressed: onDownload,
            icon: const Icon(Icons.download),
            color: Colors.black,
            tooltip: "Download",
          ),
      ],
    );
  }
}
