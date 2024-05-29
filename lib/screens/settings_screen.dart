import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rentguard/screens/login_screen.dart';
import 'package:rentguard/screens/reset_password_screen.dart';

class SettingsScreen extends StatefulWidget {
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
        MaterialPageRoute(builder: (context) => LoginScreen()),
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
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        ListTile(
          leading: Icon(Icons.edit),
          title: Text('Edit Profile'),
          onTap: () {
            // Navigate to edit profile screen
          },
        ),
        ListTile(
          leading: Icon(Icons.lock_reset),
          title: Text('Reset Password'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('Logout'),
          onTap: _logout,
        ),
        if (userRole == 'tenant')
          ListTile(
            leading: Icon(Icons.business),
            title: Text('Become House Agent'),
            onTap: () {
              // Submit request to become house agent
            },
          ),
        if (userRole == 'owner')
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Manage Properties'),
            onTap: () {
              // Navigate to manage properties screen
            },
          ),
        if (userRole == 'admin') ...[
          ListTile(
            leading: Icon(Icons.supervised_user_circle),
            title: Text('Manage Users'),
            onTap: () {
              // Navigate to manage users screen
            },
          ),
          ListTile(
            leading: Icon(Icons.home_work),
            title: Text('Manage All Properties'),
            onTap: () {
              // Navigate to manage all properties screen
            },
          ),
        ],
      ],
    );
  }
}
