import 'package:freezed_annotation/freezed_annotation.dart';

part 'funding_round.freezed.dart';
part 'funding_round.g.dart';

@freezed
class FundingRound with _$FundingRound {
  factory FundingRound({
    String? id,
    String? round,
    String? date,
    String? currency,
    int? amount,
    String? sourceUrl,
    String? sourceText,
    String? valuation,
    String? valuationCurrency,
  }) = _FundingRound;

  factory FundingRound.fromJson(Map<String, dynamic> json) => _$FundingRoundFromJson(json);
}