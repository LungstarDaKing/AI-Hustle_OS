import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/dashboard_metric_card.dart';
import '../../../../shared/widgets/dashboard_ai_insight_card.dart';
import '../../../../shared/widgets/dashboard_recent_activity.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Dashboard',
        showNotifications: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dashboard metrics
              const DashboardMetricsSection(),
              const SizedBox(height: 24),

              // AI Insights
              const DashboardAIInsightsSection(),
              const SizedBox(height: 24),

              // Recent activity
              const DashboardRecentActivitySection(),
              const SizedBox(height: 24),

              // Quick actions
              const DashboardQuickActionsSection(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement quick add action sheet
          context.go('/home/transactions/new');
        },
        label: const Text('Quick Add'),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      bottomNavigationBar: const DashboardNavigationBar(),
    );
  }

  Future<void> _refreshData() async {
    // TODO: Implement data refresh logic
    await Future.delayed(const Duration(seconds: 2));
  }
}

class DashboardMetricsSection extends StatelessWidget {
  const DashboardMetricsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        DashboardMetricCard(
          title: 'Today\'s Revenue',
          value: 'R2,450',
          change: '+12.5%',
          isPositive: true,
          icon: Icons.trending_up,
          color: Colors.green,
        ),
        DashboardMetricCard(
          title: 'Today\'s Expenses',
          value: 'R1,200',
          change: '-5.2%',
          isPositive: true,
          icon: Icons.trending_down,
          color: Colors.red,
        ),
        DashboardMetricCard(
          title: 'Estimated Profit',
          value: 'R1,250',
          change: '+18.3%',
          isPositive: true,
          icon: Icons.account_balance_wallet,
          color: Colors.deepOrange,
        ),
        DashboardMetricCard(
          title: 'Outstanding Payments',
          value: 'R3,800',
          change: '+8.7%',
          isPositive: false,
          icon: Icons.payment,
          color: Colors.amber,
        ),
      ],
    );
  }
}

class DashboardAIInsightsSection extends StatelessWidget {
  const DashboardAIInsightsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'AI Insights',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        DashboardAIInsightCard(
          title: 'Revenue Trend',
          description: 'Your revenue is 14% higher than last week.',
          icon: Icons.show_chart,
          color: Colors.blue,
        ),
        DashboardAIInsightCard(
          title: 'Top Selling Service',
          description: 'Your top-selling service this month is Haircut + Wash.',
          icon: Icons.local_fire_department,
          color: Colors.orange,
        ),
        DashboardAIInsightCard(
          title: 'Outstanding Payments',
          description: 'Three customers have outstanding payments.',
          icon: Icons.schedule_send,
          color: Colors.red,
        ),
        DashboardAIInsightCard(
          title: 'Stock Alert',
          description: 'Product X may run out in approximately 5 days based on recent sales.',
          icon: Icons.warning_amber,
          color: Colors.yellow,
        ),
      ],
    );
  }
}

class DashboardRecentActivitySection extends StatelessWidget {
  const DashboardRecentActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        DashboardRecentActivity(),
      ],
    );
  }
}

class DashboardQuickActionsSection extends StatelessWidget {
  const DashboardQuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.person_add,
                label: 'Add Customer',
                onTap: () => context.go('/customers/new'),
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.add_shopping_cart,
                label: 'Add Product',
                onTap: () => context.go('/products/new'),
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.swap_vert,
                label: 'New Sale',
                onTap: () => context.go('/transactions/new'),
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.description,
                label: 'Create Invoice',
                onTap: () => context.go('/invoices/new'),
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    {
      required IconData icon,
      required String label,
      required VoidCallback onTap,
      required Color color,
    }
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardNavigationBar extends StatelessWidget {
  const DashboardNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 65,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      indicatorColor: Theme.of(context).colorScheme.primaryContainer,
      selectedIndex: 0,
      onDestinationSelected: (int index) {
        // Handle navigation
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/business');
            break;
          case 2:
            context.go('/customers');
            break;
          case 3:
            context.go('/transactions');
            break;
          case 4:
            context.go('/ai');
            break;
          case 5:
            context.go('/more');
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.business_outlined),
          selectedIcon: Icon(Icons.business),
          label: 'Business',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outlined),
          selectedIcon: Icon(Icons.people),
          label: 'Customers',
        ),
        NavigationDestination(
          icon: Icon(Icons.payment_outlined),
          selectedIcon: Icon(Icons.payment),
          label: 'Transactions',
        ),
        NavigationDestination(
          icon: Icon(Icons.smart_toy_outlined),
          selectedIcon: Icon(Icons.smart_toy),
          label: 'AI',
        ),
        NavigationDestination(
          icon: Icon(Icons.more_horiz_outlined),
          selectedIcon: Icon(Icons.more_horiz),
          label: 'More',
        ),
      ],
    );
  }
}