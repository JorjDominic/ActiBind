import 'dart:io';
import 'package:flutter/services.dart';

abstract interface class DevicePolicyService {
  Future<List<ChildModeApp>> installedApps();
  Future<DevicePolicyCapabilities> capabilities();
  Future<DevicePolicyResult> startChildMode(ChildModePolicy policy);
  Future<DevicePolicyResult> stopChildMode();
  Future<void> requestAdmin();
  Future<void> openAccessibilitySettings();
  Future<bool> launchApp(String packageName);
}

class ChildModeApp {
  const ChildModeApp({
    required this.packageName,
    required this.name,
    this.icon,
  });
  final String packageName;
  final String name;
  final Uint8List? icon;
}

class DevicePolicyCapabilities {
  const DevicePolicyCapabilities({
    required this.isDeviceOwner,
    required this.canSuspendPackages,
    this.isProfileOwner = false,
    this.isAdminActive = false,
    this.canUseLockTask = false,
    this.isInLockTask = false,
    this.isAccessibilityEnabled = false,
  });
  final bool isDeviceOwner;
  final bool canSuspendPackages;
  final bool isProfileOwner;
  final bool isAdminActive;
  final bool canUseLockTask;
  final bool isInLockTask;
  final bool isAccessibilityEnabled;
}

class ChildModePolicy {
  const ChildModePolicy({
    required this.childName,
    required this.duration,
    required this.allowedApps,
    required this.restrictedApps,
  });
  final String childName;
  final Duration duration;
  final Set<String> allowedApps;
  final Set<String> restrictedApps;
}

class DevicePolicyResult {
  const DevicePolicyResult({
    required this.applied,
    required this.message,
    this.lockTaskStarted = false,
    this.suspendedPackages = const [],
    this.failedPackages = const [],
  });
  final bool applied;
  final String message;
  final bool lockTaskStarted;
  final List<String> suspendedPackages;
  final List<String> failedPackages;
}

class UnavailableDevicePolicyService implements DevicePolicyService {
  const UnavailableDevicePolicyService();
  @override
  Future<List<ChildModeApp>> installedApps() async => const [];
  @override
  Future<DevicePolicyCapabilities> capabilities() async =>
      const DevicePolicyCapabilities(
        isDeviceOwner: false,
        canSuspendPackages: false,
      );
  @override
  Future<DevicePolicyResult> startChildMode(ChildModePolicy policy) async =>
      const DevicePolicyResult(
        applied: false,
        message: 'Child Mode policies are only available on Android.',
      );
  @override
  Future<DevicePolicyResult> stopChildMode() async => const DevicePolicyResult(
    applied: false,
    message: 'No native device policy was active.',
  );
  @override
  Future<void> requestAdmin() async {}
  @override
  Future<void> openAccessibilitySettings() async {}
  @override
  Future<bool> launchApp(String packageName) async => false;
}

class AndroidDevicePolicyService implements DevicePolicyService {
  const AndroidDevicePolicyService();
  static const _channel = MethodChannel('com.example.actibind/child_mode');
  static DevicePolicyService get supported => Platform.isAndroid
      ? const AndroidDevicePolicyService()
      : const UnavailableDevicePolicyService();

  @override
  Future<List<ChildModeApp>> installedApps() async {
    final rows = await _channel.invokeListMethod<dynamic>('installedApps');
    return (rows ?? const [])
        .map((row) => Map<String, dynamic>.from(row as Map))
        .map(
          (row) => ChildModeApp(
            packageName: row['packageName'] as String,
            name: row['name'] as String,
            icon: row['icon'] as Uint8List?,
          ),
        )
        .toList();
  }

  @override
  Future<DevicePolicyCapabilities> capabilities() async {
    final value = await _channel.invokeMapMethod<String, dynamic>(
      'capabilities',
    );
    return DevicePolicyCapabilities(
      isDeviceOwner: value?['isDeviceOwner'] == true,
      isProfileOwner: value?['isProfileOwner'] == true,
      isAdminActive: value?['isAdminActive'] == true,
      canSuspendPackages: value?['canSuspendPackages'] == true,
      canUseLockTask: value?['canUseLockTask'] == true,
      isInLockTask: value?['isInLockTask'] == true,
      isAccessibilityEnabled: value?['isAccessibilityEnabled'] == true,
    );
  }

  @override
  Future<void> requestAdmin() => _channel.invokeMethod<void>('requestAdmin');

  @override
  Future<void> openAccessibilitySettings() =>
      _channel.invokeMethod<void>('openAccessibilitySettings');

  @override
  Future<DevicePolicyResult> startChildMode(ChildModePolicy policy) async {
    try {
      final value = await _channel.invokeMapMethod<String, dynamic>('start', {
        'restrictedPackages': policy.restrictedApps.toList(),
        'allowedPackages': policy.allowedApps.toList(),
      });
      return _result(value);
    } on MissingPluginException {
      return const DevicePolicyResult(
        applied: false,
        message:
            'The Android Child Mode service is not loaded. Rebuild and reinstall ActiBind.',
      );
    } on PlatformException catch (error) {
      return DevicePolicyResult(
        applied: false,
        message: error.message ?? 'Android could not start Child Mode.',
      );
    }
  }

  @override
  Future<bool> launchApp(String packageName) async =>
      await _channel.invokeMethod<bool>('launchApp', {
        'packageName': packageName,
      }) ??
      false;

  @override
  Future<DevicePolicyResult> stopChildMode() async {
    try {
      final value = await _channel.invokeMapMethod<String, dynamic>('stop', {
        'restrictedPackages': const <String>[],
      });
      return _result(value);
    } on PlatformException catch (error) {
      return DevicePolicyResult(
        applied: false,
        message: error.message ?? 'Android could not stop Child Mode.',
      );
    }
  }

  DevicePolicyResult _result(Map<String, dynamic>? value) => DevicePolicyResult(
    applied: value?['applied'] == true,
    message: value?['message'] as String? ?? 'Unknown device-policy result.',
    lockTaskStarted: value?['lockTaskStarted'] == true,
    suspendedPackages: List<String>.from(
      value?['suspendedPackages'] as List? ?? const [],
    ),
    failedPackages: List<String>.from(
      value?['failedPackages'] as List? ?? const [],
    ),
  );
}
