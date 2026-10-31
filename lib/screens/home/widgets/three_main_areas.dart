import 'package:flutter/material.dart';
import '../../scan/scan_job_screen.dart';
import '../../career/career_hub_screen.dart';
import '../../jobs/jobs_hub_screen.dart';

class ThreeMainAreas extends StatelessWidget {
  const ThreeMainAreas({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: const Icon(
                  Icons.explore_rounded,
                  color: Color(0xFF93C5FD),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Three Main Core Sections',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Access fraud detection, career development, and job application tracking.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3 Column Grid / Responsive Row
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth > 800;

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildScanJobCard(context)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildCareerCard(context)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildJobsCard(context)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildScanJobCard(context),
                    const SizedBox(height: 16),
                    _buildCareerCard(context),
                    const SizedBox(height: 16),
                    _buildJobsCard(context),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // ── SECTION 1: SCAN JOB ────────────────────────────────────────────────────
  Widget _buildScanJobCard(BuildContext context) {
    return _areaCardContainer(
      gradientColors: [
        const Color(0xFF1E3A8A),
        const Color(0xFF1E293B),
        const Color(0xFF0D1124),
      ],
      borderColor: const Color(0xFF3B82F6).withOpacity(0.4),
      watermarkIcon: Icons.security_rounded,
      watermarkColor: const Color(0xFF3B82F6).withOpacity(0.08),
      topIcon: Icons.search_rounded,
      topIconBgColor: const Color(0xFF2563EB),
      badgeText: 'SECTION 01',
      title: 'Scan Job',
      description: 'AI-powered recruitment fraud & scam detection.',
      items: [
        'URL & Domain Registry Check',
        'Company & Brand Impersonation',
        'Screenshot & PDF Attachment Scan',
        'Recruiter Details & Advance-Fee Detection',
      ],
      checkColor: const Color(0xFF60A5FA),
      buttonLabel: 'Scan a Job Now →',
      onButtonTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ScanJobScreen()),
      ),
    );
  }

  // ── SECTION 2: CAREER ──────────────────────────────────────────────────────
  Widget _buildCareerCard(BuildContext context) {
    return _areaCardContainer(
      gradientColors: [
        const Color(0xFF2C1A4A),
        const Color(0xFF1E1B38),
        const Color(0xFF0D1124),
      ],
      borderColor: const Color(0xFF8B5CF6).withOpacity(0.4),
      watermarkIcon: Icons.school_rounded,
      watermarkColor: const Color(0xFF8B5CF6).withOpacity(0.08),
      topIcon: Icons.business_center_rounded,
      topIconBgColor: const Color(0xFF8B5CF6),
      badgeText: 'SECTION 02',
      title: 'Career',
      description: 'Career intelligence, ATS tools & interview preparation.',
      items: [
        'ATS Resume Compatibility Scanner',
        'Job Description Skill Matching',
        'LinkedIn Profile Optimizer',
        'AI Cover Letter Generator',
        'Interview Coach (5 Core Questions)',
      ],
      checkColor: const Color(0xFFA78BFA),
      buttonLabel: 'Explore Career Hub →',
      onButtonTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CareerHubScreen()),
      ),
    );
  }

  // ── SECTION 3: JOBS ────────────────────────────────────────────────────────
  Widget _buildJobsCard(BuildContext context) {
    return _areaCardContainer(
      gradientColors: [
        const Color(0xFF0B382A),
        const Color(0xFF0C241D),
        const Color(0xFF0D1124),
      ],
      borderColor: const Color(0xFF10B981).withOpacity(0.4),
      watermarkIcon: Icons.work_rounded,
      watermarkColor: const Color(0xFF10B981).withOpacity(0.08),
      topIcon: Icons.work_outline_rounded,
      topIconBgColor: const Color(0xFF10B981),
      badgeText: 'SECTION 03',
      title: 'Jobs',
      description: 'Discover verified jobs and organize applications.',
      items: [
        'Curated & Verified Job Feed',
        'Role-Tailored Recommendations',
        'Application Pipeline & Statuses',
        'Job Tracker (CRUD with MongoDB)',
      ],
      checkColor: const Color(0xFF34D399),
      buttonLabel: 'Explore Jobs & Tracker →',
      onButtonTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const JobsHubScreen()),
      ),
    );
  }

  Widget _areaCardContainer({
    required List<Color> gradientColors,
    required Color borderColor,
    required IconData watermarkIcon,
    required Color watermarkColor,
    required IconData topIcon,
    required Color topIconBgColor,
    required String badgeText,
    required String title,
    required String description,
    required List<String> items,
    required Color checkColor,
    required String buttonLabel,
    required VoidCallback onButtonTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          // Watermark icon on right
          Positioned(
            right: -10,
            bottom: 30,
            child: Icon(
              watermarkIcon,
              size: 100,
              color: watermarkColor,
            ),
          ),

          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Icon + Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: topIconBgColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: topIconBgColor.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(topIcon, color: Colors.white, size: 20),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: checkColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Title
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),

              // Description
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),

              // Items
              ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 14, color: checkColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFFE2E8F0),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 16),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: InkWell(
                  onTap: onButtonTap,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: checkColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          buttonLabel,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: checkColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
