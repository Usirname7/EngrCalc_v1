import 'dart:math';
class MathEngine {
 static double number(String raw){
  final s=raw.trim().replaceAll(',','');
  if(s.isEmpty) throw const FormatException('Enter a value');
  final m=RegExp(r'^([+-]?\d+(?:\.\d+)?)\s+(\d+)\s*/\s*(\d+)$').firstMatch(s);
  if(m!=null){final w=double.parse(m[1]!);final n=double.parse(m[2]!);final d=double.parse(m[3]!);if(d==0)throw const FormatException('Zero denominator');return w<0?w-n/d:w+n/d;}
  final f=RegExp(r'^([+-]?\d+)\s*/\s*(\d+)$').firstMatch(s);
  if(f!=null){final d=double.parse(f[2]!);if(d==0)throw const FormatException('Zero denominator');return double.parse(f[1]!)/d;}
  final v=double.tryParse(s);if(v==null||!v.isFinite)throw const FormatException('Invalid number');return v;
 }
 static String fmt(double x,[int places=4])=>x.isFinite?double.parse(x.toStringAsFixed(places)).toString():'—';
 static double concreteYards(double lFt,double wFt,double thickIn)=>lFt*wFt*thickIn/324;
 static double boardFeet(double thickIn,double widthIn,double lengthFt)=>thickIn*widthIn*lengthFt/12;
 static double cylinder(double diameter,double length)=>pi*pow(diameter/2,2)*length;
 static double slope(double rise,double run){if(run==0)throw const FormatException('Run cannot be zero');return 100*rise/run;}
 static double volts(double amps,double ohms)=>amps*ohms;
 static double amps(double volts,double ohms){if(ohms==0)throw const FormatException('Resistance cannot be zero');return volts/ohms;}
 static double ohms(double volts,double amps){if(amps==0)throw const FormatException('Current cannot be zero');return volts/amps;}
 static double power(double volts,double amps)=>volts*amps;
 static double length(double v,String from,String to){
  const m={'in':.0254,'ft':.3048,'yd':.9144,'mm':.001,'cm':.01,'m':1.0,'km':1000.0};
  if(!m.containsKey(from)||!m.containsKey(to))throw const FormatException('Unsupported length unit');
  return v*m[from]!/m[to]!;
 }
 static String feetInches(double inches,{int denominator=16}){
  final sign=inches<0?'-':'';final x=inches.abs();var ft=(x/12).floor();var whole=(x-ft*12).floor();var n=((x-ft*12-whole)*denominator).round();
  if(n==denominator){whole++;n=0;}if(whole==12){ft++;whole=0;}
  if(n==0)return '$sign$ft\\' $whole"';
  int gcd(int a,int b)=>b==0?a:gcd(b,a%b);final g=gcd(n,denominator);
  return '$sign$ft\\' $whole ${n~/g}/${denominator~/g}"';
 }
}
