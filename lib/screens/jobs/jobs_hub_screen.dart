import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'job_feed_screen.dart';
import '../tracker/job_tracker_kanban_screen.dart';

class JobsHubScreen extends StatefulWidget {
  const JobsHubScreen({Key? key}) : super(key: key);

  @override
  State<JobsHubScreen> createState() => _JobsHubScreenState();
}

class _JobsHubScreenState extends State<JobsHubScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs & Application Tracker'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.work_outline_rounded), text: 'Job Feed'),
            Tab(icon: Icon(Icons.stars_rounded), text: 'Recommended Jobs'),
            Tab(icon: Icon(Icons.assignment_outlined), text: 'Job Tracker'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          JobFeedScreen(isEmbedded: true),
          JobFeedScreen(isEmbedded: true), // Recommended Jobs view with matched scores
          JobTrackerKanbanScreen(isEmbedded: true),
        ],
      ),
    );
  }
}
