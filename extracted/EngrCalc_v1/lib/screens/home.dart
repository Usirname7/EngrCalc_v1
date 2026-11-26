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
  TextEditingController active = TextEditingController();
  String operation = '+';
  String sourceUnit = 'in';
  String displayUnit = 'in';
  String result = '';
  String? error;
  double? resultBase;
  bool resultIsLength = true;

  static const units = ['in', 'ft', 'yd', 'mm', 'cm', 'm', 'km'];
  static const operations = ['+', '−', '× number', '× dimension', '÷ number', '÷ dimension'];

  @override
  void initState() {
    super.initState();
    active = first;
  }

  @override
  void dispose() {
    first.dispose();
    second.dispose();
    super.dispose();
  }

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

  Future<void> addFraction() async {
    final numerator = TextEditingController(text: '1');
    final denominator = TextEditingController(text: '2');
    final fraction = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insert fraction'),
        content: Row(children: [
          Expanded(child: TextField(controller: numerator, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Numerator'))),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('/')),
          Expanded(child: TextField(controller: denominator, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Denominator'))),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () {
            final n = int.tryParse(numerator.text);
            final d = int.tryParse(denominator.text);
            if (n != null && d != null && d != 0) Navigator.pop(context, '$n/$d');
          }, child: const Text('Insert')),
        ],
      ),
    );
    numerator.dispose();
    denominator.dispose();
    if (fraction != null) append('${active.text.trim().isEmpty ? '' : ' '}$fraction');
  }

  void calculate() {
    try {
      final a = MathEngine.number(first.text);
      final b = MathEngine.number(second.text);
      final aInches = MathEngine.length(a, sourceUnit, 'in');
      final bInches = MathEngine.length(b, sourceUnit, 'in');
      late final double value;
      late final bool isLength;
      switch (operation) {
        case '+': value = aInches + bInches; isLength = true; break;
        case '−': value = aInches - bInches; isLength = true; break;
        case '× number': value = aInches * b; isLength = true; break;
        case '× dimension': value = aInches * bInches; isLength = false; break;
        case '÷ number':
          if (b == 0) throw const FormatException('Cannot divide by zero');
          value = aInches / b; isLength = true; break;
        case '÷ dimension':
          if (bInches == 0) throw const FormatException('Cannot divide by zero');
          value = aInches / bInches; isLength = false; break;
        default: throw const FormatException('Choose an operation');
      }
      setState(() {
        resultBase = value;
        resultIsLength = isLength;
        error = null;
        _refreshResult();
      });
    } catch (exception) {
      setState(() {
        resultBase = null;
        result = '';
        error = exception.toString().replaceAll('FormatException: ', '');
      });
    }
  }

  void _refreshResult() {
    final value = resultBase;
    if (value == null) return;
    final shown = resultIsLength ? MathEngine.length(value, 'in', displayUnit) : value;
    result = '${MathEngine.fmt(shown, 8)} ${resultIsLength ? displayUnit : 'in²'}';
  }

  Widget key(String label, VoidCallback? action, {int flex = 1}) => Expanded(
    flex: flex,
    child: Padding(
      padding: const EdgeInsets.all(3),
      child: SizedBox(
        height: 54,
        child: FilledButton.tonal(
          onPressed: action,
          style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: Text(label, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Measurement Calculator', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        initialValue: sourceUnit,
        decoration: const InputDecoration(labelText: 'Input unit', border: OutlineInputBorder()),
        items: units.map((unit) => DropdownMenuItem(value: unit, child: Text(unit))).toList(),
        onChanged: (unit) => setState(() { sourceUnit = unit!; }),
      ),
      const SizedBox(height: 12),
      _measurementField(first, 'Measurement 1', colors),
      const SizedBox(height: 10),
      DropdownButtonFormField<String>(
        initialValue: operation,
        decoration: const InputDecoration(labelText: 'Operation', border: OutlineInputBorder()),
        items: operations.map((op) => DropdownMenuItem(value: op, child: Text(op))).toList(),
        onChanged: (op) => setState(() => operation = op!),
      ),
      const SizedBox(height: 10),
      _measurementField(second, 'Measurement 2', colors),
      const SizedBox(height: 10),
      Row(children: [key('7', () => append('7')), key('8', () => append('8')), key('9', () => append('9')), key('⌫', backspace)]),
      Row(children: [key('4', () => append('4')), key('5', () => append('5')), key('6', () => append('6')), key('C', clearActive)]),
      Row(children: [key('1', () => append('1')), key('2', () => append('2')), key('3', () => append('3')), key('Fraction', addFraction)]),
      Row(children: [key('0', () => append('0')), key('.', () => append('.')), key('−', () => append('-')), key('Space', () => append(' '))]),
      const SizedBox(height: 8),
      FilledButton(onPressed: calculate, child: const Text('Calculate')),
      if (resultBase != null && resultIsLength) ...[
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: displayUnit,
          decoration: const InputDecoration(labelText: 'Display result in', border: OutlineInputBorder()),
          items: units.map((unit) => DropdownMenuItem(value: unit, child: Text(unit))).toList(),
          onChanged: (unit) => setState(() { displayUnit = unit!; _refreshResult(); }),
        ),
      ],
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: colors.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Result', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SelectableText(error ?? (result.isEmpty ? 'Enter values and calculate' : result),
            style: TextStyle(fontSize: 23, color: error == null ? null : colors.error)),
        ]),
      ),
      const SizedBox(height: 8),
      const Text('Use the fraction key to insert a fraction into the active measurement.'),
    ]);
  }

  Widget _measurementField(TextEditingController controller, String label, ColorScheme colors) =>
    TextField(
      controller: controller,
      readOnly: true,
      onTap: () => setState(() => active = controller),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: active == controller,
        fillColor: active == controller ? colors.primaryContainer.withValues(alpha: 0.35) : null,
        suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: () {
          setState(() { controller.clear(); error = null; });
        }),
      ),
    );
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
