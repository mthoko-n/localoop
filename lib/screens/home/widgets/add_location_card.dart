import 'package:flutter/material.dart';
import 'package:localoop/theme/colours.dart';

class AddLocationCard extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;

  const AddLocationCard({
    super.key, 
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      key: key,
      child: ListTile(
        leading: isLoading 
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
        title: Text(
          isLoading ? 'Adding Location...' : 'Add Location',
          style: TextStyle(
            color: isLoading 
                ? Colors.grey 
                : null,
          ),
        ),
        onTap: isLoading ? null : onTap,
        enabled: !isLoading,
      ),
    );
  }
}