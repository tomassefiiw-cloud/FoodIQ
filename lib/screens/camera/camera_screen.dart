import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../../core/constants/app_colors.dart';
import '../../services/ai_service.dart';
import '../../services/log_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/calorie_provider.dart';
import '../../core/constants/food_database.dart';
import '../../models/calorie_log.dart';
import '../../models/ai_models.dart';
import '../../models/food_item.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  File? _selectedImage;
  String? _base64Image;
  bool _isAnalyzing = false;
  AIFoodResult? _result;
  String? _error;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 80);

    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      setState(() {
        _selectedImage = File(image.path);
        _base64Image = base64Encode(bytes);
        _result = null;
        _error = null;
      });
      _analyzeImage();
    }
  }

  Future<void> _analyzeImage() async {
    if (_base64Image == null) return;

    setState(() {
      _isAnalyzing = true;
      _error = null;
    });

    final detailed = await AIService.recognizeFoodDetailed(_base64Image!);

    if (!mounted) return;
    setState(() {
      _isAnalyzing = false;
      if (detailed.result != null) {
        _result = detailed.result;
      } else {
        _error = detailed.error ??
            'Could not identify the food. Try a clearer photo with good lighting.';
      }
    });

    // Automatically show meal type selection dialog after successful analysis.
    // This is REQUIRED — the user must select breakfast/lunch/dinner/snack
    // before the food can be logged.
    if (detailed.result != null && mounted) {
      // Use a post-frame callback to ensure the UI has fully rebuilt
      // before showing the dialog. This prevents the dialog from being
      // dismissed by the setState above.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _result != null) {
          _showMealTypeDialog(_result!);
        }
      });
    }
  }

  /// Show meal type selection dialog before logging the food.
  /// The dialog is NOT dismissible by tapping outside — the user MUST
  /// choose a meal type or explicitly press "Cancel" (which skips logging).
  Future<void> _showMealTypeDialog(AIFoodResult result) async {
    final MealType? selected = await showModalBottomSheet<MealType>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false, // User must explicitly choose
      enableDrag: false,    // Cannot swipe away — must pick or cancel
      isScrollControlled: true,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Icon header
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.restaurant_menu, color: AppColors.primary, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                'Which meal is this?',
                style: TextStyle(fontFamily: 'Poppins', 
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${result.foodName} • ${result.calories.toStringAsFixed(0)} kcal',
                style: TextStyle(fontFamily: 'Poppins', 
                  fontSize: 15,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              // Meal type options
              _MealTypeOption(
                icon: '🌅',
                label: 'Breakfast',
                subtitle: 'Morning meal',
                color: const Color(0xFFFF9800),
                onTap: () => Navigator.of(ctx).pop(MealType.breakfast),
              ),
              const SizedBox(height: 10),
              _MealTypeOption(
                icon: '☀️',
                label: 'Lunch',
                subtitle: 'Midday meal',
                color: const Color(0xFF4CAF50),
                onTap: () => Navigator.of(ctx).pop(MealType.lunch),
              ),
              const SizedBox(height: 10),
              _MealTypeOption(
                icon: '🌙',
                label: 'Dinner',
                subtitle: 'Evening meal',
                color: const Color(0xFF3F51B5),
                onTap: () => Navigator.of(ctx).pop(MealType.dinner),
              ),
              const SizedBox(height: 10),
              _MealTypeOption(
                icon: '🍿',
                label: 'Snack',
                subtitle: 'Between meals',
                color: const Color(0xFFE91E63),
                onTap: () => Navigator.of(ctx).pop(MealType.snack),
              ),
              const SizedBox(height: 16),
              // Cancel button
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(null),
                child: Text(
                  'Skip logging',
                  style: TextStyle(fontFamily: 'Poppins', 
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      await _logFood(result, mealType: selected);
    }
  }

  Future<void> _logFood(AIFoodResult result, {required MealType mealType}) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final success = await LogService.addCalorieLog(
      userId: user.id,
      foodId: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      foodName: result.foodName,
      mealType: mealType,
      portion: 1.0,
      calories: result.calories,
      protein: result.protein,
      carbs: result.carbs,
      fat: result.fat,
      fiber: 0,
      servingSize: result.servingSize,
    );

    if (success && mounted) {
      // Force dashboard + analytics to refresh immediately
      ref.invalidate(todayCalorieLogsProvider);
      ref.invalidate(todayCalorieSummaryProvider);
      ref.invalidate(weeklyCalorieLogsProvider);
      ref.invalidate(monthlyCalorieLogsProvider);

      final mealLabel = _mealTypeLabel(mealType);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${result.foodName} logged as $mealLabel! ${result.calories.toStringAsFixed(0)} kcal'),
          backgroundColor: AppColors.success,
        ),
      );
      setState(() { _selectedImage = null; _result = null; _base64Image = null; });
    }
  }

  String _mealTypeLabel(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return 'Breakfast 🌅';
      case MealType.lunch:
        return 'Lunch ☀️';
      case MealType.dinner:
        return 'Dinner 🌙';
      case MealType.snack:
        return 'Snack 🍿';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text('AI Food Scanner', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image preview
            Container(
              height: 280,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
              ),
              child: _selectedImage != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.file(_selectedImage!, width: double.infinity, height: double.infinity, fit: BoxFit.cover),
                      ),
                      if (_isAnalyzing)
                        Container(
                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(18)),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(color: AppColors.primary),
                                const SizedBox(height: 12),
                                Text('AI is analyzing...', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                                Text('Identifying your food', style: TextStyle(fontFamily: 'Poppins', color: Colors.white70, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 64, color: AppColors.primary.withOpacity(0.5)),
                      const SizedBox(height: 12),
                      Text('Take a photo of your food', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Colors.grey)),
                      Text('AI will identify and log it', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey)),
                    ],
                  ),
            ),
            const SizedBox(height: 16),

            // Camera / Gallery buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: Text('Camera', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: Text('Gallery', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Error
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error),
                    const SizedBox(height: 12),
                    Expanded(child: Text(_error!, style: TextStyle(fontFamily: 'Poppins', color: AppColors.error))),
                  ],
                ),
              ),

            // Result
            if (_result != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _result!.isConfident ? AppColors.success : AppColors.warning,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${(_result!.confidence * 100).toStringAsFixed(0)}% match',
                            style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (_result!.isEthiopian) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.ethGreen, borderRadius: BorderRadius.circular(8)),
                            child: Text('Ethiopian 🇪🇹', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(_result!.foodName, style: TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _NutrientChip(label: '${_result!.calories.toStringAsFixed(0)} kcal', color: AppColors.primary),
                        const SizedBox(width: 8),
                        _NutrientChip(label: 'P: ${_result!.protein.toStringAsFixed(1)}g', color: AppColors.proteinBlue),
                        const SizedBox(width: 8),
                        _NutrientChip(label: 'C: ${_result!.carbs.toStringAsFixed(1)}g', color: AppColors.carbsOrange),
                        const SizedBox(width: 8),
                        _NutrientChip(label: 'F: ${_result!.fat.toStringAsFixed(1)}g', color: AppColors.fatRed),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () => _showMealTypeDialog(_result!),
                        icon: const Icon(Icons.restaurant_menu),
                        label: Text('Log This Food', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        'Select meal type: Breakfast, Lunch, Dinner, or Snack',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A single meal-type option row in the bottom sheet.
class _MealTypeOption extends StatelessWidget {
  final String icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MealTypeOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(fontFamily: 'Poppins', 
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontFamily: 'Poppins', 
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _NutrientChip extends StatelessWidget {
  final String label;
  final Color color;
  const _NutrientChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
