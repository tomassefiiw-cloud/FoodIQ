import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
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

  // ----- Voice (speech-to-text) -----
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _isListening = false;
  String _selectedLocaleId = 'am-ET'; // default to Amharic
  List<stt.LocaleName> _locales = [];

  @override
  void initState() {
    super.initState();
    _messages.add(_ChatMessage(
      text: 'Hello! 👋 I\'m FoodIQ AI, your nutrition assistant specializing in Ethiopian cuisine. Ask me anything about calories, meal plans, or Ethiopian dishes!\n\nጤና ይስጥልኝ! በአማርኛም መጠየቅ ይችላሉ — ለመናገር 🎤 ይጫኑ።',
      isUser: false,
    ));
    _initSpeech();
  }

  @override
  void dispose() {
    _speech.stop();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize(
        onStatus: (status) {
          if (!mounted) return;
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (err) {
          if (!mounted) return;
          setState(() => _isListening = false);
        },
      );

      if (_speechAvailable) {
        _locales = await _speech.locales();
        // Prefer Amharic (am-ET / am) if the device has it; otherwise fall
        // back to the system locale or English.
        final amharic = _locales.where((l) =>
            l.localeId.toLowerCase().startsWith('am'));
        if (amharic.isNotEmpty) {
          _selectedLocaleId = amharic.first.localeId;
        } else {
          final sys = await _speech.systemLocale();
          _selectedLocaleId = sys?.localeId ?? 'en_US';
        }
      }
      if (mounted) setState(() {});
    } catch (_) {
      _speechAvailable = false;
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }

    if (!_speechAvailable) {
      await _initSpeech();
      if (!_speechAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Microphone/speech not available. Please grant mic permission and ensure a speech service is installed.'),
            ),
          );
        }
        return;
      }
    }

    setState(() => _isListening = true);
    await _speech.listen(
      localeId: _selectedLocaleId,
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.dictation,
      ),
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _controller.text = result.recognizedWords;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        });
        // When the engine finalizes the phrase, auto-send it.
        if (result.finalResult && _controller.text.trim().isNotEmpty) {
          setState(() => _isListening = false);
          _sendMessage();
        }
      },
    );
  }

  void _showLanguagePicker() {
    if (_locales.isEmpty) return;
    // Show a short, relevant list: Amharic + English variants first.
    final preferred = <stt.LocaleName>[];
    final others = <stt.LocaleName>[];
    for (final l in _locales) {
      final id = l.localeId.toLowerCase();
      if (id.startsWith('am') || id.startsWith('en')) {
        preferred.add(l);
      } else {
        others.add(l);
      }
    }
    final ordered = [...preferred, ...others];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Voice language',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: ordered.map((l) {
                    final selected = l.localeId == _selectedLocaleId;
                    return ListTile(
                      title: Text(l.name,
                          style: const TextStyle(fontFamily: 'Poppins')),
                      subtitle: Text(l.localeId,
                          style: const TextStyle(
                              fontFamily: 'Poppins', fontSize: 11)),
                      trailing: selected
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () {
                        setState(() => _selectedLocaleId = l.localeId);
                        Navigator.pop(ctx);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
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
              Text('FoodIQ AI', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 16)),
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
                      style: TextStyle(fontFamily: 'Poppins', 
                          fontSize: 10,
                          color: _isOnline ? AppColors.success : Colors.grey)),
                ],
              ),
            ]),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Voice language',
            icon: const Icon(Icons.language),
            onPressed: _speechAvailable ? _showLanguagePicker : null,
          ),
        ],
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isListening)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mic, color: AppColors.error, size: 16),
                          const SizedBox(width: 6),
                          Text('Listening… speak now',
                              style: TextStyle(fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: 'Ask about nutrition... / በአማርኛ ይጠይቁ',
                            filled: true,
                            fillColor: isDark ? AppColors.darkCard : AppColors.cream,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Voice (mic) button
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: _isListening
                              ? AppColors.error
                              : (isDark ? AppColors.darkCard : AppColors.cream),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.4)),
                        ),
                        child: IconButton(
                          tooltip: _isListening
                              ? 'Stop listening'
                              : 'Speak (Amharic supported)',
                          icon: Icon(
                            _isListening ? Icons.stop : Icons.mic,
                            color: _isListening ? Colors.white : AppColors.primary,
                            size: 22,
                          ),
                          onPressed: _toggleListening,
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
          style: TextStyle(fontFamily: 'Poppins', 
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
          style: TextStyle(fontFamily: 'Poppins', 
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
