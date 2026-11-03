import 'package:flutter_riverpod/flutter_riverpod.dart';

// 'en' = English  |  'hi' = Hindi
final languageProvider = StateProvider<String>((ref) => 'en');
