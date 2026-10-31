import 'package:flutter/material.dart';
import 'widgets/ai_guide_hero.dart';
import 'widgets/dashboard_career_journey_card.dart';
import 'widgets/three_main_areas.dart';
import 'widgets/recent_activity_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hero: JobShield AI Assistant
          AiGuideHero(),
          SizedBox(height: 20),

          // 2. Career Journey — Connected Workflow Card
          DashboardCareerJourneyCard(),
          SizedBox(height: 20),

          // 3. Explore Our Main Areas
          ThreeMainAreas(),
          SizedBox(height: 20),

          // 4. Recent Activity
          RecentActivitySection(),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}
