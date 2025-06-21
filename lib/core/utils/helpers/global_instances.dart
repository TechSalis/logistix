import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

final dioCacheOptions = CacheOptions(
  store: MemCacheStore(),
  policy: CachePolicy.request,
  hitCacheOnNetworkFailure: true,
  maxStale: const Duration(days: 30),
);

final dioCacheInterceptor = DioCacheInterceptor(options: dioCacheOptions);
