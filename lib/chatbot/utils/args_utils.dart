extension SecondOrNullExt on List<String>? {
  String? get secondOrNull {
    final secondArg = this?.elementAtOrNull(1);
    return secondArg;
  }
}
