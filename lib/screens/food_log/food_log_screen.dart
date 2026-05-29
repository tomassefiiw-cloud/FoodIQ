import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/food_database.dart';
import '../../models/food_item.dart';
import '../../models/calorie_log.dart';
import '../../services/log_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/calorie_provider.dart';

class FoodLogScreen extends ConsumerStatefulWidget {
  const FoodLogScreen({super.key});

  @override
  ConsumerState<FoodLogScreen> createState() => _FoodLogScreenState();
}

class _FoodLogScreenState extends ConsumerState<FoodLogScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<FoodItem> _filterFoods(List<FoodItem> foods) {
    if (_searchQuery.isEmpty) return foods;
    return FoodDatabase.searchFoods(_searchQuery)
        .where((f) => foods.any((e) => e.id == f.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Database', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Ethiopian 🇪🇹'),
            Tab(text: 'Common 🌍'),
            Tab(text: 'Custom ⭐'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search food... (English or አማርኛ)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _searchQuery = ''))
                  : null,
              ),
            ),
          ),
          // Food list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _FoodList(
                  foods: _filterFoods(FoodDatabase.ethiopianFoods),
                  onFoodTap: (food) => _showLogBottomSheet(context, food),
                ),
                _FoodList(
                  foods: _filterFoods(FoodDatabase.commonFoods),
                  onFoodTap: (food) => _showLogBottomSheet(context, food),
                ),
                const _CustomFoodTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogBottomSheet(BuildContext context, FoodItem food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FoodLogBottomSheet(food: food),
    );
  }
}

class _FoodList extends StatelessWidget {
  final List<FoodItem> foods;
  final Function(FoodItem) onFoodTap;

  const _FoodList({required this.foods, required this.onFoodTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (foods.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('No foods found', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: foods.length,
      itemBuilder: (_, i) {
        final food = foods[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onFoodTap(food),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: food.category == FoodCategory.ethiopian
                          ? AppColors.ethGreen.withOpacity(0.1)
                          : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        food.category == FoodCategory.ethiopian ? Icons.restaurant : Icons.fastfood,
                        color: food.category == FoodCategory.ethiopian ? AppColors.ethGreen : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(food.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                          if (food.nameAmharic.isNotEmpty)
                            Text(food.nameAmharic, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text('P:${food.protein.toStringAsFixed(1)}g', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.proteinBlue)),
                              const SizedBox(width: 8),
                              Text('C:${food.carbs.toStringAsFixed(1)}g', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.carbsOrange)),
                              const SizedBox(width: 8),
                              Text('F:${food.fat.toStringAsFixed(1)}g', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.fatRed)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${food.calories.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
                        Text('kcal', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FoodLogBottomSheet extends ConsumerStatefulWidget {
  final FoodItem food;
  const _FoodLogBottomSheet({required this.food});

  @override
  ConsumerState<_FoodLogBottomSheet> createState() => _FoodLogBottomSheetState();
}

class _FoodLogBottomSheetState extends ConsumerState<_FoodLogBottomSheet> {
  double _portion = 1.0;
  MealType _mealType = FoodDatabase.inferMealType();

  @override
  Widget build(BuildContext context) {
    final scaled = widget.food.scaledTo(_portion);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text(widget.food.name, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
          if (widget.food.nameAmharic.isNotEmpty)
            Text(widget.food.nameAmharic, style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 20),

          // Meal type selection
          Text('Meal Type', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: MealType.values.map((type) {
              final isSelected = type == _mealType;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _mealType = type),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : (isDark ? AppColors.darkCard : Colors.grey[100]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      type.name[0].toUpperCase() + type.name.substring(1),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: isSelected ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Portion slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Portion: ${_portion.toStringAsFixed(1)}x', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
              Text('${(_portion * widget.food.servingSize).toStringAsFixed(0)}g', style: GoogleFonts.poppins(color: Colors.grey)),
            ],
          ),
          Slider(
            value: _portion,
            min: 0.5,
            max: 3.0,
            divisions: 25,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _portion = v),
          ),
          const SizedBox(height: 12),

          // Nutrition summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NutrientItem(label: 'Calories', value: '${scaled.calories.toStringAsFixed(0)}', unit: 'kcal', color: AppColors.primary),
                _NutrientItem(label: 'Protein', value: '${scaled.protein.toStringAsFixed(1)}', unit: 'g', color: AppColors.proteinBlue),
                _NutrientItem(label: 'Carbs', value: '${scaled.carbs.toStringAsFixed(1)}', unit: 'g', color: AppColors.carbsOrange),
                _NutrientItem(label: 'Fat', value: '${scaled.fat.toStringAsFixed(1)}', unit: 'g', color: AppColors.fatRed),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Log button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                final user = ref.read(currentUserProvider);
                if (user == null) return;

                final success = await LogService.addCalorieLog(
                  userId: user.id,
                  foodId: widget.food.id,
                  foodName: widget.food.name,
                  mealType: _mealType,
                  portion: _portion,
                  calories: scaled.calories,
                  protein: scaled.protein,
                  carbs: scaled.carbs,
                  fat: scaled.fat,
                  fiber: scaled.fiber,
                  servingSize: scaled.servingSize,
                );

                if (success && mounted) {
                  Navigator.pop(context);
                  ref.invalidate(todayCalorieLogsProvider);
                  ref.invalidate(todayCalorieSummaryProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ ${widget.food.name} logged! ${scaled.calories.toStringAsFixed(0)} kcal'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Log Food', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 8),
        ],
      ),
    );
  }
}

class _NutrientItem extends StatelessWidget {
  final String label, value, unit;
  final Color color;
  const _NutrientItem({required this.label, required this.value, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        Text(unit, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

class _CustomFoodTab extends StatelessWidget {
  const _CustomFoodTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_circle_outline, size: 48, color: AppColors.primary.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text('Create custom foods', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 8),
          Text('Coming soon in next update!', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}
