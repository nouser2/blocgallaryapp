import 'package:flutter/foundation.dart' show kDebugMode;

extension DebugAutoString on String {
  String? get autoDebugging => kDebugMode ? this : null;
}
