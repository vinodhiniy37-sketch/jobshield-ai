import '../models/interview_model.dart';

class InterviewService {
  InterviewSession generateQuestions({
    required String targetRole,
    required String companyName,
    required String experienceLevel,
    String mode = 'mixed', // 'hr', 'technical', 'mixed'
    String? jobDescription,
  }) {
    final roleStr = targetRole.isNotEmpty ? targetRole : 'Software Engineer';
    final companyStr = companyName.isNotEmpty ? companyName : 'Target Company';


    // 10 Default Master Questions (Required by JobShield AI Specification)
    final List<PracticeQuestion> allMasterQuestions = [
      PracticeQuestion(
        id: 'q1',
        category: QuestionCategory.hr,
        question: '1. Tell me about yourself.',
        sampleAnswerTip: 'Use the Present-Past-Future framework: current role/education, key background accomplishments, and why you are excited about this opportunity.',
        modelAnswer: 'I am a passionate software developer specializing in mobile app development, state management, and cloud integrations with Flutter and Dart. Recently, I built high-impact cross-platform applications including real-time safety and analytics engines. My goal is to apply my clean code principles and continuous learning mindset to deliver scalable, high-performance applications.',
        keyPhrasesToInclude: ['software developer', 'cross-platform', 'Flutter', 'clean code', 'problem solving'],
      ),
      PracticeQuestion(
        id: 'q2',
        category: QuestionCategory.hr,
        question: '2. Why do you want this job at $companyStr?',
        sampleAnswerTip: 'Align your career goals with $companyStr\'s mission, engineering standards, product impact, and tech stack.',
        modelAnswer: 'I am drawn to $companyStr because of your reputation for technological innovation and engineering excellence. The $roleStr role matches my skills in modern UI development, state management, and backend integrations. I am excited to contribute to your core products while collaborating with a talented team.',
        keyPhrasesToInclude: ['company mission', 'engineering excellence', 'technical alignment', 'growth'],
      ),
      PracticeQuestion(
        id: 'q3',
        category: QuestionCategory.hr,
        question: '3. What are your strengths?',
        sampleAnswerTip: 'Highlight 2-3 specific technical and soft skills backed by brief real-world examples (e.g. debugging, clean architecture, fast learning).',
        modelAnswer: 'My primary strengths are strong technical problem-solving, clean code architecture, and rapid adaptability. For example, when building complex async UI flows, I structure state management systematically to eliminate memory leaks and reduce widget rebuilds.',
        keyPhrasesToInclude: ['problem solving', 'clean architecture', 'adaptability', 'collaboration'],
      ),
      PracticeQuestion(
        id: 'q4',
        category: QuestionCategory.hr,
        question: '4. What is your weakness and how are you working to improve it?',
        sampleAnswerTip: 'State a real non-fatal technical or process area, explain self-awareness, and show active steps you take to overcome it.',
        modelAnswer: 'Earlier in my projects, I used to focus heavily on perfectionism in UI micro-animations before finalizing core API models. I recognized this trade-off and now prioritize building robust MVP data structures and automated unit tests first before refining UI polish.',
        keyPhrasesToInclude: ['self-awareness', 'prioritization', 'continuous improvement', 'MVP approach'],
      ),
      PracticeQuestion(
        id: 'q5',
        category: QuestionCategory.hr,
        question: '5. Why should we hire you for the $roleStr position?',
        sampleAnswerTip: 'Synthesize your technical competency, proven track record, enthusiasm, and immediate readiness to deliver value.',
        modelAnswer: 'You should hire me because I combine strong hands-on technical skills in $roleStr development with a proactive problem-solving mindset. I am ready to hit the ground running, deliver clean code, communicate transparently, and take full ownership of assigned features.',
        keyPhrasesToInclude: ['technical competency', 'ownership', 'hit the ground running', 'deliver value'],
      ),
      PracticeQuestion(
        id: 'q6',
        category: QuestionCategory.technical,
        question: '6. Tell me about one of your key software engineering projects.',
        sampleAnswerTip: 'Describe the project scope, technical stack used (Flutter, Dart, Firebase, REST APIs), your specific role, and quantifiable outcomes.',
        modelAnswer: 'I built "JobShield AI", a cross-platform recruitment fraud detection and career portal using Flutter, Firebase, and local AI heuristic models. I implemented real-time risk assessment, state management using Provider, and interactive career tools, reducing user scan processing time by 45%.',
        keyPhrasesToInclude: ['architecture', 'Flutter', 'Firebase', 'state management', 'quantifiable impact'],
      ),
      PracticeQuestion(
        id: 'q7',
        category: QuestionCategory.behavioural,
        question: '7. What challenges did you face in your project and how did you solve them?',
        sampleAnswerTip: 'Use the STAR method (Situation, Task, Action, Result) focusing on root-cause analysis and systematic resolution.',
        modelAnswer: 'SITUATION: During testing, heavy list rendering caused memory inflation on low-end devices.\nTASK: Identify and resolve performance bottlenecks.\nACTION: I profiled memory using DevTools, converted nested ListView views to slivers, and properly disposed controllers.\nRESULT: Memory usage decreased by 40% and frame rates stabilized at 60 FPS.',
        keyPhrasesToInclude: ['STAR method', 'debugging', 'profiling', 'root cause', 'performance optimization'],
      ),
      PracticeQuestion(
        id: 'q8',
        category: QuestionCategory.technical,
        question: '8. What technical skills and tools do you bring for the $roleStr role?',
        sampleAnswerTip: 'List core languages, frameworks, state management patterns, databases, and version control tools relevant to the job.',
        modelAnswer: 'My technical toolkit includes Dart, Flutter, RESTful API integration, Firebase (Auth, Firestore, Storage), Provider/Riverpod state management, Git/GitHub version control, and responsive UI layout design for mobile and web platforms.',
        keyPhrasesToInclude: ['Dart', 'Flutter', 'REST APIs', 'Firebase', 'Git', 'State Management'],
      ),
      PracticeQuestion(
        id: 'q9',
        category: QuestionCategory.hr,
        question: '9. Where do you see yourself in five years?',
        sampleAnswerTip: 'Discuss technical mastery, leadership growth, architectural ownership, and long-term commitment to software excellence.',
        modelAnswer: 'In five years, I see myself as a Senior Software Engineer / Technical Lead, driving architectural decisions, mentoring junior developers, and delivering mission-critical applications that serve millions of users.',
        keyPhrasesToInclude: ['Senior Engineer', 'technical leadership', 'mentorship', 'architectural decisions'],
      ),
      PracticeQuestion(
        id: 'q10',
        category: QuestionCategory.situational,
        question: '10. Do you have any questions for us about $companyStr and the $roleStr team?',
        sampleAnswerTip: 'Always ask thoughtful reverse-interview questions about engineering culture, sprint workflow, team growth, and upcoming tech initiatives.',
        modelAnswer: 'Yes, thank you! I would love to ask:\n1. What does a typical day look like for a $roleStr on this team?\n2. What are the key engineering priorities or upcoming tech migrations for $companyStr over the next two quarters?\n3. How does the team foster technical growth and peer code reviews?',
        keyPhrasesToInclude: ['engineering culture', 'team workflow', 'tech stack', 'growth opportunities'],
      ),
    ];

    // Filter questions based on mode
    List<PracticeQuestion> filtered;
    if (mode == 'hr') {
      filtered = allMasterQuestions.where((q) => q.category == QuestionCategory.hr).toList();
    } else if (mode == 'technical') {
      filtered = allMasterQuestions.where((q) => q.category == QuestionCategory.technical || q.category == QuestionCategory.behavioural).toList();
    } else {
      filtered = List.from(allMasterQuestions);
    }

    // Ensure we always have questions (fallback to master 10 if filter is empty)
    if (filtered.isEmpty) {
      filtered = List.from(allMasterQuestions);
    }

    return InterviewSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      targetRole: roleStr,
      companyName: companyStr,
      experienceLevel: experienceLevel,
      questions: filtered,
      userAnswers: {},
      evaluations: {},
      createdAt: DateTime.now(),
    );
  }

  AnswerEvaluation evaluateAnswer({
    required PracticeQuestion question,
    required String userAnswer,
  }) {
    final text = userAnswer.trim().toLowerCase();

    if (text.isEmpty) {
      return AnswerEvaluation(
        overallScore: 20,
        relevanceScore: 10,
        clarityScore: 20,
        confidenceScore: 10,
        technicalDepthScore: 10,
        structureScore: 20,
        strengths: ['Attempted question.'],
        improvementSuggestions: ['Provide a detailed answer using specific technical examples or the STAR framework.'],
        detailedFeedback: 'Answer is too brief to demonstrate technical depth or clear communication.',
      );
    }

    // Keyword matching
    int matchedCount = 0;
    for (final phrase in question.keyPhrasesToInclude) {
      if (text.contains(phrase.toLowerCase())) {
        matchedCount++;
      }
    }

    int lengthBonus = (userAnswer.length / 10.0).clamp(10.0, 40.0).round();
    int relevance = (matchedCount > 0 ? 80 : 55) + (lengthBonus / 2).round();
    int clarity = text.contains('.') && text.contains(' ') ? 88 : 65;
    int confidence = (text.contains('i developed') || text.contains('i built') || text.contains('i resolved') || text.contains('my experience') || text.contains('i focus')) ? 92 : 72;
    int depth = (matchedCount * 22 + lengthBonus).clamp(45, 95);
    int structure = (userAnswer.split('\n').length > 1 || userAnswer.length > 150) ? 90 : 68;

    int overall = ((relevance * 0.25) + (clarity * 0.20) + (confidence * 0.15) + (depth * 0.25) + (structure * 0.15)).round().clamp(35, 98);

    final List<String> strengths = [];
    if (confidence >= 80) strengths.add('Uses strong owner mindset language ("I built", "I resolved", "My experience")');
    if (depth >= 70) strengths.add('Includes relevant industry concepts for ${question.category.label}');
    if (clarity >= 80) strengths.add('Structured sentence flow with clear focus');

    final List<String> improvements = [];
    if (matchedCount < (question.keyPhrasesToInclude.length / 2).ceil()) {
      improvements.add('Incorporate key industry terms: ${question.keyPhrasesToInclude.take(3).join(', ')}');
    }
    if (userAnswer.length < 90) {
      improvements.add('Add specific project metrics or concrete examples to strengthen proof.');
    }

    return AnswerEvaluation(
      overallScore: overall,
      relevanceScore: relevance.clamp(25, 98),
      clarityScore: clarity.clamp(25, 98),
      confidenceScore: confidence.clamp(25, 98),
      technicalDepthScore: depth.clamp(25, 98),
      structureScore: structure.clamp(25, 98),
      strengths: strengths.isNotEmpty ? strengths : ['Good effort addressing the core prompt.'],
      improvementSuggestions: improvements.isNotEmpty ? improvements : ['Maintain structured bullet points during live interviews.'],
      detailedFeedback: 'AI Evaluation based on keyword relevance, answer depth, confidence markers, and structural clarity.',
    );
  }
}
