import 'package:flutter/material.dart';
import 'package:rentguard/models/property.dart';
import 'package:rentguard/services/api_services.dart';
import 'package:rentguard/widgets/property_card.dart';
import 'package:rentguard/widgets/property_detail_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Property> _properties = [];
  List<Property> _filteredProperties = [];
  final TextEditingController _searchController = TextEditingController();
  late SharedPreferences _prefs; 

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _checkAuthentication();
  }

  void _checkAuthentication() {
    final token = _prefs.getString('token');
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      _fetchProperties();
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
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
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
      ),
    );
  }
}
