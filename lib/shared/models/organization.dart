class Organization {
  const Organization({
    required this.id,
    required this.name,
    this.logoUrl,
  });

  final String id;
  final String name;
  final String? logoUrl;

  factory Organization.fromMap(Map<String, dynamic> map) {
    return Organization(
      id: map['id'] as String,
      name: map['name'] as String,
      logoUrl: map['logo_url'] as String?,
    );
  }
}
