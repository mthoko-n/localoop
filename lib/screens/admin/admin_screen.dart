// lib/screens/admin/admin_screen.dart

import 'package:flutter/material.dart';
import '../../services/api_client.dart';
import 'services/admin_api_service.dart';
import 'model/admin_models.dart';
import 'widgets/admin_widgets.dart';

class AdminScreen extends StatefulWidget {
  final ApiClient apiClient;

  const AdminScreen({super.key, required this.apiClient});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with TickerProviderStateMixin {
  late final AdminApiService _api;
  late final TabController _tabController;

  // State management
  SystemMetrics? _metrics;
  UsersListResponse? _usersResponse;
  bool _isLoadingMetrics = true;
  bool _isLoadingUsers = false;
  String? _error;

  // Pagination
  int _currentPage = 1;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _api = AdminApiService(api: widget.apiClient);
    _tabController = TabController(length: 4, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadMetrics(),
      _loadUsers(),
    ]);
  }

  Future<void> _loadMetrics() async {
    try {
      setState(() {
        _isLoadingMetrics = true;
        _error = null;
      });

      final metrics = await _api.getSystemMetrics();
      
      if (mounted) {
        setState(() {
          _metrics = metrics;
          _isLoadingMetrics = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load metrics: $e';
          _isLoadingMetrics = false;
        });
      }
    }
  }

  Future<void> _loadUsers({int page = 1}) async {
    try {
      setState(() {
        _isLoadingUsers = true;
        if (page == 1) _error = null;
      });

      final response = await _api.getUsers(page: page, limit: _pageSize);
      
      if (mounted) {
        setState(() {
          _usersResponse = response;
          _currentPage = page;
          _isLoadingUsers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load users: $e';
          _isLoadingUsers = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadInitialData();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<bool> _confirmAction(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<String?> _getReasonDialog(String title, String prompt) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(prompt),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Enter reason (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
    return result;
  }

  // User Actions
  Future<void> _banUser(AdminUser user) async {
    final reason = await _getReasonDialog('Ban User', 'Reason for banning ${user.email}:');
    if (reason == null) return;

    final confirm = await _confirmAction(
      'Ban User',
      'Are you sure you want to ban ${user.email}?',
    );
    if (!confirm) return;

    try {
      final message = await _api.banUser(user.id, reason: reason);
      _showSnackBar(message);
      _loadUsers(page: _currentPage);
      _loadMetrics(); // Refresh metrics
    } catch (e) {
      _showSnackBar('Failed to ban user: $e', isError: true);
    }
  }

  Future<void> _unbanUser(AdminUser user) async {
    final confirm = await _confirmAction(
      'Unban User',
      'Are you sure you want to unban ${user.email}?',
    );
    if (!confirm) return;

    try {
      final message = await _api.unbanUser(user.id);
      _showSnackBar(message);
      _loadUsers(page: _currentPage);
      _loadMetrics();
    } catch (e) {
      _showSnackBar('Failed to unban user: $e', isError: true);
    }
  }

  Future<void> _promoteUser(AdminUser user) async {
    final confirm = await _confirmAction(
      'Promote User',
      'Are you sure you want to promote ${user.email} to admin?',
    );
    if (!confirm) return;

    try {
      final message = await _api.promoteUser(user.id);
      _showSnackBar(message);
      _loadUsers(page: _currentPage);
      _loadMetrics();
    } catch (e) {
      _showSnackBar('Failed to promote user: $e', isError: true);
    }
  }

  Future<void> _demoteUser(AdminUser user) async {
    final confirm = await _confirmAction(
      'Demote Admin',
      'Are you sure you want to remove admin status from ${user.email}?',
    );
    if (!confirm) return;

    try {
      final message = await _api.demoteUser(user.id);
      _showSnackBar(message);
      _loadUsers(page: _currentPage);
      _loadMetrics();
    } catch (e) {
      _showSnackBar('Failed to demote user: $e', isError: true);
    }
  }

  Future<void> _forceLogoutUser(AdminUser user) async {
    final confirm = await _confirmAction(
      'Force Logout',
      'Are you sure you want to force logout ${user.email}?',
    );
    if (!confirm) return;

    try {
      final message = await _api.forceLogoutUser(user.id);
      _showSnackBar(message);
    } catch (e) {
      _showSnackBar('Failed to logout user: $e', isError: true);
    }
  }

  Future<void> _forceLogoutAll() async {
    final confirm = await _confirmAction(
      'Force Logout All Users',
      'This will log out ALL users from ALL devices. This action cannot be undone. Continue?',
    );
    if (!confirm) return;

    try {
      final message = await _api.forceLogoutAllUsers();
      _showSnackBar(message);
      _loadMetrics(); // Refresh session count
    } catch (e) {
      _showSnackBar('Failed to logout all users: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.amber),
            SizedBox(width: 8),
            Text('Admin Dashboard'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.content_copy), text: 'Content'),
            Tab(icon: Icon(Icons.security), text: 'Security'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildUsersTab(),
          _buildContentTab(),
          _buildSecurityTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoadingMetrics)
              const LoadingCard()
            else if (_error != null)
              ErrorCard(message: _error!, onRetry: _loadMetrics)
            else if (_metrics != null)
              MetricsDashboard(metrics: _metrics!),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                _buildQuickActionCard(
                  'Force Logout All',
                  Icons.logout,
                  Colors.red,
                  _forceLogoutAll,
                ),
                _buildQuickActionCard(
                  'Refresh Data',
                  Icons.refresh,
                  Colors.blue,
                  _refreshData,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    return Column(
      children: [
        // Header with stats
        if (_metrics != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', '${_metrics!.users.total}', Icons.people),
                _buildStatItem('Active', '${_metrics!.users.active}', Icons.check_circle),
                _buildStatItem('Banned', '${_metrics!.users.banned}', Icons.block),
                _buildStatItem('Admins', '${_metrics!.users.admins}', Icons.admin_panel_settings),
              ],
            ),
          ),
        
        // Users list
        Expanded(
          child: _isLoadingUsers
              ? const Center(child: CircularProgressIndicator())
              : _usersResponse == null
                  ? ErrorCard(message: _error ?? 'Failed to load users', onRetry: () => _loadUsers())
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _usersResponse!.users.length,
                            itemBuilder: (context, index) {
                              final user = _usersResponse!.users[index];
                              return UserListItem(
                                user: user,
                                onBan: user.isActive ? () => _banUser(user) : null,
                                onUnban: !user.isActive ? () => _unbanUser(user) : null,
                                onPromote: !user.isAdmin && user.isActive ? () => _promoteUser(user) : null,
                                onDemote: user.isAdmin ? () => _demoteUser(user) : null,
                                onForceLogout: user.isActive ? () => _forceLogoutUser(user) : null,
                              );
                            },
                          ),
                        ),
                        
                        // Pagination
                        if (_usersResponse != null)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: PaginationControls(
                              pagination: _usersResponse!.pagination,
                              onPageChanged: (page) => _loadUsers(page: page),
                            ),
                          ),
                      ],
                    ),
        ),
      ],
    );
  }

  Widget _buildContentTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Content Moderation'),
          Text('Coming Soon', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSecurityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Security Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Force Logout All Users'),
              subtitle: const Text('Immediately log out all users from all devices'),
              trailing: ElevatedButton(
                onPressed: _forceLogoutAll,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Execute'),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          if (_metrics != null) ...[
            Text(
              'Current Sessions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.devices, size: 32, color: Colors.blue),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_metrics!.sessions.activeSessions}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        Text(
                          'Active Sessions',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}