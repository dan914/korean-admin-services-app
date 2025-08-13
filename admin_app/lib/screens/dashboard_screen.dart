import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ui/design_tokens.dart';
import '../providers/auth_provider.dart';
import '../providers/application_provider.dart';
import '../utils/session_manager.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    // Initialize session management
    SessionManager.instance.initialize(
      onSessionWarning: _showSessionWarning,
      onSessionExpired: _handleSessionExpired,
    );
  }
  
  void _showSessionWarning() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ 세션 만료 경고'),
        content: const Text('5분 후 자동으로 로그아웃됩니다.\n계속하시려면 "연장"을 클릭하세요.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _logout();
            },
            child: const Text('로그아웃'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              SessionManager.instance.extendSession();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('세션이 30분 연장되었습니다.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('연장'),
          ),
        ],
      ),
    );
  }
  
  void _handleSessionExpired() {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('세션이 만료되었습니다. 다시 로그인해주세요.'),
        backgroundColor: Colors.red,
      ),
    );
    _logout();
  }
  
  @override
  void dispose() {
    SessionManager.instance.dispose();
    super.dispose();
  }

  final List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.dashboard_rounded,
      label: '대시보드',
      route: '/dashboard',
    ),
    _NavItem(
      icon: Icons.description_rounded,
      label: '신청서 관리',
      route: '/applications',
    ),
    _NavItem(
      icon: Icons.webhook_rounded,
      label: 'Webhook 설정',
      route: '/webhooks',
    ),
    _NavItem(
      icon: Icons.download_rounded,
      label: '데이터 내보내기',
      route: '/export',
    ),
  ];

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('adminEmail');
    
    ref.read(authProvider.notifier).logout();
    
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    
    return Scaffold(
        backgroundColor: DesignTokens.bgDefault,
        body: Row(
          children: [
          // Sidebar for desktop
          if (isDesktop)
            _buildSidebar(),
          
          // Main content
          Expanded(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
      
      // Bottom navigation for mobile
      bottomNavigationBar: !isDesktop ? _buildBottomNav() : null,
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: DesignTokens.bgAlt,
        border: Border(
          right: BorderSide(
            color: DesignTokens.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DesignTokens.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '행정도우미',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.textPrimary,
                      ),
                    ),
                    Text(
                      '관리자 패널',
                      style: TextStyle(
                        fontSize: 12,
                        color: DesignTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Navigation items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = _selectedIndex == index;
                
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2,
                  ),
                  child: Material(
                    color: isSelected 
                        ? DesignTokens.primary.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () {
                        setState(() => _selectedIndex = index);
                        context.go(item.route);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 20,
                              color: isSelected 
                                  ? DesignTokens.primary
                                  : DesignTokens.textSecondary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected 
                                    ? FontWeight.w600 
                                    : FontWeight.normal,
                                color: isSelected 
                                    ? DesignTokens.primary
                                    : DesignTokens.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Logout button
          Container(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('로그아웃'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.danger.withOpacity(0.1),
                foregroundColor: DesignTokens.danger,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    final authState = ref.watch(authProvider);
    
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: DesignTokens.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            _navItems[_selectedIndex].label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: DesignTokens.textPrimary,
            ),
          ),
          const Spacer(),
          
          // Admin info
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: DesignTokens.bgAlt,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_circle,
                  size: 24,
                  color: DesignTokens.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  authState.adminEmail ?? 'Admin',
                  style: TextStyle(
                    fontSize: 14,
                    color: DesignTokens.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: _selectedIndex == 0 ? _buildDashboardContent() : _buildComingSoon(),
    );
  }

  Widget _buildDashboardContent() {
    final applications = ref.watch(applicationProvider);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                title: '총 신청서',
                value: '${applications.length}',
                icon: Icons.description_rounded,
                color: DesignTokens.primary,
              ),
              _buildStatCard(
                title: '오늘 접수',
                value: '${_getTodayCount(applications)}',
                icon: Icons.today_rounded,
                color: DesignTokens.success,
              ),
              _buildStatCard(
                title: '처리 대기',
                value: '${_getPendingCount(applications)}',
                icon: Icons.pending_rounded,
                color: DesignTokens.warning,
              ),
              _buildStatCard(
                title: '완료',
                value: '${_getCompletedCount(applications)}',
                icon: Icons.check_circle_rounded,
                color: DesignTokens.info,
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Recent applications
          Text(
            '최근 신청서',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: DesignTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DesignTokens.borderLight),
            ),
            child: applications.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(48),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox_rounded,
                            size: 64,
                            color: DesignTokens.textMuted,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '아직 접수된 신청서가 없습니다',
                            style: TextStyle(
                              fontSize: 16,
                              color: DesignTokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: applications.take(5).length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final app = applications[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: DesignTokens.primary.withOpacity(0.1),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: DesignTokens.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(app['name'] ?? '이름 없음'),
                        subtitle: Text(app['phone'] ?? '전화번호 없음'),
                        trailing: Text(
                          app['timestamp'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: DesignTokens.textMuted,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DesignTokens.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: color,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.textPrimary,
                ),
              ),
            ],
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: DesignTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoon() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction_rounded,
            size: 64,
            color: DesignTokens.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            '준비 중입니다',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: DesignTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '이 기능은 곧 사용 가능합니다',
            style: TextStyle(
              fontSize: 16,
              color: DesignTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() => _selectedIndex = index);
        context.go(_navItems[index].route);
      },
      type: BottomNavigationBarType.fixed,
      items: _navItems.map((item) => BottomNavigationBarItem(
        icon: Icon(item.icon),
        label: item.label,
      )).toList(),
    );
  }

  int _getTodayCount(List<Map<String, dynamic>> applications) {
    final today = DateTime.now();
    return applications.where((app) {
      final timestamp = app['timestamp'] as String?;
      if (timestamp == null) return false;
      // Simple date check - implement proper date parsing
      return timestamp.contains('${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}');
    }).length;
  }

  int _getPendingCount(List<Map<String, dynamic>> applications) {
    return applications.where((app) => app['status'] == 'pending').length;
  }

  int _getCompletedCount(List<Map<String, dynamic>> applications) {
    return applications.where((app) => app['status'] == 'completed').length;
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;

  _NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}