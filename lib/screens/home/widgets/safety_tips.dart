import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class SafetyTips extends StatelessWidget {
  const SafetyTips({Key? key}) : super(key: key);

  final List<Map<String, String>> _tips = const [
    {
      'title': 'Avoid Advance Fee Scams',
      'body': 'Reputable companies never charge candidates for recruitment, training materials, background screening, or laptop equipment software licenses.',
      'icon': 'payments_rounded',
    },
    {
      'title': 'Check Recruitment Domains',
      'body': 'Verify email domains carefully. Scammers register domains resembling famous brands (e.g., jobs-apple.com instead of apple.com) to deceive applicants.',
      'icon': 'language_rounded',
    },
    {
      'title': 'Refuse Chat-only Interviews',
      'body': 'If a recruiter refuses to talk via phone or face-to-face video and insists on Telegram, WhatsApp, or Google Chat text interviews, it is highly likely a scam.',
      'icon': 'forum_rounded',
    },
  ];

  IconData _getIcon(String name) {
    switch (name) {
      case 'payments_rounded':
        return Icons.payments_rounded;
      case 'language_rounded':
        return Icons.language_rounded;
      case 'forum_rounded':
        return Icons.forum_rounded;
      default:
        return Icons.help_center_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Job Search Safety Tips',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _tips.length,
          itemBuilder: (context, index) {
            final tip = _tips[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIcon(tip['icon']!),
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip['title']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          tip['body']!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 12,
                                height: 1.4,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
