import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jobstash_api/src/model/job.dart';

part 'jobs_response.freezed.dart';

part 'jobs_response.g.dart';

@freezed
class JobsResponse with _$JobsResponse {
  factory JobsResponse({
    required int page,
    required int count,
    required int total,
    required List<Job> data,
  }) = _JobsResponse;

  factory JobsResponse.fromJson(Map<String, dynamic> json) => _$JobsResponseFromJson(json);
}
