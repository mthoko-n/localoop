import 'dart:async';
import 'package:flutter/material.dart';
import '../home/home.dart';
import '../login/login.dart';
import '../profile/profile.dart'; 
import '../../../services/api_client.dart';
import '../../../services/auth_service.dart';

class MainNavigation extends StatefulWidget {
  final ApiClient apiClient;

  const MainNavigation({super.key, required this.apiClient});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  int _selectedIndex = 0;
  
  late StreamSubscription<bool> _authSubscription;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    // Initialize AuthService
    await AuthService().initialize();
    
    // Listen to auth state changes
    _authSubscription = AuthService().authStateStream.listen((isAuthenticated) {
      if (mounted) {
        setState(() {
          _isAuthenticated = isAuthenticated;
          if (!isAuthenticated) {
            _selectedIndex = 0; // Reset to home tab on logout
          }
        });
      }
    });

    // Set initial state
    setState(() {
      _isAuthenticated = AuthService().isAuthenticated;
      _isLoading = false;
    });
  }

  void _onLoginSuccess() {
    // AuthService will handle the state update via stream
    // No need to manually setState here
  }

  void _onTabSelected(int index) => setState(() => _selectedIndex = index);

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAuthenticated) {
      return LoginScreen(
        onLoginSuccess: _onLoginSuccess,
        apiClient: widget.apiClient, 
      );
    }

    final screens = [
      HomeScreen(apiClient: widget.apiClient),
      const Center(child: Text('Notifications (not implemented)')),
      ProfileScreen(apiClient: widget.apiClient), 
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}