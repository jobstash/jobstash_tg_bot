import 'package:database/src/dao/user_filters_dao.dart';
import 'package:database/src/dao/user_finder.dart';
import 'package:firedart/firedart.dart';
import 'package:test/test.dart';

import 'internal/document_stub.dart';

void main() {
  group('Communities Tests', () {
    test('getMatchingUsers returns users with matching community', () {
      final userFilters = DocumentStab('id1', {UserFiltersDao.communityFilterKey: 'community1'});
      final page = Page([userFilters], '');

      final result = UserFinder.getMatchingUsers(
        page: page,
        communities: ['community1'],
      );

      expect(result, equals([userFilters.id]));
    });

    test('getMatchingUsers returns no users with non-matching community', () {
      final userFilters = DocumentStab('id1', {UserFiltersDao.communityFilterKey: 'community1'});
      final page = Page([userFilters], '');

      final result = UserFinder.getMatchingUsers(
        page: page,
        communities: ['community2'],
      );

      expect(result, isEmpty);
    });

    test('getMatchingUsers returns users with one matching community from multiple', () {
      final userFilters = DocumentStab('id1', {UserFiltersDao.communityFilterKey: 'community1'});
      final page = Page([userFilters], '');

      final result = UserFinder.getMatchingUsers(
        page: page,
        communities: ['community1', 'community2'],
      );

      expect(result, equals([userFilters.id]));
    });

    test('getMatchingUsers returns no users when communities is null', () {
      final userFilters = DocumentStab('id1', {UserFiltersDao.communityFilterKey: 'community1'});
      final page = Page([userFilters], '');

      final result = UserFinder.getMatchingUsers(
        page: page,
        communities: null,
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
        UserFiltersDao.categoriesFilterKey: ['category1']
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
    test('getMatchingUsers returns users with matching community and tags', () {
      final userFilters = DocumentStab('id1', {
        UserFiltersDao.communityFilterKey: 'community1',
        UserFiltersDao.tagsFilterKey: ['tag1', 'tag2']
      });
      final page = Page([userFilters], '');

      final result = UserFinder.getMatchingUsers(
        page: page,
        communities: ['community1'],
        tags: ['tag1', 'tag2'],
      );

      expect(result, equals([userFilters.id]));
    });

    test('getMatchingUsers returns no users with non-matching community and tags', () {
      final userFilters = DocumentStab('id1', {
        UserFiltersDao.communityFilterKey: 'community1',
        UserFiltersDao.tagsFilterKey: ['tag1', 'tag2']
      });
      final page = Page([userFilters], '');

      final result = UserFinder.getMatchingUsers(
        page: page,
        communities: ['community2'],
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
        UserFiltersDao.communityFilterKey: 'community1',
        UserFiltersDao.tagsFilterKey: ['tag1']
      });
      final page = Page([userFilters], '');
      final result = UserFinder.getMatchingUsers(
        page: page,
        communities: ['community1'],
        tags: ['tag1', 'tag2'],
      );
      expect(result, equals([userFilters.id]));
    });
    test('getMatchingUsers returns no users when all parameters are null', () {
      final userFilters = DocumentStab('id1', {
        UserFiltersDao.communityFilterKey: 'community1',
        UserFiltersDao.tagsFilterKey: ['tag1'],
        UserFiltersDao.categoriesFilterKey: ['category1']
      });
      final page = Page([userFilters], '');
      final result = UserFinder.getMatchingUsers(
        page: page,
      );
      expect(result, isEmpty);
    });
  });
}
