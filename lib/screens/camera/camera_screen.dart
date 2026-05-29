import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../../core/constants/app_colors.dart';
import '../../services/ai_service.dart';
import '../../services/log_service.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/food_database.dart';
import '../../models/calorie_log.dart';
import '../../models/ai_models.dart';

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
    
    setState(() { _isAnalyzing = true; _error = null; });
    
    final result = await AIService.recognizeFood(_base64Image!);
    
    setState(() {
      _isAnalyzing = false;
      if (result != null) {
        _result = result;
      } else {
        _error = 'Could not identify the food. Try a clearer photo.';
      }
    });
  }

  Future<void> _logFood(AIFoodResult result) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final mealType = FoodDatabase.inferMealType();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${result.foodName} logged! ${result.calories.toStringAsFixed(0)} kcal'),
          backgroundColor: AppColors.success,
        ),
      );
      setState(() { _selectedImage = null; _result = null; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text('AI Food Scanner', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
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
                                Text('AI is analyzing...', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                                Text('Identifying your food', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
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
                      Text('Take a photo of your food', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
                      Text('AI will identify and log it', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
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
                    label: Text('Camera', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
                    label: Text('Gallery', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
                    const SizedBox(width: 12),
                    Expanded(child: Text(_error!, style: GoogleFonts.poppins(color: AppColors.error))),
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
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (_result!.isEthiopian) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.ethGreen, borderRadius: BorderRadius.circular(8)),
                            child: Text('Ethiopian 🇪🇹', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(_result!.foodName, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
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
                        onPressed: () => _logFood(_result!),
                        icon: const Icon(Icons.add_circle),
                        label: Text('Log This Food', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
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

class _NutrientChip extends StatelessWidget {
  final String label;
  final Color color;
  const _NutrientChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
