import 'package:flutter/material.dart';

class ActibindLogo extends StatelessWidget {
  const ActibindLogo({super.key, this.size = 40, this.borderRadius = 10});

  static const darkAsset = 'assets/icons/ActiBind Logo Dark Version.png';

  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'ActiBind logo',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          darkAsset,
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
