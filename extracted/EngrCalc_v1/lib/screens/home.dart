import 'package:flutter/material.dart';
import '../core/math_engine.dart';
import '../services/local_data.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int tab = 0;
  final pages = const [CalcPage(), ConvertPage(), ToolsPage(), DataPage()];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('EngrCalc_v1')),
    body: pages[tab],
    bottomNavigationBar: NavigationBar(
      selectedIndex: tab,
      onDestinationSelected: (value) => setState(() => tab = value),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.calculate), label: 'Calculator'),
        NavigationDestination(icon: Icon(Icons.swap_horiz), label: 'Convert'),
        NavigationDestination(icon: Icon(Icons.architecture), label: 'Tools'),
        NavigationDestination(icon: Icon(Icons.storage), label: 'Data'),
      ],
    ),
  );
}

class CalcPage extends StatefulWidget {
  const CalcPage({super.key});
  @override
  State<CalcPage> createState() => _CalcPageState();
}

class _CalcPageState extends State<CalcPage> {
  final first = TextEditingController();
  final second = TextEditingController();
  late TextEditingController active = first;

  String operation = '+';
  String sourceUnit = 'in';
  String displayUnit = 'in';
  String result = '';
  String? error;
  double? resultInches;

  static const units = ['in', 'ft', 'yd', 'mm', 'cm', 'm'];
  static const operations = ['+', '−', '×', '÷'];

  @override
  void dispose() {
    first.dispose();
    second.dispose();
    super.dispose();
  }

  void append(String value) {
    setState(() {
      final text = active.text;
      final sel = active.selection;
      final start = sel.start < 0 ? text.length : sel.start;
      final end = sel.end < 0 ? text.length : sel.end;
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
      final from = (start == end && start > 0) ? start - 1 : start;
      active.value = TextEditingValue(
        text: text.replaceRange(from, end, ''),
        selection: TextSelection.collapsed(offset: from),
      );
    });
  }

  void clearActive() {
    setState(() {
      active.clear();
      error = null;
    });
  }

  void calculate() {
    try {
      final a = MathEngine.number(first.text);
      final b = MathEngine.number(second.text);
      double value;

      switch (operation) {
        case '+':
          value = a + b;
          break;
        case '−':
          value = a - b;
          break;
        case '×':
          value = a * b;
          break;
        case '÷':
          if (b == 0) throw const FormatException('Cannot divide by zero');
          value = a / b;
          break;
        default:
          throw const FormatException('Choose an operation');
      }

      setState(() {
        resultInches = value;
        error = null;
        _updateDisplay();
      });
    } catch (e) {
      setState(() {
        resultInches = null;
        result = '';
        error = e.toString().replaceAll('FormatException: ', '');
      });
    }
  }

  void _updateDisplay() {
    if (resultInches == null) return;
    final inches = resultInches!;
    final converted = MathEngine.length(inches, 'in', displayUnit);
    final decimal = MathEngine.fmt(converted, 4);
    final fi = MathEngine.feetInches(inches);
    result = '$decimal $displayUnit\n$fi';
  }

  Widget key(String label, VoidCallback? onPressed, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: SizedBox(
          height: 56,
          child: FilledButton.tonal(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Measurement Calculator', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Enter measurements using feet, inches, or fractions', style: TextStyle(color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          value: sourceUnit,
          decoration: const InputDecoration(
            labelText: 'Input unit',
            border: OutlineInputBorder(),
          ),
          items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
          onChanged: (u) => setState(() {
            sourceUnit = u!;
            if (resultInches != null) _updateDisplay();
          }),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: first,
          readOnly: true,
          onTap: () => setState(() => active = first),
          decoration: InputDecoration(
            labelText: 'Measurement 1',
            border: const OutlineInputBorder(),
            filled: active == first,
            fillColor: active == first ? colorScheme.primaryContainer.withOpacity(0.3) : null,
            suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: () => first.clear()),
          ),
        ),
        const SizedBox(height: 12),

        SegmentedButton<String>(
          segments: operations.map((op) => ButtonSegment(value: op, label: Text(op, style: const TextStyle(fontSize: 20)))).toList(),
          selected: {operation},
          onSelectionChanged: (s) => setState(() => operation = s.first),
          showSelectedIcon: false,
        ),
        const SizedBox(height: 12),

        TextField(
          controller: second,
          readOnly: true,
          onTap: () => setState(() => active = second),
          decoration: InputDecoration(
            labelText: 'Measurement 2',
            border: const OutlineInputBorder(),
            filled: active == second,
            fillColor: active == second ? colorScheme.primaryContainer.withOpacity(0.3) : null,
            suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: () => second.clear()),
          ),
        ),
        const SizedBox(height: 16),

        Row(children: [key('7', () => append('7')), key('8', () => append('8')), key('9', () => append('9')), key('⌫', backspace)]),
        Row(children: [key('4', () => append('4')), key('5', () => append('5')), key('6', () => append('6')), key('C', clearActive)]),
        Row(children: [key('1', () => append('1')), key('2', () => append('2')), key('3', () => append('3')), key("'", () => append("' "))]),
        Row(children: [key('0', () => append('0')), key('.', () => append('.')), key('/', () => append('/')), key('"', () => append('"'))]),
        const SizedBox(height: 8),
        Row(children: [
          key('Space', () => append(' '), flex: 1),
          key('Calculate', calculate, flex: 2),
        ]),

        const SizedBox(height: 20),

        if (resultInches != null)
          DropdownButtonFormField<String>(
            value: displayUnit,
            decoration: const InputDecoration(labelText: 'Show result in', border: OutlineInputBorder()),
            items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
            onChanged: (u) => setState(() {
              displayUnit = u!;
              _updateDisplay();
            }),
          ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Result', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              SelectableText(
                error ?? (result.isEmpty ? 'Enter values and tap Calculate' : result),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: error != null ? colorScheme.error : null,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tip: Type 5\' 3 1/2" or use the buttons. Works with feet, inches, and fractions.',
          style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class ConvertPage extends StatefulWidget {
  const ConvertPage({super.key});
  @override
  State<ConvertPage> createState() => _ConvertPageState();
}
class _ConvertPageState extends State<ConvertPage> {
  final value = TextEditingController(text: '1');
  String from = 'ft', to = 'in', output = '';
  static const units = ['in', 'ft', 'yd', 'mm', 'cm', 'm', 'km'];
  @override
  void dispose() { value.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Length conversion', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    TextField(controller: value, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Value')),
    DropdownButtonFormField<String>(initialValue: from, items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(), onChanged: (u) => setState(() => from = u!)),
    DropdownButtonFormField<String>(initialValue: to, items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(), onChanged: (u) => setState(() => to = u!)),
    FilledButton(onPressed: () { try { setState(() => output = '${MathEngine.fmt(MathEngine.length(MathEngine.number(value.text), from, to), 8)} $to'); } catch (e) { setState(() => output = e.toString()); } }, child: const Text('Convert')),
    SelectableText(output, style: const TextStyle(fontSize: 22)),
  ]);
}

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});
  @override
  State<ToolsPage> createState() => _ToolsPageState();
}
class _ToolsPageState extends State<ToolsPage> {
  final a = TextEditingController(), b = TextEditingController(), c = TextEditingController();
  String tool = 'Concrete volume (yd³)', output = '';
  static const tools = ['Concrete volume (yd³)', 'Board feet', 'Cylinder volume', 'Ohm voltage', 'Ohm current', 'Ohm resistance', 'Electrical power', 'Slope percent'];
  @override
  void dispose() { a.dispose(); b.dispose(); c.dispose(); super.dispose(); }
  void calculate() {
    try {
      final x = MathEngine.number(a.text), y = MathEngine.number(b.text);
      final z = c.text.trim().isEmpty ? 0.0 : MathEngine.number(c.text);
      final result = switch (tool) {
        'Concrete volume (yd³)' => MathEngine.concreteYards(x, y, z),
        'Board feet' => MathEngine.boardFeet(x, y, z),
        'Cylinder volume' => MathEngine.cylinder(x, y),
        'Ohm voltage' => MathEngine.volts(x, y),
        'Ohm current' => MathEngine.amps(x, y),
        'Ohm resistance' => MathEngine.ohms(x, y),
        'Electrical power' => MathEngine.power(x, y),
        'Slope percent' => MathEngine.slope(x, y),
        _ => 0.0,
      };
      setState(() => output = MathEngine.fmt(result) + (tool == 'Concrete volume (yd³)' ? ' yd³' : tool == 'Board feet' ? ' bd ft' : tool == 'Slope percent' ? '%' : ''));
    } catch (e) { setState(() => output = e.toString()); }
  }
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Engineering tools', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    DropdownButtonFormField<String>(initialValue: tool, isExpanded: true, items: tools.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (t) => setState(() => tool = t!)),
    TextField(controller: a, decoration: const InputDecoration(labelText: 'Input A')),
    TextField(controller: b, decoration: const InputDecoration(labelText: 'Input B')),
    TextField(controller: c, decoration: const InputDecoration(labelText: 'Input C (if needed)')),
    FilledButton(onPressed: calculate, child: const Text('Calculate')),
    SelectableText(output, style: const TextStyle(fontSize: 22)),
    const Text('Confirm units and assumptions. Do not use as a substitute for code-compliant engineering review.'),
  ]);
}

class DataPage extends StatefulWidget {
  const DataPage({super.key});
  @override
  State<DataPage> createState() => _DataPageState();
}
class _DataPageState extends State<DataPage> {
  String status = 'Local reference databases are bundled with the app.';
  dynamic data;
  Future<void> load() async {
    try { final loaded = await LocalData.materials(); setState(() { data = loaded; status = 'Material data loaded.'; }); }
    catch (e) { setState(() => status = 'Could not load material data: $e'); }
  }
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Offline reference library', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    Text(status),
    FilledButton(onPressed: load, child: const Text('Load material weight data')),
    if (data != null) SelectableText(data.toString()),
    const Text('Steel shape table search and filtering are not integrated yet.'),
  ]);
}
