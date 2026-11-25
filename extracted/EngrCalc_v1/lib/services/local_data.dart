import 'dart:convert';
import 'package:flutter/services.dart';
class LocalData {
 static Future<dynamic> read(String path) async => jsonDecode(await rootBundle.loadString(path));
 static Future<dynamic> materials()=>read('assets/data/materials/loadWeightMaterials.json');
 static Future<dynamic> hssShapes()=>read('assets/data/steel_fabrication/beam_tables_hss_a1085.min.json');
}
