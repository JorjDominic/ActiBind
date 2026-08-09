import 'package:flutter/material.dart';

class ChildProfile {
  const ChildProfile({
    required this.name,
    required this.device,
    required this.screenTime,
    required this.initials,
    required this.color,
    this.connected = true,
    this.restrictionsActive = true,
  });

  final String name;
  final String device;
  final String screenTime;
  final String initials;
  final Color color;
  final bool connected;
  final bool restrictionsActive;
}

const mockChildren = [
  ChildProfile(
    name: 'Alex',
    device: 'Samsung Galaxy A54',
    screenTime: '2h 14m',
    initials: 'A',
    color: Color(0xFF5B5CE2),
  ),
  ChildProfile(
    name: 'Mia',
    device: 'Same device profile',
    screenTime: '1h 08m',
    initials: 'M',
    color: Color(0xFF12A594),
    connected: false,
  ),
];
