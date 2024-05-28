import 'package:flutter/material.dart';
import 'package:rentguard/models/property.dart';
import 'package:url_launcher/url_launcher.dart';

class PropertyDetailDialog extends StatelessWidget {
  final Property property;

  const PropertyDetailDialog({
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(property.location),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(property.image),
          SizedBox(height: 10),
          Text('Price: \$${property.price}'),
          Text('Description: ${property.description}'),
          GestureDetector(
            onTap: () async {
              final Uri url = Uri(scheme: 'tel', path: property.ownerPhone);
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
            },
            child: Text('Phone: ${property.ownerPhone}',
                style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'),
        ),
      ],
    );
  }
}
