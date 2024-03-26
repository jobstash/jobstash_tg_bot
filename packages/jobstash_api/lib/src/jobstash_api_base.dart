import 'package:dio/dio.dart';
import 'package:jobstash_api/src/model/tag_match_response.dart';

const _endpointMatchTags = '/tags/match';

class JobStashApi {
  JobStashApi() : _dio = Dio() {
    _dio.options.baseUrl = 'https://middleware.jobstash.xyz';
  }

  final Dio _dio;

  Future<TagMatchResponse> matchTags(List<String> tags) async {
    final response = await _dio.post(_endpointMatchTags, data: {'tags': tags});
    return TagMatchResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
