import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rentguard/services/api_services.dart';
import 'package:rentguard/models/property.dart';
import 'package:rentguard/widgets/common_input_field.dart';

class ManagePropertiesScreen extends StatefulWidget {
  @override
  _ManagePropertiesScreenState createState() => _ManagePropertiesScreenState();
}

class _ManagePropertiesScreenState extends State<ManagePropertiesScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  List<Property> _properties = [];
  bool _isLoading = false;
  bool _isEditing = false;
  int? _editingPropertyId;
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
          print('NOT FOUND');
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

  Future<void> _createOrUpdateProperty() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isEditing && _editingPropertyId != null) {
        await ApiService.updateProperty(
          _editingPropertyId!,
          _locationController.text,
          double.parse(_priceController.text),
          _descriptionController.text,
          _imageController.text,
          _ownerId!,
        );
      } else {
        await ApiService.createProperty(
          _locationController.text,
          double.parse(_priceController.text),
          _descriptionController.text,
          _imageController.text,
          _ownerId!,
        );
      }

      _clearForm();
      _fetchProperties();
    } catch (e) {
      print('Error creating/updating property');
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

  void _clearForm() {
    _locationController.clear();
    _priceController.clear();
    _descriptionController.clear();
    _imageController.clear();
    _isEditing = false;
    _editingPropertyId = null;
  }

  void _populateForm(Property property) {
    _locationController.text = property.location;
    _priceController.text = property.price.toString();
    _descriptionController.text = property.description;
    _imageController.text = property.image;
    _isEditing = true;
    _editingPropertyId = property.id;
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
                _clearForm();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Add Property'),
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
                              CommonInputField(
                                controller: _imageController,
                                labelText: 'Image URL',
                                prefixIcon: Icons.image,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an image URL';
                                  }
                                  return null;
                                },
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
                          onPressed: () {
                            _createOrUpdateProperty();
                            Navigator.of(context).pop();
                          },
                          child: Text('Add Property'),
                        ),
                      ],
                    );
                  },
                );
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
                                    _populateForm(property);
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Edit Property'),
                                          content: Form(
                                            key: _formKey,
                                            child: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  CommonInputField(
                                                    controller:
                                                        _locationController,
                                                    labelText: 'Location',
                                                    prefixIcon:
                                                        Icons.location_on,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Please enter a location';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  SizedBox(height: 10),
                                                  CommonInputField(
                                                    controller:
                                                        _priceController,
                                                    labelText: 'Price',
                                                    prefixIcon:
                                                        Icons.attach_money,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Please enter a price';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  SizedBox(height: 10),
                                                  CommonInputField(
                                                    controller:
                                                        _descriptionController,
                                                    labelText: 'Description',
                                                    prefixIcon:
                                                        Icons.description,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Please enter a description';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  SizedBox(height: 10),
                                                  CommonInputField(
                                                    controller:
                                                        _imageController,
                                                    labelText: 'Image URL',
                                                    prefixIcon: Icons.image,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Please enter an image URL';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  SizedBox(height: 10),
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
                                              onPressed: () {
                                                _createOrUpdateProperty();
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Update Property'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
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
