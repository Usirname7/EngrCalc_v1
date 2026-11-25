import 'package:flutter/material.dart';
import '../core/math_engine.dart';
import '../services/local_data.dart';
class Home extends StatefulWidget{const Home({super.key});@override State<Home> createState()=>_HomeState();}
class _HomeState extends State<Home>{
 int tab=0;final pages=const [CalcPage(),ConvertPage(),ToolsPage(),DataPage()];
 @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('EngrCalc_v1')),
 body:pages[tab],bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(v)=>setState(()=>tab=v),destinations:const[
 NavigationDestination(icon:Icon(Icons.calculate),label:'Calculator'),NavigationDestination(icon:Icon(Icons.swap_horiz),label:'Convert'),NavigationDestination(icon:Icon(Icons.architecture),label:'Tools'),NavigationDestination(icon:Icon(Icons.storage),label:'Data')]));
}
class CalcPage extends StatefulWidget{const CalcPage({super.key});@override State<CalcPage> createState()=>_CalcPageState();}
class _CalcPageState extends State<CalcPage>{
 final a=TextEditingController(),b=TextEditingController();String op='+',out='';
 void run(){try{final x=MathEngine.number(a.text),y=MathEngine.number(b.text);final r=switch(op){'+'=>x+y,'−'=>x-y,'×'=>x*y,'÷'=>y==0?throw const FormatException('Division by zero'):x/y,_=>0.0};setState(()=>out=MathEngine.fmt(r,8));}catch(e){setState(()=>out=e.toString());}}
 @override void dispose(){a.dispose();b.dispose();super.dispose();}
 @override Widget build(BuildContext c)=>ListView(padding:const EdgeInsets.all(16),children:[
 const Text('Fraction-aware construction calculator',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),const SizedBox(height:12),
 TextField(controller:a,keyboardType:const TextInputType.numberWithOptions(decimal:true,signed:true),decoration:const InputDecoration(labelText:'First value (e.g. 3 1/2)')),
 const SizedBox(height:12),SegmentedButton<String>(segments:const[ButtonSegment(value:'+',label:Text('+')),ButtonSegment(value:'−',label:Text('−')),ButtonSegment(value:'×',label:Text('×')),ButtonSegment(value:'÷',label:Text('÷'))],selected:{op},onSelectionChanged:(s)=>setState(()=>op=s.first)),
 const SizedBox(height:12),TextField(controller:b,keyboardType:const TextInputType.numberWithOptions(decimal:true,signed:true),decoration:const InputDecoration(labelText:'Second value')),
 const SizedBox(height:12),FilledButton(onPressed:run,child:const Text('Calculate')),const SizedBox(height:20),SelectableText(out.isEmpty?'Result appears here':out,style:const TextStyle(fontSize:24))]);}
class ConvertPage extends StatefulWidget{const ConvertPage({super.key});@override State<ConvertPage> createState()=>_ConvertPageState();}
class _ConvertPageState extends State<ConvertPage>{
 final v=TextEditingController(text:'1');String from='ft',to='in',out='';final units=const['in','ft','yd','mm','cm','m','km'];
 @override Widget build(BuildContext c)=>ListView(padding:const EdgeInsets.all(16),children:[const Text('Length conversion',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),const SizedBox(height:12),
 TextField(controller:v,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Value')),
 const SizedBox(height:12),DropdownButtonFormField(value:from,items:units.map((u)=>DropdownMenuItem(value:u,child:Text(u))).toList(),onChanged:(x)=>setState(()=>from=x!)),
 const SizedBox(height:12),DropdownButtonFormField(value:to,items:units.map((u)=>DropdownMenuItem(value:u,child:Text(u))).toList(),onChanged:(x)=>setState(()=>to=x!)),
 const SizedBox(height:12),FilledButton(onPressed:(){try{setState(()=>out=MathEngine.fmt(MathEngine.length(MathEngine.number(v.text),from,to),8));}catch(e){setState(()=>out=e.toString());}},child:const Text('Convert')),
 const SizedBox(height:16),SelectableText(out,style:const TextStyle(fontSize:22))]);}
class ToolsPage extends StatefulWidget{const ToolsPage({super.key});@override State<ToolsPage> createState()=>_ToolsPageState();}
class _ToolsPageState extends State<ToolsPage>{
 final a=TextEditingController(),b=TextEditingController(),d=TextEditingController();String tool='Concrete volume (yd³)',out='';
 final tools=const['Concrete volume (yd³)','Board feet','Cylinder volume','Ohm voltage','Ohm current','Ohm resistance','Electrical power','Slope percent'];
 void run(){try{final x=MathEngine.number(a.text),y=MathEngine.number(b.text),z=d.text.trim().isEmpty?0.0:MathEngine.number(d.text);
 final r=switch(tool){'Concrete volume (yd³)'=>MathEngine.concreteYards(x,y,z),'Board feet'=>MathEngine.boardFeet(x,y,z),'Cylinder volume'=>MathEngine.cylinder(x,y),'Ohm voltage'=>MathEngine.volts(x,y),'Ohm current'=>MathEngine.amps(x,y),'Ohm resistance'=>MathEngine.ohms(x,y),'Electrical power'=>MathEngine.power(x,y),'Slope percent'=>MathEngine.slope(x,y),_=>0.0};
 setState(()=>out=MathEngine.fmt(r)+(tool=='Concrete volume (yd³)'?' yd³':tool=='Board feet'?' bd ft':tool=='Slope percent'?'%':''));}catch(e){setState(()=>out=e.toString());}}
 @override Widget build(BuildContext c)=>ListView(padding:const EdgeInsets.all(16),children:[const Text('Engineering tools',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),const SizedBox(height:12),
 DropdownButtonFormField(value:tool,isExpanded:true,items:tools.map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(x)=>setState(()=>tool=x!)),
 const SizedBox(height:12),TextField(controller:a,decoration:const InputDecoration(labelText:'Input A')),const SizedBox(height:12),TextField(controller:b,decoration:const InputDecoration(labelText:'Input B')),const SizedBox(height:12),TextField(controller:d,decoration:const InputDecoration(labelText:'Input C (if needed)')),
 const SizedBox(height:12),FilledButton(onPressed:run,child:const Text('Calculate')),const SizedBox(height:16),SelectableText(out,style:const TextStyle(fontSize:22)),
 const SizedBox(height:12),const Text('Confirm units and assumptions. Do not use as a substitute for code-compliant engineering review.')]);}
class DataPage extends StatefulWidget{const DataPage({super.key});@override State<DataPage> createState()=>_DataPageState();}
class _DataPageState extends State<DataPage>{
 String status='Local reference databases are bundled when recovered.';dynamic data;
 Future<void> load()async{try{final x=await LocalData.materials();setState(()=>{data=x,status='Material data loaded.'});}catch(e){setState(()=>status='Could not load material data: $e');}}
 @override Widget build(BuildContext c)=>ListView(padding:const EdgeInsets.all(16),children:[const Text('Offline reference library',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),const SizedBox(height:12),Text(status),const SizedBox(height:12),FilledButton(onPressed:load,child:const Text('Load material weight data')),if(data!=null)SelectableText(data.toString()),const SizedBox(height:12),const Text('Steel shape reference data is included as a local file where recovered; searchable schema integration is still pending.')]);}
