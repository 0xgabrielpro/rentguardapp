import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
import 'package:rentguard/services/api_services.dart';
import 'package:rentguard/models/property.dart';
import 'package:rentguard/widgets/common_input_field.dart';

class ManagePropertiesScreen extends StatefulWidget {
  @override
  _ManagePropertiesScreenState createState() => _ManagePropertiesScreenState();
}

class _ManagePropertiesScreenState extends State<ManagePropertiesScreen> {
  List<Property> _properties = [];
  bool _isLoading = false;
  int? _ownerId;

  @override
  void initState() {
    super.initState();
    _fetchOwnerId();
    _fetchProperties();
  }

  Future<void> _fetchOwnerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _ownerId = prefs.getInt('id');
    });
  }

  Future<void> _fetchProperties() async {
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? role = prefs.getString('role');

      if (role == 'admin') {
        List<Property> properties = await ApiService.fetchProperties();
        setState(() {
          _properties = properties;
        });
      } else if (role == 'owner') {
        if (_ownerId != null) {
          List<Property> properties =
              await ApiService.fetchPropertiesByOwnerId(_ownerId!);
          setState(() {
            _properties = properties;
          });
        } else {
          print('NOT FOUND3');
        }
      } else {
        print('Invalid user');
      }
    } catch (e) {
      print('Error fetching properties');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteProperty(int propertyId) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this property?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await ApiService.deleteProperty(propertyId);
        _fetchProperties();
      } catch (e) {
        print('Error deleting property');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showPropertyFormDialog({Property? property}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PropertyFormDialog(
          property: property,
          ownerId: _ownerId,
          onFormSubmit: (success) {
            if (success) {
              _fetchProperties();
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Properties'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                _showPropertyFormDialog();
              },
              child: Text('Add Property'),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _properties.length,
                      itemBuilder: (context, index) {
                        final property = _properties[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(property.location),
                            subtitle: Text('\$${property.price}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    _showPropertyFormDialog(property: property);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _deleteProperty(property.id),
                                ),
                              ],
                            ),
                          ),
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

class PropertyFormDialog extends StatefulWidget {
  final Property? property;
  final int? ownerId;
  final Function(bool success) onFormSubmit;

  PropertyFormDialog({
    this.property,
    required this.ownerId,
    required this.onFormSubmit,
  });

  @override
  _PropertyFormDialogState createState() => _PropertyFormDialogState();
}

class _PropertyFormDialogState extends State<PropertyFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  XFile? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.property != null) {
      _populateForm(widget.property!);
    }
  }

  void _populateForm(Property property) {
    _locationController.text = property.location;
    _priceController.text = property.price.toString();
    _descriptionController.text = property.description;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  Future<void> _createOrUpdateProperty() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final location = _locationController.text;
      final price = double.parse(_priceController.text);
      final description = _descriptionController.text;

      if (widget.property != null) {
        print('Updating property: ${widget.property!.id}');
        print('Location: $location');
        print('Price: $price');
        print('Description: $description');
        print('Owner ID: ${widget.ownerId}');
        await ApiService.updateProperty(
          widget.property!.id,
          location,
          price,
          description,
          _selectedImage,
          widget.ownerId!,
        );
      } else {
        print('Creating property');
        print('Location: $location');
        print('Price: $price');
        print('Description: $description');
        print('Owner ID: ${widget.ownerId}');
        await ApiService.createProperty(
          location,
          price,
          description,
          _selectedImage,
          widget.ownerId!,
        );
      }

      widget.onFormSubmit(true);
      Navigator.of(context).pop();
    } catch (e) {
      print('Error creating/updating property: $e');
      widget.onFormSubmit(false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.property != null ? 'Edit Property' : 'Add Property'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonInputField(
                controller: _locationController,
                labelText: 'Location',
                prefixIcon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              CommonInputField(
                controller: _priceController,
                labelText: 'Price',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  } else if (double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              CommonInputField(
                controller: _descriptionController,
                labelText: 'Description',
                prefixIcon: Icons.description,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Select Image'),
              ),
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: kIsWeb
                      ? Image.network(_selectedImage!.path, height: 200)
                      : Image.file(File(_selectedImage!.path), height: 200),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createOrUpdateProperty,
          child: Text(
              widget.property != null ? 'Update Property' : 'Add Property'),
        ),
      ],
    );
  }
}
