import 'package:shared/shared.dart';

/// Base class for all remote data sources to reduce boilerplate.
abstract class BaseRemoteDataSource {
  BaseRemoteDataSource(this.gqlService);
  final GraphQLService gqlService;

  /// Executes a mutation and extracts data from the result.
  Future<T> mutate<T>(
    String document, {
    required String key,
    Map<String, dynamic>? variables,
  }) async {
    final result = await gqlService.mutate(document, variables: variables);
    return result.extractData<T>(key);
  }

  /// Executes a query and extracts data from the result.
  Future<T> query<T>(
    String document, {
    required String key,
    Map<String, dynamic>? variables,
    bool useCache = true,
  }) async {
    final result = await gqlService.query(
      document,
      variables: variables,
      useCache: useCache,
    );
    return result.extractData<T>(key);
  }
}
