/// Service Model for API data
class ServiceModel {
  final String? id;
  final String title;
  final String description;
  final String? icon;
  final String? color;
  final bool? isActive;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ServiceModel({
    this.id,
    required this.title,
    required this.description,
    this.icon,
    this.color,
    this.isActive,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id'] ?? json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'],
      color: json['color'],
      isActive: json['isActive'],
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'color': color,
      'isActive': isActive,
    };
  }
}
