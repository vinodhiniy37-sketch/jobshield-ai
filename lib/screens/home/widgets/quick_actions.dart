import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../main_screen.dart';
import '../../report/report_scam_screen.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({Key? key}) : super(key: key);

  void _navigateToTab(BuildContext context, int tabIndex) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MainScreen(initialTab: tabIndex)),
      (route) => false,
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    String? subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 10.5,
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 8.5,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionCard(
              context: context,
              title: 'Scan Job',
              icon: Icons.shield_rounded,
              color: AppColors.primary,
              onTap: () => _navigateToTab(context, 1), // tab 1 = Scan
            ),
            const SizedBox(width: 6),
            _buildActionCard(
              context: context,
              title: 'AI Assistant',
              subtitle: 'Ask anything',
              icon: Icons.smart_toy_rounded,
              color: AppColors.info,
              onTap: () => _navigateToTab(context, 2), // tab 2 = AI
            ),
            const SizedBox(width: 6),
            _buildActionCard(
              context: context,
              title: 'Career Hub',
              subtitle: 'ATS & AI Tools',
              icon: Icons.stars_rounded,
              color: AppColors.success,
              onTap: () => _navigateToTab(context, 3), // tab 3 = Career
            ),
            const SizedBox(width: 6),
            _buildActionCard(
              context: context,
              title: 'Report Scam',
              icon: Icons.campaign_rounded,
              color: AppColors.danger,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportScamScreen()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
