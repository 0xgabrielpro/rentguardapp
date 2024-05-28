import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class SettingsScreen extends StatelessWidget {
  final String userRole = 'admin';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        ListTile(
          leading: Icon(Icons.edit),
          title: Text('Edit Profile'),
          onTap: () {
            // edit profile screen
          },
        ),
        ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('Logout'),
          onTap: () {
            _logout(context); 
          },
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

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); 
    Navigator.pushReplacementNamed(context, '/login');
  }
}
