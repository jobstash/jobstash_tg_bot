import 'package:database/database.dart';

abstract class CategoryFilter {
  static const name = categoriesFilterKey;

  static final options = const [
    "ACCOUNTING",
    "BIZDEV",
    "COMMUNITY",
    "CUSTOMER_SUPPORT",
    "CYBERSECURITY",
    "DESIGN",
    "DEVREL",
    "DEVOPS",
    "ENGINEERING",
    "EVENTS",
    "FINANCE",
    "GROWTH",
    "LEGAL",
    "MANAGEMENT",
    "MARKETING",
    "OPERATIONS",
    "PARTNERSHIPS",
    "PEOPLE",
    "PRODUCT",
    "SALES",
    "TECHNICAL_WRITING",
    "OTHER",
  ];
}
