import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag.freezed.dart';

part 'tag.g.dart';

@freezed
class Tag with _$Tag {
  factory Tag({
    required String id,
    required String name,
    required String normalizedName,
  }) = _Tag;

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
}
