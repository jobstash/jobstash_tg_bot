import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jobstash_api/src/model/range.dart';

// Server sends int or Range({"low": 30, "high": 0})
// Custom converter always converts to Range
class HeadcountEstimateConverter implements JsonConverter<Range?, dynamic> {
  const HeadcountEstimateConverter();

  @override
  Range? fromJson(dynamic json) {
    if (json is int) {
      return Range(low: json, high: json);
    } else if (json is Map<String, dynamic>) {
      return Range.fromJson(json);
    }
    return null;
  }

  @override
  dynamic toJson(Range? object) => object;
}
