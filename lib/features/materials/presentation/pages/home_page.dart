import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_tracking/features/auth/domain/models/user_model.dart';
import 'package:material_tracking/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:material_tracking/features/auth/presentation/bloc/auth_event.dart';
import 'package:material_tracking/features/materials/presentation/bloc/materials_bloc.dart';
import 'package:material_tracking/features/materials/presentation/bloc/materials_event.dart';
import 'package:material_tracking/features/materials/presentation/bloc/materials_state.dart';
import 'package:material_tracking/features/materials/presentation/widgets/low_stock_alert.dart';
import 'package:material_tracking/features/materials/presentation/widgets/material_list.dart';
import 'package:material_tracking/features/materials/presentation/widgets/recent_consumptions.dart';
import 'package:material_tracking/features/materials/presentation/widgets/stats_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = authState.user;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Material Tracking'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                },
              ),
            ],
          ),
          drawer: _buildDrawer(context, user),
          body: BlocBuilder<MaterialsBloc, MaterialsState>(
            builder: (context, state) {
              if (state is MaterialsInitial) {
                context.read<MaterialsBloc>().add(LoadMaterialsEvent());
                return const Center(child: CircularProgressIndicator());
              }

              if (state is MaterialsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is MaterialsError) {
                return Center(child: Text(state.message));
              }

              if (state is MaterialsLoaded) {
                return _buildDashboard(context, state, user);
              }

              return const SizedBox.shrink();
            },
          ),
          floatingActionButton: _buildFloatingActionButton(context, user),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context, UserModel user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user.name),
            accountEmail: Text(user.email),
            currentAccountPicture: CircleAvatar(
              child: Text(
                user.name[0].toUpperCase(),
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          if (user.isAdmin) ...[
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Users'),
              onTap: () {
                Navigator.pushNamed(context, '/users');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
          ListTile(
            leading: const Icon(Icons.add_circle),
            title: const Text('Record Consumption'),
            onTap: () {
              Navigator.pushNamed(context, '/consumption');
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Consumption History'),
            onTap: () {
              Navigator.pushNamed(context, '/history');
            },
          ),
          if (user.isAdmin)
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Reports'),
              onTap: () {
                Navigator.pushNamed(context, '/reports');
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    MaterialsLoaded state,
    UserModel user,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<MaterialsBloc>().add(LoadMaterialsEvent());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!state.isOnline)
              const Card(
                color: Colors.orange,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Offline Mode - Changes will sync when online',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (user.isAdmin) ...[
              Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      title: 'Total Materials',
                      value: state.materials.length.toString(),
                      icon: Icons.inventory,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatsCard(
                      title: 'Low Stock Items',
                      value: state.materials
                          .where((m) => m.currentStock <= m.minimumStock)
                          .length
                          .toString(),
                      icon: Icons.warning,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Low Stock Alerts',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              LowStockAlert(materials: state.materials),
              const SizedBox(height: 16),
            ],
            const Text(
              'Recent Materials',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            MaterialList(
              materials: state.materials.take(5).toList(),
              onTap: (material) {
                Navigator.pushNamed(
                  context,
                  '/material-details',
                  arguments: material,
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Recent Consumptions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RecentConsumptions(
              consumptions: state.consumptions.take(5).toList(),
              materials: state.materials,
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context, UserModel user) {
    if (!user.isAdmin) return null;

    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, '/add-material');
      },
      child: const Icon(Icons.add),
    );
  }
}
