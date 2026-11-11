import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

class PayCyclePage extends StatefulWidget {
  /// No longer used now that the top buttons are gone. Kept so existing code
  /// like `PayCyclePage(onBack: ...)` in home_page.dart still compiles.
  final VoidCallback? onBack;

  const PayCyclePage({super.key, this.onBack});

  @override
  State<PayCyclePage> createState() => _PayCyclePageState();
}

class _PayCyclePageState extends State<PayCyclePage> {
  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static const _monthShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static const _weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const _weekdayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];

  final _cycleCtrl = TextEditingController(text: 'Monthly');
  final _cycleFocus = FocusNode();

  final _salaryCtrl = TextEditingController(text: '30,000');
  final _salaryFocus = FocusNode();

  late DateTime _selected;
  late int _viewMonth;
  late int _viewYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selected = DateTime(now.year, now.month, now.day);
    _viewMonth = now.month;
    _viewYear = now.year;
  }

  @override
  void dispose() {
    _cycleCtrl.dispose();
    _cycleFocus.dispose();
    _salaryCtrl.dispose();
    _salaryFocus.dispose();
    super.dispose();
  }

  // ---------- logic ----------

  double get _salary =>
      double.tryParse(_salaryCtrl.text.replaceAll(',', '')) ?? 0;

  /// Days between pay dates, or null when the cycle is monthly.
  /// The cycle is typed, so it is read loosely:
  ///   "Monthly"            -> null (same day next month)
  ///   "Weekly" / "2 weeks" -> 7 / 14 days
  ///   "Bi-weekly"          -> 14 days
  ///   "Semi-monthly"       -> 15 days
  ///   "10" / "10 days"     -> 10 days
  /// Anything unrecognised falls back to monthly.
  int? get _cycleDays {
    final t = _cycleCtrl.text.trim().toLowerCase();
    final n = int.tryParse(t.replaceAll(RegExp(r'[^0-9]'), ''));

    if (t.contains('bi')) return 14;
    if (t.contains('semi')) return 15;
    if (t.contains('week')) return 7 * ((n != null && n > 0) ? n : 1);
    if (n != null && n > 0 && !t.contains('month')) return n;
    return null;
  }

  String get _cycleHint {
    final d = _cycleDays;
    if (d == null) return 'Repeats monthly';
    if (d == 1) return 'Repeats every day';
    return 'Repeats every $d days';
  }

  /// Selected date plus one pay cycle.
  DateTime get _nextPayDate {
    final d = _cycleDays;
    if (d != null) return _selected.add(Duration(days: d));

    // Monthly: clamp to the last day, e.g. Oct 31 -> Nov 30
    final y = _selected.month == 12 ? _selected.year + 1 : _selected.year;
    final m = _selected.month == 12 ? 1 : _selected.month + 1;
    final last = DateUtils.getDaysInMonth(y, m);
    return DateTime(y, m, _selected.day > last ? last : _selected.day);
  }

  String _money(double v) {
    final isWhole = v == v.roundToDouble();
    final parts = v.toStringAsFixed(isWhole ? 0 : 2).split('.');
    final whole = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (m) => ',',
    );
    return '₱$whole${parts.length > 1 ? '.${parts[1]}' : ''}';
  }

  String _headerDate() {
    final d = DateTime.now();
    return '${_weekdayNames[d.weekday - 1]}, ${_monthNames[d.month - 1]} ${d.day}';
  }

  String _daysUntil(DateTime date) {
    final today = DateUtils.dateOnly(DateTime.now());
    final diff = DateUtils.dateOnly(date).difference(today).inDays;
    if (diff == 0) return 'today';
    if (diff == 1) return 'tomorrow';
    if (diff < 0) return '${-diff} days ago';
    return 'in $diff days';
  }

  void _shiftMonth(int delta) {
    var m = _viewMonth + delta;
    var y = _viewYear;
    if (m < 1) {
      m = 12;
      y--;
    } else if (m > 12) {
      m = 1;
      y++;
    }
    setState(() {
      _viewMonth = m;
      _viewYear = y;
    });
  }

  void _save() {
    // TODO: save the cycle text, _selected and _salary to your database / backend.
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          // tap anywhere outside a field to close the keyboard
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- Header ----
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    _headerDate(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.mutedText,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(
                    'Pay Cycle',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // ---- Set pay cycle ----
                _label('Set pay cycle'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _textField(
                        controller: _cycleCtrl,
                        focusNode: _cycleFocus,
                        icon: Icons.event_repeat_outlined,
                        hint: 'Monthly, Weekly, Bi-weekly or days',
                        keyboardType: TextInputType.text,
                        capitalize: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _editButton(() => _cycleFocus.requestFocus()),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 6, top: 6),
                  child: Text(
                    _cycleHint,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.mutedText,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ---- Set date ----
                _label('Set date'),
                const SizedBox(height: 8),
                _calendarCard(),
                const SizedBox(height: 20),

                // ---- Salary / Allowance ----
                _label('Salary/Allowance'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _textField(
                        controller: _salaryCtrl,
                        focusNode: _salaryFocus,
                        icon: Icons.payments_outlined,
                        hint: 'Enter amount',
                        keyboardType: TextInputType.number,
                        formatters: [_ThousandsFormatter()],
                        prefix: '₱ ',
                      ),
                    ),
                    const SizedBox(width: 10),
                    _editButton(() => _salaryFocus.requestFocus()),
                  ],
                ),
                const SizedBox(height: 22),

                // ---- Summary ----
                _summaryCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.darkGreen,
      ),
    ),
  );

  /// Pencil icon: tap it to jump into the field and start typing.
  Widget _editButton(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: const Padding(
        padding: EdgeInsets.all(6),
        child: Icon(Icons.edit_outlined, color: AppColors.darkGreen, size: 22),
      ),
    );
  }

  /// A typeable box styled like the design. The border turns green on focus.
  Widget _textField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
    required String hint,
    required TextInputType keyboardType,
    List<TextInputFormatter>? formatters,
    bool capitalize = false,
    String? prefix,
  }) {
    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, _) {
        final focused = focusNode.hasFocus;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: focused ? AppColors.darkGreen : AppColors.border,
              width: focused ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.darkGreen, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: keyboardType,
                  textInputAction: TextInputAction.done,
                  textCapitalization: capitalize
                      ? TextCapitalization.sentences
                      : TextCapitalization.none,
                  inputFormatters: formatters,
                  cursorColor: AppColors.darkGreen,
                  onChanged: (_) => setState(() {}), // refresh summary + hint
                  onSubmitted: (_) => _save(),
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.darkGreen,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    prefixText: prefix,
                    prefixStyle: const TextStyle(
                      fontSize: 15,
                      color: AppColors.darkGreen,
                    ),
                    hintText: hint,
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: AppColors.mutedText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _calendarCard() {
    final daysInMonth = DateUtils.getDaysInMonth(_viewYear, _viewMonth);
    final offset = DateTime(_viewYear, _viewMonth, 1).weekday % 7; // Sunday = 0
    final nowYear = DateTime.now().year;
    final years = List.generate(8, (i) => nowYear - 1 + i);
    if (!years.contains(_viewYear)) years.add(_viewYear);
    years.sort();
    final today = DateUtils.dateOnly(DateTime.now());

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // month + year pickers and previous / next arrows
          Row(
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _viewMonth,
                  isDense: true,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGreen,
                  ),
                  items: List.generate(
                    12,
                        (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text(_monthNames[i]),
                    ),
                  ),
                  onChanged: (v) => setState(() => _viewMonth = v ?? _viewMonth),
                ),
              ),
              const SizedBox(width: 16),
              DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _viewYear,
                  isDense: true,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGreen,
                  ),
                  items: years
                      .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                      .toList(),
                  onChanged: (v) => setState(() => _viewYear = v ?? _viewYear),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _shiftMonth(-1),
                icon: const Icon(Icons.chevron_left),
                color: AppColors.darkGreen,
                visualDensity: VisualDensity.compact,
                tooltip: 'Previous month',
              ),
              IconButton(
                onPressed: () => _shiftMonth(1),
                icon: const Icon(Icons.chevron_right),
                color: AppColors.darkGreen,
                visualDensity: VisualDensity.compact,
                tooltip: 'Next month',
              ),
            ],
          ),
          const SizedBox(height: 4),

          // weekday labels
          Row(
            children: _weekdays
                .map((d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mutedText,
                  ),
                ),
              ),
            ))
                .toList(),
          ),
          const SizedBox(height: 6),

          // day grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: offset + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 0,
              childAspectRatio: 1,
            ),
            itemBuilder: (_, i) {
              if (i < offset) return const SizedBox.shrink();
              final day = i - offset + 1;
              final date = DateTime(_viewYear, _viewMonth, day);
              final isSelected = DateUtils.isSameDay(date, _selected);
              final isToday = DateUtils.isSameDay(date, today);

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  FocusScope.of(context).unfocus();
                  setState(() => _selected = date);
                  _save();
                },
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.darkGreen : Colors.transparent,
                      shape: BoxShape.circle,
                      border: (isToday && !isSelected)
                          ? Border.all(color: AppColors.darkGreen, width: 1)
                          : null,
                    ),
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                        isSelected || isToday ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    final next = _nextPayDate;
    final nextText = '${_monthShort[next.month - 1]} ${next.day}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFDDEFE3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.darkGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _summaryItem('Next pay date', nextText, _daysUntil(next)),
          ),
          Expanded(
            child: _summaryItem('Amount', _money(_salary), _cycleHint),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, String caption) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.darkGreen),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGreen,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.darkGreen.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

/// Formats typed digits with thousands separators (30000 -> 30,000).
class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final text = digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (m) => ',',
    );
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}