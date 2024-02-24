import 'package:dio/dio.dart';
import 'package:jobstash_api/src/model/filter.dart';
import 'package:jobstash_api/src/model/tag_match_response.dart';

const _endpointJobFilters = '/jobs/filters';
const _endpointMatchTags = '/tags/match';

class JobStashApi {
  JobStashApi() : _dio = Dio() {
    _dio.options.baseUrl = 'https://middleware.jobstash.xyz';
  }

  final Dio _dio;

  Future<void> setFilters(String userId, List<String> filters) async {
    await _dio.post(_endpointJobFilters, data: {
      'userId': userId,
      'filters': filters,
    });
  }

  Future<TagMatchResponse> matchTags(List<String> tags) async {
    final response = await _dio.post(_endpointMatchTags, data: {'tags': tags});
    return TagMatchResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Returns a map of filter id to filter
  Future<Map<String, Filter>> getAllFilters() async {
    final response = await _dio.get(_endpointJobFilters);

    final filtersJson = response.data as Map<String, dynamic>;

    // the map is id: filter
    return filtersJson.map((key, value) => MapEntry(key, Filter.fromJson(value)));
  }
}
