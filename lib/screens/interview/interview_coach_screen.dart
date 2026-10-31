import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../services/mock_data_service.dart';

class InterviewCoachScreen extends StatefulWidget {
  final String? initialRole;
  final String? initialCompany;

  const InterviewCoachScreen({
    Key? key,
    this.initialRole,
    this.initialCompany,
  }) : super(key: key);

  @override
  State<InterviewCoachScreen> createState() => _InterviewCoachScreenState();
}

class _InterviewCoachScreenState extends State<InterviewCoachScreen> {
  final _answerController = TextEditingController();
  int _currentIndex = 0; // 0 to 4 (representing questions 1 to 5)
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  // The 5 fixed beginner-friendly questions
  final List<Map<String, dynamic>> _questions = [
    {
      'id': 1,
      'question': 'Tell me about yourself.',
      'guidance': 'Structure your answer using Present, Past, and Future: your current role/studies, key projects/skills, and why you are excited for this opportunity.',
      'isAnswered': false,
      'userAnswer': '',
      'score': null,
      'feedback': null,
      'strengths': <String>[],
      'suggestions': <String>[],
    },
    {
      'id': 2,
      'question': 'What are your strengths and weaknesses?',
      'guidance': 'Highlight 1-2 core technical or teamwork strengths with proof, and 1 real weakness accompanied by the concrete steps you are actively taking to improve.',
      'isAnswered': false,
      'userAnswer': '',
      'score': null,
      'feedback': null,
      'strengths': <String>[],
      'suggestions': <String>[],
    },
    {
      'id': 3,
      'question': 'Why should we hire you?',
      'guidance': 'Focus on how your skills match the company’s requirements, your rapid learning ability, and your dedication to delivering tangible results.',
      'isAnswered': false,
      'userAnswer': '',
      'score': null,
      'feedback': null,
      'strengths': <String>[],
      'suggestions': <String>[],
    },
    {
      'id': 4,
      'question': 'Why are you interested in this job?',
      'guidance': 'Demonstrate knowledge of the company and technology stack, and connect the role to your genuine interests and long-term career passions.',
      'isAnswered': false,
      'userAnswer': '',
      'score': null,
      'feedback': null,
      'strengths': <String>[],
      'suggestions': <String>[],
    },
    {
      'id': 5,
      'question': 'Where do you see yourself in five years?',
      'guidance': 'Share an ambitious yet realistic vision of professional growth, deepened technical expertise, leadership or mentoring, and commitment to delivering impact.',
      'isAnswered': false,
      'userAnswer': '',
      'score': null,
      'feedback': null,
      'strengths': <String>[],
      'suggestions': <String>[],
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSessionFromBackend();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _loadSessionFromBackend() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = Provider.of<MockDataService>(context, listen: false);
      final session = await service.getInterviewSession();

      if (mounted) {
        if (session['questions'] != null && session['questions'] is List) {
          final serverQuestions = session['questions'] as List;
          for (final sq in serverQuestions) {
            final id = sq['id'] as int?;
            if (id != null && id >= 1 && id <= 5) {
              final idx = id - 1;
              _questions[idx]['isAnswered'] = sq['isAnswered'] ?? false;
              _questions[idx]['userAnswer'] = sq['savedAnswer'] ?? '';
              _questions[idx]['score'] = sq['savedScore'];
              _questions[idx]['feedback'] = sq['savedFeedback'];
              _questions[idx]['strengths'] = (sq['savedStrengths'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
              _questions[idx]['suggestions'] = (sq['savedSuggestions'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
            }
          }
        }
        _answerController.text = _questions[_currentIndex]['userAnswer'] ?? '';
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = null; // Do not block UI with full error screen
        });
      }
    }
  }

  void _selectQuestion(int index) {
    if (index < 0 || index >= 5) return;
    setState(() {
      _currentIndex = index;
      _answerController.text = _questions[index]['userAnswer'] ?? '';
    });
  }

  Future<void> _submitCurrentAnswer() async {
    final text = _answerController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please type your answer before submitting.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final currentQ = _questions[_currentIndex];
    final qId = currentQ['id'] as int;

    try {
      final service = Provider.of<MockDataService>(context, listen: false);
      final result = await service.submitInterviewAnswer(qId, text);

      if (mounted) {
        if (result['success'] == true && result['evaluation'] != null) {
          final eval = result['evaluation'];
          setState(() {
            currentQ['isAnswered'] = true;
            currentQ['userAnswer'] = text;
            currentQ['score'] = eval['score'];
            currentQ['feedback'] = eval['feedback'];
            currentQ['strengths'] = (eval['strengths'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
            currentQ['suggestions'] = (eval['suggestions'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
            _isSubmitting = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Answer evaluated and saved to database!'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Could not save answer. Please try again.'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _resetAllQuestions() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Interview Session'),
        content: const Text('Are you sure you want to clear your saved answers and start fresh?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final service = Provider.of<MockDataService>(context, listen: false);
      await service.resetInterviewSession();
      setState(() {
        for (var q in _questions) {
          q['isAnswered'] = false;
          q['userAnswer'] = '';
          q['score'] = null;
          q['feedback'] = null;
          q['strengths'] = <String>[];
          q['suggestions'] = <String>[];
        }
        _currentIndex = 0;
        _answerController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✓ Session reset. Ready to practice!'), backgroundColor: AppColors.info),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final answeredCount = _questions.where((q) => q['isAnswered'] == true).length;
    final bool allCompleted = answeredCount == 5;
    final currentQ = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF070D1B) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF091024) : Colors.white,
        elevation: 0,
        title: const Text(
          'INTERVIEW COACH',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset Session',
            onPressed: _resetAllQuestions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading Interview Coach...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.record_voice_over_rounded, color: Colors.white, size: 22),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'INTERVIEW COACH',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Practice simple interview questions and improve your confidence.',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: Color(0xFFE2E8F0),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Progress Bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progress: $answeredCount/5 Answered',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${((answeredCount / 5) * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Color(0xFF93C5FD),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: answeredCount / 5,
                              minHeight: 8,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Completion Message if 5/5
                    if (allCompleted) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF064E3B).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF10B981)),
                        ),
                        child: const Row(
                          children: [
                            Text('🎉', style: TextStyle(fontSize: 28)),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Practice Completed!',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF34D399),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Great job answering all 5 core interview questions. Review your feedback below or reset anytime to practice again.',
                                    style: TextStyle(fontSize: 12, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // Question Selector Tabs (1 to 5)
                    SizedBox(
                      height: 48,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, idx) {
                          final q = _questions[idx];
                          final isSelected = _currentIndex == idx;
                          final isAnswered = q['isAnswered'] == true;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: InkWell(
                              onTap: () => _selectQuestion(idx),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark ? const Color(0xFF0F172A) : Colors.white),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : (isAnswered
                                            ? const Color(0xFF10B981)
                                            : (isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1))),
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    if (isAnswered) ...[
                                      const Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 14),
                                      const SizedBox(width: 6),
                                    ],
                                    Text(
                                      'Question ${idx + 1}',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : (isDark ? Colors.white70 : Colors.black87),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Active Question Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Question Header Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'QUESTION ${_currentIndex + 1} OF 5',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              if (currentQ['isAnswered'] == true && currentQ['score'] != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    'Score: ${currentQ['score']}/100',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Question Text
                          Text(
                            currentQ['question'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Guidance Tip
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.tips_and_updates_outlined, size: 16, color: Color(0xFFF59E0B)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    currentQ['guidance'],
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Answer Input Area
                          const Text(
                            'Your Answer:',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _answerController,
                            maxLines: 6,
                            style: TextStyle(fontSize: 13.5, color: isDark ? Colors.white : Colors.black87),
                            decoration: InputDecoration(
                              hintText: 'Type your answer here in your own words...',
                              hintStyle: TextStyle(
                                color: isDark ? const Color(0xFF64748B) : Colors.grey.shade400,
                                fontSize: 13,
                              ),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF091024) : const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Action Buttons Row
                          Row(
                            children: [
                              // Submit Answer Button
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: _isSubmitting ? null : _submitCurrentAnswer,
                                  child: _isSubmitting
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                        )
                                      : const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.send_rounded, size: 16),
                                            SizedBox(width: 8),
                                            Text(
                                              'Submit Answer',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Next Question Button
                              if (_currentIndex < 4)
                                Expanded(
                                  flex: 1,
                                  child: OutlinedButton(
                                    onPressed: () => _selectQuestion(_currentIndex + 1),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      side: BorderSide(
                                        color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    child: const Text('Next →', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Feedback & Evaluation Card (if answered)
                    if (currentQ['isAnswered'] == true && currentQ['feedback'] != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF10B981).withOpacity(0.4),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.analytics_outlined, color: Color(0xFF10B981), size: 18),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'AI Evaluation & Feedback',
                                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Feedback Text
                            Text(
                              currentQ['feedback'],
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Strengths
                            if (currentQ['strengths'] != null && (currentQ['strengths'] as List).isNotEmpty) ...[
                              const Text('Key Strengths:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                              const SizedBox(height: 4),
                              ...((currentQ['strengths'] as List).map((s) => Padding(
                                padding: const EdgeInsets.only(bottom: 3.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                                    Expanded(child: Text(s, style: const TextStyle(fontSize: 12))),
                                  ],
                                ),
                              ))),
                              const SizedBox(height: 8),
                            ],

                            // Suggestions
                            if (currentQ['suggestions'] != null && (currentQ['suggestions'] as List).isNotEmpty) ...[
                              const Text('Improvement Suggestions:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                              const SizedBox(height: 4),
                              ...((currentQ['suggestions'] as List).map((s) => Padding(
                                padding: const EdgeInsets.only(bottom: 3.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ', style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
                                    Expanded(child: Text(s, style: const TextStyle(fontSize: 12))),
                                  ],
                                ),
                              ))),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
