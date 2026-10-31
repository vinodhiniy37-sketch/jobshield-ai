import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../main_screen.dart';

class AiHelpCard extends StatefulWidget {
  const AiHelpCard({Key? key}) : super(key: key);

  // Static session-level flag to remember if the new user banner was dismissed
  static bool isDismissedInSession = false;

  @override
  State<AiHelpCard> createState() => _AiHelpCardState();
}

class _AiHelpCardState extends State<AiHelpCard> {
  void _navigateToAiChat() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen(initialTab: 2)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use a custom premium dark navy layout for cybersecurity theme
    final cardBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final glowColor = AppColors.primary.withOpacity(0.12);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: AiHelpCard.isDismissedInSession
          ? _buildDefaultHelpCard(context, isDark, cardBgColor, cardBorderColor, glowColor)
          : _buildFirstTimeUserCard(context, isDark, cardBgColor, cardBorderColor, glowColor),
    );
  }

  // Welcome Card layout for new users
  Widget _buildFirstTimeUserCard(
    BuildContext context,
    bool isDark,
    Color bgColor,
    Color borderColor,
    Color glowColor,
  ) {
    return Container(
      key: const ValueKey('first_time_card'),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cyber AI Assistant Avatar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'New here? Let me help you 👋',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Scan a job, check scam alerts, or ask me anything about job safety.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: _navigateToAiChat,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Close button (X) in corner to dismiss first-time prompt
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: Icon(
                Icons.close_rounded,
                size: 20,
                color: isDark ? Colors.white60 : Colors.black45,
              ),
              onPressed: () {
                setState(() {
                  AiHelpCard.isDismissedInSession = true;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // Help Card layout for general/re-visiting users
  Widget _buildDefaultHelpCard(
    BuildContext context,
    bool isDark,
    Color bgColor,
    Color borderColor,
    Color glowColor,
  ) {
    return Container(
      key: const ValueKey('default_card'),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Need Help Staying Safe?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Not sure what to do? Ask our AI Safety Assistant.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _navigateToAiChat,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : AppColors.primary,
                foregroundColor: isDark ? Colors.black : Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Ask AI',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
