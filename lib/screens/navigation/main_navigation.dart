import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../home/home.dart';
import '../login/login.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  final _storage = const FlutterSecureStorage();
  bool _isLoading = true;
  bool _isAuthenticated = false;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  // Check if token exists and is valid
  Future<void> _checkAuth() async {
    final token = await _storage.read(key: 'auth_token');

    bool isValid = false;

    if (token != null) {
      try {
        // Decode JWT and check expiration
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = json.decode(
              utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
          final exp = payload['exp'] as int;
          isValid = DateTime.now().millisecondsSinceEpoch ~/ 1000 < exp;
        }
      } catch (_) {
        isValid = false;
      }
    }

    setState(() {
      _isAuthenticated = isValid;
      _isLoading = false;

      // Clear invalid token
      if (!isValid) _storage.delete(key: 'auth_token');
    });
  }

  void _onLoginSuccess() {
    setState(() {
      _isAuthenticated = true;
    });
  }

  // Called when API returns 401 or token expires
  void _onAuthFailure() async {
    await _storage.delete(key: 'auth_token');
    setState(() {
      _isAuthenticated = false;
      _selectedIndex = 0;
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Show login screen if not authenticated
    if (!_isAuthenticated) {
      return LoginScreen(onLoginSuccess: _onLoginSuccess);
    }

    // Main navigation screens
    final screens = [
      HomeScreen(onAuthFailure: _onAuthFailure),
      const Center(child: Text('Notifications (not implemented)')),
      const Center(child: Text('Profile (not implemented)')),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
