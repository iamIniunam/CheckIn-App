import 'dart:convert';
import 'package:attendance_app/platform/extensions/string_extensions.dart';

extension MapExtensions on Map<String, dynamic> {
  String toJson({bool pretty = false, String? indent}) {
    if (values.firstOrNull is List && keys.firstOrNull.isNullOrBlank) {
      return jsonEncode((values.firstOrNull as List));
    }
    if (pretty && indent != null) {
      return JsonEncoder.withIndent(indent).convert(this);
    }
    return jsonEncode(this);
  }
}
