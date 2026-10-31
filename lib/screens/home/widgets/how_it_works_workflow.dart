import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../scan/scan_job_screen.dart';
import '../../resume/ats_resume_scanner_screen.dart';
import '../../resume/ats_job_match_screen.dart';
import '../../career/career_hub_screen.dart';
import '../../jobs/jobs_hub_screen.dart';
import '../../interview/interview_coach_screen.dart';
import '../../security/security_tools_screen.dart';

class HowItWorksWorkflow extends StatelessWidget {
  const HowItWorksWorkflow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> steps = [
      {
        'num': '01',
        'title': 'Scan Job',
        'subtitle': 'Check a job\nopportunity',
        'icon': Icons.search_rounded,
        'color': const Color(0xFF3B82F6),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanJobScreen())),
      },
      {
        'num': '02',
        'title': 'Analyze',
        'subtitle': 'Analyze recruitment\nrisk signals',
        'icon': Icons.psychology_rounded,
        'color': const Color(0xFF8B5CF6),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityToolsScreen())),
      },
      {
        'num': '03',
        'title': 'Risk Result',
        'subtitle': 'Understand the\nrisk',
        'icon': Icons.bar_chart_rounded,
        'color': const Color(0xFF0EA5E9),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanJobScreen())),
      },
      {
        'num': '04',
        'title': 'Stay Safe',
        'subtitle': 'Follow safety\nrecommendations',
        'icon': Icons.shield_outlined,
        'color': const Color(0xFF10B981),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityToolsScreen())),
      },
      {
        'num': '05',
        'title': 'Match',
        'subtitle': 'Resume • Cover Letter\n• LinkedIn',
        'icon': Icons.track_changes_rounded,
        'color': const Color(0xFFEC4899),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AtsJobMatchScreen())),
      },
      {
        'num': '07',
        'title': 'Apply & Track',
        'subtitle': 'Manage your\napplications',
        'icon': Icons.work_outline_rounded,
        'color': const Color(0xFFF59E0B),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JobsHubScreen())),
      },
      {
        'num': '08',
        'title': 'Interview',
        'subtitle': 'Prepare with\nAI coach',
        'icon': Icons.mic_none_rounded,
        'color': const Color(0xFF6366F1),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InterviewCoachScreen())),
      },
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0D172E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1E2D4F),
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: Color(0xFF93C5FD),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How JobShield AI Works',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.5,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Your complete journey from job discovery to career success, with safety at every step.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SecurityToolsScreen()),
                ),
                child: const Row(
                  children: [
                    Text(
                      'Learn More',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF38BDF8),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF38BDF8)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Horizontal Flow List of Connected Cards
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(steps.length * 2 - 1, (i) {
                if (i.isOdd) {
                  // Arrow connector
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: Color(0xFF475569),
                    ),
                  );
                }

                final index = i ~/ 2;
                final step = steps[index];
                final String num = step['num'];
                final String title = step['title'];
                final String subtitle = step['subtitle'];
                final IconData icon = step['icon'];
                final Color color = step['color'];
                final VoidCallback onTap = step['onTap'];

                return InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 130,
                    height: 125,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF091024),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: color.withOpacity(0.3),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Top badge with number and icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              num,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(icon, size: 12, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Title
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Subtitle
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
