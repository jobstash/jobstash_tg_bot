import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jobstash_api/jobstash_api.dart';

part 'post.freezed.dart';

part 'post.g.dart';

@freezed
class Post with _$Post {
  factory Post({
    required Organization organization,
    @JsonKey(name: 'structuredJobpost')
    required StructuredJobPost job,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}
