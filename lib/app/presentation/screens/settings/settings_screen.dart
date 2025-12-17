import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/theme/theme_cubit.dart';
import '../../../data/local/shared_preference_helper.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
                context.read<AuthBloc>().add(AuthLogoutRequested()); 
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    }

  Future<void> _confirmClearCache(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Cache'),
        content:
            const Text('This will clear locally cached data. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await SharedPreferencesHelper.getInstance()
          .then((prefs) => prefs.clearAll());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache cleared')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          /// THEME SECTION
          _sectionHeader('Appearance'),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) {
              return SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: Text(
                  mode == ThemeMode.dark ? 'Enabled' : 'Disabled',
                ),
                value: mode == ThemeMode.dark,
                onChanged: (_) {
                  context.read<ThemeCubit>().toggleTheme();
                },
                secondary: const Icon(Icons.dark_mode_outlined),
              );
            },
          ),

          const Divider(),

          /// DATA SECTION
          _sectionHeader('Storage'),
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: const Text('Clear cached data'),
            subtitle: const Text('Remove locally stored data'),
            onTap: () => _confirmClearCache(context),
          ),

          const Divider(),

          /// ACCOUNT SECTION
          _sectionHeader('Account'),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
