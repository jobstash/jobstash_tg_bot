import 'package:database/src/dao/user_finder.dart';
import 'package:firedart/firedart.dart';
import 'package:test/test.dart';

void main() {
  test('getInterestedUsers returns users with matching tags', () {
    // Prepare a Page<Document> object with a set of user filters that include specific tags
    final userFilters = DocumentStab('id', {
      'tags': ['tag1', 'tag2']
    });
    final page = Page([userFilters], '');

    // Call the getInterestedUsers method with a list of tags that match the user filters
    final result =
        UserFinder.getInterestedUsers(page, null, null, null, null, null, null, null, ['tag1', 'tag2'], null);

    // Assert that the returned list of user IDs matches the expected result
    expect(result, equals([userFilters.id]));
  });

  test('getInterestedUsers returns no users with non-matching tags', () {
    // Prepare a Page<Document> object with a set of user filters that include specific tags
    final userFilters = DocumentStab('id', {
      'tags': ['tag1', 'tag2']
    });
    final page = Page([userFilters], '');

    // Call the getInterestedUsers method with a list of tags that do not match the user filters
    final result =
        UserFinder.getInterestedUsers(page, null, null, null, null, null, null, null, ['tag3', 'tag4'], null);

    // Assert that the returned list of user IDs is empty
    expect(result, isEmpty);
  });
}

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
