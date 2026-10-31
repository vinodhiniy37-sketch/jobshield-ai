import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../services/mock_data_service.dart';
import '../../ai/ai_assistant_screen.dart';
import '../../scan/scan_job_screen.dart';
import '../../resume/ats_resume_scanner_screen.dart';
import '../../resume/ats_job_match_screen.dart';
import '../../jobs/jobs_hub_screen.dart';
import '../../cover_letter/cover_letter_generator_screen.dart';
import '../../interview/interview_coach_screen.dart';

class AiGuideHero extends StatefulWidget {
  const AiGuideHero({Key? key}) : super(key: key);

  @override
  State<AiGuideHero> createState() => _AiGuideHeroState();
}

class _AiGuideHeroState extends State<AiGuideHero> {
  final TextEditingController _chatController = TextEditingController();

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _submitChat(String query) {
    if (query.trim().isEmpty) return;
    final service = Provider.of<MockDataService>(context, listen: false);
    service.sendAiMessage(query);
    _chatController.clear();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
    );
  }

  void _openAiChatScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
    );
  }

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
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with Robot icon
          InkWell(
            onTap: _openAiChatScreen,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    color: Color(0xFF60A5FA),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'JobShield AI Assistant',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Check a job before you apply. — Safer & Smarter',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF60A5FA), size: 13),
                      SizedBox(width: 5),
                      Text(
                        'Open Full Chat →',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF60A5FA)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

              // Left Avatar + Right Chat Bubble Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 3D Glowing Robot sphere avatar
                  GestureDetector(
                    onTap: _openAiChatScreen,
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [
                            Color(0xFF3B82F6),
                            Color(0xFF1E3A8A),
                            Color(0xFF0F172A),
                          ],
                          center: Alignment(-0.2, -0.2),
                          radius: 0.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.4),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFF60A5FA).withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.smart_toy_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),

                  // Chat Message Bubble
                  Expanded(
                    child: GestureDetector(
                      onTap: _openAiChatScreen,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF091024),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                            topLeft: Radius.circular(4),
                          ),
                          border: Border.all(
                            color: const Color(0xFF1E2D4F),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: Color(0xFFE2E8F0),
                                  height: 1.5,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Hi! I\'m your JobShield AI assistant 👋\n',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  TextSpan(
                                    text:
                                        'I can help you check whether a job is safe before you apply, match your resume with a job, improve your LinkedIn profile, create a cover letter, and track your applications.\n\n',
                                  ),
                                  TextSpan(
                                    text: 'What would you like to do?',
                                    style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF93C5FD)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Interactive Chat Input Bar Inside Hero Card
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF091024),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF1E2D4F)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.psychology_rounded, color: Color(0xFF60A5FA), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _chatController,
                        onSubmitted: _submitChat,
                        style: const TextStyle(fontSize: 13, color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Ask AI Assistant anything (e.g. Is this offer real? How do I use JobShield?)...',
                          hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 12.5),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _submitChat(_chatController.text),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send_rounded, color: Colors.white, size: 15),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Horizontal Action Button Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    // 1. PRIMARY: Scan a Job (Solid Bright Blue)
                    _primaryPillButton(
                      context: context,
                      icon: Icons.search_rounded,
                      label: 'Scan a Job',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ScanJobScreen()),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // 2. Check My Resume
                    _secondaryPillButton(
                      context: context,
                      icon: Icons.description_outlined,
                      label: 'Check My Resume',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AtsResumeScannerScreen()),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // 3. Optimize LinkedIn
                    _secondaryPillButton(
                      context: context,
                      icon: Icons.workspace_premium_rounded,
                      label: 'Optimize LinkedIn',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AtsJobMatchScreen()),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // 4. Generate Cover Letter
                    _secondaryPillButton(
                      context: context,
                      icon: Icons.edit_note_rounded,
                      label: 'Generate Cover Letter',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CoverLetterGeneratorScreen()),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // 5. Find Jobs
                    _secondaryPillButton(
                      context: context,
                      icon: Icons.work_outline_rounded,
                      label: 'Find Jobs',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const JobsHubScreen()),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // 6. Track Applications
                    _secondaryPillButton(
                      context: context,
                      icon: Icons.assignment_turned_in_outlined,
                      label: 'Track Applications',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const JobsHubScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  Widget _primaryPillButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2563EB),
              Color(0xFF3B82F6),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _secondaryPillButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF091024),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF22355C),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: const Color(0xFF94A3B8)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE2E8F0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
