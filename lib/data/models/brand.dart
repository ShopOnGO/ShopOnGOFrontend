class Brand {
  final int id;
  final String name;
  final String description;
  final String logo;
  final String videoUrl;

  Brand({
    required this.id,
    required this.name,
    required this.description,
    required this.logo,
    required this.videoUrl,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['ID'] ?? json['id'] ?? 0, 
      name: json['name'] ?? 'Неизвестный бренд',
      description: json['description'] ?? '',
      logo: json['logo'] ?? '', 
      videoUrl: json['video_url'] ?? '',
    );
  }
}