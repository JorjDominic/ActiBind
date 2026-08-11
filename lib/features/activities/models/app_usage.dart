import 'dart:typed_data';

class AppUsage {
  const AppUsage({
    required this.packageName,
    required this.appName,
    required this.foreground,
    required this.lastTimeUsed,
    this.iconBytes,
  });

  final String packageName;
  final String appName;
  final Duration foreground;
  final DateTime lastTimeUsed;
  final Uint8List? iconBytes;

  factory AppUsage.fromMap(Map<Object?, Object?> map) => AppUsage(
    packageName: map['packageName'] as String,
    appName: map['appName'] as String,
    foreground: Duration(milliseconds: (map['foregroundMs'] as num).toInt()),
    lastTimeUsed: DateTime.fromMillisecondsSinceEpoch(
      (map['lastTimeUsed'] as num).toInt(),
    ),
    iconBytes: map['icon'] as Uint8List?,
  );
}
