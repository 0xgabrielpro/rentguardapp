class Property {
  final int id;
  final String location;
  final double price;
  final String description;
  final String image;
  final int ownerId;
  final String ownerPhone;

  Property({
    required this.id,
    required this.location,
    required this.price,
    required this.description,
    required this.image,
    required this.ownerId,
    required this.ownerPhone,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] ?? 0,
      location: json['location'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      ownerId: json['owner_id'] ?? 0,
      ownerPhone: json['owner_phone'] ?? '',
    );
  }
}
