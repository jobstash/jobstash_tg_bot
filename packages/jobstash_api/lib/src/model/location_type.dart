import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_type.freezed.dart';
part 'location_type.g.dart';

@freezed
class LocationType with _$LocationType {
  factory LocationType({
    required String id,
    required String name,
  }) = _LocationType;

  factory LocationType.fromJson(Map<String, dynamic> json) => _$LocationTypeFromJson(json);
}