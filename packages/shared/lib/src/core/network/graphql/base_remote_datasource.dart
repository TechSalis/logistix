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
    final result = await gqlService.mutate<T>(document, variables: variables);
    return result.extractData<T>(key);
  }

  /// Executes a query and extracts data from the result.
  Future<T> query<T>(
    String document, {
    required String key,
    Map<String, dynamic>? variables,
    bool useCache = true,
  }) async {
    final result = await gqlService.query<T>(
      document,
      variables: variables,
      useCache: useCache,
    );
    return result.extractData<T>(key);
  }

  /// Helper for GraphQL subscriptions
  Future<SyncManager> subscribe(
    String document, {
    required void Function(Map<String, dynamic> data) onData,
    Future<void> Function()? onSync,
    Map<String, dynamic>? variables,
  }) async {
    final manager = SyncManager(gqlService);
    await manager.startSubscription(
      subscriptionDocument: document,
      variables: variables,
      onData: (data) async => onData(data),
      onSync: onSync,
    );
    return manager;
  }
}
