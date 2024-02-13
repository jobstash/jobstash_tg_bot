import 'package:freezed_annotation/freezed_annotation.dart';

part 'investor.freezed.dart';
part 'investor.g.dart';

@freezed
class Investor with _$Investor {
  factory Investor({
    String? id,
    String? name,
    String? description,
    String? logoUrl,
    String? website,
    String? twitter,
    String? linkedin,
    String? crunchbase,
  }) = _Investor;

  factory Investor.fromJson(Map<String, dynamic> json) => _$InvestorFromJson(json);
}