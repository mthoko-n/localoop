import 'package:flutter/material.dart';
import '../model/place_location.dart';
import '../../chat/conversations_screen.dart';
import 'package:localoop/services/api_client.dart'; 

class LocationCard extends StatelessWidget {
  final PlaceLocation placeLocation;
  final bool isEditing;
  final VoidCallback? onDelete;
  final ApiClient apiClient; 

  const LocationCard({
    super.key,
    required this.placeLocation,
    required this.isEditing,
    this.onDelete,
    required this.apiClient,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: isEditing ? null : () => _navigateToConversations(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Location Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.location_on,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Location Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      placeLocation.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      '${placeLocation.coordinates.latitude.toStringAsFixed(4)}, ${placeLocation.coordinates.longitude.toStringAsFixed(4)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Edit/Delete button or Arrow
              if (isEditing)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToConversations(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationsScreen(
          locationId: placeLocation.placeId,
          locationName: placeLocation.name,
          locationCoordinates: placeLocation.coordinates,
          apiClient: apiClient,
        ),
      ),
    );
  }
}
