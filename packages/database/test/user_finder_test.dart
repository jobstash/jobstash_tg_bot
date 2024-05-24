import 'package:database/database.dart';
import 'package:database/src/dao/user_filters_dao.dart';
import 'package:database/src/dao/user_finder.dart';
import 'package:firedart/firedart.dart';
import 'package:test/test.dart';

void main() {
  group('Classification Tests', () {
    test('getMatchingUsers returns users with matching classification', () {
      final userFilters = DocumentStab('id1', {UserFiltersDao.classificationFilterKey: 'classification1'});
      final page = Page([userFilters], '');

      final result = UserFinder.getMatchingUsers(
        page: page,
        classification: 'classification1',
      );

      expect(result, equals([userFilters.id]));
    });

    test('getMatchingUsers returns no users with non-matching classification', () {
      final userFilters = DocumentStab('id1', {UserFiltersDao.classificationFilterKey: 'classification1'});
      final page = Page([userFilters], '');

      final result = UserFinder.getMatchingUsers(
        page: page,
        classification: 'classification2',
      );

      expect(result, isEmpty);
    });
  });

  group('Tags Tests', () {
    test('getMatchingUsers returns users with matching tags', () {
      final userFilters = DocumentStab('id1', {
        UserFiltersDao.tagsFilterKey: ['tag1', 'tag2']
      });
      final page = Page([userFilters], '');

      final result = UserFinder.getMatchingUsers(
        page: page,
        tags: ['tag1', 'tag2'],
      );

      expect(result, equals([userFilters.id]));
    });

    test('getMatchingUsers returns no users with non-matching tags', () {
      final userFilters = DocumentStab('id1', {
        UserFiltersDao.tagsFilterKey: ['tag1', 'tag2']
      });
      final page = Page([userFilters], '');

      final result = UserFinder.getMatchingUsers(
        page: page,
        tags: ['tag3', 'tag4'],
      );

      expect(result, isEmpty);
    });
  });

  group('Category Tests', () {
    test('getMatchingUsers returns users with matching category', () {
      final userFilters = DocumentStab('id1', {
        UserFiltersDao.categoriesFilterKey: ['category1']
      });
      final page = Page([userFilters], '');

      final result = UserFinder.getMatchingUsers(
        page: page,
        category: 'category1',
      );

      expect(result, equals([userFilters.id]));
    });

    test('getMatchingUsers returns no users with non-matching category', () {
      final userFilters = DocumentStab('id1', {
        'categoriesFilterKey': ['category1']
      });
      final page = Page([userFilters], '');

      final result = UserFinder.getMatchingUsers(
        page: page,
        category: 'category2',
      );

      expect(result, isEmpty);
    });
  });

  group('Combination Tests', () {
    test('getMatchingUsers returns users with matching classification and tags', () {
      final userFilters = DocumentStab('id1', {
        UserFiltersDao.classificationFilterKey: 'classification1',
        UserFiltersDao.tagsFilterKey: ['tag1', 'tag2']
      });
      final page = Page([userFilters], '');

      final result = UserFinder.getMatchingUsers(
        page: page,
        classification: 'classification1',
        tags: ['tag1', 'tag2'],
      );

      expect(result, equals([userFilters.id]));
    });

    test('getMatchingUsers returns no users with non-matching classification and tags', () {
      final userFilters = DocumentStab('id1', {
        UserFiltersDao.classificationFilterKey: 'classification1',
        UserFiltersDao.tagsFilterKey: ['tag1', 'tag2']
      });
      final page = Page([userFilters], '');

      final result = UserFinder.getMatchingUsers(
        page: page,
        classification: 'classification2',
        tags: ['tag3', 'tag4'],
      );

      expect(result, isEmpty);
    });
  });

  group('Edge Cases', () {
    test('getMatchingUsers returns no users when page is empty', () {
      final page = Page<Document>([], '');

      final result = UserFinder.getMatchingUsers(
        page: page,
      );

      expect(result, isEmpty);
    });

    test('getMatchingUsers returns users when user filters are partially set', () {
      final userFilters = DocumentStab('id1', {
        UserFiltersDao.classificationFilterKey: 'classification1',
        UserFiltersDao.tagsFilterKey: ['tag1']
      });
      final page = Page([userFilters], '');

      final result = UserFinder.getMatchingUsers(
        page: page,
        classification: 'classification1',
        tags: ['tag1', 'tag2'],
      );

      expect(result, equals([userFilters.id]));
    });

    test('getMatchingUsers returns users when all parameters are null', () {
      final userFilters = DocumentStab('id1', {
        UserFiltersDao.classificationFilterKey: 'classification1',
        UserFiltersDao.tagsFilterKey: ['tag1'],
        UserFiltersDao.categoriesFilterKey: ['category1']
      });
      final page = Page([userFilters], '');

      final result = UserFinder.getMatchingUsers(
        page: page,
      );

      expect(result.isEmpty, true);
    });
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
