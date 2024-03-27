import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jobstash_api/jobstash_api.dart';
import 'package:jobstash_api/src/model/classification.dart';

part 'post.freezed.dart';
part 'post.g.dart';

@freezed
class Post with _$Post {
  const Post._();

  factory Post({
    required Organization organization,
    @JsonKey(name: 'structuredJobpost') required StructuredJobPost job,
    Classification? classification,
  }) = _Post;

  String? get category => classification?.properties.name;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}
