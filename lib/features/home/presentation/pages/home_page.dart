import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../materials/presentation/pages/materials_page.dart';
import '../../../products/presentation/pages/product_list_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../widgets/stats_card.dart';

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
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _DashboardView(),
          MaterialsPage(),
          ProductListPage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_outlined),
            selectedIcon: Icon(Icons.inventory),
            label: 'Materials',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc bloc) =>
        bloc.state is AuthAuthenticated
            ? (bloc.state as AuthAuthenticated).user
            : null);

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user.name}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24.0),
            const Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: 'Total Materials',
                    value: '24',
                    icon: Icons.inventory,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: StatsCard(
                    title: 'Low Stock',
                    value: '3',
                    icon: Icons.warning,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: 'Products',
                    value: '12',
                    icon: Icons.category,
                    color: Colors.green,
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: StatsCard(
                    title: 'Consumptions',
                    value: '156',
                    icon: Icons.history,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32.0),
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16.0),
            Card(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return const ListTile(
                    leading: CircleAvatar(
                      child: Icon(Icons.history),
                    ),
                    title: Text('Material Consumed'),
                    subtitle: Text('Steel Sheets - 50 units'),
                    trailing: Text('2 hours ago'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
