import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../services/mock_data_service.dart';
import 'home/home_screen.dart';
import 'scan/scan_job_screen.dart';
import 'career/career_hub_screen.dart';
import 'jobs/jobs_hub_screen.dart';
import 'security/security_tools_screen.dart';
import 'history/history_screen.dart';
import 'profile/profile_screen.dart';
import 'notifications/notification_screen.dart';
import 'ai/ai_assistant_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialTab;
  const MainScreen({Key? key, this.initialTab = 0}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final List<Widget> _pages = [
    const HomeScreen(),
    const ScanJobScreen(),
    const CareerHubScreen(),
    const JobsHubScreen(),
    const SecurityToolsScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
    const AiAssistantScreen(),
  ];

  void _switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  void _handleGlobalSearch(String query) {
    if (query.trim().isEmpty) return;
    final lower = query.toLowerCase().trim();
    if (lower.contains('scan') || lower.contains('scam') || lower.contains('verify') || lower.contains('check')) {
      _switchTab(1);
    } else if (lower.contains('resume') || lower.contains('ats') || lower.contains('career') || lower.contains('cover') || lower.contains('interview') || lower.contains('linkedin')) {
      _switchTab(2);
    } else if (lower.contains('job') || lower.contains('feed') || lower.contains('tracker') || lower.contains('apply')) {
      _switchTab(3);
    } else if (lower.contains('security') || lower.contains('tool') || lower.contains('phish') || lower.contains('url')) {
      _switchTab(4);
    } else if (lower.contains('history') || lower.contains('log')) {
      _switchTab(5);
    } else if (lower.contains('profile') || lower.contains('setting')) {
      _switchTab(6);
    } else {
      final service = Provider.of<MockDataService>(context, listen: false);
      service.sendAiMessage(query);
      _switchTab(7);
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<MockDataService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userName = service.name.isNotEmpty ? service.name : 'Alex Carter';

    return Scaffold(
      backgroundColor: const Color(0xFF070D1B),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isDesktop = constraints.maxWidth >= 900;

          if (isDesktop) {
            // ── DESKTOP / WEB FULL SIDEBAR LAYOUT (MATCHING IMAGE) ───────────
            return Row(
              children: [
                // 1. LEFT SIDEBAR NAVIGATION
                _buildDesktopSidebar(context, service),

                // 2. RIGHT MAIN CONTENT AREA
                Expanded(
                  child: Column(
                    children: [
                      // TOP HEADER BAR (Search + Notifications + User Profile)
                      _buildTopHeaderBar(context, userName, service),

                      // ACTIVE CONTENT SCREEN
                      Expanded(
                        child: IndexedStack(
                          index: _currentIndex,
                          sizing: StackFit.expand,
                          children: _pages,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            // ── MOBILE / RESPONSIVE LAYOUT ───────────────────────────────────
            return Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: _buildTopHeaderBar(context, userName, service),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    sizing: StackFit.expand,
                    children: _pages,
                  ),
                ),
              ],
            );
          }
        },
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 900) return const SizedBox.shrink();

          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0D172E),
              border: Border(top: BorderSide(color: Color(0xFF1E2D4F))),
            ),
            child: SafeArea(
              child: SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _mobileNavItem(Icons.home_rounded, 'Home', 0),
                    _mobileNavItem(Icons.smart_toy_rounded, 'AI Help', 7),
                    _mobileNavItem(Icons.search_rounded, 'Scan', 1),
                    _mobileNavItem(Icons.business_center_rounded, 'Career', 2),
                    _mobileNavItem(Icons.work_rounded, 'Jobs', 3),
                    _mobileNavItem(Icons.person_rounded, 'Profile', 6),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── DESKTOP LEFT SIDEBAR (EXACT MATCH TO REFERENCE SCREENSHOT) ─────────────
  Widget _buildDesktopSidebar(BuildContext context, MockDataService service) {
    return Container(
      width: 230,
      decoration: const BoxDecoration(
        color: Color(0xFF091024),
        border: Border(
          right: BorderSide(color: Color(0xFF162342), width: 1.2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Logo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.shield_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'JobShield AI',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    'Check Before You Apply',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _sidebarItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  index: 0,
                ),
                _sidebarItem(
                  icon: Icons.smart_toy_rounded,
                  label: 'AI Assistant',
                  index: 7,
                ),
                _sidebarItem(
                  icon: Icons.search_rounded,
                  label: 'Scan Job',
                  index: 1,
                ),
                _sidebarItem(
                  icon: Icons.business_center_rounded,
                  label: 'Career',
                  index: 2,
                ),
                _sidebarItem(
                  icon: Icons.description_rounded,
                  label: 'Jobs',
                  index: 3,
                ),
                _sidebarItem(
                  icon: Icons.shield_outlined,
                  label: 'Security',
                  index: 4,
                ),
                _sidebarItem(
                  icon: Icons.history_rounded,
                  label: 'History',
                  index: 5,
                ),
                _sidebarItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                  index: 6,
                ),
              ],
            ),
          ),

          // Bottom Left "Stay Safe" Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D172E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1E2D4F)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield_rounded, color: Color(0xFF60A5FA), size: 16),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stay Safe',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Better decisions. Safer careers.',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _currentIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: InkWell(
        onTap: () => _switchTab(index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E3A8A) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(color: const Color(0xFF3B82F6).withOpacity(0.5))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── TOP HEADER BAR (SEARCH + NOTIFICATIONS + AVATAR) ───────────────────────
  Widget _buildTopHeaderBar(BuildContext context, String userName, MockDataService service) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF070D1B),
        border: Border(
          bottom: BorderSide(color: Color(0xFF162342), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF0D172E),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF1E2D4F)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: _handleGlobalSearch,
                      style: const TextStyle(fontSize: 13, color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Search jobs, features, or ask anything...',
                        hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),

          // Notification Bell Icon with Red Dot
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationScreen()),
            ),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0D172E),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1E2D4F)),
              ),
              child: Stack(
                children: [
                  const Icon(Icons.notifications_none_rounded, color: Color(0xFF94A3B8), size: 20),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),

          // User Profile Pill with Avatar & Name
          InkWell(
            onTap: () => _switchTab(6),
            borderRadius: BorderRadius.circular(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: service.profileImage.isNotEmpty
                      ? NetworkImage(service.profileImage)
                      : null,
                  backgroundColor: const Color(0xFF2563EB),
                  child: service.profileImage.isEmpty
                      ? Text(
                          userName.isNotEmpty ? userName[0] : 'A',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8), size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileNavItem(IconData icon, String label, int index) {
    final bool isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => _switchTab(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF64748B),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
