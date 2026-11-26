import 'package:flutter_test/flutter_test.dart';
import 'package:engr_calc_v1/core/math_engine.dart';

void main() {
  test('parses decimal and fractions', () {
    expect(MathEngine.number('3 1/2'), 3.5);
    expect(MathEngine.number('7/8'), closeTo(.875, 1e-9));
    expect(MathEngine.number('5\' 3 1/2"'), 63.5);
    expect(MathEngine.number('5 ft 3 in'), 63);
    expect(MathEngine.number('5' + String.fromCharCode(39) + ' 3 1/2' + String.fromCharCode(34)), 63.5);
  });
  test('formats feet and inches', () {
    expect(MathEngine.feetInches(63.5), '5\' 3 1/2"');
  });
  test('length conversion', () {
    expect(MathEngine.length(1, 'ft', 'in'), 12);
    expect(MathEngine.length(1, 'm', 'cm'), closeTo(100, 1e-8));
  });
  test('concrete volume', () {
    expect(MathEngine.concreteYards(27, 10, 4), closeTo(3.333333, 1e-5));
  });
  test('Ohm law', () {
    expect(MathEngine.volts(2, 12), 24);
    expect(MathEngine.amps(24, 12), 2);
    expect(MathEngine.ohms(24, 2), 12);
  });
  test('six calculator operations', () {
    expect(MathEngine.calculateMeasurement(24, 12, '+'), 36);
    expect(MathEngine.calculateMeasurement(24, 12, '−'), 12);
    expect(MathEngine.calculateMeasurement(24, 3, '× number'), 72);
    expect(MathEngine.calculateMeasurement(24, 12, '× dimension'), 288);
    expect(MathEngine.calculateMeasurement(24, 3, '÷ number'), 8);
    expect(MathEngine.calculateMeasurement(24, 12, '÷ dimension'), 2);
    expect(MathEngine.isAreaOperation('× dimension'), isTrue);
    expect(MathEngine.isDimensionlessOperation('÷ dimension'), isTrue);
  });
  test('division by zero is rejected', () {
    expect(() => MathEngine.slopePercent(1, 0), throwsFormatException);
  });
}
