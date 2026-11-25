import 'package:flutter/material.dart';
import 'screens/home.dart';
void main(){ WidgetsFlutterBinding.ensureInitialized(); runApp(const EngrCalc()); }
class EngrCalc extends StatelessWidget {
 const EngrCalc({super.key});
 @override Widget build(BuildContext context)=>MaterialApp(
  title:'EngrCalc_v1',debugShowCheckedModeBanner:false,
  theme:ThemeData(colorScheme:ColorScheme.fromSeed(seedColor:const Color(0xff155a75)),useMaterial3:true),
  home:const Home());
}
