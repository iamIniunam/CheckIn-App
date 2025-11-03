extension StringExtension on String {
  bool get isBlank {
    return trim().isEmpty;
  }
}

extension NullableStringExtension on String? {
  bool get isNullOrBlank {
    return this?.isBlank ?? true;
  }
}

extension Pluralize on String {
  String pluralize(int count) => count == 1 ? this : '${this}s';
}
