import 'package:flutter/material.dart';

class ChildProfile {
  const ChildProfile({
    required this.id,
    required this.userId,
    required this.name,
    required this.ageRange,
    required this.device,
    required this.avatarColor,
    required this.connected,
    required this.restrictionsActive,
    required this.screenTimeMinutes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final String ageRange;
  final String device;
  final int avatarColor;
  final bool connected;
  final bool restrictionsActive;
  final int screenTimeMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Color get color => Color(avatarColor);

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String get screenTime {
    final hours = screenTimeMinutes ~/ 60;
    final minutes = screenTimeMinutes % 60;
    if (hours == 0) return '${minutes}m';
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }

  factory ChildProfile.fromJson(Map<String, dynamic> json) => ChildProfile(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    name: json['name'] as String,
    ageRange: json['age_range'] as String? ?? '9-12',
    device: json['device_name'] as String? ?? 'No device linked',
    avatarColor: json['avatar_color'] as int? ?? 0xFF5B5CE2,
    connected: json['connected'] as bool? ?? false,
    restrictionsActive: json['restrictions_active'] as bool? ?? false,
    screenTimeMinutes: json['screen_time_minutes'] as int? ?? 0,
    createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
  );
}
