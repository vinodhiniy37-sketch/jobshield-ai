import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Scan Job Offers instantly',
      'description': 'Paste job URLs, descriptions, or upload offer letters. Our AI instantly analyzes risk parameters to keep you safe.',
      'icon': 'shield_rounded',
    },
    {
      'title': 'AI Security Partner',
      'description': 'Chat with our chatbot to ask questions about recruiter messages, check cashing queries, or safety procedures.',
      'icon': 'chat_bubble_rounded',
    },
    {
      'title': 'Report & Alert others',
      'description': 'Help secure the community. Report active scam attempts to flag fake corporations and protect other candidates.',
      'icon': 'campaign_rounded',
    },
  ];

  IconData _getIcon(String name) {
    switch (name) {
      case 'shield_rounded':
        return Icons.shield_rounded;
      case 'chat_bubble_rounded':
        return Icons.chat_bubble_rounded;
      case 'campaign_rounded':
        return Icons.campaign_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  void _onSkip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _onNext() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (_currentPage < _onboardingData.length - 1)
            TextButton(
              onPressed: _onSkip,
              child: Text(
                'Skip',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    final item = _onboardingData[index];
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: size.height * 0.03),
                          // Premium gradient circle background for icons
                          Container(
                            width: size.width * 0.35,
                            height: size.width * 0.35,
                            constraints: const BoxConstraints(maxWidth: 200, maxHeight: 200),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withOpacity(0.05),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: size.width * 0.25,
                                height: size.width * 0.25,
                                constraints: const BoxConstraints(maxWidth: 150, maxHeight: 150),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [AppColors.primary.withOpacity(0.1), AppColors.secondary.withOpacity(0.2)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Icon(
                                  _getIcon(item['icon']!),
                                  size: size.width * 0.12 > 60 ? 60 : size.width * 0.12,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.04),
                          Text(
                            item['title']!,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            item['description']!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 15,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Page Indicators & Button Action Block
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentPage == index
                              ? AppColors.primary
                              : (isDark ? AppColors.borderDark : AppColors.borderLight),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                  CustomButton(
                    text: _currentPage == _onboardingData.length - 1
                        ? 'Get Started'
                        : 'Next',
                    onPressed: _onNext,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
