import 'package:flutter/material.dart';
import 'package:rentguard/services/auth_service.dart';
import 'package:rentguard/widgets/common_input_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final userProfile = await AuthService.getUserProfile();
      setState(() {
        _userId = userProfile['user']['id'] ?? 0;
        _usernameController.text = userProfile['user']['username'] ?? '';
        _emailController.text = userProfile['user']['email'] ?? '';
        _phoneController.text = userProfile['user']['phone'] ?? '';
        // print('Fetched user profile: $userProfile');
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user profile';
      });
      print('Error in _fetchUserProfile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final String newUsername = _usernameController.text;
    final String newEmail = _emailController.text;
    final String newPhone = _phoneController.text;

    if (newUsername.isEmpty || newEmail.isEmpty || newPhone.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
        _isLoading = false;
      });
      return;
    }

    if (_userId == null) {
      setState(() {
        _errorMessage = 'User ID is not available';
        _isLoading = false;
      });
      return;
    }

    try {
      final success = await AuthService.updateUserProfile(
          _userId!, newUsername, newEmail, newPhone);
      if (success) {
        Navigator.pop(context);
      } else {
        setState(() {
          _errorMessage = 'Failed to update profile';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred while updating profile: $e';
      });
      // print('Error in _updateProfile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.blue.shade700,
      ),
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : _errorMessage != null
                            ? Center(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              )
                            : Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    CommonInputField(
                                      controller: _usernameController,
                                      labelText: 'Username',
                                      prefixIcon: Icons.person,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a username';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    CommonInputField(
                                      controller: _emailController,
                                      labelText: 'Email',
                                      prefixIcon: Icons.email,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter an email';
                                        }
                                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                            .hasMatch(value)) {
                                          return 'Please enter a valid email';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    CommonInputField(
                                      controller: _phoneController,
                                      labelText: 'Phone',
                                      prefixIcon: Icons.phone,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a phone number';
                                        }
                                        if (!RegExp(r'^[0-9]+$')
                                            .hasMatch(value)) {
                                          return 'Please enter a valid phone number';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: _updateProfile,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 50,
                                          vertical: 15,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        backgroundColor: Colors.blue.shade700,
                                      ),
                                      child: const Text(
                                        'Save Changes',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
