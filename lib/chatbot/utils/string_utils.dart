extension StringExt on String {
  String capitalize() {
    final withSpaces = replaceAll('_', ' ');
    return withSpaces[0].toUpperCase() + withSpaces.substring(1).toLowerCase();
  }
}
