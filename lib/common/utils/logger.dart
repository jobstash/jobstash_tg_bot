import 'package:logger/logger.dart';

var logger = Logger(
  filter: DevelopmentFilter(),
  printer: PrettyPrinter(),
  output: null, // Use the default LogOutput (-> send everything to console)
);
