import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jobstash_api/jobstash_api.dart';
import 'package:jobstash_api/src/model/range.dart';

part 'structured_job_post.freezed.dart';
part 'structured_job_post.g.dart';

@freezed
class StructuredJobPost with _$StructuredJobPost {
  const factory StructuredJobPost({
    required List<Tag>? tags,
    required String? summary,
    required String? payRate,
    int? minimumSalary,
    int? maximumSalary,
    required String? location,
    required String? shortUUID,
    required List<String>? requirements,
    required String? url,
    required Range? firstSeenTimestamp,
    required String? id,
    required String? title,
    required Range? lastSeenTimestamp,
    required String? description,
    required LocationType? locationType,
    required List<String>? responsibilities,
    required List<String>? benefits,
    required Range? publishedTimestamp,
    required String? seniority,
  }) = _StructuredJobPost;

  factory StructuredJobPost.fromJson(Map<String, dynamic> json) => _$StructuredJobPostFromJson(json);
}
