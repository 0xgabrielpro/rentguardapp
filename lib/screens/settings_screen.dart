import 'package:flutter/material.dart';
import 'package:rentguard/screens/agent_requests_screen.dart';
import 'package:rentguard/screens/become_agence.dart';
import 'package:rentguard/screens/manage_properties_screen.dart';
import 'package:rentguard/screens/manage_users_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rentguard/screens/login_screen.dart';
import 'package:rentguard/screens/edit_profile_screen.dart';
import 'package:rentguard/screens/reset_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String userRole = '';

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      setState(() {
        userRole = prefs.getString('role') ?? '';
      });
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('Edit Profile'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const EditProfileScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.lock_reset),
          title: const Text('Reset Password'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ResetPasswordScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.exit_to_app),
          title: const Text('Logout'),
          onTap: _logout,
        ),
        if (userRole == 'tenant')
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Become House Agent'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const BecomeAgentScreen()),
              );
            },
          ),
        if (userRole == 'owner')
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Manage Properties'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ManagePropertiesScreen()),
              );
            },
          ),
        if (userRole == 'admin') ...[
          ListTile(
            leading: const Icon(Icons.supervised_user_circle),
            title: const Text('Manage Users'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageUsersScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.home_work),
            title: const Text('Manage All Properties'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ManagePropertiesScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Requests'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AgentRequestsScreen()),
              );
            },
          ),
        ],
      ],
    );
  }
}
