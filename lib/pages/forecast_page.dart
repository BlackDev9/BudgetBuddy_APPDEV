import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  String _selectedPeriod = 'Monthly';

  // Sample financial data
  final Map<String, Map<String, dynamic>> _forecastData = {
    'Weekly': {
      'income': 5000.0,
      'expenses': 1800.0,
      'balance': 12200.0,
      'incomePoints': [800.0, 1200.0, 1800.0, 2500.0, 3200.0, 4000.0, 5000.0],
      'expensePoints': [200.0, 500.0, 700.0, 1000.0, 1300.0, 1500.0, 1800.0],
      'labels': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    },
    'Monthly': {
      'income': 15000.0,
      'expenses': 6000.0,
      'balance': 18000.0,
      'incomePoints': [3000.0, 5000.0, 7500.0, 10000.0, 12500.0, 15000.0],
      'expensePoints': [1000.0, 1800.0, 2800.0, 3800.0, 4900.0, 6000.0],
      'labels': ['1', '5', '10', '15', '20', '30'],
    },
    'Yearly': {
      'income': 180000.0,
      'expenses': 72000.0,
      'balance': 117000.0,
      'incomePoints': [15000.0, 30000.0, 45000.0, 60000.0, 75000.0, 90000.0],
      'expensePoints': [6000.0, 12000.0, 18000.0, 24000.0, 30000.0, 36000.0],
      'labels': ['Jan', 'Mar', 'May', 'Jul', 'Sep', 'Dec'],
    },
  };

  String _formatCurrency(double amount) {
    return '₱${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (match) => '${match[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    final data = _forecastData[_selectedPeriod]!;

    final income = data['income'] as double;
    final expenses = data['expenses'] as double;
    final balance = data['balance'] as double;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      children: [
        // Header
        const Text(
          'Forecast',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Your financial overview',
          style: TextStyle(fontSize: 11, color: AppColors.textGray),
        ),

        const SizedBox(height: 22),

        // Period selector
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: ['Weekly', 'Monthly', 'Yearly'].map((period) {
              final isSelected = _selectedPeriod == period;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPeriod = period;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryGreen
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      period,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textGray,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 20),

        // Financial overview card
        Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Financial Overview',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _selectedPeriod,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 17),

              const Text(
                'Projected Balance',
                style: TextStyle(fontSize: 10, color: AppColors.textGray),
              ),

              const SizedBox(height: 5),

              Text(
                _formatCurrency(balance),
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),

              const SizedBox(height: 18),

              // Chart legend
              Row(
                children: [
                  _chartLegend(AppColors.primaryGreen, 'Income'),
                  const SizedBox(width: 18),
                  _chartLegend(const Color(0xFF9BCBB2), 'Expenses'),
                ],
              ),

              const SizedBox(height: 15),

              // Financial chart
              SizedBox(
                height: 165,
                width: double.infinity,
                child: CustomPaint(
                  painter: ForecastChartPainter(
                    incomePoints: List<double>.from(
                      data['incomePoints'] as List,
                    ),
                    expensePoints: List<double>.from(
                      data['expensePoints'] as List,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Chart labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: (data['labels'] as List<String>).map((label) {
                  return Text(
                    label,
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.textGray,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Income and expenses summary
        const Text(
          'Financial Summary',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _summaryCard(
                title: 'Projected Income',
                amount: _formatCurrency(income),
                icon: Icons.arrow_downward_rounded,
                iconColor: AppColors.primaryGreen,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _summaryCard(
                title: 'Projected Expenses',
                amount: _formatCurrency(expenses),
                icon: Icons.arrow_upward_rounded,
                iconColor: Colors.redAccent,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Balance projection information
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.savings_rounded,
                  color: AppColors.primaryGreen,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Expected Savings',
                      style: TextStyle(fontSize: 11, color: AppColors.textGray),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      _formatCurrency(income - expenses),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.trending_up_rounded,
                color: AppColors.primaryGreen,
                size: 23,
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),
      ],
    );
  }

  // Chart legend
  Widget _chartLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textGray),
        ),
      ],
    );
  }

  // Financial summary card
  Widget _summaryCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: const TextStyle(fontSize: 10, color: AppColors.textGray),
          ),

          const SizedBox(height: 5),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// FINANCIAL FORECAST CHART
// ==========================================

class ForecastChartPainter extends CustomPainter {
  final List<double> incomePoints;
  final List<double> expensePoints;

  ForecastChartPainter({
    required this.incomePoints,
    required this.expensePoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (incomePoints.isEmpty || expensePoints.isEmpty) return;

    const leftPadding = 5.0;
    const rightPadding = 5.0;
    const topPadding = 10.0;
    const bottomPadding = 10.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    final maxValue =
        [...incomePoints, ...expensePoints].reduce((a, b) => a > b ? a : b) *
        1.15;

    // Draw horizontal grid lines
    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.8)
      ..strokeWidth = 0.8;

    for (int i = 0; i < 4; i++) {
      final y = topPadding + (chartHeight / 3) * i;

      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );
    }

    // Convert values into chart positions
    List<Offset> getPoints(List<double> values) {
      return List.generate(values.length, (index) {
        final x = leftPadding + (chartWidth / (values.length - 1)) * index;

        final y =
            topPadding + chartHeight - (values[index] / maxValue) * chartHeight;

        return Offset(x, y);
      });
    }

    // Draw smooth lines
    void drawLine(List<Offset> points, Color color) {
      final path = Path();

      path.moveTo(points.first.dx, points.first.dy);

      for (int i = 0; i < points.length - 1; i++) {
        final current = points[i];
        final next = points[i + 1];

        final controlPoint = (current.dx + next.dx) / 2;

        path.cubicTo(
          controlPoint,
          current.dy,
          controlPoint,
          next.dy,
          next.dx,
          next.dy,
        );
      }

      final paint = Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(path, paint);

      // Draw points
      final pointPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      for (final point in points) {
        canvas.drawCircle(point, 3, pointPaint);
      }
    }

    drawLine(getPoints(incomePoints), AppColors.primaryGreen);

    drawLine(getPoints(expensePoints), const Color(0xFF9BCBB2));
  }

  @override
  bool shouldRepaint(covariant ForecastChartPainter oldDelegate) {
    return oldDelegate.incomePoints != incomePoints ||
        oldDelegate.expensePoints != expensePoints;
  }
}
