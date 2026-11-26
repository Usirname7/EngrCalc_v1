import 'dart:math';

class MathEngine {
  static double number(String raw) {
    var s = raw.trim().replaceAll(',', '').replaceAll('−', '-')
        .replaceAll('′', "'").replaceAll('″', '"').toLowerCase();
    if (s.isEmpty) throw const FormatException('Enter a value');

    // Feet plus inches, including a fractional inch: 5' 3 1/2", 5 ft 3 in.
    final feetInches = RegExp(
      r'''^([+-]?\d+(?:\.\d+)?)\s*(?:'|ft|feet)\s*(?:(\d+(?:\.\d+)?)\s*(?:"|in|inches?)\s*)?(?:(\d+)\s*/\s*(\d+))?$'''
    ).firstMatch(s);
    if (feetInches != null) {
      final feet = double.parse(feetInches.group(1)!);
      final inches = double.tryParse(feetInches.group(2) ?? '0') ?? 0;
      final n = double.tryParse(feetInches.group(3) ?? '0') ?? 0;
      final d = double.tryParse(feetInches.group(4) ?? '1') ?? 1;
      if (d == 0) throw const FormatException('Zero denominator');
      final total = feet.abs() * 12 + inches + n / d;
      return feet < 0 ? -total : total;
    }

    final mixed = RegExp(r'^([+-]?\d+(?:\.\d+)?)\s+(\d+)\s*/\s*(\d+)$').firstMatch(s);
    if (mixed != null) {
      final whole = double.parse(mixed.group(1)!);
      final n = double.parse(mixed.group(2)!);
      final d = double.parse(mixed.group(3)!);
      if (d == 0) throw const FormatException('Zero denominator');
      return whole < 0 ? whole - n / d : whole + n / d;
    }

    final fraction = RegExp(r'^([+-]?\d+)\s*/\s*(\d+)$').firstMatch(s);
    if (fraction != null) {
      final d = double.parse(fraction.group(2)!);
      if (d == 0) throw const FormatException('Zero denominator');
      return double.parse(fraction.group(1)!) / d;
    }

    final value = double.tryParse(s.replaceAll(RegExp(r'\s*(in|inch|inches)$'), ''));
    if (value == null || !value.isFinite) throw const FormatException('Invalid number');
    return value;
  }

  static String fmt(double value, [int places = 4]) =>
      value.isFinite ? double.parse(value.toStringAsFixed(places)).toString() : '—';

  static String feetInches(double inches, {int denominator = 16}) {
    if (denominator <= 0) throw const FormatException('Denominator must be positive');
    final sign = inches < 0 ? '-' : '';
    final value = inches.abs();
    var feet = (value / 12).floor();
    var whole = (value - feet * 12).floor();
    var numerator = ((value - feet * 12 - whole) * denominator).round();
    if (numerator == denominator) { whole++; numerator = 0; }
    if (whole == 12) { feet++; whole = 0; }
    if (numerator == 0) return '$sign$feet\' $whole"';
    int gcd(int a, int b) => b == 0 ? a : gcd(b, a % b);
    final divisor = gcd(numerator, denominator);
    return '$sign$feet\' $whole ${numerator ~/ divisor}/${denominator ~/ divisor}"';
  }

  static const Map<String, double> lengthToInches = {
    'in': 1.0, 'ft': 12.0, 'yd': 36.0, 'mm': 1 / 25.4,
    'cm': 1 / 2.54, 'm': 100 / 2.54, 'km': 100000 / 2.54,
  };

  static double length(double value, String from, String to) {
    final fromFactor = lengthToInches[from], toFactor = lengthToInches[to];
    if (fromFactor == null || toFactor == null) {
      throw const FormatException('Unsupported length unit');
    }
    return value * fromFactor / toFactor;
  }

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

  // Electrical helpers and compatibility names used by the Tools screen.
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
  static double cylinder(double diameter, double length) => cylinderVolume(diameter, length);
  static double slope(double rise, double run) => slopePercent(rise, run);
}
