import 'package:flutter/material.dart';
import 'package:rentguard/models/property.dart';
import 'package:rentguard/services/api_services.dart';
import 'package:rentguard/services/auth_service.dart';
import 'package:rentguard/widgets/property_card.dart';
import 'package:rentguard/widgets/property_detail_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Property> _properties = [];
  List<Property> _filteredProperties = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void _checkAuthentication() async {
    final token = await AuthService.getToken();
    if (token != null) {
      setState(() {
        _isAuthenticated = true;
      });
      _fetchProperties();
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _fetchProperties() async {
    try {
      List<Property> properties = await ApiService.fetchProperties();
      setState(() {
        _properties = properties;
        _filteredProperties = properties;
      });
    } catch (e) {
      // Handle error
    }
  }

  void _filterProperties(String query) {
    final filtered = _properties.where((property) {
      return property.location.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredProperties = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isAuthenticated
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search by location',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (query) => _filterProperties(query),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredProperties.length,
                      itemBuilder: (context, index) {
                        final property = _filteredProperties[index];
                        return PropertyCard(
                          property: property,
                          onViewPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  PropertyDetailDialog(property: property),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
