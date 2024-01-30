import 'package:jobstash_api/jobstash_api.dart';
import 'package:riverpod/riverpod.dart';

final jobStashApiProvider = Provider(
  (ref) => JobStashApi(),  //todo pass in base url from .env?
);
