import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_tracking/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:material_tracking/features/auth/presentation/bloc/auth_state.dart';
import 'package:material_tracking/features/auth/domain/models/user_model.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Implement add user functionality
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AuthError) {
            return Center(child: Text(state.message));
          }
          if (state is Authenticated) {
            return FutureBuilder<List<UserModel>>(
              future: context.read<AuthBloc>().authRepository.getAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final users = snapshot.data ?? [];
                if (users.isEmpty) {
                  return const Center(child: Text('No users found'));
                }
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(user.name[0]),
                      ),
                      title: Text(user.name),
                      subtitle: Text(user.email),
                      trailing: Text(user.role.toString()),
                      onTap: () {
                        // TODO: Implement user details/edit functionality
                      },
                    );
                  },
                );
              },
            );
          }
          return const Center(child: Text('Not authenticated'));
        },
      ),
    );
  }
}
