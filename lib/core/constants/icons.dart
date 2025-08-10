import 'package:financy_ui/core/constants/colors.dart';
import 'package:financy_ui/features/Categories/models/categoriesModels.dart';
import 'package:financy_ui/shared/utils/color_utils.dart';
import 'package:financy_ui/shared/utils/generateID.dart';
import 'package:financy_ui/shared/utils/mappingIcon.dart';
import 'package:flutter/material.dart';

const Map<String, IconData> iconMap = {
  // Expense Icons
  'home': Icons.home,
  'shopping_cart': Icons.shopping_cart,
  'fastfood': Icons.fastfood,
  'pets': Icons.pets,
  'work': Icons.work,
  'music_note': Icons.music_note,
  'movie': Icons.movie,
  'sports_soccer': Icons.sports_soccer,
  'flight': Icons.flight,
  'school': Icons.school,
  'local_cafe': Icons.local_cafe,
  'fitness_center': Icons.fitness_center,
  'directions_car': Icons.directions_car,
  'beach_access': Icons.beach_access,
  'camera_alt': Icons.camera_alt,
  'brush': Icons.brush,
  'nature': Icons.nature,
  'healing': Icons.healing,
  'cake': Icons.cake,
  'favorite': Icons.favorite,
  'wb_sunny': Icons.wb_sunny,
  'nightlight_round': Icons.nightlight_round,
  'local_florist': Icons.local_florist,
  'lightbulb': Icons.lightbulb,
  'book': Icons.book,
  'luggage': Icons.luggage,
  'event': Icons.event,
  'payment': Icons.payment,
  'credit_card': Icons.credit_card,
  'access_time': Icons.access_time,
  'people': Icons.people,
  'public': Icons.public,
  'security': Icons.security,
  'wine_bar': Icons.wine_bar,
  'local_bar': Icons.local_bar,
  'restaurant': Icons.restaurant,
  'local_grocery_store': Icons.local_grocery_store,
  'baby_changing_station': Icons.baby_changing_station,
  'bug_report': Icons.bug_report,
  'build': Icons.build,

  // Income Icons
  'attach_money': Icons.attach_money,
  'card_giftcard': Icons.card_giftcard,
  'trending_up': Icons.trending_up,
  'storefront': Icons.storefront,
  'house': Icons.house,
  'savings': Icons.savings,
  'redeem': Icons.redeem,
  'refresh': Icons.refresh,
  'school_income': Icons.school, // tránh trùng key
  'monetization_on': Icons.monetization_on,
  'currency_bitcoin': Icons.currency_bitcoin,
  'work_outline': Icons.work_outline,
  'more_horiz': Icons.more_horiz,
};

//fix cứng 
final List<Category> defaultExpenseCategories = [
  Category(
    id: 'exp_home',
    name: 'Nhà',
    icon: IconMapping.mapIconToString(Icons.home),
    color: ColorUtils.colorToHex(AppColors.red),
    type: 'expense',
    createdAt: DateTime.now()
  ),
  Category(
    id: 'exp_shopping',
    name: 'Mua sắm',
    icon: IconMapping.mapIconToString(Icons.shopping_cart),
    color: ColorUtils.colorToHex(AppColors.pink),
    type: 'expense',
    createdAt: DateTime.now()

  ),
  Category(
    id: 'exp_food',
    name: 'Ăn uống',
    icon: IconMapping.mapIconToString(Icons.fastfood),
    color: ColorUtils.colorToHex(AppColors.orange),
    type: 'expense',
    createdAt: DateTime.now()

  ),
  Category(
    id: 'exp_car',
    name: 'Xe cộ',
    icon: IconMapping.mapIconToString(Icons.directions_car),
    color: ColorUtils.colorToHex(AppColors.lightBlue),
    type: 'expense',
    createdAt: DateTime.now()

  ),
  Category(
    id: 'exp_coffee',
    name: 'Cà phê',
    icon: IconMapping.mapIconToString(Icons.local_cafe),
    color: ColorUtils.colorToHex(AppColors.brown),
    type: 'expense',
    createdAt: DateTime.now()

  ),
  Category(
    id: 'exp_travel',
    name: 'Du lịch',
    icon: IconMapping.mapIconToString(Icons.flight),
    color: ColorUtils.colorToHex(AppColors.indigo),
    type: 'expense',
    createdAt: DateTime.now()

  ),
  Category(
    id: 'exp_health',
    name: 'Sức khỏe',
    icon: IconMapping.mapIconToString(Icons.healing),
    color: ColorUtils.colorToHex(AppColors.green),
    type: 'expense',
    createdAt: DateTime.now()

  ),
  Category(
    id: 'exp_entertain',
    name: 'Giải trí',
    icon: IconMapping.mapIconToString(Icons.movie),
    color: ColorUtils.colorToHex(AppColors.deepPurple),
    type: 'expense',
    createdAt: DateTime.now()

  ),
  Category(
    id: 'exp_education',
    name: 'Học tập',
    icon: IconMapping.mapIconToString(Icons.school),
    color: ColorUtils.colorToHex(AppColors.blue),
    type: 'expense',
    createdAt: DateTime.now()

  ),
  Category(
    id: 'exp_gift',
    name: 'Quà tặng',
    icon: IconMapping.mapIconToString(Icons.card_giftcard),
    color: ColorUtils.colorToHex(AppColors.purple),
    type: 'expense',
    createdAt: DateTime.now()

  ),
  Category(
    id: 'exp_pet',
    name: 'Thú cưng',
    icon: IconMapping.mapIconToString(Icons.pets),
    color: ColorUtils.colorToHex(AppColors.cyan),
    type: 'expense',
    createdAt: DateTime.now()

  ),
  Category(
    id: 'exp_party',
    name: 'Tiệc tùng',
    icon: IconMapping.mapIconToString(Icons.cake),
    color: ColorUtils.colorToHex(AppColors.accentPink),
    type: 'expense',
    createdAt: DateTime.now()

  ),
];


final List<Category> defaultIncomeCategories = [
  Category(
    id: GenerateID.newID(),
    name: "Lương",
    type: "income",
    icon: IconMapping.mapIconToString(Icons.attach_money),
    color: ColorUtils.colorToHex(AppColors.blue),
    createdAt: DateTime.now(),
  ),
  Category(
    id: GenerateID.newID(),
    name: "Thưởng",
    type: "income",
    icon: IconMapping.mapIconToString(Icons.card_giftcard),
    color: ColorUtils.colorToHex(AppColors.purple),
    createdAt: DateTime.now(),
  ),
  Category(
    id: GenerateID.newID(),
    name: "Đầu tư",
    type: "income",
    icon: IconMapping.mapIconToString(Icons.trending_up),
    color: ColorUtils.colorToHex(AppColors.pink),
    createdAt: DateTime.now(),
  ),
  Category(
    id: GenerateID.newID(),
    name: "Bán hàng",
    type: "income",
    icon: IconMapping.mapIconToString(Icons.storefront),
    color: ColorUtils.colorToHex(AppColors.orange),
    createdAt: DateTime.now(),
  ),
  Category(
    id: GenerateID.newID(),
    name: "Tiết kiệm",
    type: "income",
    icon: IconMapping.mapIconToString(Icons.savings),
    color: ColorUtils.colorToHex(AppColors.green),
    createdAt: DateTime.now(),
  ),
];


