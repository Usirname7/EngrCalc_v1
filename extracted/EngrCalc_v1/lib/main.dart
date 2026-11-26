import 'dart:math';

class MathEngine {
  /// Parses numbers, fractions, mixed numbers, and feet-inches strings.
  /// Examples: "5", "5.25", "1/2", "3 1/4", "5' 3 1/2\"", "5 ft 3.5 in", "5-3-8"
  static double number(String raw) {
    var s = raw.trim().replaceAll(',', '').toLowerCase();
    if (s.isEmpty) throw const FormatException('Enter a value');

    // Feet-inches patterns
    final fi = RegExp(
      r'''^(?:([+-]?\d+(?:\.\d+)?)\s*(?:'|ft|feet)\s*)?(?:(\d+(?:\.\d+)?)\s*(?:"|in|inches?))?(?:\s+(\d+)\s*/\s*(\d+))?$'''
    ).firstMatch(s.replaceAll('″', '"').replaceAll('′', "'"));
    if (fi != null && (fi.group(1) != null || fi.group(2) != null)) {
      final feet = double.tryParse(fi.group(1) ?? '0') ?? 0;
      final inches = double.tryParse(fi.group(2) ?? '0') ?? 0;
      final num = double.tryParse(fi.group(3) ?? '0') ?? 0;
      final den = double.tryParse(fi.group(4) ?? '1') ?? 1;
      if (den == 0) throw const FormatException('Zero denominator');
      return (feet * 12) + inches + (num / den);
    }

    // Mixed number: "3 1/2"
    final mixed = RegExp(r'^([+-]?\d+(?:\.\d+)?)\s+(\d+)\s*/\s*(\d+)$').firstMatch(s);
    if (mixed != null) {
      final whole = double.parse(mixed.group(1)!);
      final n = double.parse(mixed.group(2)!);
      final d = double.parse(mixed.group(3)!);
      if (d == 0) throw const FormatException('Zero denominator');
      return whole < 0 ? whole - n / d : whole + n / d;
    }

    // Simple fraction
    final frac = RegExp(r'^([+-]?\d+)\s*/\s*(\d+)$').firstMatch(s);
    if (frac != null) {
      final d = double.parse(frac.group(2)!);
      if (d == 0) throw const FormatException('Zero denominator');
      return double.parse(frac.group(1)!) / d;
    }

    final value = double.tryParse(s);
    if (value == null || !value.isFinite) throw const FormatException('Invalid number');
    return value;
  }

  static String fmt(double value, [int places = 4]) =>
      value.isFinite ? double.parse(value.toStringAsFixed(places)).toString() : '—';

  /// Converts inches → feet-inches-fraction string (e.g. 63.5 → "5′ 3 1/2″")
  static String feetInches(double inches, {int denominator = 16}) {
    if (denominator <= 0) throw const FormatException('Denominator must be positive');
    final sign = inches < 0 ? '−' : '';
    var value = inches.abs();
    var feet = (value / 12).floor();
    var wholeInches = (value - feet * 12).floor();
    var numerator = ((value - feet * 12 - wholeInches) * denominator).round();
    if (numerator == denominator) {
      wholeInches++;
      numerator = 0;
    }
    if (wholeInches == 12) {
      feet++;
      wholeInches = 0;
    }
    if (numerator == 0) return '$sign$feet′ $wholeInches″';
    int gcd(int a, int b) => b == 0 ? a : gcd(b, a % b);
    final g = gcd(numerator, denominator);
    return '$sign$feet′ $wholeInches ${numerator ~/ g}/${denominator ~/ g}″';
  }

  static const Map<String, double> lengthToInches = {
    'in': 1.0,
    'ft': 12.0,
    'yd': 36.0,
    'mm': 0.0393701,
    'cm': 0.393701,
    'm': 39.3701,
    'km': 39370.1,
  };

  static double length(double value, String from, String to) {
    if (!lengthToInches.containsKey(from) || !lengthToInches.containsKey(to)) {
      throw const FormatException('Unsupported length unit');
    }
    return value * lengthToInches[from]! / lengthToInches[to]!;
  }

  // Friendly construction helpers (all in common units)
  static double boardFeet(double thicknessIn, double widthIn, double lengthFt) =>
      thicknessIn * widthIn * lengthFt / 12;

  static double concreteYards(double lengthFt, double widthFt, double thicknessIn) =>
      lengthFt * widthFt * thicknessIn / 324;

  static double cylinderVolume(double diameter, double length) =>
      pi * pow(diameter / 2, 2) * length;

  static double slopePercent(double rise, double run) {
    if (run == 0) throw const FormatException('Run cannot be zero');
    return 100 * rise / run;
  }
}
