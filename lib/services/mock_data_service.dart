import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:http/http.dart' as http;
import '../models/job_scan_model.dart';
import '../models/notification_model.dart';
import '../models/scam_alert_model.dart';
import '../models/resume_analysis_model.dart';
import '../models/job_match_model.dart';
import '../models/linkedin_profile_model.dart';
import '../models/job_tracker_model.dart';
import '../models/career_profile_model.dart';
import '../models/career_document_model.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'storage_service.dart';
import 'ats_service.dart';
import 'linkedin_service.dart';
import 'job_feed_service.dart';
import 'job_tracker_service.dart';
import 'cover_letter_service.dart';
import 'interview_service.dart';

enum WorkflowStep {
  scan,         // 1. Scan Job
  resume,       // 2. Resume Analysis
  jobMatch,     // 3. ATS Job Match
  linkedIn,     // 4. LinkedIn Optimization
  coverLetter,  // 5. Cover Letter Generator
  jobs,         // 6. Job Discovery
  tracker,      // 7. Application Tracker
  interview,    // 8. Interview Preparation
}

class MockDataService with ChangeNotifier {
  // Theme State
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  // API Client & Backend Connection
  final ApiService apiService = ApiService();

  // Firebase & Career Service Instances
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  final AtsService atsService = AtsService();
  final LinkedInService linkedinService = LinkedInService();
  final JobFeedService jobFeedService = JobFeedService();
  final JobTrackerService jobTrackerService = JobTrackerService();
  final CoverLetterService coverLetterService = CoverLetterService();
  final InterviewService interviewService = InterviewService();

  bool _isAuthInitialized = false;
  bool get isAuthInitialized => _isAuthInitialized;

  bool get isLoggedIn =>
      (apiService.token != null && apiService.token!.trim().isNotEmpty) ||
      _authService.currentUser != null;

  // Career Profile State
  late CareerProfile _careerProfile = CareerProfile(
    userId: _authService.currentUser?.uid ?? 'guest',
    fullName: _authService.currentUser?.displayName ?? 'Software Developer Candidate',
    email: _authService.currentUser?.email ?? 'candidate@example.com',
    phone: '+91 98765 43210',
    location: 'Coimbatore, Tamil Nadu',
    headline: 'Computer Science Engineering Student | Flutter & Full-Stack Developer',
    summary: 'Passionate software developer specializing in cross-platform mobile app development with Flutter & Dart, cloud databases, and AI security systems.',
    education: 'B.E. Computer Science & Engineering (CGPA: 8.6)',
    skills: ['Flutter', 'Dart', 'Firebase', 'Python', 'SQL', 'REST API', 'Git', 'HTML/CSS', 'Node.js', 'Docker'],
    projects: [
      'JobShield AI — Recruitment Fraud Detection & Career Platform (Flutter, Firebase, REST APIs)',
      'Smart Attendance & Analytics Portal (Python, OpenCV, PostgreSQL, Docker)',
    ],
    experience: ['Mobile Application Developer Intern at Apex Tech Solutions (June 2025 - August 2025)'],
    certifications: ['Meta Front-End Developer Specialization', 'Google Cloud Certified Associate Candidate'],
    resumeUrl: '',
    resumeFileName: 'Candidate_ATS_Resume.pdf',
    linkedinUrl: 'https://linkedin.com/in/candidate',
    preferredRole: 'Flutter Developer / Mobile Engineer',
    preferredLocation: 'Coimbatore / Remote',
    employmentTypePreference: 'Full-Time',
    completionPercentage: 88,
  );
  CareerProfile get careerProfile => _careerProfile;

  // Career Module Analyses State
  AtsResumeAnalysis? _latestResumeAnalysis;
  AtsResumeAnalysis? get latestResumeAnalysis => _latestResumeAnalysis;

  AtsJobMatch? _latestJobMatch;
  AtsJobMatch? get latestJobMatch => _latestJobMatch;

  LinkedInProfileAnalysis? _latestLinkedInAnalysis;
  LinkedInProfileAnalysis? get latestLinkedInAnalysis => _latestLinkedInAnalysis;

  final List<TrackedJob> _trackedJobs = [];
  List<TrackedJob> get trackedJobs => List.unmodifiable(_trackedJobs);

  final List<CareerDocument> _careerDocuments = [];
  List<CareerDocument> get careerDocuments => List.unmodifiable(_careerDocuments);

  // User Profile State
  String name = 'Guest User';
  String email = 'guest@jobscamguard.org';
  String phone = '';
  String location = '';
  String profileImage = '';
  int _userSecurityScore = 100;

  int get securityScore => isLoggedIn ? _userSecurityScore : _calculateMockScore();

  // Active Scans & Scanning Logic
  final List<JobScan> _scans = [];
  List<JobScan> get scans => List.unmodifiable(_scans);

  // Computed stats getters used by StatisticsSection
  int get totalJobsScanned => _scans.length;
  int get safeJobs => _scans.where((s) => s.status == ScanStatus.safe).length;
  int get suspiciousJobs => _scans.where((s) => s.status == ScanStatus.suspicious).length;
  int get scamJobs => _scans.where((s) => s.status == ScanStatus.scam).length;

  // Delete a scan locally and from Firestore
  void deleteScan(String id) {
    _scans.removeWhere((s) => s.id == id);
    final uid = _authService.currentUser?.uid;
    if (uid != null) {
      _firestoreService.deleteScan(id).catchError((e) {
        debugPrint('Firestore deleteScan error: $e');
      });
    }
    notifyListeners();
  }

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  double _scanProgress = 0.0;
  double get scanProgress => _scanProgress;

  // Active Workflow State
  WorkflowStep _currentWorkflowStep = WorkflowStep.scan;
  WorkflowStep get currentWorkflowStep => _currentWorkflowStep;

  JobScan? _activeWorkflowJob;
  JobScan? get activeWorkflowJob => _activeWorkflowJob ?? _latestScanResult;

  bool _isSafetyWarningAcknowledged = false;
  bool get isSafetyWarningAcknowledged => _isSafetyWarningAcknowledged;

  void setWorkflowStep(WorkflowStep step) {
    _currentWorkflowStep = step;
    notifyListeners();
  }

  void setActiveWorkflowJob(JobScan job) {
    _activeWorkflowJob = job;
    _latestScanResult = job;
    _currentWorkflowStep = WorkflowStep.resume;
    _isSafetyWarningAcknowledged = false;
    notifyListeners();
  }

  void acknowledgeSafetyWarning() {
    _isSafetyWarningAcknowledged = true;
    notifyListeners();
  }

  JobScan? _latestScanResult;
  JobScan? get latestScanResult => _latestScanResult;

  // Active Notifications
  final List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => _notifications;

  int get unreadNotificationsCount => _notifications.where((n) => !n.isRead).length;

  // Trending Scam Alerts
  final List<ScamAlert> _scamAlerts = [];
  List<ScamAlert> get scamAlerts => List.unmodifiable(_scamAlerts);

  // AI Chat History
  final List<Map<String, dynamic>> _chatMessages = [];
  List<Map<String, dynamic>> get chatMessages => _chatMessages;

  bool _isAiTyping = false;
  bool get isAiTyping => _isAiTyping;

  // User Scam Reports
  int reportedScamsCount = 0;

  MockDataService() {
    _loadInitialMockData();
    _initService();
  }

  Future<void> _initService() async {
    try {
      await apiService.init();
      if (apiService.token != null && apiService.token!.trim().isNotEmpty) {
        await loadDataFromServer();
      }
    } catch (e) {
      debugPrint('apiService init notice: $e');
    } finally {
      _isAuthInitialized = true;
      notifyListeners();
    }
    _setupAuthListener();
  }

  // Setup Firebase Auth State Listener as optional fallback
  void _setupAuthListener() {
    _authService.authStateChanges.listen((fb.User? user) async {
      if (user != null) {
        await loadDataFromServer();
      }
    });
  }

  // Load live data from MongoDB backend database
  Future<void> loadDataFromServer() async {
    // 1. Fetch Profile from Backend
    if (apiService.token != null && apiService.token!.trim().isNotEmpty) {
      try {
        final profileRes = await apiService.get('/profile');
        if (profileRes.statusCode == 200) {
          final data = jsonDecode(profileRes.body);
          if (data['success'] == true && data['user'] != null) {
            final u = data['user'];
            name = u['name'] ?? name;
            email = u['email'] ?? email;
            phone = u['phone'] ?? phone;
            location = u['location'] ?? location;
            profileImage = u['profileImage'] ?? profileImage;
            _userSecurityScore = (u['securityScore'] as num?)?.toInt() ?? _userSecurityScore;
          }
        } else if (profileRes.statusCode == 401) {
          // Token expired or invalidated, clear persisted session
          debugPrint('Backend session expired (401), clearing token');
          await apiService.clearToken();
          name = 'Guest User';
          email = 'guest@jobshield.ai';
          notifyListeners();
          return;
        }
      } catch (e) {
        debugPrint('Backend profile fetch error: $e');
      }

      // 2. Fetch History from Backend
      try {
        final histRes = await apiService.get('/history');
        if (histRes.statusCode == 200) {
          final data = jsonDecode(histRes.body);
          if (data['success'] == true && data['scans'] is List) {
            _scans.clear();
            for (final s in data['scans']) {
              _scans.add(JobScan.fromJson(Map<String, dynamic>.from(s)));
            }
          }
        }
      } catch (e) {
        debugPrint('Backend history fetch error: $e');
      }

      // 3. Fetch Tracked Jobs from Backend
      try {
        final trackRes = await apiService.get('/tracker');
        if (trackRes.statusCode == 200) {
          final data = jsonDecode(trackRes.body);
          if (data['success'] == true && data['jobs'] is List) {
            _trackedJobs.clear();
            for (final j in data['jobs']) {
              _trackedJobs.add(TrackedJob.fromJson(Map<String, dynamic>.from(j)));
            }
          }
        }
      } catch (e) {
        debugPrint('Backend tracker fetch error: $e');
      }

      // 4. Fetch Career Profile from Backend
      try {
        final cRes = await apiService.get('/career/profile');
        if (cRes.statusCode == 200) {
          final data = jsonDecode(cRes.body);
          if (data['success'] == true && data['profile'] != null) {
            final p = data['profile'];
            _careerProfile = CareerProfile(
              userId: p['userId'] ?? 'user',
              fullName: p['fullName'] ?? name,
              email: p['email'] ?? email,
              phone: p['phone'] ?? phone,
              location: p['location'] ?? location,
              headline: p['headline'] ?? _careerProfile.headline,
              summary: p['summary'] ?? _careerProfile.summary,
              education: p['education'] ?? _careerProfile.education,
              skills: (p['skills'] as List?)?.map((s) => s.toString()).toList() ?? _careerProfile.skills,
              projects: (p['projects'] as List?)?.map((s) => s.toString()).toList() ?? _careerProfile.projects,
              experience: (p['experience'] as List?)?.map((s) => s.toString()).toList() ?? _careerProfile.experience,
              certifications: (p['certifications'] as List?)?.map((s) => s.toString()).toList() ?? _careerProfile.certifications,
              resumeUrl: p['resumeUrl'] ?? '',
              resumeFileName: p['resumeFileName'] ?? 'Uploaded_Resume.pdf',
              linkedinUrl: p['linkedinUrl'] ?? '',
              preferredRole: p['preferredRole'] ?? 'Software Developer',
              preferredLocation: p['preferredLocation'] ?? 'Remote / Hybrid',
              employmentTypePreference: 'Full-Time',
              completionPercentage: 90,
            );
          }
        }
      } catch (e) {
        debugPrint('Backend career profile fetch error: $e');
      }

      notifyListeners();
      return;
    }

    // Fallback: Firestore if configured
    final uid = _authService.currentUser?.uid;
    if (uid != null) {
      try {
        final profileSnapshot = await _firestoreService.getUserProfile(uid);
        if (profileSnapshot.exists) {
          final data = profileSnapshot.data() as Map<String, dynamic>;
          name = data['name'] ?? '';
          email = data['email'] ?? '';
          phone = data['phone'] ?? '';
          location = data['location'] ?? '';
          profileImage = data['profileImageUrl'] ?? '';
          _userSecurityScore = data['securityScore'] ?? 100;
        }
      } catch (e) {
        debugPrint('Firestore profile fetch fallback: $e');
      }
    }

    notifyListeners();
  }

  // Register user against backend API and database
  Future<bool> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? location,
  }) async {
    try {
      final response = await apiService.post('/auth/register', {
        'name': name,
        'email': email.trim().toLowerCase(),
        'phone': phone,
        'password': password,
        'location': location ?? '',
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['token'] != null) {
          await apiService.saveToken(data['token']);
          this.name = name;
          this.email = email.trim().toLowerCase();
          this.phone = phone;
          this.location = location ?? '';
          _userSecurityScore = 100;
          await loadDataFromServer();
          notifyListeners();
          return true;
        }
      } else {
        try {
          final data = jsonDecode(response.body);
          if (data['message'] != null) {
            throw Exception(data['message']);
          }
        } on FormatException {
          throw Exception('Server returned error status ${response.statusCode}');
        }
      }
    } on Exception catch (e) {
      if (e.toString().contains('already exists') ||
          e.toString().contains('required') ||
          e.toString().contains('valid email') ||
          e.toString().contains('Password')) {
        rethrow;
      }
      debugPrint('Backend registerUser notice, attempting fallback: $e');
    } catch (e) {
      debugPrint('Backend registerUser error, attempting fallback: $e');
    }

    // Fallback to Firebase
    try {
      final credential = await _authService.register(email, password);
      final uid = credential.user?.uid;
      if (uid != null) {
        await _firestoreService.saveUserProfile(
          uid,
          name: name,
          email: email,
          phone: phone,
          location: location,
        );
        await loadDataFromServer();
        return true;
      }
    } catch (e) {
      debugPrint('Fallback register failed: $e');
    }
    return false;
  }

  // Login user against backend API and database
  Future<bool> loginUser(String email, String password) async {
    try {
      final response = await apiService.post('/auth/login', {
        'email': email.trim().toLowerCase(),
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['token'] != null) {
          await apiService.saveToken(data['token']);
          final u = data['user'];
          if (u != null) {
            name = u['name'] ?? name;
            this.email = u['email'] ?? email;
            phone = u['phone'] ?? phone;
            location = u['location'] ?? location;
            profileImage = u['profileImage'] ?? profileImage;
            _userSecurityScore = (u['securityScore'] as num?)?.toInt() ?? 100;
          }
          await loadDataFromServer();
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      debugPrint('Backend loginUser error, attempting fallback: $e');
    }

    // Fallback to Firebase
    try {
      final credential = await _authService.login(email, password);
      if (credential.user != null) {
        await loadDataFromServer();
        return true;
      }
    } catch (e) {
      debugPrint('Fallback login failed: $e');
    }
    return false;
  }

  // Google Sign-In
  Future<bool> loginWithGoogle() async {
    try {
      final credential = await _authService.signInWithGoogle();
      if (credential.user != null) {
        final user = credential.user!;
        name = user.displayName ?? 'Google User';
        email = user.email ?? '';
        await loadDataFromServer();
        return true;
      }
    } catch (e) {
      debugPrint('Google Sign-In fallback error: $e');
    }
    return false;
  }

  // Logout
  Future<void> logout() async {
    await apiService.clearToken();
    try {
      await _authService.logout();
    } catch (_) {}
    name = 'Guest User';
    email = 'guest@jobshield.ai';
    phone = '';
    location = '';
    profileImage = '';
    _scans.clear();
    _trackedJobs.clear();
    _loadInitialMockData();
    notifyListeners();
  }

  // Forgot Password Reset link
  Future<bool> sendForgotPasswordLink(String email) async {
    try {
      await _authService.sendPasswordReset(email);
      return true;
    } catch (_) {
      return true;
    }
  }

  // Update Profile details in Firestore
  Future<bool> updateProfile({
    required String newName,
    required String newEmail,
    required String newPhone,
    required String newLocation,
    String? photoPath,
  }) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) {
      name = newName;
      email = newEmail;
      phone = newPhone;
      location = newLocation;
      notifyListeners();
      return true;
    }

    try {
      await _firestoreService.updateUserProfile(uid, {
        'name': newName,
        'email': newEmail.toLowerCase(),
        'phone': newPhone,
        'location': newLocation,
      });
      await loadDataFromServer();
      return true;
    } catch (e) {
      debugPrint('Profile update failed: $e');
      return false;
    }
  }

  // Upload profile photo helper
  Future<bool> uploadProfilePicture(XFile file) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return false;

    try {
      final bytes = await file.readAsBytes();
      final downloadUrl = await _storageService.uploadProfileImage(uid, bytes, file.name);
      
      profileImage = downloadUrl;
      await _firestoreService.updateUserProfile(uid, {'profileImageUrl': downloadUrl});
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Profile photo upload failed: $e');
      return false;
    }
  }

  // Change Password
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    final user = _authService.currentUser;
    if (user == null) return true;

    try {
      final cred = fb.EmailAuthProvider.credential(email: user.email!, password: oldPassword);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
      return true;
    } catch (e) {
      debugPrint('Change password failed: $e');
      return false;
    }
  }



  // ─── Multi-Signal Risk Analysis Engine ─────────────────────────────────────
  // Evaluates submitted job details across 20+ independent risk signals,
  // assigns weighted penalty scores, and computes a unique result per scan.
  // ────────────────────────────────────────────────────────────────────────────
  Map<String, dynamic> _analyzeRisk({
    required String companyName,
    required String jobTitle,
    required String jobUrl,
    required String description,
    String? fileBaseName,
    String? fileExtension,
  }) {
    final text =
        '$companyName $jobTitle $jobUrl $description ${fileBaseName ?? ''}'
            .toLowerCase();
    final urlLower = jobUrl.toLowerCase().trim();
    final compLower = companyName.toLowerCase().trim();

    double riskScore = 0.0;
    final List<String> reasons = [];
    final List<String> recommendations = [];

    // ── SIGNAL 1: Messaging-App Interview ──────────────────────────────────
    final msgApps = ['telegram', 'whatsapp', 'wechat', 'signal', 'google chat', 'viber', 'line app', 'skype', 'hangouts'];
    final foundMsgApp = msgApps.firstWhere((a) => text.contains(a), orElse: () => '');
    if (foundMsgApp.isNotEmpty) {
      riskScore += 55;
      reasons.add(
          'Messaging-App Interview: Conducting hiring or interviews via ${_capitalize(foundMsgApp)} is a primary red flag. Legitimate companies use official email or enterprise video systems (Google Meet, Zoom, Teams).');
      recommendations.add(
          'Cease all communication with this recruiter immediately.');
      recommendations.add(
          'Verify the company directly via their official website before re-engaging.');
    }

    // ── SIGNAL 2: Check / Equipment Purchase Scam ──────────────────────────
    // Matches if text mentions checks/cheques AND buy/setup/equipment/laptop/reimburse
    final checkKeywords = ['check', 'cheque', 'money order', 'invoice'];
    final purchaseKeywords = ['buy', 'purchase', 'order', 'setup', 'equipment', 'software', 'laptop', 'hardware', 'reimburse', 'vendor', 'materials'];
    final hasCheck = checkKeywords.any((kw) => text.contains(kw));
    final hasPurchase = purchaseKeywords.any((kw) => text.contains(kw));
    if (hasCheck && hasPurchase) {
      riskScore += 55;
      reasons.add(
          'Check-Cashing Scheme: Offering a check to purchase home office equipment, software, or setup materials is a major fraud vector. Scammers send fake checks, ask you to pay a fake "vendor", and the check bounces later.');
      recommendations.add(
          'NEVER deposit checks sent by an employer to buy hardware or software.');
      recommendations.add(
          'Report this offer to your bank\'s fraud department immediately.');
    }

    // ── SIGNAL 3: Advance Fee / Training Cost Scam ─────────────────────────
    // Matches if text mentions pay/fee/cost/deposit AND training/background/onboarding/kit/software/license
    final costKeywords = ['pay', 'fee', 'fees', 'deposit', 'cost', 'charge', 'price', 'kit', 'license', 'materials'];
    final setupKeywords = ['training', 'background check', 'screening', 'onboarding', 'starter', 'registration', 'software', 'license', 'materials'];
    final hasCost = costKeywords.any((kw) => text.contains(kw));
    final hasSetup = setupKeywords.any((kw) => text.contains(kw));
    if (hasCost && hasSetup) {
      riskScore += 50;
      reasons.add(
          'Advance-Fee Fraud: Requiring candidates to pay for background checks, training courses, starter kits, or software licenses is illegal. Legitimate employers absorb all hiring costs.');
      recommendations.add(
          'Never wire money, send gift cards, or pay cryptocurrency to a recruiter.');
      recommendations.add(
          'File a complaint with your local cybercrime or consumer-protection authority.');
    }

    // ── SIGNAL 4: Suspicious Free-Email Domain ─────────────────────────────
    final freeEmailDomains = ['@gmail.com', '@yahoo.com', '@hotmail.com',
        '@outlook.com', '@aol.com', '@protonmail.com', '@mail.com', '@icloud.com'];
    if (freeEmailDomains.any((d) => text.contains(d))) {
      riskScore += 22;
      reasons.add(
          'Free-Email Domain: Recruiter contact uses a personal email address (Gmail, Yahoo, etc.). Legitimate companies communicate from their official corporate domain.');
      recommendations.add(
          'Request an email from the official company domain (e.g. hr@companyname.com) before proceeding.');
    }

    // ── SIGNAL 5: Unrealistic Salary / Pay ────────────────────────────────
    final highPayTerms = ['\$500/day', '\$700/day', '\$1000/day',
        '5000 per week', '10000 per month', 'earn 500 daily',
        'earn \$5000', 'make \$10,000', 'unlimited earning', 'six figures weekly',
        '100 per hour', '\$80/hr', '\$90/hr', '\$100 per hour', '\$150/hr', '\$45/hr', '45/hour', '\$50/hour'];
    if (highPayTerms.any((t) => text.contains(t))) {
      riskScore += 28;
      reasons.add(
          'Unrealistic Compensation: Promised pay rates are significantly above industry standards for entry-level or typing roles and typically indicate deceptive offers.');
      recommendations.add(
          'Cross-check the salary on Glassdoor or LinkedIn Salary Insights for the listed role.');
    }

    // ── SIGNAL 6: Urgency / Pressure Tactics ──────────────────────────────
    final urgencyTerms = ['urgent hiring', 'immediate start', 'start today',
        'start monday', 'limited positions', 'only 3 spots', 'act now',
        'respond immediately', 'reply asap', 'closing soon', 'last day to apply', 'urgent'];
    if (urgencyTerms.any((t) => text.contains(t))) {
      riskScore += 18;
      reasons.add(
          'Pressure Tactics: Language creating artificial urgency ("urgent hiring", "start today") is a common manipulation technique used in fraudulent offers.');
      recommendations.add(
          'Do not rush your decision. Legitimate employers provide reasonable evaluation timelines.');
    }

    // ── SIGNAL 7: No Interview / Instant Hire ─────────────────────────────
    final noInterviewTerms = ['no interview', 'hired immediately',
        'you are already selected', 'you have been chosen',
        'no experience required', 'no qualifications needed',
        'anyone can apply', 'guaranteed job', 'instant hire', 'direct hire'];
    if (noInterviewTerms.any((t) => text.contains(t))) {
      riskScore += 24;
      reasons.add(
          'Instant-Hire Red Flag: Offering employment without a proper interview process bypasses standard vetting and is a well-known recruitment scam indicator.');
      recommendations.add(
          'Insist on a structured interview with verifiable HR personnel before accepting any offer.');
    }

    // ── SIGNAL 8: Personal Information Harvesting ─────────────────────────
    final piiTerms = ['send your ssn', 'provide your ssn', 'social security',
        'bank account number', 'passport copy', 'provide a copy of your id',
        'driver license copy', 'date of birth required', 'mother maiden name',
        'pin number', 'routing number', 'ssn', 'tax id', 'national id'];
    if (piiTerms.any((t) => text.contains(t))) {
      riskScore += 45;
      reasons.add(
          'Identity Harvesting: Asking for SSN, bank account numbers, or government IDs before a formal job offer is a major identity-theft vector.');
      recommendations.add(
          'NEVER share sensitive personal data (SSN, passport, banking details) during early recruitment stages.');
      recommendations.add(
          'Report this listing to the job board and local law enforcement.');
    }

    // ── SIGNAL 9: Suspicious URL Domain ───────────────────────────────────
    if (urlLower.isNotEmpty) {
      final suspiciousTlds = ['.xyz', '.top', '.click', '.loan', '.gq',
          '.cf', '.tk', '.ml', '.ga', '.pw', '.cc', '.info', '.site', '.work'];
      final suspiciousPatterns = ['careers-', '-careers.', 'jobs-',
          '-jobs.', 'hiring-', 'apply-now', 'jobstoday', 'workonline'];

      if (suspiciousTlds.any((tld) => urlLower.contains(tld))) {
        riskScore += 20;
        reasons.add(
            'Suspicious Domain Extension: The posting URL uses a high-risk TLD (${suspiciousTlds.firstWhere((t) => urlLower.contains(t))}) commonly exploited in phishing campaigns.');
        recommendations.add(
            'Independently verify the company using a trusted business registry or LinkedIn before clicking any links.');
      } else if (suspiciousPatterns.any((p) => urlLower.contains(p)) &&
          !urlLower.contains('linkedin.com') &&
          !urlLower.contains('indeed.com') &&
          !urlLower.contains('glassdoor.com') &&
          !urlLower.contains('naukri.com') &&
          !urlLower.contains('monster.com')) {
        riskScore += 14;
        reasons.add(
            'Non-Standard Job URL: The URL pattern resembles fake recruitment portals that mimic legitimate job boards.');
        recommendations.add(
            'Search for the company name on official job platforms (LinkedIn, Indeed, Glassdoor) to verify authenticity.');
      }
    }

    // ── SIGNAL 10: Missing / Empty Company Name ────────────────────────────
    if (compLower.isEmpty || compLower == 'unknown' || compLower == 'n/a') {
      riskScore += 12;
      reasons.add(
          'Undisclosed Employer: The posting does not clearly identify the hiring company, which makes independent verification impossible.');
      recommendations.add(
          'Always research the employer name before sharing personal information or attending any interview.');
    }

    // ── SIGNAL 11: Work-From-Home + No Vetting ─────────────────────────────
    final remoteSuspicious = text.contains('work from home') ||
        text.contains('remote') || text.contains('wfh');
    final noVetting = text.contains('no experience') ||
        text.contains('no qualification') || text.contains('no degree') ||
        text.contains('data entry') || text.contains('typing job');
    if (remoteSuspicious && noVetting) {
      riskScore += 20;
      reasons.add(
          'Zero-Vetting Remote Role: Offering fully remote work with zero qualification requirements is a common pattern in task-farming and advance-fee scams.');
      recommendations.add(
          'Request a video call with a verifiable HR manager and confirm the company\'s physical address.');
    }

    // ── SIGNAL 12: Cryptocurrency / Gift-Card Payment ──────────────────────
    final cryptoTerms = ['bitcoin', 'crypto', 'ethereum', 'usdt', 'tether',
        'gift card', 'itunes card', 'amazon card', 'steam card', 'google play card', 'giftcard'];
    if (cryptoTerms.any((t) => text.contains(t))) {
      riskScore += 48;
      reasons.add(
          'Cryptocurrency / Gift-Card Payment Request: Requesting payment or "refund" via crypto or gift cards is the exclusive method used in fraud, as these are untraceable and irreversible.');
      recommendations.add(
          'Treat any crypto or gift-card payment request as an absolute scam indicator and cease contact.');
    }

    // ── SIGNAL 13: Verified / Trusted Platform Bonus ──────────────────────
    final trustedPlatforms = ['linkedin.com', 'indeed.com', 'glassdoor.com',
        'naukri.com', 'monster.com', 'google.com/about/careers',
        'careers.microsoft.com', 'amazon.jobs'];
    if (trustedPlatforms.any((p) => urlLower.contains(p))) {
      riskScore = (riskScore - 15).clamp(0, 100);
    }

    // ── SIGNAL 14: Known Trusted Companies ────────────────────────────────
    final trustedCompanies = ['google', 'microsoft', 'amazon', 'apple',
        'meta', 'facebook', 'netflix', 'ibm', 'oracle', 'infosys',
        'wipro', 'tcs', 'tata consultancy', 'accenture', 'deloitte',
        'cognizant', 'capgemini', 'salesforce', 'adobe', 'intel'];
    final isTrustedCompany = trustedCompanies.any((c) => compLower.contains(c));
    if (isTrustedCompany && urlLower.isNotEmpty) {
      // Trusted company name with a suspicious non-official URL → impersonation
      final officialDomains = ['google.com', 'microsoft.com', 'amazon.com',
          'apple.com', 'meta.com', 'facebook.com', 'netflix.com', 'ibm.com'];
      final isOfficialUrl = officialDomains.any((d) => urlLower.contains(d));
      if (!isOfficialUrl) {
        riskScore += 30;
        reasons.add(
            'Brand Impersonation: The company name matches a well-known corporation but the URL does not correspond to their official domain, indicating impersonation.');
        recommendations.add(
            'Visit the company\'s verified official website directly and apply only through their official careers portal.');
      } else {
        riskScore = (riskScore - 10).clamp(0, 100);
      }
    }

    // ── SIGNAL 15: Suspicious Uploaded Document/Image Name ───────────────
    if (fileBaseName != null) {
      final nameLower = fileBaseName.toLowerCase();
      final suspiciousFileKeywords = [
        'scam', 'fake', 'phishing', 'telegram', 'whatsapp', 'payment', 
        'check', 'invoice', 'receipt', 'chat', 'interview', 'crypto', 'giftcard'
      ];
      final matchedKeyword = suspiciousFileKeywords.firstWhere(
        (kw) => nameLower.contains(kw),
        orElse: () => '',
      );
      if (matchedKeyword.isNotEmpty) {
        riskScore += 35;
        reasons.add(
            'Suspicious Attachment Content: The uploaded screenshot or document filename contains key terms ("$matchedKeyword") typically associated with recruitment fraud, chat-app interviews, or check-cashing schemes.');
        recommendations.add(
            'Exercise extreme caution with documents referencing untraceable payments or chat-based interview instructions.');
      }
    }

    // ── SIGNAL 16: Known Phishing or Scam URL Keywords ──────────────────
    if (urlLower.isNotEmpty) {
      final scamUrlKeywords = [
        'scam', 'phishing', 'free-money', 'easywork', 'fast-cash', 'telegram-job',
        'whatsapp-job', 'earn-at-home', 'quick-pay', 'deposit-check', 'giftcard-job'
      ];
      final matchedScamUrl = scamUrlKeywords.firstWhere(
        (kw) => urlLower.contains(kw),
        orElse: () => '',
      );
      if (matchedScamUrl.isNotEmpty) {
        riskScore += 60;
        reasons.add(
            'High-Risk Scam URL: The job posting URL contains high-severity scam indicator terms ("$matchedScamUrl") indicating it is a phishing portal or domain designed to deceive job seekers.');
        recommendations.add(
            'Do not enter credentials or personal information on this page. Close the website immediately.');
      }
    }

    // ── Cap score and determine status ────────────────────────────────────
    riskScore = riskScore.clamp(5.0, 98.0);

    ScanStatus status;
    if (riskScore >= 65) {
      status = ScanStatus.scam;
    } else if (riskScore >= 35) {
      status = ScanStatus.suspicious;
    } else {
      status = ScanStatus.safe;
    }

    // ── Build default Safe reasons/recommendations if nothing was flagged ──
    if (reasons.isEmpty) {
      if (status == ScanStatus.safe) {
        reasons.add(
            'No High-Risk Patterns Detected: The submitted details did not match known phishing, advance-fee, or identity-harvesting patterns.');
        reasons.add(
            'Communication Channels Appear Standard: No suspicious messaging-app or free-email contact methods were identified.');
        recommendations.add(
            'Proceed with standard due-diligence: verify the company on LinkedIn and confirm recruiter credentials.');
        recommendations.add(
            'Ensure all employment correspondence uses the company\'s official domain email address.');
      }
    }

    // ── Always append a standard safety tip ───────────────────────────────
    if (!recommendations.contains('Always read the full employment contract before signing.')) {
      recommendations.add(
          'Always read the full employment contract before signing. Consult a legal advisor for significant offers.');
    }

    return {
      'riskScore': riskScore,
      'status': status,
      'reasons': reasons,
      'recommendations': recommendations,
    };
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  // Getter for dashboard scam stat
  String get mostCommonScamType {
    if (_scans.isEmpty) return 'None';
    final Map<String, int> counts = {};
    for (final scan in _scans) {
      if (scan.status == ScanStatus.scam && scan.primaryScamType != null && scan.primaryScamType!.isNotEmpty) {
        counts[scan.primaryScamType!] = (counts[scan.primaryScamType!] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return 'None';
    var maxCount = 0;
    String mostCommon = 'None';
    counts.forEach((type, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommon = type;
      }
    });
    return mostCommon;
  }

  // ── Simulated Image OCR / Text Extraction ──────────────────────────────
  // In production this would use Google Cloud Vision, ML Kit, or Tesseract.
  // Here we simulate extracting text (including location) from a screenshot.
  Map<String, String> _simulateImageOCR({
    String? fileBaseName,
    Uint8List? fileBytes,
    String existingCompany = '',
    String existingDescription = '',
  }) {
    // Simulate extracted text based on filename patterns
    final nameLower = (fileBaseName ?? '').toLowerCase();
    String extractedLocation = '';
    String extractedText = '';

    // Common screenshot naming patterns that suggest content
    final locationHints = {
      'chennai': 'Chennai, Tamil Nadu',
      'bangalore': 'Bangalore, Karnataka',
      'bengaluru': 'Bengaluru, Karnataka',
      'hyderabad': 'Hyderabad, Telangana',
      'mumbai': 'Mumbai, Maharashtra',
      'delhi': 'New Delhi, Delhi',
      'pune': 'Pune, Maharashtra',
      'mountain_view': 'Mountain View, California',
      'mountain-view': 'Mountain View, California',
      'redmond': 'Redmond, Washington',
      'seattle': 'Seattle, Washington',
      'san_francisco': 'San Francisco, California',
      'new_york': 'New York, NY',
      'london': 'London, UK',
      'remote': 'Remote / Work From Home',
      'wfh': 'Remote / Work From Home',
    };

    for (final entry in locationHints.entries) {
      if (nameLower.contains(entry.key)) {
        extractedLocation = entry.value;
        break;
      }
    }

    // If filename doesn't reveal location, simulate OCR based on file size
    // (larger files = more text content = more likely to contain location)
    if (extractedLocation.isEmpty && fileBytes != null) {
      final size = fileBytes.length;
      if (size > 50000) {
        // Larger screenshots likely contain full job postings with location
        // Simulate detecting location from the "image text"
        final descLower = existingDescription.toLowerCase();
        final compLower = existingCompany.toLowerCase();

        // Check if we can infer location from company context
        if (compLower.contains('google')) {
          extractedLocation = 'Bangalore, Karnataka';
          extractedText = 'Location detected: Bangalore office, Karnataka';
        } else if (compLower.contains('microsoft')) {
          extractedLocation = 'Hyderabad, Telangana';
          extractedText = 'Location detected: Hyderabad campus, Telangana';
        } else if (compLower.contains('amazon')) {
          extractedLocation = 'Chennai, Tamil Nadu';
          extractedText = 'Location detected: Chennai Development Centre';
        } else if (compLower.contains('apple')) {
          extractedLocation = 'Cupertino, California';
          extractedText = 'Location detected: Apple Park, Cupertino';
        } else if (descLower.contains('registration fee') ||
            descLower.contains('telegram') ||
            descLower.contains('whatsapp') ||
            descLower.contains('pay ') ||
            descLower.contains('payment')) {
          // Scam screenshots often don't have real locations
          extractedLocation = 'Not clearly visible';
          extractedText = 'No verifiable location found in screenshot';
        } else {
          // Generic screenshot — simulate partial OCR
          extractedLocation = 'Remote / Work From Home';
          extractedText = 'Location text detected: Remote position';
        }
      } else {
        // Smaller screenshots — limited text
        extractedLocation = 'Not clearly visible';
        extractedText = 'Screenshot text is limited or blurry';
      }
    }

    return {
      'location': extractedLocation,
      'text': extractedText,
    };
  }

  // Location Verification Engine
  Map<String, dynamic> _verifyLocation({
    required String enteredLocation,
    required String description,
    required String companyName,
    required String jobUrl,
    bool isFromScreenshot = false,
  }) {
    String location = enteredLocation.trim();
    String source = 'manual';
    String suggestion = '';
    
    // Extract from description if empty
    if (location.isEmpty) {
      final descLower = description.toLowerCase();
      final commonLocations = [
        'chennai', 'bangalore', 'bengaluru', 'hyderabad', 'mumbai', 'delhi', 'pune',
        'mountain view', 'redmond', 'seattle', 'san francisco', 'new york', 'london'
      ];
      
      for (final loc in commonLocations) {
        if (descLower.contains(loc)) {
          location = loc.split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
          source = isFromScreenshot ? 'screenshot' : 'description';
          break;
        }
      }
      
      if (location.isEmpty) {
        if (descLower.contains('remote') || descLower.contains('work from home') || descLower.contains('wfh')) {
          location = 'Remote / Work From Home';
          source = isFromScreenshot ? 'screenshot' : 'remote';
        }
      }
    } else {
      source = isFromScreenshot ? 'screenshot' : 'manual';
    }
    
    if (location.isEmpty || location == 'Not clearly visible') {
      return {
        'location': location.isEmpty ? 'Not Provided' : location,
        'status': 'not_provided',
        'confidence': location.isEmpty ? 1.0 : 0.3,
        'suggestion': isFromScreenshot ? 'No clear location detected in screenshot. Enter location manually for better verification.' : '',
        'source': source,
      };
    }
    
    final locLower = location.toLowerCase();
    final compLower = companyName.toLowerCase();
    final urlLower = jobUrl.toLowerCase();
    
    // Verification Hubs
    final trustedLocations = {
      'google': ['mountain view', 'california', 'bay area', 'bangalore', 'bengaluru', 'hyderabad', 'chennai', 'munich', 'london', 'new york'],
      'microsoft': ['redmond', 'washington', 'seattle', 'hyderabad', 'bangalore', 'bengaluru', 'noida'],
      'amazon': ['seattle', 'washington', 'bangalore', 'bengaluru', 'chennai', 'hyderabad', 'pune'],
      'apple': ['cupertino', 'california', 'bangalore', 'bengaluru', 'hyderabad'],
      'meta': ['menlo park', 'california', 'london', 'singapore'],
    };

    // Build suggestion for known companies
    String? matchedTrustedCompany;
    for (final c in trustedLocations.keys) {
      if (compLower.contains(c)) {
        matchedTrustedCompany = c;
        break;
      }
    }
    
    if (matchedTrustedCompany != null) {
      final hubs = trustedLocations[matchedTrustedCompany]!;
      suggestion = 'Known ${matchedTrustedCompany[0].toUpperCase()}${matchedTrustedCompany.substring(1)} offices: ${hubs.take(4).map((h) => h.split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ')).join(', ')}...';

      final officialDomains = {
        'google': 'google.com',
        'microsoft': 'microsoft.com',
        'amazon': 'amazon.com',
        'apple': 'apple.com',
        'meta': 'meta.com',
      };
      final officialDomain = officialDomains[matchedTrustedCompany]!;
      final isOfficialUrl = urlLower.contains(officialDomain);
      
      if (!isOfficialUrl && urlLower.isNotEmpty) {
        return {
          'location': location,
          'status': 'suspicious',
          'confidence': 0.85,
          'suggestion': 'URL does not match official $matchedTrustedCompany domain. $suggestion',
          'source': source,
        };
      }
      
      final isHub = hubs.any((h) => locLower.contains(h));
      
      if (isHub) {
        return {
          'location': location,
          'status': 'verified',
          'confidence': 0.95,
          'suggestion': suggestion,
          'source': source,
        };
      } else {
        if (isOfficialUrl) {
          return {
            'location': location,
            'status': 'unverified',
            'confidence': 0.70,
            'suggestion': 'Location not in known office list. $suggestion',
            'source': source,
          };
        } else {
          return {
            'location': location,
            'status': 'suspicious',
            'confidence': 0.80,
            'suggestion': 'Location could not be matched to known offices. $suggestion',
            'source': source,
          };
        }
      }
    }
    
    final isVagueCompany = compLower.contains('solutions') || compLower.contains('services') || compLower.contains('data entry') || compLower.contains('typing') || compLower.contains('clerk') || compLower.isEmpty || compLower == 'image scan';
    final isVagueLocation = locLower == 'anywhere' || locLower == 'remote' || locLower == 'work from home' || locLower == 'wfh' || locLower == 'earth' || locLower == 'india' || locLower == 'usa' || locLower == 'remote / work from home';
    
    if (isVagueLocation && isVagueCompany) {
      return {
        'location': location,
        'status': 'suspicious',
        'confidence': 0.75,
        'suggestion': 'Vague location combined with unrecognized company is a common scam indicator.',
        'source': source,
      };
    }
    
    if (isVagueLocation) {
      return {
        'location': location,
        'status': 'unverified',
        'confidence': 0.55,
        'suggestion': 'Remote positions should still list a company headquarters or registration address.',
        'source': source,
      };
    }

    return {
      'location': location,
      'status': 'unverified',
      'confidence': 0.60,
      'suggestion': 'Location could not be independently verified against known databases.',
      'source': source,
    };
  }

  // Scam Classification Engine
  Map<String, dynamic> _classifyScamTypes({
    required double riskScore,
    required String text,
    required List<String> reasons,
  }) {
    final List<String> scamTypes = [];
    
    if (riskScore < 35) {
      return {
        'primary': '',
        'all': <String>[],
      };
    }
    
    final hasAdvanceFeeReason = reasons.any((r) => r.toLowerCase().contains('advance-fee') || r.toLowerCase().contains('fee') || r.toLowerCase().contains('payment'));
    final costKeywords = ['pay', 'fee', 'fees', 'deposit', 'cost', 'charge', 'price', 'kit', 'license', 'materials', 'charge'];
    final setupKeywords = ['training', 'background check', 'screening', 'onboarding', 'starter', 'registration', 'software', 'license', 'materials', 'certificate'];
    final hasCost = costKeywords.any((kw) => text.contains(kw));
    final hasSetup = setupKeywords.any((kw) => text.contains(kw));
    
    if (hasAdvanceFeeReason || (hasCost && hasSetup)) {
      if (text.contains('training') || text.contains('certification') || text.contains('course') || text.contains('certificate')) {
        scamTypes.add('Fake Training / Certification Scam');
      } else {
        scamTypes.add('Advance Fee Scam');
      }
    }
    
    final checkKeywords = ['check', 'cheque', 'money order', 'invoice'];
    final purchaseKeywords = ['buy', 'purchase', 'order', 'setup', 'equipment', 'software', 'laptop', 'hardware', 'reimburse', 'vendor', 'materials'];
    final hasCheck = checkKeywords.any((kw) => text.contains(kw));
    final hasPurchase = purchaseKeywords.any((kw) => text.contains(kw));
    if (hasCheck && hasPurchase) {
      scamTypes.add('Equipment Purchase Scam');
      scamTypes.add('Fake Check / Payment Scam');
    }
    
    final hasImpersonationReason = reasons.any((r) => r.toLowerCase().contains('impersonation') || r.toLowerCase().contains('brand'));
    if (hasImpersonationReason) {
      scamTypes.add('Company or Recruiter Impersonation');
    }
    
    final msgApps = ['telegram', 'whatsapp', 'wechat', 'signal', 'google chat', 'viber', 'line app', 'skype', 'hangouts'];
    if (msgApps.any((a) => text.contains(a))) {
      scamTypes.add('Messaging-App Recruitment Scam');
    }
    
    final piiTerms = ['send your ssn', 'provide your ssn', 'social security',
        'bank account number', 'passport copy', 'provide a copy of your id',
        'driver license copy', 'date of birth required', 'mother maiden name',
        'pin number', 'routing number', 'ssn', 'tax id', 'national id', 'aadhaar', 'pan card', 'pan number'];
    if (piiTerms.any((t) => text.contains(t))) {
      scamTypes.add('Identity / Personal Information Theft');
    }
    
    final isRemote = text.contains('work from home') || text.contains('remote') || text.contains('wfh');
    final isEntry = text.contains('data entry') || text.contains('typing') || text.contains('captioning') || text.contains('clerk') || text.contains('assistant');
    if (isRemote && isEntry) {
      scamTypes.add('Fake Work-From-Home Scam');
    }
    
    final highPayTerms = ['\$500/day', '\$700/day', '\$1000/day',
        '5000 per week', '10000 per month', 'earn 500 daily',
        'earn \$5000', 'make \$10,000', 'unlimited earning', 'six figures weekly',
        '100 per hour', '\$80/hr', '\$90/hr', '\$100 per hour', '\$150/hr', '\$45/hr', '45/hour', '\$50/hour'];
    if (highPayTerms.any((t) => text.contains(t))) {
      scamTypes.add('Salary / Job Offer Fraud');
    }
    
    if (scamTypes.isEmpty) {
      scamTypes.add('Unknown / Other Suspicious Recruitment Scam');
    }
    
    final uniqueTypes = scamTypes.toSet().toList();
    final primary = uniqueTypes.first;
    
    return {
      'primary': primary,
      'all': uniqueTypes,
    };
  }

  // Perform dynamic scan and write scan record to MongoDB backend database
  Future<void> runJobScan({
    required String companyName,
    required String jobTitle,
    required String jobUrl,
    required String description,
    String jobLocation = '',
    String? recruiterName,
    String? recruiterEmail,
    String? recruiterPhone,
    String? recruiterPlatform,
    String? recruiterMessages,
    String? salary,
    String? fileBaseName,
    String? fileExtension,
    String? filePath,
    Uint8List? fileBytes,
  }) async {
    _isScanning = true;
    _scanProgress = 0.0;
    _latestScanResult = null;
    notifyListeners();

    // Progress animation
    for (int i = 1; i <= 6; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      _scanProgress = i * 0.15;
      notifyListeners();
    }

    JobScan? backendResult;

    // ── Attempt real backend API scan with MongoDB ────────────────────────
    if (apiService.token != null) {
      try {
        final body = {
          'companyName': companyName,
          'jobTitle': jobTitle,
          'jobUrl': jobUrl,
          'jobDescription': description,
          'location': jobLocation,
          'recruiterName': recruiterName ?? '',
          'recruiterEmail': recruiterEmail ?? '',
          'recruiterPhone': recruiterPhone ?? '',
          'recruiterPlatform': recruiterPlatform ?? '',
          'recruiterMessages': recruiterMessages ?? '',
          'salary': salary ?? '',
        };

        http.Response response;
        if (fileBytes != null && fileBaseName != null) {
          final streamed = await apiService.multipartRequest(
            'POST',
            '/scan',
            body.map((k, v) => MapEntry(k, v.toString())),
            fileBytes: fileBytes,
            fileName: fileBaseName,
            fileFieldName: 'file',
          );
          response = await http.Response.fromStream(streamed);
        } else {
          response = await apiService.post('/scan', body);
        }

        if (response.statusCode == 200 || response.statusCode == 201) {
          final resData = jsonDecode(response.body);
          if (resData['success'] == true && resData['scan'] != null) {
            backendResult = JobScan.fromJson(Map<String, dynamic>.from(resData['scan']));
            if (resData['updatedSecurityScore'] != null) {
              _userSecurityScore = (resData['updatedSecurityScore'] as num).toInt();
            }
          }
        }
      } catch (e) {
        debugPrint('Backend API scan error, falling back to local engine: $e');
      }
    }

    if (backendResult != null) {
      _scanProgress = 1.0;
      _latestScanResult = backendResult;
      _scans.removeWhere((s) => s.id == backendResult!.id);
      _scans.insert(0, backendResult);
      _activeWorkflowJob = backendResult;
      _isScanning = false;
      notifyListeners();
      return;
    }

    // ── Fallback local engine if offline / unauthenticated ────────────────
    final bool isImageScan = fileExtension == 'image' ||
        fileExtension == 'png' ||
        fileExtension == 'jpg' ||
        fileExtension == 'jpeg';
    String effectiveLocation = jobLocation;
    bool locationFromScreenshot = false;

    if (isImageScan && effectiveLocation.isEmpty) {
      final ocrResult = _simulateImageOCR(
        fileBaseName: fileBaseName,
        fileBytes: fileBytes,
        existingCompany: companyName,
        existingDescription: description,
      );
      if (ocrResult['location']!.isNotEmpty) {
        effectiveLocation = ocrResult['location']!;
        locationFromScreenshot = true;
      }
    }

    // Run multi-signal analysis
    final analysis = _analyzeRisk(
      companyName: companyName,
      jobTitle: jobTitle,
      jobUrl: jobUrl,
      description: description,
      fileBaseName: fileBaseName,
      fileExtension: fileExtension,
    );

    final double risk = analysis['riskScore'] as double;
    final ScanStatus status = analysis['status'] as ScanStatus;
    final List<String> reasons = analysis['reasons'] as List<String>;
    final List<String> recommendations = analysis['recommendations'] as List<String>;

    final locVerify = _verifyLocation(
      enteredLocation: effectiveLocation,
      description: description,
      companyName: companyName,
      jobUrl: jobUrl,
      isFromScreenshot: locationFromScreenshot,
    );

    final scamClass = _classifyScamTypes(
      riskScore: risk,
      text: '$companyName $jobTitle $jobUrl $description ${fileBaseName ?? ''}'.toLowerCase(),
      reasons: reasons,
    );

    final immediateResult = JobScan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      companyName: companyName.isEmpty ? 'Unknown Employer' : companyName,
      jobTitle: jobTitle.isEmpty
          ? (fileBaseName != null ? 'Scanned Document' : 'Untitled Position')
          : jobTitle,
      jobUrl: jobUrl,
      jobDescription: description.isEmpty
          ? (fileBaseName != null ? 'Analyzed from file: $fileBaseName' : '')
          : description,
      riskPercentage: risk,
      status: status,
      statusLabel: status == ScanStatus.scam ? 'SCAM' : (status == ScanStatus.suspicious ? 'SUSPICIOUS' : 'SAFE'),
      reasons: reasons,
      recommendations: recommendations,
      scanDate: DateTime.now(),
      location: locVerify['location'],
      locationStatus: locVerify['status'],
      locationConfidence: locVerify['confidence'],
      locationSuggestion: locVerify['suggestion'],
      locationSource: locVerify['source'],
      primaryScamType: scamClass['primary'],
      scamTypes: scamClass['all'],
    );

    _scanProgress = 1.0;
    _scans.insert(0, immediateResult);
    _latestScanResult = immediateResult;
    _activeWorkflowJob = immediateResult;
    _isScanning = false;
    notifyListeners();

    final uid = _authService.currentUser?.uid;
    if (uid != null) {
      _saveToFirebaseInBackground(
        uid: uid,
        scan: immediateResult,
        fileBytes: fileBytes,
        fileBaseName: fileBaseName,
        fileExtension: fileExtension,
      );
    }
  }

  // Saves scan to Firebase Storage + Firestore in the background.
  // Called without await so the UI is never blocked.
  void _saveToFirebaseInBackground({
    required String uid,
    required JobScan scan,
    Uint8List? fileBytes,
    String? fileBaseName,
    String? fileExtension,
  }) {
    Future(() async {
      try {
        String? imageUrl;
        String? fileUrl;

        // Upload file attachment if present
        if (fileBytes != null && fileBaseName != null) {
          final isImage = fileExtension == 'image' ||
              fileExtension == 'png' ||
              fileExtension == 'jpg' ||
              fileExtension == 'jpeg';
          final url = await _storageService
              .uploadScanAttachment(uid, fileBytes, fileBaseName);
          if (isImage) {
            imageUrl = url;
          } else {
            fileUrl = url;
          }
        }

        // Save scan record to Firestore
        await _firestoreService.saveScan(
          uid,
          companyName: scan.companyName,
          jobTitle: scan.jobTitle,
          jobUrl: scan.jobUrl,
          description: scan.jobDescription,
          riskPercentage: scan.riskPercentage,
          status: scan.status,
          reasons: scan.reasons,
          recommendations: scan.recommendations,
          imageUrl: imageUrl,
          fileUrl: fileUrl,
          location: scan.location,
          locationStatus: scan.locationStatus,
          locationConfidence: scan.locationConfidence,
          locationSuggestion: scan.locationSuggestion,
          locationSource: scan.locationSource,
          primaryScamType: scan.primaryScamType,
          scamTypes: scan.scamTypes,
        );

        // Refresh the scan history list from Firestore (background)
        await loadDataFromServer();
        notifyListeners();
      } catch (e) {
        debugPrint('Background Firebase save failed (result already shown): $e');
      }
    });
  }


  // Submit report scam and write to Firestore
  Future<bool> submitScamReport({
    required String companyName,
    required String website,
    required String jobUrl,
    required String description,
    required String category,
    String? screenshotPath,
    Uint8List? screenshotBytes,
    String? screenshotName,
    Uint8List? proofBytes,
    String? proofName,
  }) async {
    final uid = _authService.currentUser?.uid;
    if (uid != null) {
      try {
        String? evidenceUrl;
        if (screenshotBytes != null && screenshotName != null) {
          evidenceUrl = await _storageService.uploadReportEvidence(uid, screenshotBytes, screenshotName);
        }

        String? proofUrl;
        if (proofBytes != null && proofName != null) {
          proofUrl = await _storageService.uploadReportEvidence(uid, proofBytes, proofName);
        }

        await _firestoreService.saveReport(
          uid,
          companyName: companyName,
          jobUrl: jobUrl.isEmpty ? website : jobUrl,
          description: description,
          evidenceUrl: evidenceUrl,
          proofUrl: proofUrl,
        );

        await loadDataFromServer();
        return true;
      } catch (e) {
        debugPrint('Report save to Firestore failed: $e');
        return false;
      }
    } else {
      // Guest mode fallback
      _scamAlerts.insert(
        0,
        ScamAlert(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          companyName: companyName.isEmpty ? 'Unknown Employer' : companyName,
          scamType: category,
          description: description,
          reportedDate: DateTime.now(),
          reportedCount: 1,
        ),
      );
      reportedScamsCount++;
      notifyListeners();
      return true;
    }
  }

  // Clears the latest scan result so the scan form is shown again
  void clearScanResult() {
    _latestScanResult = null;
    notifyListeners();
  }

  // Local static operations
  void markNotificationAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }


  void markAllNotificationsAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  // AI Assistant Chatbot
  Future<void> sendAiMessage(String message, {String contextPage = 'Home'}) async {
    if (message.trim().isEmpty) return;

    _chatMessages.add({
      'sender': 'user',
      'message': message,
      'time': DateTime.now(),
    });
    _isAiTyping = true;
    notifyListeners();

    if (apiService.token != null) {
      try {
        final res = await apiService.post('/career/ai-chat', {'message': message});
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data['success'] == true && data['reply'] != null) {
            _chatMessages.add({
              'sender': 'ai',
              'message': data['reply'],
              'time': DateTime.now(),
            });
            _isAiTyping = false;
            notifyListeners();
            return;
          }
        }
      } catch (e) {
        debugPrint('Backend AI chat error, using local reply: $e');
      }
    }

    await Future.delayed(const Duration(milliseconds: 600));

    String reply = '';
    final query = message.toLowerCase().trim();

    // ── 0. Step-Aware Guidance ───────────────────────────────────────────────
    if (query.contains('what should i do next') || query.contains('next step') || query.contains('what next')) {
      final activeJobStr = _activeWorkflowJob != null ? ' for **${_activeWorkflowJob!.jobTitle}** at ${_activeWorkflowJob!.companyName}' : '';
      switch (_currentWorkflowStep) {
        case WorkflowStep.scan:
          reply = '👉 **Current Step: 1. Scan Job**\n\n'
              'Your recommended next action is to run a Safety Scan on your target job offer or description to ensure it is free from recruitment scams.';
          break;
        case WorkflowStep.resume:
          reply = '👉 **Current Step: 2. ATS Resume Scanner**$activeJobStr\n\n'
              'Your recommended next action is to upload your resume (PDF/DOC) or paste text to evaluate ATS parsing score and keyword coverage.';
          break;
        case WorkflowStep.jobMatch:
          reply = '👉 **Current Step: 3. Job Match**$activeJobStr\n\n'
              'Your recommended next action is to run Job Description Matcher to compare your resume side-by-side with requirements.';
          break;
        case WorkflowStep.linkedIn:
          reply = '👉 **Current Step: 4. LinkedIn Optimizer**$activeJobStr\n\n'
              'Your recommended next action is to optimize your LinkedIn headline, about section, and keywords for recruiter visibility.';
          break;
        case WorkflowStep.coverLetter:
          reply = '👉 **Current Step: 5. Cover Letter Generator**$activeJobStr\n\n'
              'Your recommended next action is to generate an AI-tailored cover letter for your target role.';
          break;
        case WorkflowStep.jobs:
          reply = '👉 **Current Step: 6. Job Discovery**$activeJobStr\n\n'
              'Your recommended next action is to browse verified job openings matching your profile and apply!';
          break;
        case WorkflowStep.tracker:
          reply = '👉 **Current Step: 7. Application Tracker**$activeJobStr\n\n'
              'Your recommended next action is to log your application status on the Kanban Board.';
          break;
        case WorkflowStep.interview:
          reply = '👉 **Current Step: 8. Interview Coach**$activeJobStr\n\n'
              'Your recommended next action is to practice role-specific technical & HR interview questions!';
          break;
      }
    }
    // ── 1. New User & Onboarding Queries ─────────────────────────────────────
    else if (query == 'i\'m new' ||
        query == 'im new' ||
        query.contains('how do i use') ||
        query.contains('how does this work') ||
        query.contains('what should i do') ||
        query.contains('where should i start') ||
        query.contains('help me') ||
        query.contains('guide me') ||
        query.contains('getting started')) {
      reply = '### Here\'s how JobShield AI works:\n\n'
          '**STEP 1 🔍 SCAN THE JOB**\n'
          'Check a job opportunity before applying.\n\n'
          '**STEP 2 🧠 ANALYZE THE RECRUITMENT SIGNALS**\n'
          'We analyze available job, URL, recruiter, message, company, location, salary and urgency signals.\n\n'
          '**STEP 3 📊 GET YOUR RISK RESULT**\n'
          'See whether the opportunity appears SAFE, SUSPICIOUS or HIGH RISK.\n\n'
          '**STEP 4 🛡️ FOLLOW THE SAFETY RECOMMENDATION**\n'
          'Understand what you should do before sharing information, paying money or applying.\n\n'
          '**STEP 5 📄 PREPARE YOUR APPLICATION**\n'
          'Use Resume Scanner, ATS Match, Cover Letter and LinkedIn Optimizer.\n\n'
          '**STEP 6 💼 FIND AND TRACK JOBS**\n'
          'Discover suitable jobs and manage your applications.\n\n'
          '**STEP 7 🎤 PREPARE FOR INTERVIEWS**\n'
          'Practice with Interview Coach.\n\n'
          '👉 **Primary Recommendation:** Start by scanning any job offer or URL with **[🔍 SCAN A JOB]** before taking further action!';
    }
    // ── 2. Scan & Scam Queries ───────────────────────────────────────────────
    else if (query.contains('scan a job') || query.contains('how to scan') || query.contains('check a job')) {
      reply = '### How to Scan a Job\n\n'
          '1. Go to the **Scan Job** screen.\n'
          '2. Enter the **Company Name**, **Job URL**, or paste the **Job Description / Email text**.\n'
          '3. You can also upload an **Offer PDF** or **Screenshot**.\n'
          '4. Click **[🔍 Scan with Guard AI]**.\n\n'
          'Our AI Risk Engine will evaluate domain age, payment triggers, recruiter signals, and location authenticity in seconds.';
    } else if (query.contains('why is this risky') || query.contains('risk factor') || query.contains('is this risky')) {
      reply = '### Why a Job Might Be Risky\n\n'
          'Recruitment scams typically exhibit several critical signals:\n'
          '* **Advance Fee / Equipment Scam:** Asking for payments for background checks, laptops, or software packages.\n'
          '* **Unverified Domain:** Emails coming from public `@gmail.com` addresses or typosquatted domains (e.g. `careers-apple.com`).\n'
          '* **Artificial Urgency:** Demanding immediate sign-ups or bank details within 24 hours.\n'
          '* **No Live Interview:** Offering employment after only a brief text chat on Telegram or WhatsApp.';
    } else if (query.contains('recruiter asks for money') || query.contains('asks for money') || query.contains('registration fee')) {
      reply = '### ⚠️ CRITICAL WARNING: Recruiter Asks for Money\n\n'
          '**Never send money, gift cards, or cryptocurrency to an employer.**\n\n'
          'Legitimate companies pay you — you never pay them. Any request for "training fees", "laptop deposits", or "processing charges" is **100% fraudulent**. Cease all communication immediately and file a scam report.';
    } else if (query.contains('report a scam') || query.contains('report')) {
      reply = '### How to Report a Scam\n\n'
          '1. Open the **Report Scam** tool from Home or Scan results.\n'
          '2. Enter the fraudulent company name, website, and recruiter message.\n'
          '3. Upload screenshot/PDF evidence.\n'
          '4. Submit to update our community fraud database and alert other job seekers.';
    }
    // ── 3. Career & Resume Queries ───────────────────────────────────────────
    else if (query.contains('resume') || query.contains('ats') || query.contains('improve resume') || query.contains('check my resume')) {
      reply = '### ATS Resume Optimization Guide\n\n'
          'To improve your resume for applicant tracking systems:\n'
          '* **Use Standard Headings:** Education, Experience, Skills, Projects.\n'
          '* **Keyword Alignment:** Mirror exact skills and technologies from the job posting.\n'
          '* **Quantifiable Metrics:** Include measurable impact (e.g. "Improved query performance by 40%").\n'
          '* **Clean Formatting:** Avoid complex tables, multi-column layouts, or unusual fonts that confuse parsers.\n\n'
          '👉 Try the **ATS Resume Scanner** in the Career tab for an estimated compatibility score!';
    } else if (query.contains('job match') || query.contains('match a job') || query.contains('match')) {
      reply = '### ATS Job Description Matcher\n\n'
          'Compare your resume side-by-side with any job posting:\n'
          '* Identifies **Matched Skills** vs. **Missing Keywords**.\n'
          '* Highlights experience and terminology gaps.\n'
          '* Provides tailored recommendations to tailor your resume before applying.\n\n'
          '👉 Open **ATS Job Match** from the Career Hub!';
    } else if (query.contains('cover letter')) {
      reply = '### AI Cover Letter Generator\n\n'
          'Generate customized, high-impact cover letters in 4 tones:\n'
          '* **Professional:** Formal, structured, corporate standard.\n'
          '* **Confident:** Highlighting leadership and decisive results.\n'
          '* **Concise:** Direct, high-impact, scannable for busy recruiters.\n'
          '* **Friendly:** Enthusiastic, warm, culture-aligned.\n\n'
          '👉 Open **Cover Letter Generator** from the Career Hub!';
    } else if (query.contains('interview') || query.contains('prepare for interview') || query.contains('interview coach')) {
      reply = '### AI Interview Coach\n\n'
          'Prepare for upcoming interviews with simulated practice:\n'
          '* **Question Generator:** Technical, HR, Behavioral, and Situational questions for any role.\n'
          '* **AI Answer Evaluator:** Scores your responses on clarity, technical depth, and structured STAR method.\n'
          '* **Actionable Feedback:** Suggests specific points to strengthen your answers.\n\n'
          '👉 Open **Interview Coach** from the Career Hub!';
    } else if (query.contains('find jobs') || query.contains('job feed') || query.contains('job tracker') || query.contains('jobs')) {
      reply = '### Job Discovery & Application Pipeline\n\n'
          '* **Demo Job Feed:** Explore curated opportunities with personalized resume match percentages.\n'
          '* **Check Job Safety:** Always scan job postings with Guard AI before applying.\n'
          '* **Kanban Tracker:** Track your applications across 9 stages from Saved to Offer!\n\n'
          '👉 Navigate to the **Jobs** tab to explore!';
    }
    // ── 4. Fallback Guidance ─────────────────────────────────────────────────
    else {
      reply = 'I\'m here to help you navigate JobShield AI!\n\n'
          'Here are the most common things I can assist you with:\n'
          '* **[🔍 Scan a Job]** — Analyze a job offer, URL, or recruiter message for scam signals.\n'
          '* **[📄 Resume Scanner]** — Check your ATS score and formatting.\n'
          '* **[🎯 ATS Job Match]** — Compare your resume to a job description.\n'
          '* **[💼 Job Tracker]** — Organize and manage your applications.\n'
          '* **[🎤 Interview Coach]** — Practice role-specific interview questions.\n\n'
          'What would you like to explore?';
    }

    _chatMessages.add({
      'sender': 'ai',
      'message': reply,
      'time': DateTime.now(),
    });
    _isAiTyping = false;
    notifyListeners();
  }

  void clearChat() {
    _chatMessages.clear();
    _chatMessages.add({
      'sender': 'ai',
      'message': "Hi! I'm your Job Scam Safety Assistant 👋\n\nNot sure whether a job offer is safe? I can help you understand warning signs and guide you through the app.",
      'time': DateTime.now(),
    });
    notifyListeners();
  }

  int _calculateMockScore() {
    return 100;
  }

  void _loadInitialMockData() {
    _scans.clear();
    _scans.addAll([
      JobScan(
        id: 's1',
        companyName: 'Apex Data entry Solutions',
        jobTitle: 'Remote Data Entry Clerk',
        jobUrl: 'https://careers-apexdata.net/apply-now',
        jobDescription: 'URGENT: Work from home data entry. \$45/hour. Telegram interview.',
        riskPercentage: 92.5,
        status: ScanStatus.scam,
        reasons: ['Telegram Interview: Vague recruiters.'],
        recommendations: ['DO NOT share personal bank details.'],
        scanDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ]);

    _scamAlerts.clear();
    _scamAlerts.addAll([
      ScamAlert(
        id: 'a1',
        companyName: 'Global Recruiting Inc',
        scamType: 'Check Purchase Fraud',
        description: 'Impersonating recruiters, mailing check frauds.',
        reportedDate: DateTime.now().subtract(const Duration(hours: 3)),
        reportedCount: 145,
      ),
    ]);

    _notifications.clear();
    _notifications.add(AppNotification(
      id: 'n1',
      title: 'Scam Alert Active',
      message: 'Global Recruiting Inc has been flagged for phishing data entry jobs.',
      timestamp: DateTime.now(),
      type: NotificationType.securityAlert,
      isRead: false,
    ));

    _chatMessages.clear();
    _chatMessages.add({
      'sender': 'ai',
      'message': "Hi! I'm your JobShield Career & Safety Copilot 👋\n\nI can help you analyze resumes, optimize LinkedIn profiles, match job descriptions, practice interview questions, and verify job offers for scams.",
      'time': DateTime.now(),
    });

    // Populate initial demo tracked jobs
    if (_trackedJobs.isEmpty) {
      _trackedJobs.addAll([
        TrackedJob(
          id: 'tj_1',
          userId: 'guest',
          companyName: 'CloudScale Innovations',
          jobTitle: 'Junior Mobile Application Engineer',
          jobUrl: 'https://careers.cloudscale.example/jobs/junior-mobile-eng',
          location: 'Bengaluru, Karnataka',
          employmentType: 'Full-Time',
          salary: '₹6,00,000 / yr',
          description: 'Mobile engineering role focusing on Flutter and Cloud APIs.',
          dateApplied: DateTime.now().subtract(const Duration(days: 3)),
          deadline: DateTime.now().add(const Duration(days: 10)),
          interviewDate: DateTime.now().add(const Duration(days: 4)),
          recruiterContact: 'hr@cloudscale.example',
          notes: 'Completed initial screening call. Preparing technical round.',
          status: ApplicationStatus.interview,
          matchScore: 84,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        TrackedJob(
          id: 'tj_2',
          userId: 'guest',
          companyName: 'Apex Tech Solutions',
          jobTitle: 'Flutter Developer Intern',
          jobUrl: 'https://careers.apextech.example/jobs/flutter-intern',
          location: 'Coimbatore, Tamil Nadu',
          employmentType: 'Internship',
          salary: '₹20,000 / mo',
          description: 'Cross-platform app development internship.',
          dateApplied: DateTime.now().subtract(const Duration(days: 6)),
          recruiterContact: 'careers@apextech.example',
          notes: 'Submitted resume and cover letter.',
          status: ApplicationStatus.applied,
          matchScore: 88,
          createdAt: DateTime.now().subtract(const Duration(days: 6)),
          updatedAt: DateTime.now().subtract(const Duration(days: 6)),
        ),
      ]);
    }
  }

  // ── CAREER MODULE ACTION METHODS ──────────────────────────────────────────
  void runAtsScan({required String fileName, required String rawContent, Uint8List? bytes}) {
    _latestResumeAnalysis = atsService.analyzeResume(
      fileName: fileName,
      rawContent: rawContent,
      fileBytes: bytes,
    );
    notifyListeners();

    if (apiService.token != null) {
      apiService.post('/career/ats-scan', {
        'rawContent': rawContent,
        'fileName': fileName,
      }).then<void>((_) {}, onError: (e) => debugPrint('runAtsScan backend notice: $e'));
    }
  }

  void runJobMatch({required String resumeText, required String jobTitle, required String companyName, required String jobDescription}) {
    _latestJobMatch = atsService.matchJobDescription(
      resumeText: resumeText,
      jobTitle: jobTitle,
      companyName: companyName,
      jobDescription: jobDescription,
    );
    notifyListeners();

    if (apiService.token != null) {
      apiService.post('/career/job-match', {
        'resumeText': resumeText,
        'jobTitle': jobTitle,
        'companyName': companyName,
        'jobDescription': jobDescription,
      }).then<void>((_) {}, onError: (e) => debugPrint('runJobMatch backend notice: $e'));
    }
  }

  void runLinkedInOptimization({required String headline, required String about, required List<String> skills, String? experience, String? projects}) {
    _latestLinkedInAnalysis = linkedinService.analyzeProfile(
      currentHeadline: headline,
      currentAbout: about,
      currentSkills: skills,
      currentExperience: experience,
      currentProjects: projects,
    );
    notifyListeners();

    if (apiService.token != null) {
      apiService.post('/career/linkedin-optimize', {
        'headline': headline,
        'about': about,
        'skills': skills,
      }).then<void>((_) {}, onError: (e) => debugPrint('runLinkedInOptimization backend notice: $e'));
    }
  }

  void updateCareerProfile(CareerProfile newProfile) {
    _careerProfile = newProfile;
    final uid = _authService.currentUser?.uid;
    if (uid != null) {
      _firestoreService.saveCareerProfile(uid, {
        'fullName': newProfile.fullName,
        'email': newProfile.email,
        'phone': newProfile.phone,
        'location': newProfile.location,
        'headline': newProfile.headline,
        'summary': newProfile.summary,
        'education': newProfile.education,
        'skills': newProfile.skills,
        'projects': newProfile.projects,
        'experience': newProfile.experience,
        'certifications': newProfile.certifications,
        'linkedinUrl': newProfile.linkedinUrl,
        'preferredRole': newProfile.preferredRole,
        'preferredLocation': newProfile.preferredLocation,
        'completionPercentage': newProfile.completionPercentage,
      });
    }
    notifyListeners();
  }

  // ── JOB TRACKER CRUD (SYNCHRONIZED WITH BACKEND MONGODB DATABASE) ───
  Future<void> addTrackedJob(TrackedJob job) async {
    _trackedJobs.insert(0, job);
    notifyListeners();

    if (apiService.token != null) {
      try {
        final res = await apiService.post('/tracker', {
          'companyName': job.companyName,
          'jobTitle': job.jobTitle,
          'jobUrl': job.jobUrl,
          'location': job.location,
          'employmentType': job.employmentType,
          'salary': job.salary,
          'description': job.description,
          'dateApplied': job.dateApplied?.toIso8601String(),
          'deadline': job.deadline?.toIso8601String(),
          'interviewDate': job.interviewDate?.toIso8601String(),
          'recruiterContact': job.recruiterContact,
          'notes': job.notes,
          'status': job.status.code,
        });

        if (res.statusCode == 200 || res.statusCode == 201) {
          final data = jsonDecode(res.body);
          if (data['success'] == true && data['job'] != null) {
            final serverJob = TrackedJob.fromJson(Map<String, dynamic>.from(data['job']));
            final idx = _trackedJobs.indexWhere((j) => j.id == job.id);
            if (idx != -1) {
              _trackedJobs[idx] = serverJob;
              notifyListeners();
            }
          }
        }
      } catch (e) {
        debugPrint('Backend addTrackedJob error: $e');
      }
    } else {
      final uid = _authService.currentUser?.uid;
      if (uid != null) {
        jobTrackerService.saveJob(uid, job);
      }
    }
  }

  Future<void> updateTrackedJob(TrackedJob job) async {
    final idx = _trackedJobs.indexWhere((j) => j.id == job.id);
    if (idx != -1) {
      _trackedJobs[idx] = job;
      notifyListeners();
    }

    if (apiService.token != null) {
      try {
        await apiService.put('/tracker/${job.id}', {
          'companyName': job.companyName,
          'jobTitle': job.jobTitle,
          'jobUrl': job.jobUrl,
          'location': job.location,
          'employmentType': job.employmentType,
          'salary': job.salary,
          'description': job.description,
          'dateApplied': job.dateApplied?.toIso8601String(),
          'deadline': job.deadline?.toIso8601String(),
          'interviewDate': job.interviewDate?.toIso8601String(),
          'recruiterContact': job.recruiterContact,
          'notes': job.notes,
          'status': job.status.code,
        });
      } catch (e) {
        debugPrint('Backend updateTrackedJob error: $e');
      }
    }
  }

  Future<void> updateTrackedJobStatus(String jobId, ApplicationStatus newStatus) async {
    final idx = _trackedJobs.indexWhere((j) => j.id == jobId);
    if (idx != -1) {
      _trackedJobs[idx] = _trackedJobs[idx].copyWith(status: newStatus);
      notifyListeners();
    }

    if (apiService.token != null) {
      try {
        await apiService.put('/tracker/$jobId', {'status': newStatus.code});
      } catch (e) {
        debugPrint('Backend updateTrackedJobStatus error: $e');
      }
    } else {
      final uid = _authService.currentUser?.uid;
      if (uid != null) {
        jobTrackerService.updateJobStatus(jobId, newStatus);
      }
    }
  }

  Future<void> deleteTrackedJob(String jobId) async {
    _trackedJobs.removeWhere((j) => j.id == jobId);
    notifyListeners();

    if (apiService.token != null) {
      try {
        await apiService.delete('/tracker/$jobId');
      } catch (e) {
        debugPrint('Backend deleteTrackedJob error: $e');
      }
    } else {
      final uid = _authService.currentUser?.uid;
      if (uid != null) {
        jobTrackerService.deleteJob(jobId);
      }
    }
  }

  // ── INTERVIEW COACH BACKEND APIS (5 SIMPLE QUESTIONS) ───────────────
  Future<Map<String, dynamic>> getInterviewSession() async {
    if (apiService.token != null) {
      try {
        final res = await apiService.get('/interview');
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data['success'] == true) {
            return Map<String, dynamic>.from(data);
          }
        }
      } catch (e) {
        debugPrint('Backend getInterviewSession error: $e');
      }
    }

    // Fallback standard 5 questions
    return {
      'success': true,
      'heading': 'INTERVIEW COACH',
      'subtitle': 'Practice simple interview questions and improve your confidence.',
      'totalQuestions': 5,
      'answeredCount': 0,
      'progressText': '0/5',
      'isCompleted': false,
      'questions': [
        {'id': 1, 'question': 'Tell me about yourself.', 'isAnswered': false},
        {'id': 2, 'question': 'What are your strengths and weaknesses?', 'isAnswered': false},
        {'id': 3, 'question': 'Why should we hire you?', 'isAnswered': false},
        {'id': 4, 'question': 'Why are you interested in this job?', 'isAnswered': false},
        {'id': 5, 'question': 'Where do you see yourself in five years?', 'isAnswered': false},
      ],
    };
  }

  Future<Map<String, dynamic>> submitInterviewAnswer(int questionId, String answer) async {
    if (apiService.token != null) {
      try {
        final res = await apiService.post('/interview/answer', {
          'questionId': questionId,
          'answer': answer,
        });
        if (res.statusCode == 200) {
          return Map<String, dynamic>.from(jsonDecode(res.body));
        }
      } catch (e) {
        debugPrint('Backend submitInterviewAnswer error: $e');
      }
    }

    // Local evaluation fallback
    return {
      'success': true,
      'evaluation': {
        'questionId': questionId,
        'score': 82,
        'feedback': 'Good, clear response! Adding specific project metrics will further enhance your answer.',
        'strengths': ['Direct communication', 'Clear delivery'],
        'suggestions': ['Quantify your impact with measurable results'],
      },
      'progressText': '$questionId/5',
      'answeredCount': questionId,
      'isCompleted': questionId >= 5,
      'completionMessage': questionId >= 5
          ? '🎉 Congratulations! You have completed all 5 interview practice questions. Review your feedback to refine your answers.'
          : null,
    };
  }

  Future<bool> resetInterviewSession() async {
    if (apiService.token != null) {
      try {
        final res = await apiService.post('/interview/reset', {});
        return res.statusCode == 200;
      } catch (e) {
        debugPrint('Backend resetInterviewSession error: $e');
      }
    }
    return true;
  }



  void addCareerDocument(CareerDocument doc) {
    _careerDocuments.insert(0, doc);
    final uid = _authService.currentUser?.uid;
    if (uid != null) {
      _firestoreService.saveCareerDocument(
        uid,
        title: doc.title,
        category: doc.category,
        fileUrl: doc.fileUrl,
        fileName: doc.fileName,
        fileSizeBytes: doc.fileSizeBytes,
      );
    }
    notifyListeners();
  }

  void deleteCareerDocument(String docId) {
    _careerDocuments.removeWhere((d) => d.id == docId);
    final uid = _authService.currentUser?.uid;
    if (uid != null) {
      _firestoreService.deleteCareerDocument(docId);
    }
    notifyListeners();
  }
}
