import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

// Soft divider color for list separators (replaces the strong dark green).
const _dividerColor = Color(0xFFE3EAE5);

// Light green used for icon tiles and circles.
const _softGreen = Color(0xFFDDEFE3);

/// Formats an amount as pesos with thousands separators, e.g. ₱12,980.00.
String peso(double v) {
  final parts = v.toStringAsFixed(2).split('.');
  final whole = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (m) => ',',
  );
  return '₱$whole.${parts[1]}';
}

/// Long date for the page headers, e.g. "Wednesday, November 11".
String headerDate(DateTime d) {
  const days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
}

/// Short date, e.g. "Oct 21, 2026".
String shortDate(DateTime d) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[d.month - 1]} ${d.day}, ${d.year}';
}

/// Shared look for the white cards: rounded corners, thin border, soft shadow.
/// Pass [color] to change the fill (the total card uses dark green).
BoxDecoration cardDecoration({
  double radius = 22,
  Color color = Colors.white,
}) => BoxDecoration(
  color: color,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: AppColors.border, width: 1),
  boxShadow: const [
    BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2)),
  ],
);

/// Soft green round back button used in the Add Category and Edit Expense headers.
class _BackCircle extends StatelessWidget {
  final VoidCallback onTap;

  const _BackCircle({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: _softGreen,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.chevron_left,
          color: AppColors.darkGreen,
          size: 28,
        ),
      ),
    );
  }
}

/// The round green + button used in both page headers.
class _AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
          color: AppColors.darkGreen,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 24),
      ),
    );
  }
}

// Colors used only by the expense categories.
class ExpenseColors {
  static const utilities = Color(0xFF14B8A6);
  static const transpo = Color(0xFF0EA5E9);
  static const subscription = Color(0xFF0284C7);
  static const food = Color(0xFF2563EB);
  static const shopping = Color(0xFF06B6D4);
}

class ExpenseCategory {
  final String name;
  final double amount;
  final Color color;
  final IconData icon;

  const ExpenseCategory(this.name, this.amount, this.color, this.icon);
}

const categories = <ExpenseCategory>[
  ExpenseCategory(
    'Utilities',
    2850,
    ExpenseColors.utilities,
    Icons.bolt_outlined,
  ),
  ExpenseCategory(
    'Transpo',
    500,
    ExpenseColors.transpo,
    Icons.directions_car_outlined,
  ),
  ExpenseCategory(
    'Subscription',
    2000,
    ExpenseColors.subscription,
    Icons.subscriptions_outlined,
  ),
  ExpenseCategory(
    'Food / Drinks',
    3630,
    ExpenseColors.food,
    Icons.shopping_basket_outlined,
  ),
  ExpenseCategory(
    'Shopping',
    4000,
    ExpenseColors.shopping,
    Icons.shopping_bag_outlined,
  ),
];

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  String _month = 'OCT 2026';

  // Editable copy of the categories so new ones can be added.
  List<ExpenseCategory> _cats = List.of(categories);

  // Colors handed out to newly added categories (cycled).
  static const _palette = <Color>[
    ExpenseColors.utilities,
    ExpenseColors.transpo,
    ExpenseColors.subscription,
    ExpenseColors.food,
    ExpenseColors.shopping,
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFFF59E0B),
  ];

  Future<void> _addCategory() async {
    final result = await showAddCategorySheet(
      context,
      existingNames: _cats.map((c) => c.name).toList(),
    );
    if (result == null || !mounted) return;

    setState(() {
      _cats = [
        ..._cats,
        ExpenseCategory(
          result.name,
          0, // no expenses yet
          _palette[_cats.length % _palette.length],
          result.icon,
        ),
      ];
    });
    // TODO: save the new category (name + icon) to your database / backend.
  }

  /// Called by the details page when an expense is added or edited.
  /// [delta] is added to the category's total (negative to subtract), so the
  /// total card and the chart on this page stay correct.
  void _onAmountChanged(String categoryName, double delta) {
    setState(() {
      _cats = [
        for (final c in _cats)
          c.name == categoryName
              ? ExpenseCategory(
                  c.name,
                  math.max(0.0, c.amount + delta),
                  c.color,
                  c.icon,
                )
              : c,
      ];
    });
  }

  final _months = const ['SEP 2026', 'OCT 2026', 'NOV 2026'];

  double get _total => _cats.fold(0, (sum, c) => sum + c.amount);

  @override
  Widget build(BuildContext context) {
    // Show every category, biggest first, so the list has something to scroll.
    final sorted = [..._cats]..sort((a, b) => b.amount.compareTo(a.amount));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Fixed header + cards ----
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  headerDate(DateTime.now()),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.mutedText,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Text(
                      'Expenses',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ),
                  _AddButton(onTap: _addCategory),
                ],
              ),
              const SizedBox(height: 12),
              // CARD 1: donut chart + legend + month dropdown
              _chartCard(),
              const SizedBox(height: 12),
              // CARD 2: green card with this month's total
              _totalCard(),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.only(left: 2, bottom: 6),
                child: Text(
                  'Expenses by category',
                  style: TextStyle(fontSize: 14),
                ),
              ),

              // ---- Scrollable category card (fills remaining space) ----
              Expanded(child: _categoryList(sorted)),
            ],
          ),
        ),
      ),
    );
  }

  /// CARD 1 - Chart card.
  /// Left: the donut chart. Right: month dropdown and the legend (color dot + name).
  /// Only categories that have spending (amount > 0) are drawn.
  Widget _chartCard() {
    // New categories with no spending yet are left out of the chart and legend.
    final shown = _cats.where((c) => c.amount > 0).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: cardDecoration(radius: 20),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: CustomPaint(painter: DonutPainter(shown)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _monthDropdown(),
                const SizedBox(height: 6),
                for (final c in shown)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: c.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            c.name,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Small month picker inside the chart card (e.g. OCT 2026).
  /// Right now it only changes the label; hook it to your database query later.
  Widget _monthDropdown() {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _month,
          isDense: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: AppColors.darkGreen,
          ),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.darkGreen,
          ),
          items: _months
              .map((m) => DropdownMenuItem(value: m, child: Text(m)))
              .toList(),
          onChanged: (v) => setState(() => _month = v ?? _month),
        ),
      ),
    );
  }

  /// CARD 2 - Total expenses card.
  /// Dark green card with white text showing the sum of all categories.
  Widget _totalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: cardDecoration(radius: 18, color: AppColors.darkGreen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total expenses this month',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            peso(_total),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Track your spending',
            style: TextStyle(fontSize: 13, color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// CARD 3 - Expenses by category.
  /// One scrollable white card; each row is a category (see [_categoryRow]).
  /// The soft lines between rows use [_dividerColor].
  Widget _categoryList(List<ExpenseCategory> items) {
    return Container(
      decoration: cardDecoration(radius: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ListView.separated(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(
            height: 1,
            thickness: 1,
            indent: 14,
            endIndent: 14,
            color: _dividerColor,
          ),
          itemBuilder: (_, i) => _categoryRow(items[i]),
        ),
      ),
    );
  }

  /// One row inside CARD 3: icon box, category name, amount, arrow.
  /// Tapping it opens the category details page ([CategoryExpensesPage]).
  Widget _categoryRow(ExpenseCategory c) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryExpensesPage(
              title: c.name,
              categories: _cats,
              onAmountChanged: _onAmountChanged,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(c.icon, color: c.color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                c.name,
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
            Text(
              '-${peso(c.amount)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 16),
            const Icon(
              Icons.chevron_right,
              color: AppColors.darkGreen,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}

// Draws the donut chart from the category amounts.
class DonutPainter extends CustomPainter {
  final List<ExpenseCategory> data;

  DonutPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.fold<double>(0, (s, c) => s + c.amount);
    if (total == 0) return;

    final strokeWidth = size.width * 0.25;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: (size.width - strokeWidth) / 2,
    );

    double start = -math.pi / 2;

    for (final c in data) {
      final sweep = (c.amount / total) * 2 * math.pi;
      final paint = Paint()
        ..color = c.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, start, sweep - 0.01, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant DonutPainter old) => old.data != data;
}

// =====================================================================
// Category details page (opens when a category row is tapped)
// =====================================================================

/// One expense entry (a row in the list).
class ExpenseItem {
  final String name;
  final double amount;
  final DateTime date;
  final IconData icon;

  /// Optional logo (e.g. 'assets/logos/mcdo.png'). If null, [icon] is shown.
  final String? imageAsset;

  const ExpenseItem({
    required this.name,
    required this.amount,
    required this.date,
    this.icon = Icons.receipt_long_outlined,
    this.imageAsset,
  });
}

class CategoryExpensesPage extends StatefulWidget {
  final String title;

  /// Items to show. If omitted, sample data is used.
  final List<ExpenseItem>? items;

  /// All categories, used by the Add Expense sheet's category picker.
  final List<ExpenseCategory> categories;

  /// Called after an expense is added or edited, with the change in a
  /// category's total (positive adds, negative subtracts).
  final void Function(String categoryName, double amount)? onAmountChanged;

  const CategoryExpensesPage({
    super.key,
    required this.title,
    this.items,
    this.categories = const [],
    this.onAmountChanged,
  });

  @override
  State<CategoryExpensesPage> createState() => _CategoryExpensesPageState();
}

class _CategoryExpensesPageState extends State<CategoryExpensesPage> {
  late List<ExpenseItem> _items = widget.items ?? _sampleItems(widget.title);

  /// All categories for the pickers. Falls back to this page's own category
  /// if none were passed in.
  List<ExpenseCategory> get _allCategories => widget.categories.isNotEmpty
      ? widget.categories
      : [
          ExpenseCategory(
            widget.title,
            0,
            AppColors.darkGreen,
            Icons.receipt_long_outlined,
          ),
        ];

  /// Opens the Add Expense sheet and adds the result to the list.
  Future<void> _addExpense() async {
    final result = await showAddExpenseSheet(
      context,
      categories: _allCategories,
      initialCategory: widget.title,
    );
    if (result == null || !mounted) return;

    // Use the typed name; if it was left blank, fall back to the category name.
    final item = ExpenseItem(
      name: result.name.isNotEmpty ? result.name : result.category.name,
      amount: result.amount,
      date: result.date,
      icon: result.category.icon,
    );

    // Only show it here if it belongs to the category this page is showing.
    if (result.category.name == widget.title) {
      setState(() => _items = [..._items, item]);
    }
    widget.onAmountChanged?.call(result.category.name, result.amount);
    // TODO: save the new expense (category, amount, date) to your database.
  }

  /// Opens the full-screen Edit Expense page for [item] and applies the result.
  Future<void> _editExpense(ExpenseItem item) async {
    final result = await Navigator.push<ExpenseInput>(
      context,
      MaterialPageRoute(
        builder: (_) => EditExpensePage(
          item: item,
          categoryName: widget.title,
          categories: _allCategories,
        ),
      ),
    );
    if (result == null || !mounted) return;

    // Deleted: remove the row and subtract its amount from the category total.
    if (result.deleted) {
      setState(() => _items = [..._items]..remove(item));
      widget.onAmountChanged?.call(widget.title, -item.amount);
      // TODO: delete this expense from your database.
      return;
    }

    final sameCategory = result.category.name == widget.title;
    final edited = ExpenseItem(
      name: result.name.isNotEmpty ? result.name : result.category.name,
      amount: result.amount,
      date: result.date,
      icon: sameCategory ? item.icon : result.category.icon,
      imageAsset: sameCategory ? item.imageAsset : null,
    );

    setState(() {
      final next = [..._items];
      final index = next.indexOf(item);
      if (index >= 0) {
        if (sameCategory) {
          next[index] = edited; // update in place
        } else {
          next.removeAt(index); // moved to another category
        }
      }
      _items = next;
    });

    // Keep the Expenses page totals and chart in sync.
    widget.onAmountChanged?.call(widget.title, -item.amount);
    widget.onAmountChanged?.call(result.category.name, result.amount);
    // TODO: save the changes (name, category, amount, date) to your database.
  }

  // ---------- helpers ----------

  static String _dateLabel(DateTime d) {
    final now = DateTime.now();
    if (DateUtils.isSameDay(d, now)) return 'Today';
    return shortDate(d);
  }

  /// Sorts newest-first and flattens into [String header | ExpenseItem].
  List<Object> _grouped() {
    final sorted = [..._items]..sort((a, b) => b.date.compareTo(a.date));
    final out = <Object>[];
    DateTime? current;
    for (final item in sorted) {
      if (current == null || !DateUtils.isSameDay(current, item.date)) {
        current = item.date;
        out.add(_dateLabel(item.date));
      }
      out.add(item);
    }
    return out;
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    final rows = _grouped();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  headerDate(DateTime.now()),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.mutedText,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ),
                  ),
                  _AddButton(onTap: _addExpense),
                ],
              ),
              const SizedBox(height: 14),
              // CARD: the list of expenses for this category.
              // Grouped by date; scrolls when there are many items.
              Expanded(
                child: Container(
                  decoration: cardDecoration(radius: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: rows.isEmpty
                        ? const Center(
                            child: Text(
                              'No expenses yet',
                              style: TextStyle(color: AppColors.mutedText),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            physics: const BouncingScrollPhysics(),
                            itemCount: rows.length,
                            itemBuilder: (_, i) {
                              final row = rows[i];
                              if (row is String) {
                                return _dateHeader(row, i == 0);
                              }
                              return _expenseRow(row as ExpenseItem);
                            },
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Light green strip that starts each day's group ("Today", "Oct 20, 2026").
  Widget _dateHeader(String label, bool isFirst) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6FAF7),
        border: Border(
          top: isFirst
              ? BorderSide.none
              : const BorderSide(color: _dividerColor, width: 1),
          bottom: const BorderSide(color: _dividerColor, width: 1),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }

  /// One expense inside the details card: logo/icon box, name, amount, arrow.
  Widget _expenseRow(ExpenseItem item) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => _editExpense(item),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  padding: const EdgeInsets.all(6),
                  child: item.imageAsset != null
                      ? Image.asset(item.imageAsset!, fit: BoxFit.contain)
                      : Icon(item.icon, color: AppColors.darkGreen, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ),
                Text(
                  '-${peso(item.amount)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 24),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.darkGreen,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        const Divider(
          height: 1,
          thickness: 1,
          indent: 12,
          endIndent: 12,
          color: _dividerColor,
        ),
      ],
    );
  }

  // ---------- sample data (replace with database data) ----------

  static List<ExpenseItem> _sampleItems(String title) {
    final now = DateTime.now();
    DateTime daysAgo(int n) =>
        DateTime(now.year, now.month, now.day).subtract(Duration(days: n));

    if (!title.toLowerCase().startsWith('food')) return const [];

    return [
      ExpenseItem(
        name: 'Chick Fillet',
        amount: 130,
        date: daysAgo(0),
        icon: Icons.lunch_dining,
      ),
      ExpenseItem(
        name: 'Spanish latte',
        amount: 250,
        date: daysAgo(0),
        icon: Icons.local_cafe_outlined,
      ),
      ExpenseItem(
        name: 'Whopper jr',
        amount: 165,
        date: daysAgo(1),
        icon: Icons.lunch_dining,
      ),
      ExpenseItem(
        name: 'Bacon pizza',
        amount: 565,
        date: daysAgo(1),
        icon: Icons.local_pizza_outlined,
      ),
      ExpenseItem(
        name: 'Wintermelon',
        amount: 39,
        date: daysAgo(2),
        icon: Icons.emoji_food_beverage_outlined,
      ),
      ExpenseItem(
        name: 'Sisig',
        amount: 70,
        date: daysAgo(2),
        icon: Icons.restaurant,
      ),
      ExpenseItem(
        name: 'Burrito',
        amount: 200,
        date: daysAgo(2),
        icon: Icons.restaurant_menu,
      ),
    ];
  }
}

// =====================================================================
// Add category (opens as a modal bottom sheet from the + button)
// =====================================================================

/// What the sheet returns when the user taps Save.
class NewCategory {
  final String name;
  final IconData icon;

  const NewCategory(this.name, this.icon);
}

const _categoryIcons = <IconData>[
  Icons.shopping_cart_outlined,
  Icons.shopping_basket_outlined,
  Icons.restaurant,
  Icons.local_cafe_outlined,
  Icons.directions_car_outlined,
  Icons.home_outlined,
  Icons.bolt_outlined,
  Icons.receipt_long_outlined,
  Icons.medical_services_outlined,
  Icons.school_outlined,
  Icons.sports_esports_outlined,
  Icons.movie_outlined,
  Icons.pets,
  Icons.flight_takeoff,
  Icons.card_giftcard,
  Icons.fitness_center,
  Icons.phone_android,
  Icons.savings_outlined,
  Icons.checkroom,
  Icons.child_care,
  Icons.build_outlined,
  Icons.subscriptions_outlined,
  Icons.shopping_bag_outlined,
  Icons.more_horiz,
];

/// Opens the Add Category sheet. Returns null if the user dismisses it.
Future<NewCategory?> showAddCategorySheet(
  BuildContext context, {
  List<String> existingNames = const [],
}) {
  return showModalBottomSheet<NewCategory>(
    context: context,
    isScrollControlled: true, // lets the sheet rise above the keyboard
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddCategorySheet(existingNames: existingNames),
  );
}

/// The Add Category pop-up card (modal bottom sheet).
/// Has the header, icon picker circle, name field and Save button.
class AddCategorySheet extends StatefulWidget {
  final List<String> existingNames;

  const AddCategorySheet({super.key, this.existingNames = const []});

  @override
  State<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<AddCategorySheet> {
  final _nameCtrl = TextEditingController();
  IconData _icon = Icons.shopping_cart_outlined;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter a category name');
      return;
    }
    final exists = widget.existingNames.any(
      (n) => n.toLowerCase() == name.toLowerCase(),
    );
    if (exists) {
      setState(() => _error = 'That category already exists');
      return;
    }
    Navigator.pop(context, NewCategory(name, _icon));
  }

  Future<void> _pickIcon() async {
    FocusScope.of(context).unfocus();
    final picked = await showModalBottomSheet<IconData>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _IconPickerSheet(selected: _icon),
    );
    if (picked != null) setState(() => _icon = picked);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final keyboard = media.viewInsets.bottom;
    // Tall sheet, but never taller than the space above the keyboard.
    final height = math.min(
      media.size.height * 0.78,
      media.size.height - media.padding.top - keyboard - 16,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Container(
        height: height,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),

            // header
            Row(
              children: [
                _BackCircle(onTap: () => Navigator.pop(context)),
                const SizedBox(width: 14),
                const Text(
                  'Add Category',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGreen,
                  ),
                ),
              ],
            ),

            // content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),
                    Center(child: _iconAvatar()),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'Tap to change icon',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Text(
                        'Category Name',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameCtrl,
                      maxLength: 24,
                      textCapitalization: TextCapitalization.words,
                      cursorColor: AppColors.darkGreen,
                      onChanged: (_) {
                        if (_error != null) setState(() => _error = null);
                      },
                      onSubmitted: (_) => _save(),
                      style: const TextStyle(fontSize: 15, color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'e.g. Groceries',
                        hintStyle: const TextStyle(color: AppColors.mutedText),
                        counterText: '',
                        errorText: _error,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        border: _pill(AppColors.border),
                        enabledBorder: _pill(AppColors.border),
                        focusedBorder: _pill(AppColors.darkGreen, width: 1.5),
                        errorBorder: _pill(Colors.redAccent),
                        focusedErrorBorder: _pill(Colors.redAccent, width: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // save button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder _pill(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: color, width: width),
      );

  /// ICON CARD: big circle showing the chosen icon plus a small pencil badge.
  /// Tapping it opens the icon picker.
  Widget _iconAvatar() {
    return GestureDetector(
      onTap: _pickIcon,
      child: SizedBox(
        width: 140,
        height: 140,
        child: Stack(
          children: [
            Center(
              child: Container(
                width: 130,
                height: 130,
                decoration: const BoxDecoration(
                  color: _softGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon, size: 58, color: AppColors.darkGreen),
              ),
            ),
            Positioned(
              right: 4,
              bottom: 8,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.darkGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(Icons.edit, size: 17, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ICON PICKER card: a small sheet with a grid of icons to choose from.
/// The selected icon is highlighted in dark green; tapping one closes the sheet.
class _IconPickerSheet extends StatelessWidget {
  final IconData selected;

  const _IconPickerSheet({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 14),
              child: Text(
                'Choose an icon',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGreen,
                ),
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 6,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                for (final icon in _categoryIcons)
                  InkWell(
                    onTap: () => Navigator.pop(context, icon),
                    customBorder: const CircleBorder(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: icon == selected
                            ? AppColors.darkGreen
                            : _softGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 24,
                        color: icon == selected
                            ? Colors.white
                            : AppColors.darkGreen,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// Add expense (opens as a modal bottom sheet from the + on the details page)
// =====================================================================

/// What the Add Expense sheet and the Edit Expense page return
/// (the Edit page sets [deleted] when the user removes the expense).
class ExpenseInput {
  final ExpenseCategory category;
  final double amount;
  final DateTime date;

  /// Optional name typed by the user (empty if left blank).
  final String name;

  /// True when the Edit page returned because the user deleted the expense.
  final bool deleted;

  const ExpenseInput(
    this.category,
    this.amount,
    this.date,
    this.name, {
    this.deleted = false,
  });
}

/// Opens the calendar dialog (in the app's green) and returns the chosen date.
Future<DateTime?> pickExpenseDate(BuildContext context, DateTime initial) {
  return showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: DateTime(2020),
    lastDate: DateTime.now().add(const Duration(days: 365)),
    builder: (ctx, child) => Theme(
      data: Theme.of(ctx).copyWith(
        colorScheme: Theme.of(ctx).colorScheme
            .copyWith(primary: AppColors.darkGreen, onPrimary: Colors.white),
      ),
      child: child!,
    ),
  );
}

/// Opens the Add Expense sheet. Returns null if the user dismisses it.
Future<ExpenseInput?> showAddExpenseSheet(
  BuildContext context, {
  required List<ExpenseCategory> categories,
  required String initialCategory,
}) {
  return showModalBottomSheet<ExpenseInput>(
    context: context,
    isScrollControlled: true, // lets the sheet rise above the keyboard
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddExpenseSheet(
      categories: categories,
      initialCategory: initialCategory,
    ),
  );
}

/// The Add Expense pop-up card: category picker, amount and date.
class AddExpenseSheet extends StatefulWidget {
  final List<ExpenseCategory> categories;
  final String initialCategory;

  const AddExpenseSheet({
    super.key,
    required this.categories,
    required this.initialCategory,
  });

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  late ExpenseCategory _category = widget.categories.firstWhere(
    (c) => c.name == widget.initialCategory,
    orElse: () => widget.categories.first,
  );
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  DateTime _date = DateUtils.dateOnly(DateTime.now());
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final picked = await pickExpenseDate(context, _date);
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter an amount greater than 0');
      return;
    }
    Navigator.pop(
      context,
      ExpenseInput(_category, amount, _date, _nameCtrl.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // header: title + close
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Add Expense',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: AppColors.darkGreen),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                _categoryRow(),
                const SizedBox(height: 18),

                // optional name of the expense
                _nameField(),
                const SizedBox(height: 18),

                // amount
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(
                    'Amount',
                    style: TextStyle(fontSize: 15, color: AppColors.mutedText),
                  ),
                ),
                _amountField(),
                const SizedBox(height: 10),

                _dateRow(),
                const SizedBox(height: 22),

                // submit
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Add Expense'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Rounded icon tile used at the left of the category and date rows.
  Widget _iconTile(IconData icon, {bool circle = false}) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: _softGreen,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(18),
      ),
      child: Icon(icon, size: 30, color: AppColors.darkGreen),
    );
  }

  /// Label + value + trailing icon with a soft underline.
  Widget _pickerBody(String label, String value, IconData trailing) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.mutedText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGreen,
                  ),
                ),
              ],
            ),
          ),
          Icon(trailing, color: AppColors.darkGreen),
        ],
      ),
    );
  }

  /// Category picker: tap to choose from the list of categories.
  Widget _categoryRow() {
    return PopupMenuButton<ExpenseCategory>(
      tooltip: '',
      color: Colors.white,
      onSelected: (c) => setState(() => _category = c),
      itemBuilder: (_) => [
        for (final c in widget.categories)
          PopupMenuItem(
            value: c,
            child: Row(
              children: [
                Icon(c.icon, color: c.color, size: 22),
                const SizedBox(width: 12),
                Text(c.name),
              ],
            ),
          ),
      ],
      child: Row(
        children: [
          _iconTile(_category.icon),
          const SizedBox(width: 16),
          Expanded(
            child: _pickerBody(
              'Category',
              _category.name,
              Icons.keyboard_arrow_down,
            ),
          ),
        ],
      ),
    );
  }

  UnderlineInputBorder _underline(Color color, [double width = 1]) =>
      UnderlineInputBorder(
        borderSide: BorderSide(color: color, width: width),
      );

  /// Optional name of the expense (e.g. "Chick Fillet").
  Widget _nameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            'Name (optional)',
            style: TextStyle(fontSize: 15, color: AppColors.mutedText),
          ),
        ),
        TextField(
          controller: _nameCtrl,
          maxLength: 30,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          cursorColor: AppColors.darkGreen,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: AppColors.darkGreen,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            counterText: '',
            hintText: 'e.g. Chick Fillet',
            hintStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppColors.darkGreen.withValues(alpha: 0.35),
            ),
            enabledBorder: _underline(AppColors.border.withValues(alpha: 0.6)),
            focusedBorder: _underline(AppColors.darkGreen, 1.5),
          ),
        ),
      ],
    );
  }

  /// Big amount input with a peso sign and an underline.
  Widget _amountField() {
    const textStyle = TextStyle(
      fontSize: 38,
      fontWeight: FontWeight.w600,
      color: AppColors.darkGreen,
    );

    return TextField(
      controller: _amountCtrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      cursorColor: AppColors.darkGreen,
      style: textStyle,
      onChanged: (_) {
        if (_error != null) setState(() => _error = null);
      },
      onSubmitted: (_) => _submit(),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        prefixText: '₱',
        prefixStyle: textStyle,
        hintText: '0.00',
        hintStyle: textStyle.copyWith(
          color: AppColors.darkGreen.withValues(alpha: 0.45),
        ),
        errorText: _error,
        enabledBorder: _underline(AppColors.border.withValues(alpha: 0.6)),
        focusedBorder: _underline(AppColors.darkGreen, 1.5),
        errorBorder: _underline(Colors.redAccent),
        focusedErrorBorder: _underline(Colors.redAccent, 1.5),
      ),
    );
  }

  /// Date picker row: tap to open the calendar dialog.
  Widget _dateRow() {
    return InkWell(
      onTap: _pickDate,
      child: Row(
        children: [
          _iconTile(Icons.calendar_month_outlined, circle: true),
          const SizedBox(width: 16),
          Expanded(
            child: _pickerBody('Date', shortDate(_date), Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// Edit expense (full screen page, opens when an expense row is tapped)
// =====================================================================

/// Round soft-green badge with an icon inside (used for category / date).
class _IconBadge extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;

  const _IconBadge({required this.icon, this.size = 48, this.iconSize = 24});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: _softGreen,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: iconSize, color: AppColors.darkGreen),
    );
  }
}

/// Full-screen page for editing one expense.
/// Pops with an [ExpenseInput] when saved, or null when cancelled.
class EditExpensePage extends StatefulWidget {
  final ExpenseItem item;
  final String categoryName;
  final List<ExpenseCategory> categories;

  const EditExpensePage({
    super.key,
    required this.item,
    required this.categoryName,
    required this.categories,
  });

  @override
  State<EditExpensePage> createState() => _EditExpensePageState();
}

class _EditExpensePageState extends State<EditExpensePage> {
  late ExpenseCategory _category = widget.categories.firstWhere(
    (c) => c.name == widget.categoryName,
    orElse: () => widget.categories.first,
  );
  late final _nameCtrl = TextEditingController(text: widget.item.name);
  late final _amountCtrl = TextEditingController(
    text: widget.item.amount.toStringAsFixed(2),
  );
  late DateTime _date = DateUtils.dateOnly(widget.item.date);
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCategory() async {
    FocusScope.of(context).unfocus();
    final picked = await showModalBottomSheet<ExpenseCategory>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            for (final c in widget.categories)
              ListTile(
                leading: Icon(c.icon, color: c.color),
                title: Text(c.name),
                trailing: c.name == _category.name
                    ? const Icon(Icons.check, color: AppColors.darkGreen)
                    : null,
                onTap: () => Navigator.pop(context, c),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _category = picked);
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final picked = await pickExpenseDate(context, _date);
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter an amount greater than 0');
      return;
    }
    Navigator.pop(
      context,
      ExpenseInput(_category, amount, _date, _nameCtrl.text.trim()),
    );
  }

  /// Asks for confirmation, then closes the page with a "deleted" result.
  Future<void> _delete() async {
    FocusScope.of(context).unfocus();
    final item = widget.item;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Delete expense?',
          style: TextStyle(color: AppColors.darkGreen),
        ),
        content: Text(
          'This will remove "${item.name}" (${peso(item.amount)}). '
          'This can\'t be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(foregroundColor: AppColors.darkGreen),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    Navigator.pop(
      context,
      ExpenseInput(_category, item.amount, item.date, item.name, deleted: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          // tap outside a field to close the keyboard
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // header
                Row(
                  children: [
                    _BackCircle(onTap: () => Navigator.pop(context)),
                    const SizedBox(width: 14),
                    const Text(
                      'Edit Expense',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // big category icon
                Center(
                  child: _IconBadge(
                    icon: _category.icon,
                    size: 120,
                    iconSize: 56,
                  ),
                ),
                const SizedBox(height: 26),

                // name
                _label('Name (optional)'),
                _box(
                  child: TextField(
                    controller: _nameCtrl,
                    maxLength: 30,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    cursorColor: AppColors.darkGreen,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkGreen,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      hintText: 'e.g. Chick Fillet',
                      hintStyle: TextStyle(
                        fontSize: 18,
                        color: AppColors.darkGreen.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // category
                _label('Category'),
                _box(
                  onTap: _pickCategory,
                  child: Row(
                    children: [
                      _IconBadge(icon: _category.icon),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _category.name,
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.darkGreen,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.darkGreen,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // amount
                _label('Amount'),
                _box(
                  child: Row(
                    children: [
                      const Text(
                        '₱',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextField(
                          controller: _amountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          cursorColor: AppColors.darkGreen,
                          onChanged: (_) {
                            if (_error != null) setState(() => _error = null);
                          },
                          onSubmitted: (_) => _save(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGreen,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: '0.00',
                            hintStyle: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGreen.withValues(
                                alpha: 0.35,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 6),
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                const SizedBox(height: 18),

                // date
                _label('Date'),
                _box(
                  onTap: _pickDate,
                  child: Row(
                    children: [
                      const _IconBadge(icon: Icons.calendar_month_outlined),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          shortDate(_date),
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.darkGreen,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.darkGreen,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // buttons
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Save Changes'),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.darkGreen,
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                Center(
                  child: TextButton.icon(
                    onPressed: _delete,
                    icon: const Icon(Icons.delete_outline, size: 20),
                    label: const Text('Delete expense'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontSize: 15, color: AppColors.mutedText),
    ),
  );

  /// Rounded outlined box used for every field on this page.
  Widget _box({required Widget child, VoidCallback? onTap}) {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: SizedBox(
            height: 48,
            child: Align(alignment: Alignment.centerLeft, child: child),
          ),
        ),
      ),
    );
  }
}
