import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../services/mock_data_service.dart';
import '../scan/scan_job_screen.dart';
import '../career/career_hub_screen.dart';
import '../resume/ats_resume_scanner_screen.dart';
import '../resume/ats_job_match_screen.dart';
import '../linkedin/linkedin_optimizer_screen.dart';
import '../cover_letter/cover_letter_generator_screen.dart';
import '../interview/interview_coach_screen.dart';
import '../jobs/jobs_hub_screen.dart';
import '../jobs/job_feed_screen.dart';
import '../tracker/job_tracker_kanban_screen.dart';
import '../history/history_screen.dart';
import '../report/report_scam_screen.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({Key? key}) : super(key: key);

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showWorkflow = true; // Show workflow routing panel by default

  final List<String> _suggestedQuestions = const [
    'Is this job offer legitimate?',
    'How do I spot recruitment fraud?',
    'What should I do if a recruiter asks for money?',
    'How do I improve my ATS resume score?',
    'Help me prepare for a technical interview',
    'How do I verify a company?',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage([String? text]) {
    final message = text ?? _messageController.text;
    if (message.trim().isEmpty) return;

    final service = Provider.of<MockDataService>(context, listen: false);
    service.sendAiMessage(message);
    _messageController.clear();
    _scrollToBottom();
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Simulated share options triggered.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _startMockVoiceInput() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Listening for threats...',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 24),
              // Pulse circles representing microphone
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 20 + (index % 2 == 0 ? 16 : 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Say something like "Is careers-apple.com legitimate?"',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _sendMessage('Are Telegram recruiter chats a scam?');
                },
                child: const Text('Simulate Audio Input'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Parses basic markdown notation internally for styling chats
  Widget _parseMarkdownText(String text, BuildContext context, bool isUser) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: 14.5,
      color: isUser ? Colors.white : (theme.brightness == Brightness.dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
    );

    final lines = text.split('\n');
    List<Widget> children = [];

    for (var line in lines) {
      if (line.trim().isEmpty) {
        children.add(const SizedBox(height: 6));
        continue;
      }

      // Headers (### Header)
      if (line.startsWith('### ')) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              line.substring(4),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isUser ? Colors.white : AppColors.primary,
              ),
            ),
          ),
        );
        continue;
      }

      // Bullets (* bullet)
      if (line.trim().startsWith('* ') || line.trim().startsWith('- ')) {
        final content = line.trim().substring(2);
        children.add(
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isUser ? Colors.white : AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _parseInlineBold(content, textStyle),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Normal text
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: _parseInlineBold(line, textStyle),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _parseInlineBold(String content, TextStyle? defaultStyle) {
    final List<TextSpan> spans = [];
    final pattern = RegExp(r'\*\*(.*?)\*\*');
    int start = 0;

    for (final match in pattern.allMatches(content)) {
      if (match.start > start) {
        spans.add(TextSpan(text: content.substring(start, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
      start = match.end;
    }

    if (start < content.length) {
      spans.add(TextSpan(text: content.substring(start)));
    }

    return RichText(
      text: TextSpan(
        style: defaultStyle,
        children: spans,
      ),
    );
  }

  // ── Workflow Routing Panel ─────────────────────────────────────────────────
  Widget _buildWorkflowPanel(BuildContext context, bool isDark) {
    final Color cardBg = isDark ? AppColors.darkCard : Colors.white;
    final Color borderCol = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : const Color(0xFFF5F7FF),
        border: Border(bottom: BorderSide(color: borderCol)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.smart_toy_rounded, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('What do you want to do?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('Choose a path or chat below', style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Three main branch cards
          Row(
            children: [
              // 🔍 SCAN JOB
              Expanded(
                child: _BranchCard(
                  icon: Icons.manage_search_rounded,
                  label: '🔍 Scan Job',
                  color: AppColors.danger,
                  isDark: isDark,
                  subOptions: [
                    _SubOption('Job URL / Text', Icons.link_rounded, () => _navigate(context, const ScanJobScreen())),
                    _SubOption('Evidence Upload', Icons.upload_file_rounded, () => _navigate(context, const ScanJobScreen())),
                    _SubOption('Scan History', Icons.history_rounded, () => _navigate(context, const HistoryScreen())),
                    _SubOption('Report Scam', Icons.flag_rounded, () => _navigate(context, const ReportScamScreen())),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // 💼 CAREER
              Expanded(
                child: _BranchCard(
                  icon: Icons.stars_rounded,
                  label: '💼 Career',
                  color: AppColors.primary,
                  isDark: isDark,
                  subOptions: [
                    _SubOption('ATS Resume', Icons.description_rounded, () => _navigate(context, const AtsResumeScannerScreen())),
                    _SubOption('Job Match', Icons.compare_arrows_rounded, () => _navigate(context, const AtsJobMatchScreen())),
                    _SubOption('LinkedIn AI', Icons.badge_rounded, () => _navigate(context, const LinkedInOptimizerScreen())),
                    _SubOption('Cover Letter', Icons.edit_note_rounded, () => _navigate(context, const CoverLetterGeneratorScreen())),
                    _SubOption('Interview Coach', Icons.record_voice_over_rounded, () => _navigate(context, const InterviewCoachScreen())),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // 📋 JOBS
              Expanded(
                child: _BranchCard(
                  icon: Icons.work_rounded,
                  label: '📋 Jobs',
                  color: const Color(0xFF059669),
                  isDark: isDark,
                  subOptions: [
                    _SubOption('Job Feed', Icons.feed_rounded, () => _navigate(context, const JobFeedScreen())),
                    _SubOption('Job Tracker', Icons.assignment_turned_in_rounded, () => _navigate(context, const JobTrackerKanbanScreen())),
                    _SubOption('All Jobs', Icons.work_outline_rounded, () => _navigate(context, const JobsHubScreen())),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChat(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              'JobShield AI is ready!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a workflow above to get started,\nor ask me anything about job safety & career growth.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final service = Provider.of<MockDataService>(context);
    final messages = service.chatMessages;

    // Trigger scrolling on message update
    if (messages.isNotEmpty) {
      _scrollToBottom();
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.smart_toy_rounded, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text('JobShield AI'),
          ],
        ),
        actions: [
          // Toggle workflow panel
          IconButton(
            icon: Icon(_showWorkflow ? Icons.chat_bubble_outline_rounded : Icons.grid_view_rounded),
            tooltip: _showWorkflow ? 'Open Chat' : 'Show Menu',
            onPressed: () => setState(() => _showWorkflow = !_showWorkflow),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Chat?'),
                  content: const Text('Are you sure you want to delete the AI chat conversation logs?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        service.clearChat();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear', style: TextStyle(color: AppColors.danger)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Workflow Routing Panel ───────────────────────────────────
            if (_showWorkflow) _buildWorkflowPanel(context, isDark),

            // Chat Dialog panel
            Expanded(
              child: messages.isEmpty
                  ? _buildEmptyChat(isDark)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: messages.length + (service.isAiTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        // AI Typing Loader Item
                        if (index == messages.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.primary.withOpacity(0.1),
                                  child: const Icon(Icons.smart_toy_rounded, size: 16, color: AppColors.primary),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkCard : Colors.grey[200],
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(16),
                                      bottomLeft: Radius.circular(4),
                                      bottomRight: Radius.circular(16),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(strokeWidth: 1.5),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Guard AI is typing...',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final msg = messages[index];
                        final bool isAi = msg['sender'] == 'ai';

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
                            children: [
                              if (isAi) ...[
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.primary.withOpacity(0.1),
                                  child: const Icon(Icons.security_rounded, size: 16, color: AppColors.primary),
                                ),
                                const SizedBox(width: 10),
                              ],
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: isAi
                                        ? (isDark ? AppColors.darkCard : Colors.white)
                                        : AppColors.primary,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(16),
                                      topRight: const Radius.circular(16),
                                      bottomLeft: Radius.circular(isAi ? 4 : 16),
                                      bottomRight: Radius.circular(isAi ? 16 : 4),
                                    ),
                                    border: isAi
                                        ? Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight)
                                        : null,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _parseMarkdownText(msg['message'], context, !isAi),
                                      if (isAi) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.copy_rounded, size: 16),
                                              onPressed: () => _copyToClipboard(msg['message']),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                            const SizedBox(width: 12),
                                            IconButton(
                                              icon: const Icon(Icons.share_rounded, size: 16),
                                              onPressed: () => _shareMessage(msg['message']),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              if (!isAi) ...[
                                const SizedBox(width: 10),
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.primary.withOpacity(0.2),
                                  child: Text(
                                    service.name[0],
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // Suggested prompt tags (only show when typing is empty)
            if (_messageController.text.isEmpty && !service.isAiTyping)
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _suggestedQuestions.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        label: Text(
                          _suggestedQuestions[index],
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        onPressed: () => _sendMessage(_suggestedQuestions[index]),
                        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
                        side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      ),
                    );
                  },
                ),
              ),

            // Input Text Panel
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : Colors.white,
                border: Border(
                  top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.mic_none_rounded, color: AppColors.primary),
                    onPressed: _startMockVoiceInput,
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _messageController,
                        onSubmitted: (val) => _sendMessage(),
                        onChanged: (text) {
                          // Force state update to show/hide prompt chips
                          setState(() {});
                        },
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Ask about a company or offer...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                      onPressed: () => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sub Option Data Class ────────────────────────────────────────────────────
class _SubOption {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _SubOption(this.label, this.icon, this.onTap);
}

// ─── Branch Card Widget ───────────────────────────────────────────────────────
class _BranchCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final List<_SubOption> subOptions;

  const _BranchCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.subOptions,
  });

  @override
  State<_BranchCard> createState() => _BranchCardState();
}

class _BranchCardState extends State<_BranchCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _expanded ? widget.color.withOpacity(0.5) : (widget.isDark ? AppColors.borderDark : AppColors.borderLight),
            width: _expanded ? 1.5 : 1,
          ),
          boxShadow: _expanded
              ? [BoxShadow(color: widget.color.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 3))]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 16),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: widget.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: widget.color,
                  ),
                ],
              ),
            ),
            // Sub-options (expanded)
            if (_expanded) ...[
              const Divider(height: 1),
              ...widget.subOptions.map((opt) => InkWell(
                    onTap: opt.onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      child: Row(
                        children: [
                          Icon(opt.icon, size: 13, color: widget.color.withOpacity(0.8)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              opt.label,
                              style: const TextStyle(fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Colors.grey[400]),
                        ],
                      ),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
