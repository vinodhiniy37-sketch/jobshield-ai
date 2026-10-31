import '../models/job_feed_model.dart';

class JobFeedService {
  // Returns demo job opportunities dataset clearly labeled as "Demo Job Feed"
  List<JobOpportunity> getDemoJobFeed({List<String>? userSkills}) {
    final List<String> skills = userSkills ?? ['Flutter', 'Dart', 'Firebase', 'Git', 'SQL'];

    final List<JobOpportunity> allJobs = [
      JobOpportunity(
        id: 'job_1',
        title: 'Flutter Developer Intern',
        company: 'Apex Tech Solutions',
        location: 'Coimbatore, Tamil Nadu',
        employmentType: 'Internship',
        workplaceType: 'Hybrid',
        postedDate: '2 days ago',
        requiredSkills: ['Flutter', 'Dart', 'Firebase', 'REST API'],
        matchedSkills: [],
        missingSkills: [],
        salary: '₹15,000 - ₹25,000 / month',
        matchScore: 86,
        description: 'Seeking a motivated Flutter Developer Intern to build clean, cross-platform mobile applications. Hands-on experience with State Management and Firebase authentication preferred.',
        jobUrl: 'https://careers.apextech.example/jobs/flutter-intern',
        isDemo: true,
      ),
      JobOpportunity(
        id: 'job_2',
        title: 'Junior Mobile Application Engineer',
        company: 'CloudScale Innovations',
        location: 'Bengaluru, Karnataka',
        employmentType: 'Full-Time',
        workplaceType: 'Remote',
        postedDate: '1 day ago',
        requiredSkills: ['Flutter', 'Dart', 'State Management', 'Git', 'Docker'],
        matchedSkills: [],
        missingSkills: [],
        salary: '₹6,00,000 - ₹8,50,000 / year',
        matchScore: 78,
        description: 'Join our mobile engineering squad building high-throughput consumer apps. You will collaborate with backend developers to integrate cloud APIs and deliver slick UI components.',
        jobUrl: 'https://careers.cloudscale.example/jobs/junior-mobile-eng',
        isDemo: true,
      ),
      JobOpportunity(
        id: 'job_3',
        title: 'Python & AI Trainee Developer',
        company: 'Cognitive Systems Hub',
        location: 'Chennai, Tamil Nadu',
        employmentType: 'Full-Time',
        workplaceType: 'On-site',
        postedDate: '3 days ago',
        requiredSkills: ['Python', 'SQL', 'REST API', 'Git', 'Machine Learning'],
        matchedSkills: [],
        missingSkills: [],
        salary: '₹4,50,000 - ₹6,00,000 / year',
        matchScore: 72,
        description: 'Opportunity for fresh graduates with strong Python and database fundamentals. You will assist in training NLP models and building automation services for enterprise clients.',
        jobUrl: 'https://careers.cognitivesystems.example/jobs/python-ai-trainee',
        isDemo: true,
      ),
      JobOpportunity(
        id: 'job_4',
        title: 'Frontend React & Mobile Engineer',
        company: 'NexGen Digital Labs',
        location: 'Hyderabad, Telangana',
        employmentType: 'Full-Time',
        workplaceType: 'Remote',
        postedDate: 'Just now',
        requiredSkills: ['JavaScript', 'React', 'TypeScript', 'HTML/CSS', 'Git'],
        matchedSkills: [],
        missingSkills: [],
        salary: '₹5,50,000 - ₹7,50,000 / year',
        matchScore: 68,
        description: 'Building modern web & hybrid mobile interfaces. Strong grasp of web architecture, responsive CSS, and state management required.',
        jobUrl: 'https://careers.nexgendigital.example/jobs/frontend-engineer',
        isDemo: true,
      ),
      JobOpportunity(
        id: 'job_5',
        title: 'Full Stack Software Engineer Intern',
        company: 'Vanguard Cybertech',
        location: 'Coimbatore, Tamil Nadu',
        employmentType: 'Internship',
        workplaceType: 'Hybrid',
        postedDate: '4 days ago',
        requiredSkills: ['Node.js', 'Express', 'MongoDB', 'React', 'Flutter'],
        matchedSkills: [],
        missingSkills: [],
        salary: '₹18,000 - ₹30,000 / month',
        matchScore: 82,
        description: 'End-to-end web & mobile development internship. Experience with REST APIs, database schemas, and version control is highly valued.',
        jobUrl: 'https://careers.vanguardcyber.example/jobs/fullstack-intern',
        isDemo: true,
      ),
    ];

    // Compute personalized skill matches
    return allJobs.map((job) {
      final List<String> matched = [];
      final List<String> missing = [];

      for (final reqSkill in job.requiredSkills) {
        if (skills.any((s) => s.toLowerCase() == reqSkill.toLowerCase())) {
          matched.add(reqSkill);
        } else {
          missing.add(reqSkill);
        }
      }

      int computedScore = 60;
      if (job.requiredSkills.isNotEmpty) {
        computedScore = ((matched.length / job.requiredSkills.length) * 100).round().clamp(45, 95);
      }

      return JobOpportunity(
        id: job.id,
        title: job.title,
        company: job.company,
        location: job.location,
        employmentType: job.employmentType,
        workplaceType: job.workplaceType,
        postedDate: job.postedDate,
        requiredSkills: job.requiredSkills,
        matchedSkills: matched,
        missingSkills: missing,
        salary: job.salary,
        matchScore: computedScore,
        description: job.description,
        jobUrl: job.jobUrl,
        isDemo: true,
      );
    }).toList();
  }
}
