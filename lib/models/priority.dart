enum Priority {
  high,
  medium,
  low;

  String get displayName {
    switch (this) {
      case Priority.high:
        return 'High';
      case Priority.medium:
        return 'Medium';
      case Priority.low:
        return 'Low';
    }
  }

  int get colorValue {
    switch (this) {
      case Priority.high:
        return 0xFFEF5350; // Red
      case Priority.medium:
        return 0xFFFF9800; // Orange
      case Priority.low:
        return 0xFF66BB6A; // Green
    }
  }

  int get sortOrder {
    switch (this) {
      case Priority.high:
        return 0;
      case Priority.medium:
        return 1;
      case Priority.low:
        return 2;
    }
  }

  static Priority fromString(String value) {
    return Priority.values.firstWhere(
      (e) => e.name == value,
      orElse: () => Priority.medium,
    );
  }
}
