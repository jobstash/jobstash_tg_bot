import 'package:freezed_annotation/freezed_annotation.dart';

part 'filter.freezed.dart';

part 'filter.g.dart';

@freezed
class Filter with _$Filter {
  const Filter._();

  const factory Filter({
    String? paramKey,
    required String label,
    required bool show,
    required FilterKind kind,
    required int position,
    List<dynamic>? options,
    required String? prefix,
    required String? googleAnalyticsEventName,
    required FilterValue? value,
  }) = _Filter;

  factory Filter.fromJson(Map<String, dynamic> json) => _$FilterFromJson(json);
}

enum FilterKind {
  @JsonValue('SINGLE_SELECT')
  singleSelect,
  @JsonValue('MULTI_SELECT')
  multiSelect,
  @JsonValue('MULTI_SELECT_WITH_SEARCH')
  multiSelectWithSearch,
  @JsonValue('RANGE')
  range,
}

@freezed
class FilterValue with _$FilterValue {
  const FilterValue._();

  const factory FilterValue({
    required FilterValueItem lowest,
    required FilterValueItem highest,
  }) = _FilterValue;

  factory FilterValue.fromJson(Map<String, dynamic> json) => _$FilterValueFromJson(json);
}

@freezed
class FilterValueItem with _$FilterValueItem {
  const FilterValueItem._();

  const factory FilterValueItem({
    required String paramKey,
    required double value,
  }) = _FilterValueItem;

  factory FilterValueItem.fromJson(Map<String, dynamic> json) => _$FilterValueItemFromJson(json);
}
