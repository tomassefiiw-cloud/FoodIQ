import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../services/ai_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/calorie_provider.dart';
import '../../providers/water_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _messages.add(_ChatMessage(
      text: 'Hello! 👋 I\'m FoodIQ AI, your nutrition assistant specializing in Ethiopian cuisine. Ask me anything about calories, meal plans, or Ethiopian dishes!',
      isUser: false,
    ));
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });

    final user = ref.read(currentUserProvider);
    final calorieSummary = await ref.read(todayCalorieSummaryProvider.future);
    final waterSummary = await ref.read(todayWaterSummaryProvider.future);

    final res = await AIService.chatWithAssistantFull(
      userMessage: text,
      currentCalories: calorieSummary.totalCalories,
      currentWaterMl: waterSummary.totalMl,
      calorieGoal: user?.calorieGoal ?? 2000,
    );

    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _isOnline = !res.wasOffline;
      _messages.add(_ChatMessage(text: res.reply, isUser: false));
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(gradient: AppColors.orangeGradient, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('FoodIQ AI', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
              Row(
                children: [
                  Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          color: _isOnline ? AppColors.success : Colors.grey,
                          shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(_isOnline ? 'Online' : 'Offline',
                      style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: _isOnline ? AppColors.success : Colors.grey)),
                ],
              ),
            ]),
          ],
        ),
      ),
      body: Column(
        children: [
          // Quick questions
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _QuickChip(label: 'How many calories in Injera?', onTap: () => _sendQuick('How many calories in Injera?')),
                _QuickChip(label: 'Low calorie Ethiopian food?', onTap: () => _sendQuick('Suggest low calorie Ethiopian foods')),
                _QuickChip(label: 'Protein sources', onTap: () => _sendQuick('What are good protein sources in Ethiopian cuisine?')),
                _QuickChip(label: 'Meal plan', onTap: () => _sendQuick('Suggest a balanced Ethiopian meal plan')),
                _QuickChip(label: 'Fasting foods', onTap: () => _sendQuick('What Ethiopian foods are good during fasting?')),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == _messages.length && _isTyping) {
                  return _TypingIndicator();
                }
                final msg = _messages[i];
                return _ChatBubble(message: msg);
              },
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -2))],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Ask about nutrition...',
                        filled: true,
                        fillColor: isDark ? AppColors.darkCard : AppColors.cream,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(gradient: AppColors.orangeGradient, shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendQuick(String text) {
    _controller.text = text;
    _sendMessage();
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isUser
            ? AppColors.primary
            : (isDark ? AppColors.darkCard : Colors.grey[100]),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(message.isUser ? 18 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 18),
          ),
        ),
        child: Text(
          message.text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: message.isUser ? Colors.white : null,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.primary : AppColors.primary,
          ),
        ),
        onPressed: onTap,
        backgroundColor: isDark
            ? AppColors.primary.withOpacity(0.18)
            : AppColors.primaryBg,
        side: BorderSide(
          color: AppColors.primary.withOpacity(isDark ? 0.7 : 0.4),
          width: 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.grey[100],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) => AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => Container(
              width: 8, height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.4 + 0.3 * ((_controller.value + i * 0.33) % 1)),
                shape: BoxShape.circle,
              ),
            ),
          )),
        ),
      ),
    );
  }
}
