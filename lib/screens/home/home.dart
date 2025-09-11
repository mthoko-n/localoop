import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/colours.dart';
import 'widgets/location_card.dart';
import 'widgets/add_location_card.dart';
import 'location_search.dart';
import 'services/home_api_service.dart';
import 'model/location.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeApiService _api = HomeApiService();
  List<Location> _locations = [];
  bool _isLoading = true;
  bool _isEditing = false;
  static const int maxLocations = 4;

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  Future<void> _fetchLocations() async {
    setState(() => _isLoading = true);
    try {
      final locations = await _api.getUserLocations();
      setState(() => _locations = locations);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load locations: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);
  }

  void _removeLocation(String id) async {
    try {
      await _api.removeLocation(id);
      setState(() => _locations.removeWhere((loc) => loc.id == id));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to remove location: $e')));
    }
  }

  void _addLocation() async {
    final newLocation = await Navigator.push<Location>(
      context,
      MaterialPageRoute(builder: (_) => const LocationSearchScreen()),
    );

    if (newLocation != null) {
      setState(() => _locations.add(newLocation));
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _locations.removeAt(oldIndex);
      _locations.insert(newIndex, item);
    });
  }

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
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: ReorderableListView(
                      onReorder: _onReorder,
                      children: [
                        for (final location in _locations)
                          LocationCard(
                            key: ValueKey(location.id),
                            location: location,
                            isEditing: _isEditing,
                            onDelete: () => _removeLocation(location.id),
                          ),
                        if (_locations.length < maxLocations)
                          AddLocationCard(
                            key: const ValueKey('add_card'),
                            onTap: _addLocation,
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '${_locations.length} of $maxLocations locations',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
    );
  }
}
