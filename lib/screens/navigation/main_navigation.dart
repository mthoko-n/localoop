import 'dart:async';
import 'package:flutter/material.dart';
import '../home/home.dart';
import '../login/login.dart';
import '../profile/profile.dart';
import '../admin/admin_screen.dart'; // You'll need to create this
import '../../../services/api_client.dart';
import '../../../services/auth_service.dart';
import '../profile/services/profile_api_service.dart';

class MainNavigation extends StatefulWidget {
  final ApiClient apiClient;

  const MainNavigation({super.key, required this.apiClient});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  bool _isAdmin = false; // Track admin status
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
            _isAdmin = false; // Reset admin status
          }
        });
        
        // Check admin status when user logs in
        if (isAuthenticated) {
          _checkAdminStatus();
        }
      }
    });

    // Set initial state
    setState(() {
      _isAuthenticated = AuthService().isAuthenticated;
      _isLoading = false;
    });
    
    // Check admin status if already authenticated
    if (_isAuthenticated) {
      _checkAdminStatus();
    }
  }

  Future<void> _checkAdminStatus() async {
    try {
      final profileService = ProfileApiService(api: widget.apiClient);
      final profile = await profileService.getUserProfile();
      if (mounted) {
        setState(() {
          _isAdmin = profile.isAdmin;
        });
      }
    } catch (e) {
      // If profile fetch fails, assume not admin
      if (mounted) {
        setState(() {
          _isAdmin = false;
        });
      }
    }
  }

  void _onLoginSuccess() {
    // AuthService will handle the state update via stream
    // Admin status will be checked automatically in the listener
  }

  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index);
  }

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

    // Build screens array dynamically based on admin status
    final screens = [
      HomeScreen(apiClient: widget.apiClient),
      const Center(child: Text('Notifications (not implemented)')),
      ProfileScreen(apiClient: widget.apiClient),
      if (_isAdmin) AdminScreen(apiClient: widget.apiClient),
    ];

    // Build navigation items dynamically
    final navItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home), 
        label: 'Home'
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.notifications), 
        label: 'Notifications'
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person), 
        label: 'Profile'
      ),
      if (_isAdmin) const BottomNavigationBarItem(
        icon: Icon(Icons.admin_panel_settings), 
        label: 'Admin'
      ),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: _isAdmin ? BottomNavigationBarType.fixed : BottomNavigationBarType.shifting,
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
        items: navItems,
      ),
    );
  }
}