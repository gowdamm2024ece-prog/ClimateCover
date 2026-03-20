// lib/models/worker.dart
class Worker {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String platform;
  final String city;
  final String pincode;
  final bool aadhaarVerified;
  final String upiId;
  final double riskScore;
  final String zoneRiskLevel;
  final DateTime joinedAt;

  const Worker({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.platform,
    required this.city,
    required this.pincode,
    required this.aadhaarVerified,
    required this.upiId,
    required this.riskScore,
    required this.zoneRiskLevel,
    required this.joinedAt,
  });

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}';

  // TODO: replace with fromJson(Map<String,dynamic> json) when backend ready
  factory Worker.fromJson(Map<String, dynamic> json) => Worker(
    id: json['id'],
    firstName: json['first_name'],
    lastName: json['last_name'],
    phone: json['phone_number'],
    platform: json['platform'],
    city: json['city'],
    pincode: json['pincode'],
    aadhaarVerified: json['aadhaar_verified'],
    upiId: json['upi_id'] ?? '',
    riskScore: (json['risk_score'] ?? 0.5).toDouble(),
    zoneRiskLevel: json['zone_risk_level'] ?? 'medium',
    joinedAt: DateTime.parse(json['created_at']),
  );
}