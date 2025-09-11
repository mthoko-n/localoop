import 'package:flutter/material.dart';
import 'package:localoop/theme/colours.dart';

class AddLocationCard extends StatelessWidget {
  final VoidCallback onTap;

  const AddLocationCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      key: key,
      child: ListTile(
        leading: const Icon(Icons.add),
        title: const Text('Add Location'),
        onTap: onTap,
      ),
    );
  }
}
