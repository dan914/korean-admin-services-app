class CodeItem {
  final String code;
  final String ko;
  final String en;
  final String? source;
  final String? note;

  const CodeItem({
    required this.code,
    required this.ko,
    required this.en,
    this.source,
    this.note,
  });

  @override
  String toString() => ko;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeItem &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}