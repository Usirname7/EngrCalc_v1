import 'package:flutter_test/flutter_test.dart';
import 'package:engr_calc_v1/core/math_engine.dart';

void main() {
  group('measurement parser', () {
    test('parses decimals, simple fractions and mixed fractions', () {
      expect(MathEngine.number('3.5'), 3.5);
      expect(MathEngine.number('7/8'), closeTo(.875, 1e-9));
      expect(MathEngine.number('3 1/2'), 3.5);
      expect(MathEngine.number('-3 1/2'), -3.5);
    });

    test('parses feet and inches in common formats', () {
      expect(MathEngine.number("5'"), 60);
      expect(MathEngine.number('5 ft 3 in'), 63);
      expect(MathEngine.number("5' 3 1/2\""), 63.5);
      expect(MathEngine.number('12 in'), 12);
      expect(MathEngine.number('−2.5'), -2.5);
    });

    test('rejects invalid values and zero fraction denominator', () {
      expect(() => MathEngine.number(''), throwsFormatException);
      expect(() => MathEngine.number('abc'), throwsFormatException);
      expect(() => MathEngine.number('3/0'), throwsFormatException);
    });
  });

  group('formatting and conversions', () {
    test('formats feet and inches with reduced fractions', () {
      expect(MathEngine.feetInches(63.5), "5' 3 1/2\""); 
      expect(MathEngine.feetInches(12), "1' 0\"");
      expect(MathEngine.feetInches(-6), "-0' 6\"");
    });

    test('converts between supported length units', () {
      expect(MathEngine.length(1, 'ft', 'in'), 12);
      expect(MathEngine.length(1, 'm', 'cm'), closeTo(100, 1e-8));
      expect(MathEngine.length(1, 'yd', 'ft'), closeTo(3, 1e-8));
    });
  });

  group('six calculator operations', () {
    test('addition and subtraction', () {
      expect(MathEngine.calculateMeasurement(24, 12, '+'), 36);
      expect(MathEngine.calculateMeasurement(24, 12, '−'), 12);
    });

    test('multiplication by number and by dimension', () {
      expect(MathEngine.calculateMeasurement(24, 3, '× number'), 72);
      expect(MathEngine.calculateMeasurement(24, 12, '× dimension'), 288);
      expect(MathEngine.isAreaOperation('× dimension'), isTrue);
    });

    test('division by number and by dimension', () {
      expect(MathEngine.calculateMeasurement(24, 3, '÷ number'), 8);
      expect(MathEngine.calculateMeasurement(24, 12, '÷ dimension'), 2);
      expect(MathEngine.isDimensionlessOperation('÷ dimension'), isTrue);
    });

    test('both division operations reject zero', () {
      expect(() => MathEngine.calculateMeasurement(24, 0, '÷ number'), throwsFormatException);
      expect(() => MathEngine.calculateMeasurement(24, 0, '÷ dimension'), throwsFormatException);
    });
  });

  group('engineering tool formulas', () {
    test('board feet uses 144 cubic inches per board foot', () {
      expect(MathEngine.boardFeet(1, 12, 12), 1);
      expect(MathEngine.boardFeet(2, 12, 12), 2);
    });

    test('concrete yards uses feet, feet, and inches', () {
      expect(MathEngine.concreteYards(27, 10, 4), closeTo(3.333333, 1e-5));
    });

    test('cylinder volume uses pi times radius squared times length', () {
      expect(MathEngine.cylinderVolume(2, 10), closeTo(10 * 3.141592653589793, 1e-9));
    });

    test('Ohm law and electrical power', () {
      expect(MathEngine.volts(2, 12), 24);
      expect(MathEngine.amps(24, 12), 2);
      expect(MathEngine.ohms(24, 2), 12);
      expect(MathEngine.power(24, 2), 48);
      expect(() => MathEngine.amps(24, 0), throwsFormatException);
      expect(() => MathEngine.ohms(24, 0), throwsFormatException);
    });

    test('slope percent and zero run validation', () {
      expect(MathEngine.slopePercent(1, 12), closeTo(8.333333, 1e-5));
      expect(() => MathEngine.slopePercent(1, 0), throwsFormatException);
    });
  });
}
