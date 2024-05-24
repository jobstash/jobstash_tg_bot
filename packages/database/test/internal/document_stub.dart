import 'package:firedart/firedart.dart';

class DocumentStab implements Document {
  final String _id;
  final Map<String, dynamic> _map;

  DocumentStab(this._id, this._map);

  @override
  operator [](String key) {
    return _map[key];
  }

  @override
  DateTime get createTime => DateTime.now();

  @override
  String get id => _id;

  @override
  Map<String, dynamic> get map => _map;

  @override
  String get path => '/path/to/document';

  @override
  DocumentReference get reference => throw UnimplementedError();

  @override
  DateTime get updateTime => DateTime.now();
}
