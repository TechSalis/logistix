import 'dart:async';
import 'dart:io';
import 'package:bootstrap/interfaces/connectivity/connectivity.dart';
import 'package:bootstrap/interfaces/http/oauth_token/models/codec.dart';
import 'package:bootstrap/interfaces/http/oauth_token/models/oauth_token.dart';
import 'package:bootstrap/interfaces/http/token_store.dart';
import 'package:bootstrap/interfaces/logger/logger.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared/shared.dart';

typedef RefreshTokenHandler =
    Future<OAuthToken?> Function(OAuthToken token, GraphQLClient client);

class GraphQLService {
  GraphQLService(
    this.tokenStore, {
    required UserStore userStore,
    required IConnectivityService connectivity,
    required RefreshTokenHandler onRefreshToken,
    required AuthStatusRepository authStatus,
    Logger? logger,
  }) : _userStore = userStore,
       _connectivity = connectivity,
       _onRefreshToken = onRefreshToken,
       _authStatus = authStatus,
       _logger = logger;

  final TokenStore tokenStore;
  final UserStore _userStore;
  final IConnectivityService _connectivity;
  final RefreshTokenHandler _onRefreshToken;
  final AuthStatusRepository _authStatus;
  final Logger? _logger;

  Future<String?> get sessionId async {
    return (await _userStore.getUser())?.sessionId;
  }

  late final GraphQLClient client;
  WebSocketLink? _wsLink;

  StreamController<void>? _reconnectController;
  StreamSubscription<bool>? _connectivitySubscription;

  bool _isRefreshing = false;
  Completer<void>? _refreshCompleter;

  Future<void> init(String graphqlUrl, {String? wsUrl}) async {
    final httpLink = HttpLink(
      graphqlUrl,
      defaultHeaders: {'x-client-key': EnvConfig.instance.clientKey},
    );

    final authLink = AuthLink(
      getToken: () async {
        final tokenObj = await tokenStore.read();
        return tokenObj?.authorization;
      },
    );

    late final Link link;

    // If WebSocket URL is provided, create split link
    if (wsUrl != null) {
      _wsLink = WebSocketLink(
        wsUrl,
        subProtocol: GraphQLProtocol.graphqlTransportWs,
        config: SocketClientConfig(
          initialPayload: () async {
            final tokenObj = await tokenStore.read();
            return {
              HttpHeaders.authorizationHeader: tokenObj?.authorization,
              'x-client-key': EnvConfig.instance.clientKey,
            };
          },
        ),
      );

      // Split: WebSocket for subscriptions, HTTP for queries/mutations
      link = authLink
          .concat(
            Link.split((request) => request.isSubscription, _wsLink!, httpLink),
          )
          .concat(DedupeLink());
    } else {
      link = authLink.concat(httpLink).concat(DedupeLink());
    }

    // Listen to connectivity changes to trigger catch-up syncs
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      connected,
    ) {
      if (connected) {
        _logger?.info('Network reachable, triggering reconnection sync');
        _reconnectController?.add(null);
      }
    });

    client = GraphQLClient(
      link: link,
      cache: GraphQLCache(store: HiveStore()),
      queryRequestTimeout: const Duration(seconds: 20),
    );
  }

  void dispose() {
    _wsLink?.dispose();
    _connectivitySubscription?.cancel();
    _reconnectController?.close();
  }

  Stream<QueryResult<T>> subscribe<T>(
    String document, {
    Map<String, dynamic>? variables,
  }) {
    _logger?.debug(
      'Starting GraphQL subscription',
      extra: {'document': document, 'variables': variables},
    );
    return client.subscribe<T>(
      SubscriptionOptions<T>(
        document: gql(document),
        variables: variables ?? {},
      ),
    );
  }

  /// Starts a GraphQL subscription and executes [onSync] catch-up logic
  /// whenever the connection is established or restored.
  Stream<QueryResult<T>> subscribeWithSync<T>(
    String document, {
    required Future<void> Function() onSync,
    Map<String, dynamic>? variables,
  }) {
    // 2. Listen to internal reconnection events (socket or network)
    // We use a separate subscription because we don't want to cancel the main one
    // when this method is called multiple times.
    _reconnectController ??= StreamController<void>.broadcast();
    _reconnectController?.stream.listen((_) {
      _logger?.info('Subscription catch-up sync triggered');
      onSync();
    });

    return subscribe<T>(document, variables: variables);
  }

  Future<void> refreshAccessToken(OAuthToken token) async {
    if (_isRefreshing) {
      return _refreshCompleter?.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<void>();
    _logger?.info('Starting token refresh');

    try {
      final newToken = await _onRefreshToken(token, client);
      if (newToken != null) {
        await tokenStore.write(newToken);
        _logger?.info('Token refreshed successfully');
      } else {
        _logger?.warn('Token refresh returned null, clearing local tokens');
        await tokenStore.delete();
      }
    } on Object catch (e) {
      _logger?.error('Token refresh error: $e');
      // Only delete on authentication failure, not transient network errors
      if (e is OperationException) {
        if (_isAuthenticationError(
          QueryResult(
            exception: e,
            source: QueryResultSource.network,
            options: QueryOptions(document: gql('')),
          ),
        )) {
          _logger?.warn('Authentication failed during refresh, clearing token');
          await tokenStore.delete();
          _authStatus.setUnauthenticated();
        }
      }
      rethrow;
    } finally {
      _isRefreshing = false;
      _refreshCompleter?.complete();
      _refreshCompleter = null;
    }
  }

  Future<QueryResult<T>> query<T>(
    String document, {
    Map<String, dynamic>? variables,
    int maxRetries = 2,
    Duration retryDelay = const Duration(seconds: 1),
    bool useCache = true,
  }) async {
    _logger?.debug(
      'Executing GraphQL query',
      extra: {'document': document, 'variables': variables},
    );

    // Try network first, fallback to cache on failure
    final result = await _executeWithRetry<T>(
      () => client.query<T>(
        QueryOptions<T>(
          document: gql(document),
          variables: variables ?? {},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      ),
      maxRetries: maxRetries,
      retryDelay: retryDelay,
    );

    // If network succeeded, return result
    if (!result.hasException) return result;

    // Network failed, try cache if enabled
    if (useCache) {
      try {
        _logger?.info('Network failed, trying cache fallback');
        final cacheResult = await client.query<T>(
          QueryOptions<T>(
            document: gql(document),
            variables: variables ?? {},
            fetchPolicy: FetchPolicy.cacheOnly,
          ),
        );

        // Return cache result if it has data, otherwise return network error
        if (cacheResult.data != null && !cacheResult.hasException) {
          _logger?.info('Cache fallback successful');
          return cacheResult;
        }
      } on Object catch (e) {
        _logger?.warn('Cache fallback failed: $e');
      }
    }

    return result;
  }

  Future<QueryResult<T>> mutate<T>(
    String document, {
    Map<String, dynamic>? variables,
    int maxRetries = 2,
    Duration retryDelay = const Duration(seconds: 3),
  }) async {
    _logger?.debug(
      'Executing GraphQL mutation',
      extra: {'document': document, 'variables': variables},
    );
    return _executeWithRetry<T>(
      () => client.mutate<T>(
        MutationOptions<T>(document: gql(document), variables: variables ?? {}),
      ),
      maxRetries: maxRetries,
      retryDelay: retryDelay,
    );
  }

  Future<QueryResult<T>> _executeWithRetry<T>(
    Future<QueryResult<T>> Function() operation, {
    required int maxRetries,
    required Duration retryDelay,
  }) async {
    var attempts = 0;
    QueryResult<T>? lastError;

    while (attempts <= maxRetries) {
      try {
        final result = await operation();

        if (result.hasException) {
          final isAuthError = _isAuthenticationError(result);
          if (isAuthError && attempts < maxRetries) {
            _logger?.info('Authentication error detected');
            attempts++;
            try {
              final token = await tokenStore.read();
              if (token == null) {
                // If we reach here with an auth error but no token,
                // it means we're genuinely unauthenticated.
                _authStatus.setUnauthenticated();
                return result;
              }

              // Try to refresh to sync latest roles/permissions
              _logger?.info(
                'Auth error detected, attempting refresh to sync latest roles',
              );
              await refreshAccessToken(token);
              // Retry immediately after refresh
              continue;
            } on Object catch (e) {
              // Only logout if it's an explicit authentication error during refresh
              // Rethrow or return result for transient errors
              _logger?.error('Token refresh failed during retry: $e');
              if (e is OperationException &&
                  _isAuthenticationError(
                    QueryResult(
                      exception: e,
                      source: QueryResultSource.network,
                      options: QueryOptions(document: gql('')),
                    ),
                  )) {
                _authStatus.setUnauthenticated();
              }
              return result;
            }
          }

          // Check if error is retryable
          if (_isRetryable(result.exception) && attempts < maxRetries) {
            _logger?.warn(
              'Retryable error, attempt ${attempts + 1}/${maxRetries + 1}',
            );
            lastError = result;
            attempts++;
            await Future<void>.delayed(retryDelay * attempts);
            continue;
          }

          _logger?.error(
            'GraphQL operation failed',
            extra: {'exception': result.exception},
          );
          return result;
        }

        return result;
      } on Object catch (e) {
        _logger?.error('GraphQL operation exception: $e');
        if (_isRetryable(e) && attempts < maxRetries) {
          _logger?.warn(
            'Retrying after exception, attempt ${attempts + 1}/${maxRetries + 1}',
          );
          attempts++;
          await Future<void>.delayed(retryDelay * attempts);
          continue;
        }
        rethrow;
      }
    }

    return lastError ?? (throw Exception('Operation failed'));
  }

  bool _isRetryable(dynamic error) {
    if (error is OperationException) {
      final linkException = error.linkException;

      if (linkException is NetworkException) {
        return true;
      }

      if (linkException is ServerException) {
        final statusCode =
            linkException.parsedResponse?.response['statusCode'] as int?;
        return statusCode != null && statusCode >= 500;
      }

      final graphQLErrors = error.graphqlErrors;
      if (graphQLErrors.isNotEmpty) {
        final code = graphQLErrors.first.extensions?['code']?.toString();

        return GraphQLErrorCodes.isNetworkError(code) ||
            GraphQLErrorCodes.isServerError(code);
      }
    }

    if (error is TimeoutException) {
      return true;
    }

    return false;
  }

  bool _isAuthenticationError(QueryResult result) {
    if (!result.hasException) return false;

    final exception = result.exception!;

    // Check Link Exception (ServerException with 401)
    final linkEx = exception.linkException;
    if (linkEx is ServerException) {
      final statusCode = linkEx.parsedResponse?.response['statusCode'] as int?;
      if (statusCode == 401) return true;
    }

    // Check GraphQLError codes
    final graphQLErrors = exception.graphqlErrors;
    if (graphQLErrors.isNotEmpty) {
      final code = graphQLErrors.first.extensions?['code']?.toString();
      if (GraphQLErrorCodes.isAuthError(code)) return true;
    }

    return false;
  }

  static Future<OAuthToken?> defaultRefreshToken(
    OAuthToken? currentToken,
    GraphQLClient _,
  ) async {
    final refreshToken = currentToken?.refreshToken;
    if (refreshToken == null) return null;

    final refreshClient = GraphQLClient(
      link: HttpLink(EnvConfig.instance.graphqlUrl),
      cache: GraphQLCache(),
    );

    final result = await refreshClient.mutate<Map<String, dynamic>>(
      MutationOptions<Map<String, dynamic>>(
        document: gql(r'''
                  mutation RefreshToken($token: String!) {
                    refreshToken(token: $token) {
                      access_token
                      refresh_token
                      token_type
                      expires_in
                    }
                  }
                '''),
        variables: {'token': refreshToken},
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final data = result.data?['refreshToken'];
    if (data == null) {
      return null;
    }

    return const OAuthTokenCodec().decode(data as Map<String, dynamic>);
  }
}
