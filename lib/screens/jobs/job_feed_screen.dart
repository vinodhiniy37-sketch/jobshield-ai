import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../services/mock_data_service.dart';
import '../../models/job_feed_model.dart';
import '../../models/job_tracker_model.dart';
import '../scan/scan_job_screen.dart';
import '../resume/ats_job_match_screen.dart';

class JobFeedScreen extends StatefulWidget {
  final bool isEmbedded;
  const JobFeedScreen({Key? key, this.isEmbedded = false}) : super(key: key);

  @override
  State<JobFeedScreen> createState() => _JobFeedScreenState();
}

class _JobFeedScreenState extends State<JobFeedScreen> {
  String _selectedFilter = 'All'; // 'All', 'Internship', 'Remote'

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final service = Provider.of<MockDataService>(context);

    final userSkills = service.careerProfile.skills;
    final jobs = service.jobFeedService.getDemoJobFeed(userSkills: userSkills);

    final filtered = jobs.where((j) {
      if (_selectedFilter == 'Internship') return j.employmentType == 'Internship';
      if (_selectedFilter == 'Remote') return j.workplaceType == 'Remote';
      return true;
    }).toList();

    return Scaffold(
      appBar: widget.isEmbedded ? null : AppBar(
        title: const Text('Job Feed & Recommendations'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Demo Label Badge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.primary.withOpacity(0.1),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Demo Job Feed — Match scores dynamically calculated against your profile skills.',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Filter Chips
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildChip('All Opportunities', 'All', isDark),
                  _buildChip('Internships', 'Internship', isDark),
                  _buildChip('Remote Roles', 'Remote', isDark),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Feed Items List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final job = filtered[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 2),
                                  Text('${job.company} • ${job.location}', style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                                ],
                              ),
                            ),
                            // Match Score Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${job.matchScore}% Match',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.success),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Required Skills Chips
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: job.requiredSkills.map((s) {
                            final isMatched = job.matchedSkills.contains(s);
                            return Chip(
                              avatar: Icon(isMatched ? Icons.check : Icons.circle_outlined, size: 12, color: isMatched ? AppColors.success : Colors.grey),
                              label: Text(s, style: TextStyle(fontSize: 10, fontWeight: isMatched ? FontWeight.bold : FontWeight.normal)),
                              backgroundColor: isMatched ? AppColors.success.withOpacity(0.1) : (isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade100),
                              side: BorderSide.none,
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        Text(job.description, style: const TextStyle(fontSize: 12, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),

                        // Action Buttons Row (Unified Workflow)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.shield_rounded, size: 14),
                              label: const Text('Scan Before Applying', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3A8A),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ScanJobScreen(
                                      initialJobTitle: job.title,
                                      initialCompanyName: job.company,
                                      initialJobDescription: job.description,
                                      initialJobUrl: job.jobUrl,
                                      initialLocation: job.location,
                                    ),
                                  ),
                                );
                              },
                            ),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.compare_arrows_rounded, size: 14),
                              label: const Text('ATS Match', style: TextStyle(fontSize: 11)),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => AtsJobMatchScreen(
                                    initialJobTitle: job.title,
                                    initialCompanyName: job.company,
                                    initialJobDescription: job.description,
                                  )),
                                );
                              },
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.bookmark_add_outlined, size: 14),
                              label: const Text('Add to Tracker', style: TextStyle(fontSize: 11)),
                              onPressed: () {
                                final tracked = TrackedJob(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                  userId: service.careerProfile.userId,
                                  companyName: job.company,
                                  jobTitle: job.title,
                                  jobUrl: job.jobUrl,
                                  location: job.location,
                                  employmentType: job.employmentType,
                                  salary: job.salary,
                                  description: job.description,
                                  dateApplied: DateTime.now(),
                                  recruiterContact: '',
                                  notes: 'Added from Job Feed.',
                                  status: ApplicationStatus.saved,
                                  matchScore: job.matchScore,
                                  createdAt: DateTime.now(),
                                  updatedAt: DateTime.now(),
                                );
                                service.addTrackedJob(tracked);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Added "${job.title}" to Job Tracker!'), backgroundColor: AppColors.success),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, String value, bool isDark) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black))),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedFilter = value),
        selectedColor: AppColors.primary,
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        side: BorderSide(color: isSelected ? Colors.transparent : (isDark ? AppColors.borderDark : AppColors.borderLight)),
      ),
    );
  }
}
