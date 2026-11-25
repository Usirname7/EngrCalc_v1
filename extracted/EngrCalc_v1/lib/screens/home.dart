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
class CalcPage extends StatefulWidget {
  const CalcPage({super.key});
  @override State<CalcPage> createState() => _CalcPageState();
}
class _CalcPageState extends State<CalcPage> {
  final first = TextEditingController();
  final second = TextEditingController();
  late TextEditingController active = first;
  String operation = '+', sourceUnit = 'in', displayUnit = 'in', result = '';
  String? error;
  double? resultValue;
  bool resultIsLength = true;
  static const units = ['in', 'ft', 'yd', 'mm', 'cm', 'm', 'km'];
  static const operations = ['+', '−', '× number', '× dimension', '÷ number', '÷ dimension'];

  @override void dispose() { first.dispose(); second.dispose(); super.dispose(); }

  void append(String value) {
    setState(() {
      final text = active.text;
      final selection = active.selection;
      final start = selection.start < 0 ? text.length : selection.start;
      final end = selection.end < 0 ? text.length : selection.end;
      active.value = TextEditingValue(
        text: text.replaceRange(start, end, value),
        selection: TextSelection.collapsed(offset: start + value.length),
      );
      error = null;
    });
  }

  void backspace() {
    setState(() {
      final text = active.text;
      if (text.isEmpty) return;
      final end = active.selection.end < 0 ? text.length : active.selection.end;
      final start = active.selection.start < 0 ? end : active.selection.start;
      final from = start == end && start > 0 ? start - 1 : start;
      active.value = TextEditingValue(text: text.replaceRange(from, end, ''),
        selection: TextSelection.collapsed(offset: from));
    });
  }

  Future<void> addFraction() async {
    final n = TextEditingController(text: '1'), d = TextEditingController(text: '2');
    final fraction = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Insert fraction'),
      content: Row(children: [
        Expanded(child: TextField(controller: n, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Numerator'))),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('/')),
        Expanded(child: TextField(controller: d, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Denominator'))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () {
          final numerator = int.tryParse(n.text), denominator = int.tryParse(d.text);
          if (numerator != null && denominator != null && denominator != 0) {
            Navigator.pop(ctx, '$numerator/$denominator');
          }
        }, child: const Text('Insert')),
      ],
    ));
    n.dispose(); d.dispose();
    if (fraction != null) append((active.text.trim().isEmpty ? '' : ' ') + fraction);
  }

  void updateResult() {
    final value = resultValue;
    if (value == null) return;
    final converted = resultIsLength ? MathEngine.length(value, sourceUnit, displayUnit) : value;
    setState(() => result = MathEngine.fmt(converted, 8) +
      (resultIsLength ? ' $displayUnit' : ' $sourceUnit²'));
  }

  void calculate() {
    try {
      final a = MathEngine.number(first.text), b = MathEngine.number(second.text);
      late double value; late bool isLength;
      switch (operation) {
        case '+': value = a + b; isLength = true; break;
        case '−': value = a - b; isLength = true; break;
        case '× number': value = a * b; isLength = true; break;
        case '× dimension': value = a * b; isLength = false; break;
        case '÷ number':
          if (b == 0) throw const FormatException('Division by zero');
          value = a / b; isLength = true; break;
        case '÷ dimension':
          if (b == 0) throw const FormatException('Division by zero');
          value = a / b; isLength = false; break;
        default: throw const FormatException('Choose an operation');
      }
      setState(() { resultValue = value; resultIsLength = isLength; error = null; });
      updateResult();
    } catch (e) { setState(() { resultValue = null; result = ''; error = e.toString(); }); }
  }

  Widget key(String label, VoidCallback? action, {int flex = 1}) => Expanded(
    flex: flex, child: Padding(padding: const EdgeInsets.all(3),
      child: SizedBox(height: 50, child: FilledButton.tonal(
        onPressed: action, child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))))));

  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(14), children: [
    const Text('Measurement calculator', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
    const SizedBox(height: 6), const Text('Select a line, enter a measurement, then choose an operation.'),
    const SizedBox(height: 12),
    DropdownButtonFormField<String>(value: sourceUnit, decoration: const InputDecoration(labelText: 'Input measurement unit'),
      items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
      onChanged: (u) => setState(() { sourceUnit = u!; displayUnit = u; if (resultValue != null) updateResult(); })),
    const SizedBox(height: 10),
    TextField(controller: first, readOnly: true, onTap: () => setState(() => active = first),
      decoration: InputDecoration(labelText: 'Measurement 1 ($sourceUnit)', border: const OutlineInputBorder(),
        suffixIcon: IconButton(onPressed: first.clear, icon: const Icon(Icons.clear)))),
    const SizedBox(height: 10),
    SegmentedButton<String>(segments: operations.map((op) => ButtonSegment(value: op, label: Text(op))).toList(),
      selected: {operation}, onSelectionChanged: (s) => setState(() => operation = s.first), showSelectedIcon: false),
    const SizedBox(height: 10),
    TextField(controller: second, readOnly: true, onTap: () => setState(() => active = second),
      decoration: InputDecoration(labelText: 'Measurement 2 / multiplier ($sourceUnit)', border: const OutlineInputBorder(),
        suffixIcon: IconButton(onPressed: second.clear, icon: const Icon(Icons.clear)))),
    const SizedBox(height: 8),
    Row(children: [key('7', () => append('7')), key('8', () => append('8')), key('9', () => append('9')), key('⌫', backspace)]),
    Row(children: [key('4', () => append('4')), key('5', () => append('5')), key('6', () => append('6')), key('C', () => setState(() { active.clear(); error = null; }))]),
    Row(children: [key('1', () => append('1')), key('2', () => append('2')), key('3', () => append('3')), key('Fraction', addFraction)]),
    Row(children: [key('0', () => append('0')), key('.', () => append('.')), key('±', () => append('-')), key('Calculate', calculate, flex: 2)]),
    const SizedBox(height: 12),
    if (resultValue != null && resultIsLength) DropdownButtonFormField<String>(
      value: displayUnit, decoration: const InputDecoration(labelText: 'Display result in'),
      items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
      onChanged: (u) { setState(() => displayUnit = u!); updateResult(); }),
    const SizedBox(height: 10),
    Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Result', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 6),
        SelectableText(error ?? (result.isEmpty ? 'Enter values and calculate' : result),
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w600)),
      ])),
  ]);
}

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
