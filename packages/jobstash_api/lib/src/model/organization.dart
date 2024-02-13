import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jobstash_api/src/model/funding_round.dart';
import 'package:jobstash_api/src/model/investor.dart';
import 'package:jobstash_api/src/model/project.dart';

part 'organization.freezed.dart';
part 'organization.g.dart';

@freezed
class Organization with _$Organization {
  factory Organization({
    String? id,
    String? orgId,
    String? name,
    String? description,
    String? summary,
    String? location,
    String? logoUrl,
    int? headcountEstimate,
    int? createdTimestamp,
    int? updatedTimestamp,
    int? aggregateRating,
    Map<String, dynamic>? aggregateRatings,
    int? reviewCount,
    String? discord,
    String? website,
    String? telegram,
    String? github,
    String? alias,
    String? twitter,
    String? docs,
    List<String>? community,
    List<Project>? projects,
    List<FundingRound>? fundingRounds,
    List<Investor>? investors,
    List<String>? reviews,
  }) = _Organization;

  factory Organization.fromJson(Map<String, dynamic> json) => _$OrganizationFromJson(json);
}