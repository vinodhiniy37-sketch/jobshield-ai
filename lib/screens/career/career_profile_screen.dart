import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../services/mock_data_service.dart';
import '../../models/career_profile_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class CareerProfileScreen extends StatefulWidget {
  const CareerProfileScreen({Key? key}) : super(key: key);

  @override
  State<CareerProfileScreen> createState() => _CareerProfileScreenState();
}

class _CareerProfileScreenState extends State<CareerProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _headlineController = TextEditingController();
  final _educationController = TextEditingController();
  final _skillsController = TextEditingController();
  final _projectsController = TextEditingController();
  final _experienceController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _roleController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cp = Provider.of<MockDataService>(context, listen: false).careerProfile;
      _nameController.text = cp.fullName;
      _emailController.text = cp.email;
      _phoneController.text = cp.phone;
      _locationController.text = cp.location;
      _headlineController.text = cp.headline;
      _educationController.text = cp.education;
      _skillsController.text = cp.skills.join(', ');
      _projectsController.text = cp.projects.join('\n');
      _experienceController.text = cp.experience.join('\n');
      _linkedinController.text = cp.linkedinUrl;
      _roleController.text = cp.preferredRole;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _headlineController.dispose();
    _educationController.dispose();
    _skillsController.dispose();
    _projectsController.dispose();
    _experienceController.dispose();
    _linkedinController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  void _saveCareerProfile() {
    final service = Provider.of<MockDataService>(context, listen: false);
    final skillsList = _skillsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    final projectsList = _projectsController.text.split('\n').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
    final expList = _experienceController.text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    int completion = CareerProfile.calculateCompletion(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      education: _educationController.text.trim(),
      skills: skillsList,
      projects: projectsList,
      experience: expList,
      resumeUrl: service.careerProfile.resumeUrl,
      linkedinUrl: _linkedinController.text.trim(),
    );

    setState(() => _isSaving = true);

    final updated = CareerProfile(
      userId: service.careerProfile.userId,
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      location: _locationController.text.trim(),
      headline: _headlineController.text.trim(),
      summary: service.careerProfile.summary,
      education: _educationController.text.trim(),
      skills: skillsList,
      projects: projectsList,
      experience: expList,
      certifications: service.careerProfile.certifications,
      resumeUrl: service.careerProfile.resumeUrl,
      resumeFileName: service.careerProfile.resumeFileName,
      linkedinUrl: _linkedinController.text.trim(),
      preferredRole: _roleController.text.trim(),
      preferredLocation: service.careerProfile.preferredLocation,
      employmentTypePreference: service.careerProfile.employmentTypePreference,
      completionPercentage: completion,
    );

    service.updateCareerProfile(updated);

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Career Profile updated successfully!'), backgroundColor: AppColors.success),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final service = Provider.of<MockDataService>(context);
    final cp = service.careerProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Completion Progress Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Career Profile Completeness', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('${cp.completionPercentage}%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _getScoreColor(cp.completionPercentage))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: cp.completionPercentage / 100.0,
                        minHeight: 8,
                        backgroundColor: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(cp.completionPercentage)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Complete your profile to generate accurate ATS resume matches, cover letters, and interview coaching.',
                      style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Form Sections
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Personal & Contact Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    CustomTextField(label: 'Full Name', controller: _nameController),
                    const SizedBox(height: 10),
                    CustomTextField(label: 'Email Address', controller: _emailController),
                    const SizedBox(height: 10),
                    CustomTextField(label: 'Phone Number', controller: _phoneController),
                    const SizedBox(height: 10),
                    CustomTextField(label: 'Current Location', controller: _locationController),
                    const SizedBox(height: 10),
                    CustomTextField(label: 'Professional Headline', controller: _headlineController, hintText: 'e.g. CSE Student | Flutter & Full-Stack Developer'),
                    const SizedBox(height: 20),

                    const Text('Education & Preferred Role', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    CustomTextField(label: 'Education (College / Degree / Specialization)', controller: _educationController, hintText: 'e.g. B.E. Computer Science Engineering'),
                    const SizedBox(height: 10),
                    CustomTextField(label: 'Preferred Target Job Role', controller: _roleController, hintText: 'e.g. Software Engineer / Mobile Developer'),
                    const SizedBox(height: 20),

                    const Text('Skills & Tech Stack', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    CustomTextField(label: 'Technical Skills (Comma Separated)', controller: _skillsController, hintText: 'Flutter, Dart, Firebase, Python, SQL, REST API, Git'),
                    const SizedBox(height: 20),

                    const Text('Key Projects & Internships', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    CustomTextField(label: 'Projects (One per line)', controller: _projectsController, maxLines: 3, hintText: 'JobShield AI Platform - Built Flutter & Firebase app...'),
                    const SizedBox(height: 10),
                    CustomTextField(label: 'Work Experience / Internships (One per line)', controller: _experienceController, maxLines: 2, hintText: 'Mobile Developer Intern at Apex Tech...'),
                    const SizedBox(height: 10),
                    CustomTextField(label: 'LinkedIn Profile URL', controller: _linkedinController, hintText: 'https://linkedin.com/in/username'),
                    const SizedBox(height: 20),

                    CustomButton(
                      text: _isSaving ? 'Saving Profile...' : 'Save Career Profile',
                      icon: Icons.save_rounded,
                      onPressed: _isSaving ? null : _saveCareerProfile,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
