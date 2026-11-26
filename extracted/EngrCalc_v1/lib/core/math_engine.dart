import 'dart:math';

class MathEngine {
  static double number(String raw) {
    var s = raw.trim().replaceAll(',', '').toLowerCase();
    if (s.isEmpty) throw const FormatException('Enter a value');
    s = s.replaceAll('′', "'").replaceAll('″', '"').replaceAll('−', '-');

    final feet = RegExp(r"([+-]?\d+(?:\.\d+)?)\s*(?:'|ft)").firstMatch(s);
    final inch = RegExp(r'([+-]?\d+(?:\.\d+)?)\s*(?:"|in)').firstMatch(s);
    final frac = RegExp(r'(\d+)\s*/\s*(\d+)').firstMatch(s);

    if (feet != null || inch != null || frac != null) {
      double total = 0;
      if (feet != null) total += double.parse(feet.group(1)!) * 12;
      if (inch != null) total += double.parse(inch.group(1)!);
      if (frac != null) {
        final n = double.parse(frac.group(1)!);
        final d = double.parse(frac.group(2)!);
        if (d == 0) throw const FormatException('Zero denominator');
        total += n / d;
      }
      return total;
    }

    final mixed = RegExp(r'^([+-]?\d+(?:\.\d+)?)\s+(\d+)\s*/\s*(\d+)$').firstMatch(s);
    if (mixed != null) {
      final whole = double.parse(mixed.group(1)!);
      final n = double.parse(mixed.group(2)!);
      final d = double.parse(mixed.group(3)!);
      if (d == 0) throw const FormatException('Zero denominator');
      return whole < 0 ? whole - n / d : whole + n / d;
    }

    final simple = RegExp(r'^([+-]?\d+)\s*/\s*(\d+)$').firstMatch(s);
    if (simple != null) {
      final d = double.parse(simple.group(2)!);
      if (d == 0) throw const FormatException('Zero denominator');
      return double.parse(simple.group(1)!) / d;
    }

    final value = double.tryParse(s);
    if (value == null || !value.isFinite) throw const FormatException('Invalid number');
    return value;
  }

  static String fmt(double value, [int places = 4]) =>
      value.isFinite ? double.parse(value.toStringAsFixed(places)).toString() : '—';

  static String feetInches(double inches, {int denominator = 16}) {
    final sign = inches < 0 ? '-' : '';
    var value = inches.abs();
    var feet = (value / 12).floor();
    var whole = (value - feet * 12).floor();
    var num = ((value - feet * 12 - whole) * denominator).round();
    if (num == denominator) { whole++; num = 0; }
    if (whole == 12) { feet++; whole = 0; }
    if (num == 0) return '${sign}${feet}\\' ${whole}"';
    int gcd(int a, int b) => b == 0 ? a : gcd(b, a % b);
    final g = gcd(num, denominator);
    return '${sign}${feet}\\' ${whole} ${num ~/ g}/${denominator ~/ g}"';
  }

  static const Map<String, double> lengthToInches = {
    'in': 1.0, 'ft': 12.0, 'yd': 36.0, 'mm': 0.0393701, 'cm': 0.393701, 'm': 39.3701,
  };

  static double length(double value, String from, String to) {
    if (!lengthToInches.containsKey(from) || !lengthToInches.containsKey(to)) {
      throw const FormatException('Unsupported length unit');
    }
    return value * lengthToInches[from]! / lengthToInches[to]!;
  }

  static double boardFeet(double t, double w, double l) => t * w * l / 12;
  static double concreteYards(double l, double w, double thick) => l * w * thick / 324;
  static double cylinderVolume(double d, double l) => pi * pow(d / 2, 2) * l;
  static double slopePercent(double rise, double run) {
    if (run == 0) throw const FormatException('Run cannot be zero');
    return 100 * rise / run;
  }
}
