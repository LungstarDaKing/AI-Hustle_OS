import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      destinations: [
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