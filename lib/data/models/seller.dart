class Seller {
  final int? id;
  final String name;
  final String shortCode;
  final bool isActive;

  const Seller({
    this.id,
    required this.name,
    required this.shortCode,
    this.isActive = true,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Seller copyWith({
    int? id,
    String? name,
    String? shortCode,
    bool? isActive,
  }) {
    return Seller(
      id: id ?? this.id,
      name: name ?? this.name,
      shortCode: shortCode ?? this.shortCode,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'short_code': shortCode,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Seller.fromMap(Map<String, dynamic> map) {
    return Seller(
      id: map['id'] as int?,
      name: map['name'] as String,
      shortCode: map['short_code'] as String,
      isActive: (map['is_active'] as int) == 1,
    );
  }
}
