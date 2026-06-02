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
import '../../providers/food_provider.dart';
import '../../services/food_service.dart';

class FoodLogScreen extends ConsumerStatefulWidget {
  final int initialTab;
  const FoodLogScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<FoodLogScreen> createState() => _FoodLogScreenState();
}

class _FoodLogScreenState extends ConsumerState<FoodLogScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 2),
    );
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
                  ref.invalidate(weeklyCalorieLogsProvider);
                  ref.invalidate(monthlyCalorieLogsProvider);
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
// ============================================================================
// Custom Foods Tab — list user-created foods + add new manually.
// ============================================================================
class _CustomFoodTab extends ConsumerWidget {
  const _CustomFoodTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customAsync = ref.watch(customFoodsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: customAsync.when(
        data: (foods) {
          if (foods.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline,
                        size: 64, color: AppColors.primary.withOpacity(0.4)),
                    const SizedBox(height: 16),
                    Text('No custom foods yet',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: isDark ? Colors.grey[300] : Colors.grey[800])),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to add your own foods with custom nutrition info.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => _showAddManualFood(context, ref),
                      icon: const Icon(Icons.add),
                      label: Text('Add food manually',
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            itemCount: foods.length,
            itemBuilder: (_, i) {
              final food = foods[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04), blurRadius: 6)
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => _FoodLogBottomSheet(food: food),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              gradient: AppColors.orangeGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.restaurant_menu,
                                color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(food.name,
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15)),
                                const SizedBox(height: 2),
                                Text(
                                    '${food.calories.toStringAsFixed(0)} kcal · '
                                    'P ${food.protein.toStringAsFixed(0)}g · '
                                    'C ${food.carbs.toStringAsFixed(0)}g · '
                                    'F ${food.fat.toStringAsFixed(0)}g',
                                    style: GoogleFonts.poppins(
                                        fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.redAccent),
                            tooltip: 'Delete',
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text('Delete ${food.name}?',
                                      style: GoogleFonts.poppins()),
                                  content: Text(
                                    'This only removes the custom food, not any logs you already added.',
                                    style: GoogleFonts.poppins(fontSize: 13),
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel')),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent),
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Delete')),
                                  ],
                                ),
                              );
                              if (ok == true) {
                                await FoodService.deleteCustomFood(food.id);
                                ref.invalidate(customFoodsProvider);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off,
                    size: 48, color: Colors.redAccent),
                const SizedBox(height: 12),
                Text('Could not load custom foods',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('$e',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(customFoodsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'addCustomFoodFAB',
        onPressed: () => _showAddManualFood(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text('Add food',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
    );
  }

  static void _showAddManualFood(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ManualFoodSheet(),
    );
  }
}

// ============================================================================
// Manual food entry bottom sheet (saves to custom_foods table).
// ============================================================================
class _ManualFoodSheet extends ConsumerStatefulWidget {
  const _ManualFoodSheet();

  @override
  ConsumerState<_ManualFoodSheet> createState() => _ManualFoodSheetState();
}

class _ManualFoodSheetState extends ConsumerState<_ManualFoodSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController(text: '0');
  final _carbsCtrl = TextEditingController(text: '0');
  final _fatCtrl = TextEditingController(text: '0');
  final _fiberCtrl = TextEditingController(text: '0');
  final _servingCtrl = TextEditingController(text: '100');
  bool _alsoLogNow = true;
  MealType _mealType = FoodDatabase.inferMealType();
  bool _busy = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _calCtrl.dispose();
    _proteinCtrl.dispose();
    _carbsCtrl.dispose();
    _fatCtrl.dispose();
    _fiberCtrl.dispose();
    _servingCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Add food manually',
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  'Type the nutrition info from the package or your own recipe.',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Food name',
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _calCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Calories',
                          suffixText: 'kcal',
                          prefixIcon: Icon(Icons.local_fire_department),
                        ),
                        validator: (v) {
                          final n = double.tryParse(v ?? '');
                          if (n == null || n <= 0) return 'Must be > 0';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _servingCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Serving',
                          suffixText: 'g',
                          prefixIcon: Icon(Icons.scale),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _proteinCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Protein (g)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _carbsCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Carbs (g)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _fatCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Fat (g)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _fiberCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Fiber (g) — optional',
                    prefixIcon: Icon(Icons.eco),
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.primary,
                  value: _alsoLogNow,
                  onChanged: (v) => setState(() => _alsoLogNow = v ?? true),
                  title: Text('Also log this now (as ${_mealType.name})',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(
                    _alsoLogNow
                        ? 'It will be added to today\'s ${_mealType.name} entries.'
                        : 'Just save it to your custom foods list.',
                    style:
                        GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                  ),
                ),
                if (_alsoLogNow) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: MealType.values.map((m) {
                      final selected = m == _mealType;
                      return ChoiceChip(
                        label: Text(
                            m.name[0].toUpperCase() + m.name.substring(1),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: selected ? Colors.white : null,
                            )),
                        selected: selected,
                        onSelected: (_) => setState(() => _mealType = m),
                        selectedColor: AppColors.primary,
                        backgroundColor:
                            isDark ? AppColors.darkCard : Colors.grey[100],
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _busy ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _busy
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5))
                        : Text('Save food',
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _busy = true);
    try {
      final name = _nameCtrl.text.trim();
      final cal = double.parse(_calCtrl.text);
      final protein = double.tryParse(_proteinCtrl.text) ?? 0;
      final carbs = double.tryParse(_carbsCtrl.text) ?? 0;
      final fat = double.tryParse(_fatCtrl.text) ?? 0;
      final fiber = double.tryParse(_fiberCtrl.text) ?? 0;
      final serving = double.tryParse(_servingCtrl.text) ?? 100;

      final ok = await FoodService.addCustomFood(
        userId: user.id,
        name: name,
        calories: cal,
        protein: protein,
        carbs: carbs,
        fat: fat,
        fiber: fiber,
        servingSize: serving,
      );

      if (!ok) throw Exception('Could not save (check internet)');

      // Optionally log it right now too
      if (_alsoLogNow) {
        await LogService.addCalorieLog(
          userId: user.id,
          foodId: 'manual_${DateTime.now().millisecondsSinceEpoch}',
          foodName: name,
          mealType: _mealType,
          portion: 1.0,
          calories: cal,
          protein: protein,
          carbs: carbs,
          fat: fat,
          fiber: fiber,
          servingSize: serving,
        );
        ref.invalidate(todayCalorieLogsProvider);
        ref.invalidate(todayCalorieSummaryProvider);
        ref.invalidate(weeklyCalorieLogsProvider);
        ref.invalidate(monthlyCalorieLogsProvider);
      }

      ref.invalidate(customFoodsProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _alsoLogNow
                  ? '✅ $name saved & logged (${cal.toStringAsFixed(0)} kcal)'
                  : '✅ $name added to your custom foods',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
