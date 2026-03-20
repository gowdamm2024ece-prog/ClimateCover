// lib/models/disruption.dart
class DisruptionEvent {
  final String id;
  final String type;
  final String severity;
  final String city;
  final DateTime startedAt;
  final DateTime? endedAt;
  final double rainfallMm;
  final bool isActive;

  const DisruptionEvent({
    required this.id,
    required this.type,
    required this.severity,
    required this.city,
    required this.startedAt,
    this.endedAt,
    required this.rainfallMm,
    required this.isActive,
  });

  String get typeLabel {
    switch (type) {
      case 'heavy_rain':   return 'Heavy Rain';
      case 'flood':        return 'Flood Alert';
      case 'severe_aqi':  return 'Severe Pollution';
      case 'extreme_heat': return 'Extreme Heat';
      case 'curfew':       return 'Curfew';
      default:             return type;
    }
  }

  factory DisruptionEvent.fromJson(Map<String, dynamic> json) =>
      DisruptionEvent(
        id:         json['id'],
        type:       json['disruption_type'],
        severity:   json['severity'],
        city:       json['affected_city'],
        startedAt:  DateTime.parse(json['started_at']),
        endedAt:    json['ended_at'] != null
                        ? DateTime.parse(json['ended_at'])
                        : null,
        rainfallMm: (json['trigger_data']?['rainfall_mm'] ?? 0).toDouble(),
        isActive:   json['ended_at'] == null,
      );
}