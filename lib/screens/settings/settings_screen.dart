import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../services/mock_data_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailAlerts = false;
  String _selectedLanguage = 'English';

  final List<String> _languages = ['English', 'Spanish', 'French', 'German', 'Hindi', 'Japanese'];

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select App Language'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _languages
                  .map((lang) => RadioListTile<String>(
                        title: Text(lang),
                        value: lang,
                        groupValue: _selectedLanguage,
                        onChanged: (val) {
                          setState(() {
                            _selectedLanguage = val!;
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Language switched to $_selectedLanguage.')),
                          );
                        },
                      ))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'JobScam Guard',
      applicationVersion: '1.0.0 (Release Build)',
      applicationLegalese: '© 2026 JobScam Guard Project. All rights reserved.',
      applicationIcon: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.shield_rounded, color: Colors.white, size: 28),
      ),
      children: [
        const SizedBox(height: 12),
        const Text(
          'JobScam Guard is a security platform utilizing local parsing models and community reports to detect phishing recruiters, advance fee schemes, and fraudulent job descriptions.',
        ),
      ],
    );
  }

  void _showRatingDialog() {
    int rating = 5;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Rate JobScam Guard'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Enjoying the app? Rate us to support cybersecurity safety!'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => IconButton(
                        icon: Icon(
                          index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: AppColors.warning,
                          size: 32,
                        ),
                        onPressed: () {
                          setModalState(() {
                            rating = index + 1;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Maybe Later'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Thank you for rating us!'), backgroundColor: AppColors.success),
                    );
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showFeedbackDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Send Feedback'),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Share features you would like or bugs encountered...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feedback submitted. Thank you!'), backgroundColor: AppColors.success),
                );
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSettingCard(Widget child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final service = Provider.of<MockDataService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          children: [
            _buildSectionHeader('THEME SYSTEM'),
            _buildSettingCard(
              SwitchListTile(
                title: const Text('Dark Mode Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text(
                  isDark ? 'Dark Theme activated.' : 'Light Theme activated.',
                  style: const TextStyle(fontSize: 12),
                ),
                secondary: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: AppColors.primary),
                value: service.themeMode == ThemeMode.dark,
                onChanged: (val) {
                  service.toggleTheme();
                },
                activeColor: AppColors.primary,
              ),
            ),

            _buildSectionHeader('NOTIFICATIONS'),
            _buildSettingCard(
              Column(
                children: [
                  SwitchListTile(
                    title: const Text('New scam alerts', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Push alerts on trending scams and fake employers.', style: TextStyle(fontSize: 11)),
                    value: _pushNotifications,
                    onChanged: (val) {
                      setState(() {
                        _pushNotifications = val;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Scan status updates', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Receive notifications when deep scans finish.', style: TextStyle(fontSize: 11)),
                    value: _emailAlerts,
                    onChanged: (val) {
                      setState(() {
                        _emailAlerts = val;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),

            _buildSectionHeader('GENERAL'),
            _buildSettingCard(
              Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.language_rounded, size: 20, color: AppColors.primary),
                    title: const Text('App Language', style: TextStyle(fontSize: 14)),
                    trailing: Text(_selectedLanguage, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    onTap: _showLanguageDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined, size: 20, color: AppColors.primary),
                    title: const Text('Privacy Center & Guidelines', style: TextStyle(fontSize: 14)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Privacy Guidelines'),
                          content: const Text('JobScam Guard local analyzer is designed to protect credentials. All scanned logs are stored locally on your machine.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Okay')),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.policy_outlined, size: 20, color: AppColors.primary),
                    title: const Text('Terms of Service', style: TextStyle(fontSize: 14)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Terms of Service'),
                          content: const Text('Users are prohibited from uploading malicious files. Scans are provided as heuristic evaluations to detect frauds.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Okay')),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            _buildSectionHeader('ABOUT & FAQS'),
            _buildSettingCard(
              Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.help_center_outlined, size: 20, color: AppColors.primary),
                    title: const Text('Help, Support & FAQs', style: TextStyle(fontSize: 14)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Support Center'),
                          content: const Text('Have issues? Email us at support@jobscamguard.org or visit our online FAQ portal.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Okay')),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.feedback_outlined, size: 20, color: AppColors.primary),
                    title: const Text('Send App Feedback', style: TextStyle(fontSize: 14)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _showFeedbackDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.star_outline_rounded, size: 20, color: AppColors.primary),
                    title: const Text('Rate App', style: TextStyle(fontSize: 14)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _showRatingDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded, size: 20, color: AppColors.primary),
                    title: const Text('About App', style: TextStyle(fontSize: 14)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _showAboutDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
