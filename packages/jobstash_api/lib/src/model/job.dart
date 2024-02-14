// {
// "id": "string",
// "url": "string",
// "title": "string",
// "summary": "string",
// "description": "string",
// "requirements": [
// "string"
// ],
// "responsibilities": [
// "string"
// ],
// "shortUUID": "string",
// "minimumSalary": 0,
// "maximumSalary": 0,
// "salary": 0,
// "seniority": "string",
// "benefits": [
// "string"
// ],
// "culture": "string",
// "location": "string",
// "salaryCurrency": "string",
// "paysInCrypto": true,
// "featured": true,
// "featureStartDate": 0,
// "featureEndDate": 0,
// "offersTokenAllocation": true,
// "timestamp": 0,
// "tags": [
// "string"
// ],
// "commitment": "string",
// "locationType": "string",
// "classification": "string",
// "organization": [
// {
// "id": "string",
// "orgId": "string",
// "name": "string",
// "description": "string",
// "summary": "string",
// "location": "string",
// "logoUrl": "string",
// "headcountEstimate": 0,
// "createdTimestamp": 0,
// "updatedTimestamp": 0,
// "aggregateRating": 0,
// "aggregateRatings": {},
// "reviewCount": 0,
// "discord": "string",
// "website": "string",
// "telegram": "string",
// "github": "string",
// "alias": "string",
// "twitter": "string",
// "docs": "string",
// "community": [
// "string"
// ],
// "projects": [
// {
// "id": "string",
// "name": "string",
// "logo": "string",
// "tokenSymbol": "string",
// "tvl": 0,
// "monthlyVolume": 0,
// "monthlyFees": 0,
// "monthlyRevenue": 0,
// "monthlyActiveUsers": 0,
// "isMainnet": true,
// "orgId": "string",
// "description": "string",
// "defiLlamaId": "string",
// "defiLlamaSlug": "string",
// "defiLlamaParent": "string",
// "tokenAddress": "string",
// "createdTimestamp": 0,
// "updatedTimestamp": 0,
// "category": "string",
// "website": "string",
// "github": "string",
// "twitter": "string",
// "telegram": "string",
// "discord": "string",
// "docs": "string",
// "hacks": [
// {
// "id": "string",
// "date": 0,
// "defiId": "string",
// "category": "string",
// "fundsLost": 0,
// "issueType": "string",
// "description": "string",
// "fundsReturned": 0
// }
// ],
// "audits": [
// {
// "id": "string",
// "link": "string",
// "name": "string",
// "defiId": "string",
// "date": 0,
// "techIssues": 0
// }
// ],
// "chains": [
// {
// "id": "string",
// "name": "string",
// "logo": "string"
// }
// ],
// "jobs": [
// "string"
// ],
// "investors": [
// {
// "id": "string",
// "name": "string"
// }
// ],
// "repos": [
// "string"
// ]
// }
// ],
// "fundingRounds": [
// {
// "id": "string",
// "raisedAmount": 0,
// "roundName": "string",
// "date": 0,
// "sourceLink": "string",
// "createdTimestamp": 0,
// "updatedTimestamp": 0
// }
// ],
// "investors": [
// {
// "id": "string",
// "name": "string"
// }
// ],
// "reviews": [
// "string"
// ]
// }
// ]
// }
//create freezed model from json above

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jobstash_api/src/model/organization.dart';
import 'package:jobstash_api/src/model/tag.dart';

part 'job.freezed.dart';

part 'job.g.dart';

@freezed
class Job with _$Job {
  factory Job({
    String? id,
    String? url,
    String? title,
    String? summary,
    String? description,
    List<String>? requirements,
    List<String>? responsibilities,
    String? shortUUID,
    int? minimumSalary,
    int? maximumSalary,
    int? salary,
    String? seniority,
    List<String>? benefits,
    String? culture,
    String? location,
    String? salaryCurrency,
    bool? paysInCrypto,
    bool? featured,
    int? featureStartDate,
    int? featureEndDate,
    bool? offersTokenAllocation,
    int? timestamp,
    List<Tag>? tags,
    String? commitment,
    String? locationType,
    String? classification,
    Organization? organization,
  }) = _Job;

  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);
}
