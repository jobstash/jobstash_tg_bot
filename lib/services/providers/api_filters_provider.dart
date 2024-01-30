import 'package:jobstash_api/jobstash_api.dart';
import 'package:jobstash_bot/services/dependencies.dart';
import 'package:riverpod/riverpod.dart';

final filtersProvider = FutureProvider<Map<String, Filter>>(
  (ref) {
    final api = ref.read(jobStashApiProvider);
    return api.getAllFilters();
  },
);
