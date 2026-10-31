import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../services/mock_data_service.dart';
import '../../models/job_tracker_model.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/empty_state.dart';
import '../interview/interview_coach_screen.dart';

class JobTrackerKanbanScreen extends StatefulWidget {
  final bool isEmbedded;
  const JobTrackerKanbanScreen({Key? key, this.isEmbedded = false}) : super(key: key);

  @override
  State<JobTrackerKanbanScreen> createState() => _JobTrackerKanbanScreenState();
}

class _JobTrackerKanbanScreenState extends State<JobTrackerKanbanScreen> {
  ApplicationStatus? _selectedStatusFilter;

  // Add new job dialog
  void _showAddJobDialog(BuildContext context) {
    final companyController = TextEditingController();
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    final locationController = TextEditingController();
    final salaryController = TextEditingController();
    final recruiterController = TextEditingController();
    final notesController = TextEditingController();
    ApplicationStatus status = ApplicationStatus.applied;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Job Application', style: TextStyle(fontWeight: FontWeight.bold)),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(label: 'Company Name *', controller: companyController, hintText: 'e.g. Google, Zoho'),
                  const SizedBox(height: 10),
                  CustomTextField(label: 'Job Title *', controller: titleController, hintText: 'e.g. Flutter Developer'),
                  const SizedBox(height: 10),
                  CustomTextField(label: 'Location', controller: locationController, hintText: 'e.g. Coimbatore / Remote'),
                  const SizedBox(height: 10),
                  CustomTextField(label: 'Salary (Optional)', controller: salaryController, hintText: 'e.g. ₹8,00,000 / yr'),
                  const SizedBox(height: 10),
                  CustomTextField(label: 'Job URL (Optional)', controller: urlController, hintText: 'https://...'),
                  const SizedBox(height: 10),
                  CustomTextField(label: 'Recruiter Contact / Email', controller: recruiterController, hintText: 'hr@company.com'),
                  const SizedBox(height: 10),
                  CustomTextField(label: 'Notes', controller: notesController, hintText: 'Referral notes, interview dates, deadline...'),
                  const SizedBox(height: 14),
                  const Text('Application Status *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<ApplicationStatus>(
                    value: status,
                    decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                    items: [
                      ApplicationStatus.applied,
                      ApplicationStatus.interview,
                      ApplicationStatus.selected,
                      ApplicationStatus.rejected,
                      ApplicationStatus.saved,
                      ApplicationStatus.offer,
                    ].map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s.label),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => status = val);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                if (companyController.text.trim().isEmpty || titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Company name and job title are required.'), backgroundColor: Colors.red),
                  );
                  return;
                }
                final service = Provider.of<MockDataService>(context, listen: false);
                final newJob = TrackedJob(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  userId: service.careerProfile.userId,
                  companyName: companyController.text.trim(),
                  jobTitle: titleController.text.trim(),
                  jobUrl: urlController.text.trim(),
                  location: locationController.text.trim(),
                  employmentType: 'Full-Time',
                  salary: salaryController.text.trim(),
                  description: '',
                  dateApplied: DateTime.now(),
                  recruiterContact: recruiterController.text.trim(),
                  notes: notesController.text.trim(),
                  status: status,
                  matchScore: 88,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                service.addTrackedJob(newJob);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✓ Job added to tracker!'), backgroundColor: AppColors.success),
                );
              },
              child: const Text('Add Job'),
            ),
          ],
        ),
      ),
    );
  }

  // Edit existing job dialog
  void _showEditJobDialog(BuildContext context, TrackedJob job) {
    final companyController = TextEditingController(text: job.companyName);
    final titleController = TextEditingController(text: job.jobTitle);
    final locationController = TextEditingController(text: job.location);
    final salaryController = TextEditingController(text: job.salary);
    final notesController = TextEditingController(text: job.notes);
    ApplicationStatus status = job.status;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Job Application', style: TextStyle(fontWeight: FontWeight.bold)),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(label: 'Company Name *', controller: companyController, hintText: 'Company'),
                  const SizedBox(height: 10),
                  CustomTextField(label: 'Job Title *', controller: titleController, hintText: 'Job Title'),
                  const SizedBox(height: 10),
                  CustomTextField(label: 'Location', controller: locationController, hintText: 'Location'),
                  const SizedBox(height: 10),
                  CustomTextField(label: 'Salary', controller: salaryController, hintText: 'Salary'),
                  const SizedBox(height: 10),
                  CustomTextField(label: 'Notes', controller: notesController, hintText: 'Notes'),
                  const SizedBox(height: 14),
                  const Text('Application Status *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<ApplicationStatus>(
                    value: status,
                    decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                    items: [
                      ApplicationStatus.applied,
                      ApplicationStatus.interview,
                      ApplicationStatus.selected,
                      ApplicationStatus.rejected,
                      ApplicationStatus.saved,
                      ApplicationStatus.offer,
                    ].map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s.label),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => status = val);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                if (companyController.text.trim().isEmpty || titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Company name and job title are required.'), backgroundColor: Colors.red),
                  );
                  return;
                }
                final service = Provider.of<MockDataService>(context, listen: false);
                final updatedJob = job.copyWith(
                  companyName: companyController.text.trim(),
                  jobTitle: titleController.text.trim(),
                  location: locationController.text.trim(),
                  salary: salaryController.text.trim(),
                  notes: notesController.text.trim(),
                  status: status,
                );
                service.updateTrackedJob(updatedJob);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✓ Job application updated!'), backgroundColor: AppColors.success),
                );
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.selected:
      case ApplicationStatus.offer:
        return const Color(0xFF10B981); // Emerald Green
      case ApplicationStatus.interview:
      case ApplicationStatus.technicalRound:
      case ApplicationStatus.hrRound:
        return const Color(0xFFF59E0B); // Amber / Orange
      case ApplicationStatus.applied:
      case ApplicationStatus.screening:
        return const Color(0xFF3B82F6); // Blue
      case ApplicationStatus.rejected:
      case ApplicationStatus.withdrawn:
        return const Color(0xFFEF4444); // Red
      case ApplicationStatus.saved:
      default:
        return const Color(0xFF8B5CF6); // Purple
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final service = Provider.of<MockDataService>(context);

    final filteredJobs = _selectedStatusFilter == null
        ? service.trackedJobs
        : service.trackedJobs.where((j) => j.status == _selectedStatusFilter).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF070D1B) : const Color(0xFFF8FAFC),
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              backgroundColor: isDark ? const Color(0xFF091024) : Colors.white,
              elevation: 0,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.assignment_outlined, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Job Tracker', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(
                        '${service.trackedJobs.length} application${service.trackedJobs.length == 1 ? '' : 's'} tracked',
                        style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
                  tooltip: 'Add Job',
                  onPressed: () => _showAddJobDialog(context),
                ),
                const SizedBox(width: 8),
              ],
            ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Stats Summary Row
                _buildStatsRow(service, isDark),

                // 2. Filter Status Chips Bar
                Container(
                  height: 48,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildFilterChip('All (${service.trackedJobs.length})', null, isDark),
                      _buildFilterChip('Applied (${service.trackedJobs.where((j) => j.status == ApplicationStatus.applied).length})', ApplicationStatus.applied, isDark),
                      _buildFilterChip('Interview (${service.trackedJobs.where((j) => j.status == ApplicationStatus.interview).length})', ApplicationStatus.interview, isDark),
                      _buildFilterChip('Selected (${service.trackedJobs.where((j) => j.status == ApplicationStatus.selected).length})', ApplicationStatus.selected, isDark),
                      _buildFilterChip('Rejected (${service.trackedJobs.where((j) => j.status == ApplicationStatus.rejected).length})', ApplicationStatus.rejected, isDark),
                      _buildFilterChip('Saved (${service.trackedJobs.where((j) => j.status == ApplicationStatus.saved).length})', ApplicationStatus.saved, isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // 3. Applications List / Adaptive Responsive Cards
                Expanded(
                  child: filteredJobs.isEmpty
                      ? EmptyState(
                          title: _selectedStatusFilter == null
                              ? 'No Applications Tracked Yet'
                              : 'No ${_selectedStatusFilter!.label} Applications',
                          description: _selectedStatusFilter == null
                              ? 'Tap "+ Add Job" below to track your job applications and stay organized throughout your search.'
                              : 'No jobs found matching this status filter.',
                          icon: Icons.assignment_outlined,
                        )
                      : isDesktop
                          ? _buildResponsiveGrid(context, filteredJobs, isDark, service)
                          : _buildMobileList(context, filteredJobs, isDark, service),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddJobDialog(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Job', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFilterChip(String label, ApplicationStatus? status, bool isDark) {
    final bool isSelected = _selectedStatusFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          fontSize: 11.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
        ),
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        selectedColor: AppColors.primary,
        side: BorderSide(
          color: isSelected
              ? AppColors.primary
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
        ),
        onSelected: (_) {
          setState(() {
            _selectedStatusFilter = isSelected ? null : status;
          });
        },
      ),
    );
  }

  Widget _buildStatsRow(MockDataService service, bool isDark) {
    final total = service.trackedJobs.length;
    final applied = service.trackedJobs.where((j) => j.status == ApplicationStatus.applied).length;
    final interview = service.trackedJobs.where((j) => j.status == ApplicationStatus.interview).length;
    final selected = service.trackedJobs.where((j) => j.status == ApplicationStatus.selected).length;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          _buildStatCard('Total', total.toString(), const Color(0xFF6366F1), isDark),
          const SizedBox(width: 8),
          _buildStatCard('Applied', applied.toString(), const Color(0xFF3B82F6), isDark),
          const SizedBox(width: 8),
          _buildStatCard('Interview', interview.toString(), const Color(0xFFF59E0B), isDark),
          const SizedBox(width: 8),
          _buildStatCard('Selected', selected.toString(), const Color(0xFF10B981), isDark),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10.5, color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveGrid(BuildContext context, List<TrackedJob> jobs, bool isDark, MockDataService service) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: jobs.map((job) {
          return SizedBox(
            width: 420,
            child: _buildJobCard(context, job, isDark, service),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileList(BuildContext context, List<TrackedJob> jobs, bool isDark, MockDataService service) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: jobs.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildJobCard(context, jobs[index], isDark, service),
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, TrackedJob job, bool isDark, MockDataService service) {
    final statusColor = _getStatusColor(job.status);
    final dateStr = job.dateApplied != null
        ? DateFormat('MMM d, yyyy').format(job.dateApplied!)
        : 'Applied recently';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Avatar + Title + Status Pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(
                    job.companyName.isNotEmpty ? job.companyName[0].toUpperCase() : 'J',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: statusColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.jobTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job.companyName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Status Selector Pill
              PopupMenuButton<ApplicationStatus>(
                initialValue: job.status,
                tooltip: 'Change Status',
                onSelected: (newStatus) {
                  service.updateTrackedJobStatus(job.id, newStatus);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        job.status.label,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: statusColor),
                    ],
                  ),
                ),
                itemBuilder: (ctx) => [
                  ApplicationStatus.applied,
                  ApplicationStatus.interview,
                  ApplicationStatus.selected,
                  ApplicationStatus.rejected,
                  ApplicationStatus.saved,
                  ApplicationStatus.offer,
                ].map((s) => PopupMenuItem(
                  value: s,
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: _getStatusColor(s), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(s.label, style: const TextStyle(fontSize: 12.5)),
                    ],
                  ),
                )).toList(),
              ),
            ],
          ),

          // Location & Salary Row
          if (job.location.isNotEmpty || job.salary.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                if (job.location.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 13, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        job.location,
                        style: TextStyle(fontSize: 11.5, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                if (job.salary.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.currency_rupee, size: 13, color: Color(0xFF10B981)),
                      const SizedBox(width: 4),
                      Text(
                        job.salary,
                        style: TextStyle(fontSize: 11.5, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B)),
                      ),
                    ],
                  ),
              ],
            ),
          ],

          // Notes
          if (job.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B).withOpacity(0.6) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                job.notes,
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Bottom Action Row: Date + Edit/Delete/Prep Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Date
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(
                    dateStr,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),

              // Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Practice Interview
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InterviewCoachScreen(
                            initialRole: job.jobTitle,
                            initialCompany: job.companyName,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.mic_rounded, size: 13, color: AppColors.primary),
                          SizedBox(width: 4),
                          Text('Prep', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Edit Button
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 17),
                    tooltip: 'Edit Job',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    color: Colors.grey,
                    onPressed: () => _showEditJobDialog(context, job),
                  ),
                  const SizedBox(width: 4),

                  // Delete Button
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 17),
                    tooltip: 'Delete Job',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    color: AppColors.danger,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Remove Job Application'),
                          content: Text('Are you sure you want to remove "${job.companyName} — ${job.jobTitle}" from your tracker?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
                              onPressed: () {
                                service.deleteTrackedJob(job.id);
                                Navigator.pop(ctx);
                              },
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
