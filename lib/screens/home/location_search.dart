import 'package:flutter/material.dart';
import 'model/location.dart';
import 'services/home_api_service.dart';
import 'model/search_result.dart';

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final _searchController = TextEditingController();
  List<Location> _results = [];
  bool _isLoading = false;

  void _search(String query) async {
    if (query.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final results = await HomeApiService().searchLocations(query);
      setState(() => _results = results);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Search failed: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _selectLocation(Location loc) {
    Navigator.pop(context, loc); // return selected location to home.dart
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Locations')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                  hintText: 'Search locations...',
                  prefixIcon: Icon(Icons.search)),
              onChanged: _search,
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final loc = _results[index];
                return ListTile(
                  title: Text(loc.name),
                  subtitle: Text('ID: ${loc.id}'),
                  onTap: () => _selectLocation(loc),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
