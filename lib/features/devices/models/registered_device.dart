class RegisteredDevice {
  const RegisteredDevice({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.platform,
    required this.connected,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final String type;
  final String platform;
  final bool connected;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isPc => type == 'pc';

  factory RegisteredDevice.fromJson(Map<String, dynamic> json) =>
      RegisteredDevice(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        name: json['name'] as String,
        type: json['device_type'] as String,
        platform: json['platform'] as String? ?? 'Other',
        connected: json['connected'] as bool? ?? true,
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
        updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
      );
}
