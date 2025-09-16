import 'package:flutter/material.dart';
import 'widgets/location_card.dart';
import 'widgets/add_location_card.dart';
import 'location_search.dart';
import 'services/home_api_service.dart';
import 'model/place_location.dart';
import 'package:localoop/services/api_client.dart';

class HomeScreen extends StatefulWidget {
  final ApiClient apiClient;
  // Remove onAuthFailure since AuthService handles this automatically
  
  const HomeScreen({
    super.key,
    required this.apiClient,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeApiService _api;
  List<PlaceLocation> _locations = [];
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isAddingLocation = false;
  static const int maxLocations = 4;

  @override
  void initState() {
    super.initState();
    _api = HomeApiService(api: widget.apiClient);
    _fetchLocations();
  }

  Future<void> _fetchLocations() async {
    setState(() => _isLoading = true);
    try {
      final locations = await _api.getUserLocations();
      setState(() => _locations = locations ?? []);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load locations: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleEdit() => setState(() => _isEditing = !_isEditing);

  void _removeLocation(String placeId) async {
    try {
      await _api.removeLocation(placeId);
      setState(() => _locations.removeWhere((loc) => loc.placeId == placeId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location removed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove location: $e')),
      );
    }
  }

  void _addLocation() async {
    if (_locations.length >= maxLocations) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You can only join up to $maxLocations locations'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final newLocation = await Navigator.push<PlaceLocation>(
      context,
      MaterialPageRoute(builder: (_) => LocationSearchScreen(api: _api)),
    );

    if (newLocation != null) {
      setState(() => _isAddingLocation = true);

      try {
        final savedLocation = await _api.addLocation(
          newLocation.name,
          newLocation.coordinates.latitude,
          newLocation.coordinates.longitude,
        );

        setState(() => _locations.add(savedLocation));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        String errorMessage = 'Failed to add location';
        if (e.toString().contains('MAX_LOCATIONS_REACHED')) {
          errorMessage = 'You can only join up to $maxLocations locations';
        } else {
          errorMessage = 'Failed to add location: ${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isAddingLocation = false);
      }
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _locations.removeAt(oldIndex);
      _locations.insert(newIndex, item);
    });
  }

  Future<void> _refreshLocations() async => _fetchLocations();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Localoop'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: _toggleEdit,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshLocations,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshLocations,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(
                      child: ReorderableListView(
                        onReorder: _onReorder,
                        children: [
                          for (final location in _locations)
                           LocationCard(
                            key: ValueKey(location.placeId),
                            placeLocation: location,
                            isEditing: _isEditing,
                            onDelete: () => _removeLocation(location.placeId),
                            apiClient: widget.apiClient,
                          ),

                          if (_locations.length < maxLocations)
                            AddLocationCard(
                              key: const ValueKey('add_card'),
                              onTap: _isAddingLocation ? null : _addLocation,
                              isLoading: _isAddingLocation,
                            ),
                        ],
                      ),
                    ),
                    if (_isAddingLocation)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Adding location...'),
                          ],
                        ),
                      ),
                    Text(
                      '${_locations.length} of $maxLocations locations',
                      style: textTheme.bodyMedium?.copyWith(
                        color: _locations.length >= maxLocations
                            ? Colors.orange
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}