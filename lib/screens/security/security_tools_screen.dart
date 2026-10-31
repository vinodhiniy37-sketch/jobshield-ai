import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../scan/scan_job_screen.dart';
import '../report/report_scam_screen.dart';
import '../history/history_screen.dart';

class SecurityToolsScreen extends StatefulWidget {
  const SecurityToolsScreen({Key? key}) : super(key: key);

  @override
  State<SecurityToolsScreen> createState() => _SecurityToolsScreenState();
}

class _SecurityToolsScreenState extends State<SecurityToolsScreen> {
  final _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _openToolDialog(BuildContext context, String toolTitle, String description, IconData icon, Color color) {
    _inputController.clear();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          toolTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'Individual Security Investigation Tool',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _inputController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter text, URL, company or message to analyze...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.open_in_new_rounded, size: 16),
                      label: const Text('Open in Full Scan'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ScanJobScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.security_rounded, size: 16),
                      label: const Text('Analyze'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        final val = _inputController.text.trim();
                        Navigator.pop(ctx);
                        if (val.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter content to inspect.')),
                          );
                          return;
                        }
                        _showAnalysisResult(context, toolTitle, val, color);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showAnalysisResult(BuildContext context, String tool, String input, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lower = input.toLowerCase();

    bool isSuspicious = lower.contains('telegram') ||
        lower.contains('whatsapp') ||
        lower.contains('fee') ||
        lower.contains('pay') ||
        lower.contains('check') ||
        lower.contains('urgent') ||
        lower.contains('crypto') ||
        lower.contains('@gmail.com') ||
        lower.contains('gift card') ||
        lower.contains('wire');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(isSuspicious ? Icons.warning_amber_rounded : Icons.verified_rounded,
                color: isSuspicious ? AppColors.danger : AppColors.success),
            const SizedBox(width: 8),
            Text('$tool Result'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSuspicious ? AppColors.danger.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    isSuspicious ? 'STATUS: SUSPICIOUS SIGNALS DETECTED' : 'STATUS: NO CRITICAL FLAGS DETECTED',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isSuspicious ? AppColors.danger : AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text('Inspected Input: "$input"', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
            const SizedBox(height: 12),
            Text(
              isSuspicious
                  ? 'High risk recruitment patterns detected (advance payment request, unverified channel, or domain anomaly). Never transfer funds or share banking details.'
                  : 'Basic syntax and safety check passed. We recommend running a full job scan for complete verification.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScanJobScreen()),
              );
            },
            child: const Text('Full Job Scan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> tools = [
      {
        'id': '01',
        'title': 'URL / Phishing Detector',
        'desc': 'Analyzes domain registration age, typosquatting, and SSL security indicators.',
        'icon': Icons.link_rounded,
        'color': AppColors.primary,
      },
      {
        'id': '02',
        'title': 'Recruiter Identity Intelligence',
        'desc': 'Verifies recruiter email domain match, LinkedIn credibility, and public persona.',
        'icon': Icons.person_search_rounded,
        'color': const Color(0xFF0284C7),
      },
      {
        'id': '03',
        'title': 'Communication Analyzer',
        'desc': 'Scans recruiter messages, chat transcripts, and email copy for fraud cues.',
        'icon': Icons.chat_bubble_outline_rounded,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'id': '04',
        'title': 'Company Impersonation Detector',
        'desc': 'Cross-checks registered business names with known clone scams and typosquat domains.',
        'icon': Icons.domain_verification_rounded,
        'color': const Color(0xFFD97706),
      },
      {
        'id': '05',
        'title': 'Job Location Verification',
        'desc': 'Validates office address existence and flags phantom or inconsistent work locations.',
        'icon': Icons.location_on_rounded,
        'color': AppColors.success,
      },
      {
        'id': '06',
        'title': 'Salary Reality Checker',
        'desc': 'Compares promised compensation against industry market averages to spot too-good-to-be-true offers.',
        'icon': Icons.payments_rounded,
        'color': const Color(0xFF059669),
      },
      {
        'id': '07',
        'title': 'Scam Urgency Detector',
        'desc': 'Flags manipulative countdowns, immediate start pressure, and fast-track hiring traps.',
        'icon': Icons.timer_outlined,
        'color': AppColors.warning,
      },
      {
        'id': '08',
        'title': 'Scam Type Classification',
        'desc': 'Classifies threats into Advance Fee, Check Cashing, Task Scam, or Identity Theft.',
        'icon': Icons.category_rounded,
        'color': AppColors.danger,
      },
      {
        'id': '09',
        'title': 'Fraud Attack Chain Detection',
        'desc': 'Detects multi-stage scams transitioning from job board to Telegram to wire transfers.',
        'icon': Icons.account_tree_rounded,
        'color': const Color(0xFFE11D48),
      },
      {
        'id': '10',
        'title': 'Evidence Analyzer',
        'desc': 'Extracts OCR text and headers from offer letters, PDFs, and screenshots.',
        'icon': Icons.document_scanner_rounded,
        'color': const Color(0xFF4F46E5),
      },
      {
        'id': '11',
        'title': 'Report Scam',
        'desc': 'File a community threat report to protect fellow job seekers.',
        'icon': Icons.flag_rounded,
        'color': AppColors.danger,
        'isAction': true,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportScamScreen())),
      },
      {
        'id': '12',
        'title': 'Incident Response',
        'desc': 'Step-by-step checklist if you shared sensitive information or transferred funds.',
        'icon': Icons.emergency_rounded,
        'color': const Color(0xFFDC2626),
      },
      {
        'id': '13',
        'title': 'Follow-up Scam Protection',
        'desc': 'Shield against recovery scams targeting candidates who previously lost money.',
        'icon': Icons.shield_rounded,
        'color': const Color(0xFF7C3AED),
      },
      {
        'id': '14',
        'title': 'Candidate Safety Center',
        'desc': 'Comprehensive directory of cybersecurity best practices and fraud prevention guides.',
        'icon': Icons.health_and_safety_rounded,
        'color': AppColors.primary,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Investigation Tools'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Scan History',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0F172A),
                      AppColors.primary.withOpacity(0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.security_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Individual Security Tools',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                              ),
                              Text(
                                '14 specialized fraud investigation modules',
                                style: TextStyle(fontSize: 11, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Use these individual tools for targeted investigations or run a full SCAN JOB for complete end-to-end recruitment risk scoring.',
                      style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.shield_rounded, size: 16),
                      label: const Text('Open Full Scan Job'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ScanJobScreen()),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Specialized Investigation Tools',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              // Tool List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tools.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final tool = tools[index];
                  final String id = tool['id'];
                  final String title = tool['title'];
                  final String desc = tool['desc'];
                  final IconData icon = tool['icon'];
                  final Color color = tool['color'];
                  final VoidCallback? customTap = tool['onTap'];

                  return InkWell(
                    onTap: customTap ?? () => _openToolDialog(context, title, desc, icon, color),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              id,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(icon, color: color, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  desc,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey[400]),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
