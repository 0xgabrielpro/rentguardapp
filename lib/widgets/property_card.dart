import 'package:flutter/material.dart';
import 'package:rentguard/models/property.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onViewPressed;

  const PropertyCard({required this.property, required this.onViewPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(property.image, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.location,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Price: \$${property.price}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  property.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    child: Text('View'),
                    onPressed: onViewPressed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
