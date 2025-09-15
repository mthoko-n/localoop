import 'package:flutter/material.dart';
import '../model/place_location.dart';
import '../../chat/conversations_screen.dart';

class LocationCard extends StatelessWidget {
  final PlaceLocation placeLocation;
  final bool isEditing;
  final VoidCallback? onDelete;

  const LocationCard({
    super.key,
    required this.placeLocation,
    required this.isEditing,
    this.onDelete,
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
                    
                    // You can add more info here like address or distance
                    Text(
                      '${placeLocation.coordinates.latitude.toStringAsFixed(4)}, ${placeLocation.coordinates.longitude.toStringAsFixed(4)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Activity indicators (you'll get this from API later)
                    Row(
                      children: [
                        _buildActivityChip(
                          context,
                          icon: Icons.chat_bubble_outline,
                          label: '3 active', // This will come from API
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        _buildActivityChip(
                          context,
                          icon: Icons.circle,
                          label: '2 unread', // This will come from API  
                          color: Colors.orange,
                        ),
                      ],
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
        ),
      ),
    );
  }

  Widget _buildActivityChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}