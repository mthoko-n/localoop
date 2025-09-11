import 'package:flutter/material.dart';
import 'package:localoop/theme/app_theme.dart';
import 'package:localoop/theme/colours.dart';
import '../model/location.dart';

class LocationCard extends StatelessWidget {
  final Location location;
  final bool isEditing;
  final VoidCallback onDelete;

  const LocationCard({
    super.key,
    required this.location,
    this.isEditing = false,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      key: key,
      child: ListTile(
        leading: const Icon(Icons.location_on),
        title: Text(location.name),
        subtitle: Text(location.status ?? 'No new messages'),
        trailing: isEditing
            ? IconButton(
                icon: const Icon(Icons.delete, color: AppColors.error),
                onPressed: onDelete,
              )
            : null,
      ),
    );
  }
}
