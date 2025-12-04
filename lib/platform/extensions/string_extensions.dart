extension StringExtension on String {
  bool get isBlank {
    return trim().isEmpty;
  }

  String toSentenceCase() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  int toInt() {
    return int.tryParse(this) ?? 0;
  }
}

extension NullableStringExtension on String? {
  bool get isNullOrBlank {
    return this?.isBlank ?? true;
  }

  String ifNullOrBlank(String Function() defaultValue) {
    return isNullOrBlank ? defaultValue() : this ?? defaultValue();
  }
}

extension Pluralize on String {
  String pluralize(int count) => count == 1 ? this : '${this}s';
}
