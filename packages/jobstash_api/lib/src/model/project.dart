import 'package:freezed_annotation/freezed_annotation.dart';

part 'project.freezed.dart';

part 'project.g.dart';

@freezed
class Project with _$Project {
  factory Project({
    String? id,
    String? name,
    String? description,
    String? url,
    String? logoUrl,
    String? status,
    String? category,
    String? launchDate,
    String? platform,
    String? token,
    String? tokenType,
    String? blockchain,
    String? consensus,
    String? smartContractAddress,
    String? explorer,
    String? whitepaper,
    String? website,
    String? twitter,
    String? telegram,
    String? discord,
    String? reddit,
    String? github,
    String? youtube,
    String? medium,
    String? linkedin,
    String? wikipedia,
  }) = _Project;

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);
}
