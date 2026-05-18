class ClubModel {
  final String clubId;
  final String name;
  final String description;
  final String? logoUrl;

  ClubModel({
    required this.clubId,
    required this.name,
    required this.description,
    this.logoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
    };
  }

  factory ClubModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ClubModel(
      clubId: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      logoUrl: map['logoUrl'],
    );
  }
}
