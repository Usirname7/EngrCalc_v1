import 'package:flutter_test/flutter_test.dart';
import 'package:engr_calc_v1/core/math_engine.dart';
void main(){
 test('mixed fraction parser',(){expect(MathEngine.number('3 1/2'),3.5);expect(MathEngine.number('7/8'),closeTo(.875,1e-9));});
 test('concrete conversion',(){expect(MathEngine.concreteYards(27,10,4),closeTo(3.333333,1e-5));});
 test('Ohm law',(){expect(MathEngine.volts(2,12),24);});
}
