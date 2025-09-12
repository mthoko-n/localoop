import 'package:flutter/material.dart';
import 'package:localoop/theme/colours.dart';
import '../model/place_location.dart';

class LocationCard extends StatelessWidget {
  final PlaceLocation placeLocation;
  final bool isEditing;
  final VoidCallback onDelete;

  const LocationCard({
    super.key,
    required this.placeLocation,
    this.isEditing = false,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      key: key,
      child: ListTile(
        leading: const Icon(Icons.location_on),
        title: Text(placeLocation.name),
        subtitle: Text(placeLocation.address.isNotEmpty
            ? placeLocation.address
            : 'No address available'),
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
