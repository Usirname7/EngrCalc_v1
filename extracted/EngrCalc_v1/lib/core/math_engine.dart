import 'dart:math';

class MathEngine {
  static double number(String raw) {
    final s = raw.trim().replaceAll(',', '');
    if (s.isEmpty) throw const FormatException('Enter a value');
    final mixed = RegExp(r'^([+-]?\d+(?:\.\d+)?)\s+(\d+)\s*/\s*(\d+)$').firstMatch(s);
    if (mixed != null) {
      final whole = double.parse(mixed[1]!);
      final numerator = double.parse(mixed[2]!);
      final denominator = double.parse(mixed[3]!);
      if (denominator == 0) throw const FormatException('Zero denominator');
      return whole < 0 ? whole - numerator / denominator : whole + numerator / denominator;
    }
    final fraction = RegExp(r'^([+-]?\d+)\s*/\s*(\d+)$').firstMatch(s);
    if (fraction != null) {
      final denominator = double.parse(fraction[2]!);
      if (denominator == 0) throw const FormatException('Zero denominator');
      return double.parse(fraction[1]!) / denominator;
    }
    final value = double.tryParse(s);
    if (value == null || !value.isFinite) throw const FormatException('Invalid number');
    return value;
  }
  static String fmt(double value, [int places = 4]) =>
      value.isFinite ? double.parse(value.toStringAsFixed(places)).toString() : '—';
  static double concreteYards(double lengthFt, double widthFt, double thicknessIn) =>
      lengthFt * widthFt * thicknessIn / 324;
  static double boardFeet(double thicknessIn, double widthIn, double lengthFt) =>
      thicknessIn * widthIn * lengthFt / 12;
  static double cylinder(double diameter, double length) => pi * pow(diameter / 2, 2) * length;
  static double slope(double rise, double run) {
    if (run == 0) throw const FormatException('Run cannot be zero');
    return 100 * rise / run;
  }
  static double volts(double amps, double ohms) => amps * ohms;
  static double amps(double volts, double ohms) {
    if (ohms == 0) throw const FormatException('Resistance cannot be zero');
    return volts / ohms;
  }
  static double ohms(double volts, double amps) {
    if (amps == 0) throw const FormatException('Current cannot be zero');
    return volts / amps;
  }
  static double power(double volts, double amps) => volts * amps;
  static const Map<String, double> lengthMeters = {
    'in': 0.0254, 'ft': 0.3048, 'yd': 0.9144,
    'mm': 0.001, 'cm': 0.01, 'm': 1.0, 'km': 1000.0,
  };
  static double length(double value, String from, String to) {
    if (!lengthMeters.containsKey(from) || !lengthMeters.containsKey(to)) {
      throw const FormatException('Unsupported length unit');
    }
    return value * lengthMeters[from]! / lengthMeters[to]!;
  }
  static String feetInches(double inches, {int denominator = 16}) {
    if (denominator <= 0) throw const FormatException('Denominator must be positive');
    final sign = inches < 0 ? '−' : '';
    final value = inches.abs();
    var feet = (value / 12).floor();
    var wholeInches = (value - feet * 12).floor();
    var numerator = ((value - feet * 12 - wholeInches) * denominator).round();
    if (numerator == denominator) { wholeInches++; numerator = 0; }
    if (wholeInches == 12) { feet++; wholeInches = 0; }
    if (numerator == 0) return '$sign$feet′ $wholeInches″';
    int gcd(int a, int b) => b == 0 ? a : gcd(b, a % b);
    final divisor = gcd(numerator, denominator);
    return '$sign$feet′ $wholeInches \${numerator ~/ divisor}/\${denominator ~/ divisor}″';
  }
}
