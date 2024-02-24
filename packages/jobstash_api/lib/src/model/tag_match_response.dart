import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag_match_response.freezed.dart';

part 'tag_match_response.g.dart';

@freezed
class TagMatchResponse with _$TagMatchResponse {
  const factory TagMatchResponse({
    required bool success,
    String? message,
    Data? data,
  }) = _TagMatchResponse;

  factory TagMatchResponse.fromJson(Map<String, dynamic> json) => _$TagMatchResponseFromJson(json);
}

@freezed
class Data with _$Data {
  const factory Data({
    @JsonKey(name: 'recognized_tags') List<String>? recognizedTags,
    @JsonKey(name: 'unrecognized_tags') List<String>? unrecognizedTags,
  }) = _Data;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
}
