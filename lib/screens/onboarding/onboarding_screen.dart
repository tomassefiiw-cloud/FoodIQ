import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final _pages = [
    _OnboardingPage(
      icon: Icons.restaurant_menu,
      color: Color(0xFFFF6B35),
      title: 'Track Ethiopian Calories',
      description: 'Over 103 traditional Ethiopian dishes with accurate nutritional data. From Injera to Doro Wot, we\'ve got you covered! 🇪🇹',
    ),
    _OnboardingPage(
      icon: Icons.camera_alt,
      color: Color(0xFF0EA5E9),
      title: 'AI Food Recognition',
      description: 'Snap a photo of your meal and our AI instantly identifies it and logs the calories. Powered by Gemini Vision! 📸',
    ),
    _OnboardingPage(
      icon: Icons.analytics,
      color: Color(0xFF22C55E),
      title: 'Smart Analytics',
      description: 'Daily charts, weekly trends, and nutritional insights. Understand your eating habits like never before! 📊',
    ),
    _OnboardingPage(
      icon: Icons.smart_toy,
      color: Color(0xFF8B5CF6),
      title: 'AI Nutrition Assistant',
      description: 'Chat with our AI about Ethiopian cuisine, meal plans, and nutrition tips. Available 24/7! 🤖',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: widget.onComplete,
                child: Text('Skip', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 16)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => _pages[i],
              ),
            ),
            // Page indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == i ? 32 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _currentPage == i ? const Color(0xFFFF6B35) : Colors.grey[300],
                      borderRadius: BorderRadius.circular(5),
                    ),
                  );
                }),
              ),
            ),
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _pages.length - 1) {
                      widget.onComplete();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 70, color: color),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Poppins', fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Colors.grey[600], height: 1.6),
          ),
        ],
      ),
    );
  }
}
