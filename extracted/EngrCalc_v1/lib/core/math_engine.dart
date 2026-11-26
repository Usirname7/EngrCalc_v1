import 'dart:math';

class MathEngine {
  static double number(String raw) {
    var s = raw.trim().replaceAll(',', '').toLowerCase()
      .replaceAll('′', "'").replaceAll('″', '"').replaceAll('−', '-');
    if (s.isEmpty) throw const FormatException('Enter a value');

    double parsePart(String part) {
      final cleaned = part.trim().replaceAll(RegExp(r'(inches|inch|in|")$'), '').trim();
      final mixed = RegExp(r'^([+-]?\d+(?:\.\d+)?)\s+(\d+)\s*/\s*(\d+)$').firstMatch(cleaned);
      if (mixed != null) {
        final whole = double.parse(mixed.group(1)!);
        final n = double.parse(mixed.group(2)!);
        final d = double.parse(mixed.group(3)!);
        if (d == 0) throw const FormatException('Zero denominator');
        return whole < 0 ? whole - n / d : whole + n / d;
      }
      final fraction = RegExp(r'^([+-]?\d+)\s*/\s*(\d+)$').firstMatch(cleaned);
      if (fraction != null) {
        final d = double.parse(fraction.group(2)!);
        if (d == 0) throw const FormatException('Zero denominator');
        return double.parse(fraction.group(1)!) / d;
      }
      final value = double.tryParse(cleaned);
      if (value == null || !value.isFinite) throw const FormatException('Invalid number');
      return value;
    }

    final feet = RegExp(r"^([+-]?\d+(?:\.\d+)?)\s*(?:'|ft)\s*(.*)$").firstMatch(s);
    if (feet != null) {
      final wholeFeet = double.parse(feet.group(1)!);
      final remainder = feet.group(2)!.trim();
      if (remainder.isEmpty) return wholeFeet * 12;
      final inches = parsePart(remainder);
      return wholeFeet < 0 ? wholeFeet * 12 - inches.abs() : wholeFeet * 12 + inches;
    }
    if (RegExp(r'(?:"|\bin\b)').hasMatch(s)) return parsePart(s);
    return parsePart(s);
  }

  static String fmt(double value, [int places = 4]) =>
      value.isFinite ? double.parse(value.toStringAsFixed(places)).toString() : '—';

  static String feetInches(double inches, {int denominator = 16}) {
    final sign = inches < 0 ? '-' : '';
    final value = inches.abs();
    var feet = (value / 12).floor();
    var whole = (value - feet * 12).floor();
    var num = ((value - feet * 12 - whole) * denominator).round();
    if (num == denominator) { whole++; num = 0; }
    if (whole == 12) { feet++; whole = 0; }
    if (num == 0) return "$sign$feet' $whole\"";
    int gcd(int a, int b) => b == 0 ? a : gcd(b, a % b);
    final g = gcd(num, denominator);
    return "$sign$feet' $whole ${num ~/ g}/${denominator ~/ g}\"";
  }

  static const Map<String, double> lengthToInches = {
    'in': 1.0, 'ft': 12.0, 'yd': 36.0,
    'mm': 0.0393701, 'cm': 0.393701, 'm': 39.3701, 'km': 39370.1,
  };

  static double length(double value, String from, String to) {
    if (!lengthToInches.containsKey(from) || !lengthToInches.containsKey(to)) {
      throw const FormatException('Unsupported length unit');
    }
    return value * lengthToInches[from]! / lengthToInches[to]!;
  }

  static double toInches(double value, String unit) {
    final factor = lengthToInches[unit];
    if (factor == null) throw FormatException('Unsupported length unit: $unit');
    return value * factor;
  }

  static double calculateMeasurement(double a, double b, String operation) {
    switch (operation) {
      case '+': return a + b;
      case '−': return a - b;
      case '× number': return a * b;
      case '× dimension': return a * b;
      case '÷ number':
        if (b == 0) throw const FormatException('Cannot divide by zero');
        return a / b;
      case '÷ dimension':
        if (b == 0) throw const FormatException('Cannot divide by zero');
        return a / b;
      default: throw const FormatException('Choose an operation');
    }
  }

  static bool isAreaOperation(String operation) =>
      operation == '× dimension';
  static bool isDimensionlessOperation(String operation) =>
      operation == '÷ dimension';

  // Engineering-tool calculations. Dimensional inputs for these tools are inches.
  // Board feet: thickness, width, and length are all entered in inches.
  static double boardFeet(double thickness, double width, double length) =>
      thickness * width * length / 144.0;
  static double concreteYards(double length, double width, double thickness) =>
      length * width * thickness / 324.0;
  static double cylinderVolume(double diameter, double length) =>
      (pi * pow(diameter / 2, 2) * length).toDouble();
  static double cylinder(double diameter, double length) =>
      cylinderVolume(diameter, length);
  static double volts(double current, double resistance) => current * resistance;
  static double amps(double voltage, double resistance) {
    if (resistance == 0) throw const FormatException('Resistance cannot be zero');
    return voltage / resistance;
  }
  static double ohms(double voltage, double current) {
    if (current == 0) throw const FormatException('Current cannot be zero');
    return voltage / current;
  }
  static double power(double voltage, double current) => voltage * current;
  static double slopePercent(double rise, double run) {
    if (run == 0) throw const FormatException('Run cannot be zero');
    return 100 * rise / run;
  }
  static double slope(double rise, double run) => slopePercent(rise, run);
}