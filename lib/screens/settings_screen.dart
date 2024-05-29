import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rentguard/screens/login_screen.dart';
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
      // If token is not found, navigate to the login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      // Retrieve user role from preferences
      setState(() {
        userRole = prefs.getString('role') ?? '';
      });
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Remove the token
    await prefs.remove('role');  // Remove the role
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
            // Navigate to edit profile screen
          },
        ),
        ListTile(
          leading: const Icon(Icons.lock_reset),
          title: const Text('Reset Password'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ResetPasswordScreen()),
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
              // Submit request to become house agent
            },
          ),
        if (userRole == 'owner')
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Manage Properties'),
            onTap: () {
              // Navigate to manage properties screen
            },
          ),
        if (userRole == 'admin') ...[
          ListTile(
            leading: const Icon(Icons.supervised_user_circle),
            title: const Text('Manage Users'),
            onTap: () {
              // Navigate to manage users screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.home_work),
            title: const Text('Manage All Properties'),
            onTap: () {
              // Navigate to manage all properties screen
            },
          ),
        ],
      ],
    );
  }
}
