import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jobstash_api/src/converters/headcount_custom_converter.dart';
import 'package:jobstash_api/src/model/range.dart';

part 'organization.freezed.dart';
part 'organization.g.dart';

@freezed
class Organization with _$Organization {
  const factory Organization({
    required Range identity,
    required List<String> labels,
    required Properties properties,
    required String elementId,
  }) = _Organization;

  factory Organization.fromJson(Map<String, dynamic> json) => _$OrganizationFromJson(json);
}

@freezed
class Properties with _$Properties {
  const factory Properties({
    String? summary,
    Range? createdTimestamp,
    String? name,
    String? description,
    String? location,
    String? id,
    Range? updatedTimestamp,
    String? orgId,
    @HeadcountEstimateConverter() Range? headcountEstimate,
  }) = _Properties;

  factory Properties.fromJson(Map<String, dynamic> json) => _$PropertiesFromJson(json);
}
