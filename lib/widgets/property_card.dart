import 'package:flutter/material.dart';
import 'package:rentguard/models/property.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onViewPressed;

  const PropertyCard({super.key, required this.property, required this.onViewPressed});

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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Price: \$${property.price}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  property.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onViewPressed,
                    child: const Text('View'),
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
