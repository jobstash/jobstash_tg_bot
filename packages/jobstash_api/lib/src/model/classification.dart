import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jobstash_api/jobstash_api.dart';

part 'classification.freezed.dart';
part 'classification.g.dart';

@freezed
class Classification with _$Classification {
  factory Classification({
    required Properties properties,
  }) = _Classification;

  factory Classification.fromJson(Map<String, dynamic> json) => _$ClassificationFromJson(json);
}
