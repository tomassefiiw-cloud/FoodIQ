import '../../models/food_item.dart';

class EthiopianFoods {
  static const List<FoodItem> items = [
    // ===== BREADS & STAPLES (et_001 - et_015) =====
    FoodItem(id: 'et_001', name: 'Injera', nameAmharic: 'እንጀራ', calories: 110, protein: 3.7, carbs: 23, fat: 0.7, fiber: 3.2, servingSize: 100, category: FoodCategory.ethiopian, description: 'Spongy sourdough flatbread made from teff flour'),
    FoodItem(id: 'et_002', name: 'Dabbo', nameAmharic: 'ዳቦ', calories: 265, protein: 8.0, carbs: 49, fat: 3.5, fiber: 2.1, servingSize: 100, category: FoodCategory.ethiopian, description: 'Ethiopian sweet bread'),
    FoodItem(id: 'et_003', name: 'Ambasha', nameAmharic: 'አምባሻ', calories: 280, protein: 7.5, carbs: 52, fat: 5.0, fiber: 1.8, servingSize: 100, category: FoodCategory.ethiopian, description: 'Ethiopian spiced festive bread'),
    FoodItem(id: 'et_004', name: 'Kita', nameAmharic: 'ቂጣ', calories: 240, protein: 6.0, carbs: 46, fat: 4.0, fiber: 1.5, servingSize: 100, category: FoodCategory.ethiopian, description: 'Thin unleavened flatbread'),
    FoodItem(id: 'et_005', name: 'Chechebsa', nameAmharic: 'ጨጨብሳ', calories: 320, protein: 8.5, carbs: 42, fat: 14, fiber: 2.3, servingSize: 200, category: FoodCategory.ethiopian, description: 'Shredded flatbread with spiced butter'),
    FoodItem(id: 'et_006', name: 'Genfo', nameAmharic: 'ገንፎ', calories: 350, protein: 9.0, carbs: 58, fat: 10, fiber: 3.0, servingSize: 250, category: FoodCategory.ethiopian, description: 'Ethiopian porridge with butter and spices'),
    FoodItem(id: 'et_007', name: 'Bula', nameAmharic: 'ቡላ', calories: 160, protein: 2.0, carbs: 38, fat: 0.5, fiber: 0.8, servingSize: 100, category: FoodCategory.ethiopian, description: 'Enset flour porridge'),
    FoodItem(id: 'et_008', name: 'Kocho', nameAmharic: 'ቆጮ', calories: 180, protein: 2.5, carbs: 40, fat: 0.8, fiber: 2.0, servingSize: 100, category: FoodCategory.ethiopian, description: 'Enset bread from southern Ethiopia'),
    FoodItem(id: 'et_009', name: 'Aja', nameAmharic: 'አጃ', calories: 130, protein: 4.0, carbs: 26, fat: 1.5, fiber: 3.5, servingSize: 100, category: FoodCategory.ethiopian, description: 'Oat-based Ethiopian porridge'),
    FoodItem(id: 'et_010', name: 'Injera Firfir', nameAmharic: 'እንጀራ ፍርፍር', calories: 280, protein: 7.5, carbs: 40, fat: 11, fiber: 3.0, servingSize: 200, category: FoodCategory.ethiopian, description: 'Shredded injera with spiced butter'),
    FoodItem(id: 'et_011', name: 'Dabo Kolo', nameAmharic: 'ዳቦ ቆሎ', calories: 420, protein: 10, carbs: 62, fat: 16, fiber: 2.5, servingSize: 100, category: FoodCategory.ethiopian, description: 'Deep-fried snack bread pieces'),
    FoodItem(id: 'et_012', name: 'Himbasha', nameAmharic: 'ህምባሻ', calories: 275, protein: 7.0, carbs: 50, fat: 6.0, fiber: 1.5, servingSize: 100, category: FoodCategory.ethiopian, description: 'Eritrean/Ethiopian celebration bread'),
    FoodItem(id: 'et_013', name: 'Mulmul', nameAmharic: 'ሙልሙል', calories: 220, protein: 5.5, carbs: 44, fat: 3.0, fiber: 2.0, servingSize: 100, category: FoodCategory.ethiopian, description: 'Small wheat bread rolls'),
    FoodItem(id: 'et_014', name: 'Enset Bread', nameAmharic: 'እንሰት ዳቦ', calories: 170, protein: 1.8, carbs: 39, fat: 0.3, fiber: 2.5, servingSize: 100, category: FoodCategory.ethiopian, description: 'Bread made from enset plant'),
    FoodItem(id: 'et_015', name: 'Teff Flatbread', nameAmharic: 'ጤፍ እንጀራ', calories: 100, protein: 3.5, carbs: 21, fat: 0.6, fiber: 3.0, servingSize: 80, category: FoodCategory.ethiopian, description: 'Thin teff-based flatbread'),

    // ===== STEWS / WOT (et_016 - et_040) =====
    FoodItem(id: 'et_016', name: 'Doro Wot', nameAmharic: 'ዶሮ ወጥ', calories: 250, protein: 22, carbs: 8, fat: 15, fiber: 1.5, servingSize: 200, category: FoodCategory.ethiopian, description: 'Spicy chicken stew - the crown jewel of Ethiopian cuisine'),
    FoodItem(id: 'et_017', name: 'Misir Wot', nameAmharic: 'ምስር ወጥ', calories: 180, protein: 12, carbs: 24, fat: 4.5, fiber: 8.0, servingSize: 200, category: FoodCategory.ethiopian, description: 'Spicy red lentil stew'),
    FoodItem(id: 'et_018', name: 'Shiro Wot', nameAmharic: 'ሽሮ ወጥ', calories: 195, protein: 10, carbs: 22, fat: 7.5, fiber: 6.0, servingSize: 200, category: FoodCategory.ethiopian, description: 'Chickpea flour stew with spices'),
    FoodItem(id: 'et_019', name: 'Key Wot', nameAmharic: 'ቀይ ወጥ', calories: 230, protein: 18, carbs: 10, fat: 14, fiber: 2.0, servingSize: 200, category: FoodCategory.ethiopian, description: 'Spicy red beef stew'),
    FoodItem(id: 'et_020', name: 'Duba Wot', nameAmharic: 'ዱባ ወጥ', calories: 120, protein: 4.0, carbs: 18, fat: 4.5, fiber: 3.0, servingSize: 200, category: FoodCategory.ethiopian, description: 'Pumpkin stew'),
    FoodItem(id: 'et_021', name: 'Atkilt Wot', nameAmharic: 'አትክልት ወጥ', calories: 105, protein: 3.5, carbs: 16, fat: 3.5, fiber: 4.5, servingSize: 200, category: FoodCategory.ethiopian, description: 'Mixed vegetable stew'),
    FoodItem(id: 'et_022', name: 'Kik Wot', nameAmharic: 'ክክ ወጥ', calories: 175, protein: 11, carbs: 26, fat: 3.0, fiber: 7.5, servingSize: 200, category: FoodCategory.ethiopian, description: 'Split pea stew'),
    FoodItem(id: 'et_023', name: 'Gomen', nameAmharic: 'ጎሜን', calories: 85, protein: 4.5, carbs: 8, fat: 4.5, fiber: 5.0, servingSize: 150, category: FoodCategory.ethiopian, description: 'Collard greens with spices'),
    FoodItem(id: 'et_024', name: 'Fasolia', nameAmharic: 'ፋሶሊያ', calories: 110, protein: 5.0, carbs: 15, fat: 3.5, fiber: 4.0, servingSize: 150, category: FoodCategory.ethiopian, description: 'Green beans and carrots stew'),
    FoodItem(id: 'et_025', name: 'Shiro Alicha', nameAmharic: 'ሽሮ አሊጫ', calories: 170, protein: 9.0, carbs: 20, fat: 6.0, fiber: 5.5, servingSize: 200, category: FoodCategory.ethiopian, description: 'Mild chickpea flour stew'),
    FoodItem(id: 'et_026', name: 'Yatakilt Alicha', nameAmharic: 'ያታክልት አሊጫ', calories: 95, protein: 3.0, carbs: 14, fat: 3.0, fiber: 3.5, servingSize: 200, category: FoodCategory.ethiopian, description: 'Mild mixed vegetable stew'),
    FoodItem(id: 'et_027', name: 'Doro Alicha', nameAmharic: 'ዶሮ አሊጫ', calories: 210, protein: 20, carbs: 7, fat: 12, fiber: 1.0, servingSize: 200, category: FoodCategory.ethiopian, description: 'Mild chicken stew'),
    FoodItem(id: 'et_028', name: 'Kai Seg Wot', nameAmharic: 'ቀይ ስጋ ወጥ', calories: 245, protein: 20, carbs: 9, fat: 16, fiber: 1.5, servingSize: 200, category: FoodCategory.ethiopian, description: 'Spicy beef stew'),
    FoodItem(id: 'et_029', name: 'Yebeg Wot', nameAmharic: 'የበግ ወጥ', calories: 270, protein: 19, carbs: 8, fat: 20, fiber: 1.0, servingSize: 200, category: FoodCategory.ethiopian, description: 'Spicy lamb stew'),
    FoodItem(id: 'et_030', name: 'Dinch Wot', nameAmharic: 'ዲንች ወጥ', calories: 130, protein: 3.5, carbs: 22, fat: 3.5, fiber: 3.0, servingSize: 200, category: FoodCategory.ethiopian, description: 'Potato stew'),
    FoodItem(id: 'et_031', name: 'Karot Wot', nameAmharic: 'ካሮት ወጥ', calories: 100, protein: 2.5, carbs: 16, fat: 3.0, fiber: 4.0, servingSize: 150, category: FoodCategory.ethiopian, description: 'Carrot stew'),
    FoodItem(id: 'et_032', name: 'Tikil Gomen', nameAmharic: 'ጥቅል ጎሜን', calories: 75, protein: 3.0, carbs: 10, fat: 2.5, fiber: 4.5, servingSize: 150, category: FoodCategory.ethiopian, description: 'Cabbage with turmeric'),
    FoodItem(id: 'et_033', name: 'Shiro Beg Wot', nameAmharic: 'ሽሮ በግ ወጥ', calories: 215, protein: 15, carbs: 14, fat: 11, fiber: 4.0, servingSize: 200, category: FoodCategory.ethiopian, description: 'Chickpea stew with lamb'),
    FoodItem(id: 'et_034', name: 'Yetsom Beyaynetu', nameAmharic: 'የጾም በየይነቱ', calories: 350, protein: 14, carbs: 48, fat: 12, fiber: 10, servingSize: 400, category: FoodCategory.ethiopian, description: 'Fasting platter - mix of vegetable dishes'),
    FoodItem(id: 'et_035', name: 'Quanta Wot', nameAmharic: 'ቋንቋ ወጥ', calories: 290, protein: 28, carbs: 10, fat: 16, fiber: 1.5, servingSize: 200, category: FoodCategory.ethiopian, description: 'Spicy dried meat stew'),

    // ===== RAW MEAT DISHES (et_036 - et_043) =====
    FoodItem(id: 'et_036', name: 'Kitfo', nameAmharic: 'ክትፎ', calories: 320, protein: 28, carbs: 2, fat: 23, fiber: 0, servingSize: 200, category: FoodCategory.ethiopian, description: 'Minced raw beef with mitmita spice'),
    FoodItem(id: 'et_037', name: 'Gored Gored', nameAmharic: 'ጎረድ ጎረድ', calories: 300, protein: 26, carbs: 1, fat: 22, fiber: 0, servingSize: 200, category: FoodCategory.ethiopian, description: 'Cubed raw beef with spices'),
    FoodItem(id: 'et_038', name: 'Tire Siga', nameAmharic: 'ጥሬ ስጋ', calories: 280, protein: 25, carbs: 0, fat: 20, fiber: 0, servingSize: 150, category: FoodCategory.ethiopian, description: 'Raw beef chunks'),
    FoodItem(id: 'et_039', name: 'Kitfo Leb Leb', nameAmharic: 'ክትፎ ለብ ለብ', calories: 310, protein: 27, carbs: 3, fat: 22, fiber: 0, servingSize: 200, category: FoodCategory.ethiopian, description: 'Slightly warmed kitfo'),
    FoodItem(id: 'et_040', name: 'Kurt', nameAmharic: 'ኩርት', calories: 260, protein: 24, carbs: 0, fat: 18, fiber: 0, servingSize: 150, category: FoodCategory.ethiopian, description: 'Raw beef dipped in sauce'),
    FoodItem(id: 'et_041', name: 'Quanta', nameAmharic: 'ቋንቋ', calories: 250, protein: 32, carbs: 5, fat: 12, fiber: 0, servingSize: 100, category: FoodCategory.ethiopian, description: 'Dried spiced meat'),
    FoodItem(id: 'et_042', name: 'Quanta Firfir', nameAmharic: 'ቋንቋ ፍርፍር', calories: 310, protein: 22, carbs: 28, fat: 13, fiber: 2.5, servingSize: 250, category: FoodCategory.ethiopian, description: 'Dried meat with shredded injera'),
    FoodItem(id: 'et_043', name: 'Dereq Tibs', nameAmharic: 'ደረቅ ጥብስ', calories: 275, protein: 23, carbs: 5, fat: 19, fiber: 0.5, servingSize: 200, category: FoodCategory.ethiopian, description: 'Dry sauteed meat'),

    // ===== VEGETABLE DISHES (et_044 - et_053) =====
    FoodItem(id: 'et_044', name: 'Gomen Besiga', nameAmharic: 'ጎሜን በስጋ', calories: 160, protein: 12, carbs: 8, fat: 9, fiber: 4.5, servingSize: 200, category: FoodCategory.ethiopian, description: 'Collard greens with meat'),
    FoodItem(id: 'et_045', name: 'Misir Alicha', nameAmharic: 'ምስር አሊጫ', calories: 155, protein: 10, carbs: 22, fat: 3.0, fiber: 7.5, servingSize: 200, category: FoodCategory.ethiopian, description: 'Mild yellow lentil stew'),
    FoodItem(id: 'et_046', name: 'Kik Alicha', nameAmharic: 'ክክ አሊጫ', calories: 150, protein: 9.5, carbs: 24, fat: 2.5, fiber: 7.0, servingSize: 200, category: FoodCategory.ethiopian, description: 'Mild split pea stew'),
    FoodItem(id: 'et_047', name: 'Sik Sik', nameAmharic: 'ስስቅ', calories: 190, protein: 15, carbs: 10, fat: 10, fiber: 3.0, servingSize: 200, category: FoodCategory.ethiopian, description: 'Mixed vegetable and grain dish'),
    FoodItem(id: 'et_048', name: 'Tmhim', nameAmharic: 'ጥምህም', calories: 95, protein: 3.0, carbs: 14, fat: 3.0, fiber: 4.0, servingSize: 150, category: FoodCategory.ethiopian, description: 'Spiced vegetable dish'),
    FoodItem(id: 'et_049', name: 'Ater Kik', nameAmharic: 'አጠር ክክ', calories: 160, protein: 10, carbs: 25, fat: 2.5, fiber: 6.5, servingSize: 200, category: FoodCategory.ethiopian, description: 'Chickpea stew'),
    FoodItem(id: 'et_050', name: 'Hilibit', nameAmharic: 'ሂሊቢት', calories: 140, protein: 5.0, carbs: 20, fat: 4.0, fiber: 5.0, servingSize: 200, category: FoodCategory.ethiopian, description: 'Ethiopian vegetable medley'),
    FoodItem(id: 'et_051', name: 'Zigni', nameAmharic: 'ዚግኒ', calories: 200, protein: 15, carbs: 12, fat: 10, fiber: 2.0, servingSize: 200, category: FoodCategory.ethiopian, description: 'Spicy meat and vegetable stew'),
    FoodItem(id: 'et_052', name: 'Birsen', nameAmharic: 'ብርሰን', calories: 85, protein: 4.0, carbs: 12, fat: 2.5, fiber: 4.0, servingSize: 150, category: FoodCategory.ethiopian, description: 'Green vegetable stew'),
    FoodItem(id: 'et_053', name: 'Inguday Tibs', nameAmharic: 'እንጉዳይ ጥብስ', calories: 130, protein: 5.0, carbs: 10, fat: 7.0, fiber: 3.0, servingSize: 150, category: FoodCategory.ethiopian, description: 'Sautéed mushrooms'),

    // ===== SNACKS & APPETIZERS (et_054 - et_063) =====
    FoodItem(id: 'et_054', name: 'Kolo', nameAmharic: 'ቆሎ', calories: 190, protein: 7.0, carbs: 30, fat: 5.5, fiber: 4.0, servingSize: 100, category: FoodCategory.ethiopian, description: 'Roasted barley snack'),
    FoodItem(id: 'et_055', name: 'Sambusa', nameAmharic: 'ሳምቡሳ', calories: 210, protein: 6.0, carbs: 24, fat: 10, fiber: 2.0, servingSize: 80, category: FoodCategory.ethiopian, description: 'Ethiopian samosa with lentil filling'),
    FoodItem(id: 'et_056', name: 'Dabbo Kolo', nameAmharic: 'ዳቦ ቆሎ', calories: 420, protein: 10, carbs: 62, fat: 16, fiber: 2.5, servingSize: 100, category: FoodCategory.ethiopian, description: 'Fried bread snack'),
    FoodItem(id: 'et_057', name: 'Nifro', nameAmharic: 'ንፍሮ', calories: 175, protein: 6.5, carbs: 32, fat: 2.0, fiber: 5.0, servingSize: 150, category: FoodCategory.ethiopian, description: 'Boiled wheat and barley mix'),
    FoodItem(id: 'et_058', name: 'Ashuk', nameAmharic: 'አሹክ', calories: 160, protein: 8.0, carbs: 28, fat: 2.0, fiber: 5.5, servingSize: 150, category: FoodCategory.ethiopian, description: 'Roasted chickpeas'),
    FoodItem(id: 'et_059', name: 'Chickpea Flour Snack', nameAmharic: 'ሽሮ ስንቅ', calories: 185, protein: 9.0, carbs: 25, fat: 6.0, fiber: 4.0, servingSize: 100, category: FoodCategory.ethiopian, description: 'Roasted chickpea flour balls'),
    FoodItem(id: 'et_060', name: 'Tihini', nameAmharic: 'ጥሂኒ', calories: 200, protein: 7.0, carbs: 28, fat: 7.5, fiber: 3.0, servingSize: 100, category: FoodCategory.ethiopian, description: 'Sesame-based snack'),
    FoodItem(id: 'et_061', name: 'Baklava', nameAmharic: 'ባክላቫ', calories: 350, protein: 5.0, carbs: 42, fat: 18, fiber: 1.5, servingSize: 80, category: FoodCategory.ethiopian, description: 'Sweet pastry with nuts and honey'),
    FoodItem(id: 'et_062', name: 'Kita with Honey', nameAmharic: 'ቂጣ ከማር', calories: 280, protein: 6.0, carbs: 48, fat: 8.0, fiber: 1.5, servingSize: 100, category: FoodCategory.ethiopian, description: 'Flatbread with honey'),
    FoodItem(id: 'et_063', name: 'Fendisha', nameAmharic: 'ፈንዲሻ', calories: 230, protein: 5.5, carbs: 40, fat: 6.0, fiber: 2.0, servingSize: 100, category: FoodCategory.ethiopian, description: 'Corn snack'),

    // ===== BEVERAGES (et_064 - et_075) =====
    FoodItem(id: 'et_064', name: 'Buna (Coffee)', nameAmharic: 'ቡና', calories: 5, protein: 0.3, carbs: 0, fat: 0, fiber: 0, servingSize: 200, category: FoodCategory.ethiopian, description: 'Traditional Ethiopian coffee'),
    FoodItem(id: 'et_065', name: 'Shai (Tea)', nameAmharic: 'ሻይ', calories: 2, protein: 0, carbs: 0.5, fat: 0, fiber: 0, servingSize: 200, category: FoodCategory.ethiopian, description: 'Ethiopian spiced tea'),
    FoodItem(id: 'et_066', name: 'Tej', nameAmharic: 'ጠጅ', calories: 180, protein: 0.5, carbs: 32, fat: 0, fiber: 0, servingSize: 250, category: FoodCategory.ethiopian, description: 'Ethiopian honey wine'),
    FoodItem(id: 'et_067', name: 'Tella', nameAmharic: 'ጠላ', calories: 150, protein: 1.0, carbs: 26, fat: 0, fiber: 0, servingSize: 250, category: FoodCategory.ethiopian, description: 'Traditional Ethiopian beer'),
    FoodItem(id: 'et_068', name: 'Ambo Water', nameAmharic: 'አምቦ ውሃ', calories: 0, protein: 0, carbs: 0, fat: 0, fiber: 0, servingSize: 330, category: FoodCategory.ethiopian, description: 'Ethiopian sparkling mineral water'),
    FoodItem(id: 'et_069', name: 'Areke', nameAmharic: 'አረቄ', calories: 120, protein: 0, carbs: 0, fat: 0, fiber: 0, servingSize: 100, category: FoodCategory.ethiopian, description: 'Ethiopian distilled spirit'),
    FoodItem(id: 'et_070', name: 'Spris', nameAmharic: 'ስፕሪስ', calories: 80, protein: 1.0, carbs: 18, fat: 0.5, fiber: 1.0, servingSize: 250, category: FoodCategory.ethiopian, description: 'Mixed fruit juice'),
    FoodItem(id: 'et_071', name: 'Mango Juice', nameAmharic: 'ማንጎ ጭማቂ', calories: 95, protein: 0.8, carbs: 23, fat: 0.3, fiber: 1.5, servingSize: 250, category: FoodCategory.ethiopian, description: 'Fresh mango juice'),
    FoodItem(id: 'et_072', name: 'Papaya Juice', nameAmharic: 'ፓፓያ ጭማቂ', calories: 75, protein: 0.6, carbs: 18, fat: 0.2, fiber: 2.0, servingSize: 250, category: FoodCategory.ethiopian, description: 'Fresh papaya juice'),
    FoodItem(id: 'et_073', name: 'Avocado Juice', nameAmharic: 'አቮካዶ ጭማቂ', calories: 160, protein: 2.5, carbs: 8, fat: 14, fiber: 3.5, servingSize: 250, category: FoodCategory.ethiopian, description: 'Creamy avocado juice'),
    FoodItem(id: 'et_074', name: 'Buna with Milk', nameAmharic: 'ቡና በወተት', calories: 85, protein: 4.0, carbs: 8, fat: 3.5, fiber: 0, servingSize: 250, category: FoodCategory.ethiopian, description: 'Coffee with milk'),
    FoodItem(id: 'et_075', name: 'Buna Kuraz', nameAmharic: 'ቡና ቁራዝ', calories: 45, protein: 0.3, carbs: 6, fat: 2.0, fiber: 0, servingSize: 200, category: FoodCategory.ethiopian, description: 'Coffee ceremony brew with sugar'),

    // ===== COMBO MEALS (et_076 - et_083) =====
    FoodItem(id: 'et_076', name: 'Injera + Doro Wot', nameAmharic: 'እንጀራ ዶሮ ወጥ', calories: 360, protein: 26, carbs: 31, fat: 16, fiber: 4.5, servingSize: 300, category: FoodCategory.ethiopian, description: 'Injera with spicy chicken stew'),
    FoodItem(id: 'et_077', name: 'Full Bayenetu', nameAmharic: 'ፉል በየኔቱ', calories: 450, protein: 18, carbs: 55, fat: 17, fiber: 8.0, servingSize: 400, category: FoodCategory.ethiopian, description: 'Vegetarian combo platter'),
    FoodItem(id: 'et_078', name: 'Injera + Kitfo', nameAmharic: 'እንጀራ ክትፎ', calories: 430, protein: 32, carbs: 25, fat: 24, fiber: 3.0, servingSize: 300, category: FoodCategory.ethiopian, description: 'Injera with raw minced beef'),
    FoodItem(id: 'et_079', name: 'Injera + Shiro', nameAmharic: 'እንጀራ ሽሮ', calories: 305, protein: 14, carbs: 45, fat: 8.0, fiber: 9.0, servingSize: 300, category: FoodCategory.ethiopian, description: 'Injera with chickpea flour stew'),
    FoodItem(id: 'et_080', name: 'Injera + Tibs', nameAmharic: 'እንጀራ ጥብስ', calories: 380, protein: 24, carbs: 28, fat: 20, fiber: 3.0, servingSize: 300, category: FoodCategory.ethiopian, description: 'Injera with sautéed meat'),
    FoodItem(id: 'et_081', name: 'Injera + Misir', nameAmharic: 'እንጀራ ምስር', calories: 290, protein: 16, carbs: 47, fat: 5.0, fiber: 11, servingSize: 300, category: FoodCategory.ethiopian, description: 'Injera with lentil stew'),
    FoodItem(id: 'et_082', name: 'Meat Beyaynetu', nameAmharic: 'ስጋ በየይነቱ', calories: 550, protein: 30, carbs: 50, fat: 25, fiber: 5.0, servingSize: 500, category: FoodCategory.ethiopian, description: 'Mixed meat platter with injera'),
    FoodItem(id: 'et_083', name: 'Fasting Combo', nameAmharic: 'የጾም ድንበር', calories: 380, protein: 14, carbs: 52, fat: 13, fiber: 10, servingSize: 400, category: FoodCategory.ethiopian, description: 'Lentil and vegetable combo platter'),

    // ===== SPICES & CONDIMENTS (et_084 - et_089) =====
    FoodItem(id: 'et_084', name: 'Berbere', nameAmharic: 'በርበሬ', calories: 35, protein: 1.5, carbs: 6, fat: 1.0, fiber: 2.5, servingSize: 15, category: FoodCategory.ethiopian, description: 'Hot pepper spice blend'),
    FoodItem(id: 'et_085', name: 'Mitmita', nameAmharic: 'ሚጥሚጣ', calories: 30, protein: 1.0, carbs: 5, fat: 0.8, fiber: 2.0, servingSize: 10, category: FoodCategory.ethiopian, description: 'Hot spice blend with cardamom'),
    FoodItem(id: 'et_086', name: 'Niter Kibbeh', nameAmharic: 'ንጥር ቅቤ', calories: 90, protein: 0, carbs: 0, fat: 10, fiber: 0, servingSize: 12, category: FoodCategory.ethiopian, description: 'Spiced clarified butter'),
    FoodItem(id: 'et_087', name: 'Awaze', nameAmharic: 'አዋዜ', calories: 40, protein: 1.0, carbs: 4, fat: 2.0, fiber: 1.0, servingSize: 15, category: FoodCategory.ethiopian, description: 'Spicy dipping sauce'),
    FoodItem(id: 'et_088', name: 'Datta', nameAmharic: 'ዳታ', calories: 25, protein: 0.5, carbs: 4, fat: 0.8, fiber: 1.0, servingSize: 15, category: FoodCategory.ethiopian, description: 'Chili pepper paste'),
    FoodItem(id: 'et_089', name: 'Senafich', nameAmharic: 'ሰናፍጭ', calories: 20, protein: 1.0, carbs: 2, fat: 1.0, fiber: 0.5, servingSize: 15, category: FoodCategory.ethiopian, description: 'Mustard sauce'),

    // ===== BREAKFAST ITEMS (et_090 - et_097) =====
    FoodItem(id: 'et_090', name: 'Firfir', nameAmharic: 'ፍርፍር', calories: 280, protein: 8.0, carbs: 38, fat: 12, fiber: 3.0, servingSize: 250, category: FoodCategory.ethiopian, description: 'Shredded injera with spiced butter and berbere'),
    FoodItem(id: 'et_091', name: 'Kinche', nameAmharic: 'ቂንጬ', calories: 170, protein: 5.5, carbs: 34, fat: 2.0, fiber: 3.5, servingSize: 200, category: FoodCategory.ethiopian, description: 'Cracked wheat porridge'),
    FoodItem(id: 'et_092', name: 'Ful', nameAmharic: 'ፉል', calories: 220, protein: 12, carbs: 28, fat: 7.0, fiber: 8.0, servingSize: 250, category: FoodCategory.ethiopian, description: 'Fava bean stew with spices'),
    FoodItem(id: 'et_093', name: 'Fatira', nameAmharic: 'ፋጥራ', calories: 350, protein: 12, carbs: 40, fat: 16, fiber: 2.0, servingSize: 200, category: FoodCategory.ethiopian, description: 'Fried pastry with egg and honey'),
    FoodItem(id: 'et_094', name: 'Enkulal Firfir', nameAmharic: 'እንቁላል ፍርፍር', calories: 230, protein: 14, carbs: 20, fat: 11, fiber: 2.0, servingSize: 200, category: FoodCategory.ethiopian, description: 'Scrambled eggs with shredded injera'),
    FoodItem(id: 'et_095', name: 'Enkulal Tibs', nameAmharic: 'እንቁላል ጥብስ', calories: 195, protein: 13, carbs: 4, fat: 14, fiber: 0.5, servingSize: 150, category: FoodCategory.ethiopian, description: 'Fried eggs Ethiopian style'),
    FoodItem(id: 'et_096', name: 'Shahan Ful', nameAmharic: 'ሻህን ፉል', calories: 260, protein: 14, carbs: 32, fat: 8.0, fiber: 9.0, servingSize: 300, category: FoodCategory.ethiopian, description: 'Special fava bean breakfast with eggs'),
    FoodItem(id: 'et_097', name: 'Atmit', nameAmharic: 'አጥሚት', calories: 200, protein: 6.0, carbs: 35, fat: 4.0, fiber: 2.5, servingSize: 250, category: FoodCategory.ethiopian, description: 'Oat and barley drink'),

    // ===== TIBS VARIATIONS (et_098 - et_103) =====
    FoodItem(id: 'et_098', name: 'Siga Tibs', nameAmharic: 'ስጋ ጥብስ', calories: 260, protein: 22, carbs: 5, fat: 17, fiber: 0.5, servingSize: 200, category: FoodCategory.ethiopian, description: 'Sautéed beef cubes'),
    FoodItem(id: 'et_099', name: 'Yebeg Tibs', nameAmharic: 'የበግ ጥብስ', calories: 275, protein: 20, carbs: 5, fat: 20, fiber: 0.5, servingSize: 200, category: FoodCategory.ethiopian, description: 'Sautéed lamb cubes'),
    FoodItem(id: 'et_100', name: 'Doro Tibs', nameAmharic: 'ዶሮ ጥብስ', calories: 230, protein: 24, carbs: 4, fat: 13, fiber: 0.5, servingSize: 200, category: FoodCategory.ethiopian, description: 'Sautéed chicken pieces'),
    FoodItem(id: 'et_101', name: 'Tibs Special', nameAmharic: 'ጥብስ ስፔሻል', calories: 300, protein: 23, carbs: 8, fat: 21, fiber: 1.0, servingSize: 250, category: FoodCategory.ethiopian, description: 'Premium sautéed meat with vegetables'),
    FoodItem(id: 'et_102', name: 'Keysir Tibs', nameAmharic: 'ቀስር ጥብስ', calories: 150, protein: 3.0, carbs: 18, fat: 7.0, fiber: 3.0, servingSize: 200, category: FoodCategory.ethiopian, description: 'Sautéed carrots with spices'),
    FoodItem(id: 'et_103', name: 'Kurt Siga', nameAmharic: 'ኩርት ስጋ', calories: 290, protein: 26, carbs: 2, fat: 21, fiber: 0, servingSize: 200, category: FoodCategory.ethiopian, description: 'Chunky beef pieces with dipping sauce'),
  ];
}

class CommonFoods {
  static const List<FoodItem> items = [
    // ===== PROTEINS (cm_001 - cm_012) =====
    FoodItem(id: 'cm_001', name: 'Chicken Breast', calories: 165, protein: 31, carbs: 0, fat: 3.6, fiber: 0, servingSize: 100, category: FoodCategory.common, description: 'Grilled skinless chicken breast'),
    FoodItem(id: 'cm_002', name: 'Egg (Boiled)', calories: 155, protein: 13, carbs: 1.1, fat: 11, fiber: 0, servingSize: 100, category: FoodCategory.common, description: 'Hard-boiled egg'),
    FoodItem(id: 'cm_003', name: 'Salmon Fillet', calories: 208, protein: 20, carbs: 0, fat: 13, fiber: 0, servingSize: 100, category: FoodCategory.common, description: 'Baked salmon fillet'),
    FoodItem(id: 'cm_004', name: 'Tofu', calories: 76, protein: 8.0, carbs: 1.9, fat: 4.8, fiber: 0.3, servingSize: 100, category: FoodCategory.common, description: 'Firm tofu'),
    FoodItem(id: 'cm_005', name: 'Beef Steak', calories: 271, protein: 26, carbs: 0, fat: 18, fiber: 0, servingSize: 100, category: FoodCategory.common, description: 'Grilled beef steak'),
    FoodItem(id: 'cm_006', name: 'Turkey Breast', calories: 135, protein: 30, carbs: 0, fat: 1.0, fiber: 0, servingSize: 100, category: FoodCategory.common, description: 'Roasted turkey breast'),
    FoodItem(id: 'cm_007', name: 'Shrimp', calories: 99, protein: 24, carbs: 0.2, fat: 0.3, fiber: 0, servingSize: 100, category: FoodCategory.common, description: 'Boiled shrimp'),
    FoodItem(id: 'cm_008', name: 'Pork Chop', calories: 231, protein: 25, carbs: 0, fat: 14, fiber: 0, servingSize: 100, category: FoodCategory.common, description: 'Grilled pork chop'),
    FoodItem(id: 'cm_009', name: 'Tuna (Canned)', calories: 116, protein: 26, carbs: 0, fat: 0.8, fiber: 0, servingSize: 100, category: FoodCategory.common, description: 'Canned tuna in water'),
    FoodItem(id: 'cm_010', name: 'Lamb Chop', calories: 254, protein: 22, carbs: 0, fat: 18, fiber: 0, servingSize: 100, category: FoodCategory.common, description: 'Grilled lamb chop'),
    FoodItem(id: 'cm_011', name: 'Bacon', calories: 541, protein: 37, carbs: 1.4, fat: 42, fiber: 0, servingSize: 100, category: FoodCategory.common, description: 'Fried bacon strips'),
    FoodItem(id: 'cm_012', name: 'Sausage', calories: 301, protein: 12, carbs: 2.0, fat: 27, fiber: 0, servingSize: 100, category: FoodCategory.common, description: 'Pork sausage'),

    // ===== CARBS & GRAINS (cm_013 - cm_022) =====
    FoodItem(id: 'cm_013', name: 'White Rice', calories: 130, protein: 2.7, carbs: 28, fat: 0.3, fiber: 0.4, servingSize: 100, category: FoodCategory.common, description: 'Cooked white rice'),
    FoodItem(id: 'cm_014', name: 'Brown Rice', calories: 112, protein: 2.3, carbs: 24, fat: 0.8, fiber: 1.8, servingSize: 100, category: FoodCategory.common, description: 'Cooked brown rice'),
    FoodItem(id: 'cm_015', name: 'Pasta', calories: 131, protein: 5.0, carbs: 25, fat: 1.1, fiber: 1.8, servingSize: 100, category: FoodCategory.common, description: 'Cooked pasta'),
    FoodItem(id: 'cm_016', name: 'White Bread', calories: 265, protein: 9.0, carbs: 49, fat: 3.2, fiber: 2.7, servingSize: 100, category: FoodCategory.common, description: 'Sliced white bread'),
    FoodItem(id: 'cm_017', name: 'Whole Wheat Bread', calories: 247, protein: 13, carbs: 41, fat: 3.4, fiber: 7.0, servingSize: 100, category: FoodCategory.common, description: 'Whole wheat sliced bread'),
    FoodItem(id: 'cm_018', name: 'Oatmeal', calories: 68, protein: 2.4, carbs: 12, fat: 1.4, fiber: 1.7, servingSize: 100, category: FoodCategory.common, description: 'Cooked oatmeal'),
    FoodItem(id: 'cm_019', name: 'Quinoa', calories: 120, protein: 4.4, carbs: 21, fat: 1.9, fiber: 2.8, servingSize: 100, category: FoodCategory.common, description: 'Cooked quinoa'),
    FoodItem(id: 'cm_020', name: 'Couscous', calories: 112, protein: 3.8, carbs: 23, fat: 0.2, fiber: 1.4, servingSize: 100, category: FoodCategory.common, description: 'Cooked couscous'),
    FoodItem(id: 'cm_021', name: 'Tortilla', calories: 312, protein: 8.2, carbs: 52, fat: 8.5, fiber: 2.3, servingSize: 100, category: FoodCategory.common, description: 'Flour tortilla'),
    FoodItem(id: 'cm_022', name: 'Croissant', calories: 406, protein: 8.2, carbs: 46, fat: 21, fiber: 2.0, servingSize: 100, category: FoodCategory.common, description: 'Butter croissant'),

    // ===== FRUITS (cm_023 - cm_034) =====
    FoodItem(id: 'cm_023', name: 'Banana', calories: 89, protein: 1.1, carbs: 23, fat: 0.3, fiber: 2.6, servingSize: 100, category: FoodCategory.common, description: 'Raw banana'),
    FoodItem(id: 'cm_024', name: 'Apple', calories: 52, protein: 0.3, carbs: 14, fat: 0.2, fiber: 2.4, servingSize: 100, category: FoodCategory.common, description: 'Raw apple with skin'),
    FoodItem(id: 'cm_025', name: 'Mango', calories: 60, protein: 0.8, carbs: 15, fat: 0.4, fiber: 1.6, servingSize: 100, category: FoodCategory.common, description: 'Raw mango'),
    FoodItem(id: 'cm_026', name: 'Orange', calories: 47, protein: 0.9, carbs: 12, fat: 0.1, fiber: 2.4, servingSize: 100, category: FoodCategory.common, description: 'Raw orange'),
    FoodItem(id: 'cm_027', name: 'Strawberries', calories: 32, protein: 0.7, carbs: 7.7, fat: 0.3, fiber: 2.0, servingSize: 100, category: FoodCategory.common, description: 'Fresh strawberries'),
    FoodItem(id: 'cm_028', name: 'Blueberries', calories: 57, protein: 0.7, carbs: 14, fat: 0.3, fiber: 2.4, servingSize: 100, category: FoodCategory.common, description: 'Fresh blueberries'),
    FoodItem(id: 'cm_029', name: 'Grapes', calories: 69, protein: 0.7, carbs: 18, fat: 0.2, fiber: 0.9, servingSize: 100, category: FoodCategory.common, description: 'Fresh grapes'),
    FoodItem(id: 'cm_030', name: 'Watermelon', calories: 30, protein: 0.6, carbs: 7.6, fat: 0.2, fiber: 0.4, servingSize: 100, category: FoodCategory.common, description: 'Fresh watermelon'),
    FoodItem(id: 'cm_031', name: 'Pineapple', calories: 50, protein: 0.5, carbs: 13, fat: 0.1, fiber: 1.4, servingSize: 100, category: FoodCategory.common, description: 'Fresh pineapple'),
    FoodItem(id: 'cm_032', name: 'Avocado', calories: 160, protein: 2.0, carbs: 8.5, fat: 15, fiber: 6.7, servingSize: 100, category: FoodCategory.common, description: 'Fresh avocado'),
    FoodItem(id: 'cm_033', name: 'Papaya', calories: 43, protein: 0.5, carbs: 11, fat: 0.3, fiber: 1.7, servingSize: 100, category: FoodCategory.common, description: 'Fresh papaya'),
    FoodItem(id: 'cm_034', name: 'Pomegranate', calories: 83, protein: 1.7, carbs: 19, fat: 1.2, fiber: 4.0, servingSize: 100, category: FoodCategory.common, description: 'Fresh pomegranate seeds'),

    // ===== VEGETABLES (cm_035 - cm_044) =====
    FoodItem(id: 'cm_035', name: 'Broccoli', calories: 34, protein: 2.8, carbs: 7.0, fat: 0.4, fiber: 2.6, servingSize: 100, category: FoodCategory.common, description: 'Steamed broccoli'),
    FoodItem(id: 'cm_036', name: 'Spinach', calories: 23, protein: 2.9, carbs: 3.6, fat: 0.4, fiber: 2.2, servingSize: 100, category: FoodCategory.common, description: 'Raw spinach'),
    FoodItem(id: 'cm_037', name: 'Sweet Potato', calories: 86, protein: 1.6, carbs: 20, fat: 0.1, fiber: 3.0, servingSize: 100, category: FoodCategory.common, description: 'Baked sweet potato'),
    FoodItem(id: 'cm_038', name: 'Carrot', calories: 41, protein: 0.9, carbs: 10, fat: 0.2, fiber: 2.8, servingSize: 100, category: FoodCategory.common, description: 'Raw carrot'),
    FoodItem(id: 'cm_039', name: 'Tomato', calories: 18, protein: 0.9, carbs: 3.9, fat: 0.2, fiber: 1.2, servingSize: 100, category: FoodCategory.common, description: 'Raw tomato'),
    FoodItem(id: 'cm_040', name: 'Cucumber', calories: 15, protein: 0.7, carbs: 3.6, fat: 0.1, fiber: 0.5, servingSize: 100, category: FoodCategory.common, description: 'Raw cucumber'),
    FoodItem(id: 'cm_041', name: 'Bell Pepper', calories: 31, protein: 1.0, carbs: 6.0, fat: 0.3, fiber: 2.1, servingSize: 100, category: FoodCategory.common, description: 'Raw bell pepper'),
    FoodItem(id: 'cm_042', name: 'Onion', calories: 40, protein: 1.1, carbs: 9.3, fat: 0.1, fiber: 1.7, servingSize: 100, category: FoodCategory.common, description: 'Raw onion'),
    FoodItem(id: 'cm_043', name: 'Cauliflower', calories: 25, protein: 1.9, carbs: 5.0, fat: 0.3, fiber: 2.0, servingSize: 100, category: FoodCategory.common, description: 'Steamed cauliflower'),
    FoodItem(id: 'cm_044', name: 'Zucchini', calories: 17, protein: 1.2, carbs: 3.1, fat: 0.3, fiber: 1.0, servingSize: 100, category: FoodCategory.common, description: 'Raw zucchini'),

    // ===== LEGUMES (cm_045 - cm_052) =====
    FoodItem(id: 'cm_045', name: 'Lentils (Cooked)', calories: 116, protein: 9.0, carbs: 20, fat: 0.4, fiber: 7.9, servingSize: 100, category: FoodCategory.common, description: 'Cooked lentils'),
    FoodItem(id: 'cm_046', name: 'Chickpeas (Cooked)', calories: 164, protein: 8.9, carbs: 27, fat: 2.6, fiber: 7.6, servingSize: 100, category: FoodCategory.common, description: 'Cooked chickpeas'),
    FoodItem(id: 'cm_047', name: 'Black Beans', calories: 132, protein: 8.9, carbs: 24, fat: 0.5, fiber: 8.7, servingSize: 100, category: FoodCategory.common, description: 'Cooked black beans'),
    FoodItem(id: 'cm_048', name: 'Kidney Beans', calories: 127, protein: 8.7, carbs: 23, fat: 0.5, fiber: 6.4, servingSize: 100, category: FoodCategory.common, description: 'Cooked kidney beans'),
    FoodItem(id: 'cm_049', name: 'Green Peas', calories: 81, protein: 5.4, carbs: 14, fat: 0.2, fiber: 5.1, servingSize: 100, category: FoodCategory.common, description: 'Cooked green peas'),
    FoodItem(id: 'cm_050', name: 'Edamame', calories: 121, protein: 12, carbs: 9.0, fat: 5.2, fiber: 5.0, servingSize: 100, category: FoodCategory.common, description: 'Steamed edamame'),
    FoodItem(id: 'cm_051', name: 'Pinto Beans', calories: 143, protein: 9.0, carbs: 26, fat: 0.7, fiber: 9.0, servingSize: 100, category: FoodCategory.common, description: 'Cooked pinto beans'),
    FoodItem(id: 'cm_052', name: 'Soybeans', calories: 173, protein: 17, carbs: 10, fat: 9.0, fiber: 6.0, servingSize: 100, category: FoodCategory.common, description: 'Cooked soybeans'),

    // ===== DAIRY (cm_053 - cm_060) =====
    FoodItem(id: 'cm_053', name: 'Whole Milk', calories: 61, protein: 3.2, carbs: 4.8, fat: 3.3, fiber: 0, servingSize: 100, category: FoodCategory.common, description: 'Whole cow milk'),
    FoodItem(id: 'cm_054', name: 'Greek Yogurt', calories: 59, protein: 10, carbs: 3.6, fat: 0.7, fiber: 0, servingSize: 100, category: FoodCategory.common, description: 'Plain Greek yogurt'),
    FoodItem(id: 'cm_055', name: 'Cheddar Cheese', calories: 403, protein: 25, carbs: 1.3, fat: 33, fiber: 0, servingSize: 100, category: FoodCategory.common, description: 'Aged cheddar cheese'),
    FoodItem(id: 'cm_056', name: 'Cottage Cheese', calories: 98, protein: 11, carbs: 3.4, fat: 4.3, fiber: 0, servingSize: 100, category: FoodCategory.common, description: 'Low-fat cottage cheese'),
    FoodItem(id: 'cm_057', name: 'Mozzarella', calories: 280, protein: 22, carbs: 2.2, fat: 22, fiber: 0, servingSize: 100, category: FoodCategory.common, description: 'Fresh mozzarella'),
    FoodItem(id: 'cm_058', name: 'Butter', calories: 717, protein: 0.9, carbs: 0.1, fat: 81, fiber: 0, servingSize: 14, category: FoodCategory.common, description: 'Salted butter (1 tbsp)'),
    FoodItem(id: 'cm_059', name: 'Cream Cheese', calories: 342, protein: 6.0, carbs: 4.0, fat: 34, fiber: 0, servingSize: 100, category: FoodCategory.common, description: 'Plain cream cheese'),
    FoodItem(id: 'cm_060', name: 'Feta Cheese', calories: 264, protein: 14, carbs: 4.0, fat: 21, fiber: 0, servingSize: 100, category: FoodCategory.common, description: 'Crumbled feta cheese'),

    // ===== NUTS & SEEDS (cm_061 - cm_068) =====
    FoodItem(id: 'cm_061', name: 'Almonds', calories: 579, protein: 21, carbs: 22, fat: 50, fiber: 12, servingSize: 30, category: FoodCategory.common, description: 'Raw almonds (1 oz)'),
    FoodItem(id: 'cm_062', name: 'Peanuts', calories: 567, protein: 26, carbs: 16, fat: 49, fiber: 8.5, servingSize: 30, category: FoodCategory.common, description: 'Roasted peanuts (1 oz)'),
    FoodItem(id: 'cm_063', name: 'Chia Seeds', calories: 486, protein: 17, carbs: 42, fat: 31, fiber: 34, servingSize: 15, category: FoodCategory.common, description: 'Dried chia seeds (1 tbsp)'),
    FoodItem(id: 'cm_064', name: 'Walnuts', calories: 654, protein: 15, carbs: 14, fat: 65, fiber: 6.7, servingSize: 30, category: FoodCategory.common, description: 'Raw walnuts (1 oz)'),
    FoodItem(id: 'cm_065', name: 'Cashews', calories: 553, protein: 18, carbs: 30, fat: 44, fiber: 3.3, servingSize: 30, category: FoodCategory.common, description: 'Roasted cashews (1 oz)'),
    FoodItem(id: 'cm_066', name: 'Flaxseeds', calories: 534, protein: 18, carbs: 29, fat: 42, fiber: 27, servingSize: 15, category: FoodCategory.common, description: 'Ground flaxseeds (1 tbsp)'),
    FoodItem(id: 'cm_067', name: 'Pistachios', calories: 560, protein: 20, carbs: 28, fat: 45, fiber: 10, servingSize: 30, category: FoodCategory.common, description: 'Roasted pistachios (1 oz)'),
    FoodItem(id: 'cm_068', name: 'Sunflower Seeds', calories: 584, protein: 21, carbs: 20, fat: 51, fiber: 8.6, servingSize: 30, category: FoodCategory.common, description: 'Roasted sunflower seeds (1 oz)'),

    // ===== BEVERAGES (cm_069 - cm_076) =====
    FoodItem(id: 'cm_069', name: 'Orange Juice', calories: 45, protein: 0.7, carbs: 10, fat: 0.2, fiber: 0.2, servingSize: 100, category: FoodCategory.common, description: 'Fresh orange juice'),
    FoodItem(id: 'cm_070', name: 'Green Tea', calories: 1, protein: 0, carbs: 0, fat: 0, fiber: 0, servingSize: 240, category: FoodCategory.common, description: 'Brewed green tea'),
    FoodItem(id: 'cm_071', name: 'Black Coffee', calories: 2, protein: 0.3, carbs: 0, fat: 0, fiber: 0, servingSize: 240, category: FoodCategory.common, description: 'Brewed black coffee'),
    FoodItem(id: 'cm_072', name: 'Milkshake', calories: 112, protein: 3.2, carbs: 18, fat: 3.5, fiber: 0, servingSize: 100, category: FoodCategory.common, description: 'Chocolate milkshake'),
    FoodItem(id: 'cm_073', name: 'Smoothie', calories: 68, protein: 1.5, carbs: 14, fat: 0.5, fiber: 1.5, servingSize: 100, category: FoodCategory.common, description: 'Mixed fruit smoothie'),
    FoodItem(id: 'cm_074', name: 'Coconut Water', calories: 19, protein: 0.7, carbs: 3.7, fat: 0.2, fiber: 1.1, servingSize: 100, category: FoodCategory.common, description: 'Natural coconut water'),
    FoodItem(id: 'cm_075', name: 'Hot Chocolate', calories: 80, protein: 3.0, carbs: 12, fat: 2.5, fiber: 0.5, servingSize: 100, category: FoodCategory.common, description: 'Hot chocolate with milk'),
    FoodItem(id: 'cm_076', name: 'Lemonade', calories: 40, protein: 0.1, carbs: 10, fat: 0.1, fiber: 0.1, servingSize: 100, category: FoodCategory.common, description: 'Fresh lemonade'),

    // ===== PREPARED FOODS (cm_077 - cm_080) =====
    FoodItem(id: 'cm_077', name: 'Pizza (Cheese)', calories: 266, protein: 11, carbs: 33, fat: 10, fiber: 2.3, servingSize: 100, category: FoodCategory.common, description: 'Cheese pizza slice'),
    FoodItem(id: 'cm_078', name: 'French Fries', calories: 312, protein: 3.4, carbs: 41, fat: 15, fiber: 3.8, servingSize: 100, category: FoodCategory.common, description: 'Deep-fried potato fries'),
    FoodItem(id: 'cm_079', name: 'Hamburger', calories: 295, protein: 17, carbs: 24, fat: 14, fiber: 1.3, servingSize: 100, category: FoodCategory.common, description: 'Beef hamburger'),
    FoodItem(id: 'cm_080', name: 'Fried Chicken', calories: 246, protein: 19, carbs: 10, fat: 15, fiber: 0.5, servingSize: 100, category: FoodCategory.common, description: 'Fried chicken pieces'),
  ];
}

class FoodDatabase {
  static List<FoodItem> get allFoods => [...EthiopianFoods.items, ...CommonFoods.items];
  
  static List<FoodItem> get ethiopianFoods => EthiopianFoods.items;
  static List<FoodItem> get commonFoods => CommonFoods.items;

  static FoodItem? getFoodById(String id) {
    try {
      return allFoods.firstWhere((food) => food.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<FoodItem> searchFoods(String query) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    final results = <_SearchResult>[];
    
    for (final food in allFoods) {
      int score = 0;
      final nameLower = food.name.toLowerCase();
      final amharicLower = food.nameAmharic.toLowerCase();
      final descLower = (food.description ?? '').toLowerCase();
      
      if (nameLower == q) {
        score = 100;
      } else if (nameLower.startsWith(q)) {
        score = 80;
      } else if (nameLower.contains(q)) {
        score = 60;
      } else if (amharicLower.contains(q)) {
        score = 70;
      } else if (descLower.contains(q)) {
        score = 40;
      }
      
      if (score > 0) {
        results.add(_SearchResult(food: food, score: score));
      }
    }
    
    results.sort((a, b) => b.score.compareTo(a.score));
    return results.map((r) => r.food).toList();
  }

  static List<FoodItem> getByCategory(FoodCategory category) {
    return allFoods.where((food) => food.category == category).toList();
  }

  static MealType inferMealType() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return MealType.breakfast;
    if (hour >= 11 && hour < 15) return MealType.lunch;
    if (hour >= 15 && hour < 21) return MealType.dinner;
    return MealType.snack;
  }
}

class _SearchResult {
  final FoodItem food;
  final int score;
  _SearchResult({required this.food, required this.score});
}
