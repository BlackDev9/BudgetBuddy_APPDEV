import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'expenses_page.dart';
import 'paycyle_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const _HomeDashboard(),

          const _ComingSoonPage(
            title: 'Financial Forecast',
            icon: Icons.trending_up_rounded,
          ),

          const ExpensesPage(),

          // Back arrow on this page returns to the Home tab
          PayCyclePage(
            onBack: () => setState(() => _selectedIndex = 0),
          ),
        ],
      ),

      // Bottom navigation
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: AppColors.lightGreen,
        elevation: 3,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up_rounded),
            label: 'Forecast',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Expenses',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Pay Cycle',
          ),
        ],
      ),
    );
  }
}

// ==========================================
// HOME DASHBOARD
// ==========================================

class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 18,
      ),
      children: [

        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hello, Sage 👋',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Welcome back to Budget Buddy!',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ),

            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: AppColors.primaryGreen,
                size: 24,
              ),
            ),
          ],
        ),

        const SizedBox(height: 25),

        // Current balance card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.primaryGreen,
                AppColors.darkGreen,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Balance',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                '₱9,000.00',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 18),

              const Divider(
                color: Colors.white30,
                height: 1,
              ),

              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _balanceInfo(
                    Icons.arrow_downward_rounded,
                    'Income',
                    '₱15,000',
                  ),
                  _balanceInfo(
                    Icons.arrow_upward_rounded,
                    'Expenses',
                    '₱6,000',
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Pay cycle countdown
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.primaryGreen,
                  size: 25,
                ),
              ),

              const SizedBox(width: 13),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next Payday',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textGray,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'December 1, 2026',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),

              const Column(
                children: [
                  Text(
                    '12',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  Text(
                    'Days left',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textGray,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),

        // Quick actions
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _quickAction(
                Icons.add_circle_outline,
                'Add Expense',
                    () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Add Expense coming soon!'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _quickAction(
                Icons.analytics_outlined,
                'View Forecast',
                    () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Forecast page coming soon!'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 25),

        // Recent transactions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),

            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('View all transactions coming soon!'),
                  ),
                );
              },
              child: const Text(
                'See All',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 5),

        _transactionItem(
          Icons.restaurant_rounded,
          'Food / Drinks',
          'Today • 10:30 AM',
          '-₱250.00',
          Colors.orange,
        ),

        _transactionItem(
          Icons.directions_bus_rounded,
          'Transportation',
          'Yesterday • 8:15 AM',
          '-₱100.00',
          Colors.blue,
        ),

        _transactionItem(
          Icons.shopping_bag_rounded,
          'Shopping',
          'November 5, 2026',
          '-₱500.00',
          Colors.purple,
        ),

        const SizedBox(height: 25),
      ],
    );
  }

  // Balance information
  Widget _balanceInfo(
      IconData icon,
      String label,
      String amount,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
        const SizedBox(width: 7),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Quick action button
  Widget _quickAction(
      IconData icon,
      String label,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.primaryGreen,
              size: 27,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Recent transaction item
  Widget _transactionItem(
      IconData icon,
      String title,
      String date,
      String amount,
      Color iconColor,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ),
          ),

          Text(
            amount,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// TEMPORARY PLACEHOLDER PAGES
// ==========================================

class _ComingSoonPage extends StatelessWidget {
  final String title;
  final IconData icon;

  const _ComingSoonPage({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 65,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This feature is coming soon!',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textGray,
            ),
          ),
        ],
      ),
    );
  }
}