import 'dart:async';
import 'dart:io';
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
    required RefreshTokenHandler onRefreshToken,
    Logger? logger,
  }) : _onRefreshToken = onRefreshToken,
       _logger = logger;

  final TokenStore tokenStore;
  final RefreshTokenHandler _onRefreshToken;
  final Logger? _logger;

  late final GraphQLClient client;

  bool _isRefreshing = false;
  Completer<void>? _refreshCompleter;

  Future<void> init(String graphqlUrl, {String? wsUrl}) async {
    final httpLink = HttpLink(graphqlUrl);

    final authLink = AuthLink(
      getToken: () async {
        final tokenObj = await tokenStore.read();
        return tokenObj?.authorization;
      },
    );

    var link = authLink.concat(httpLink).concat(DedupeLink());

    if (wsUrl != null && wsUrl.isNotEmpty) {
      final wsLink = WebSocketLink(
        wsUrl,
        config: SocketClientConfig(
          initialPayload: () async {
            final tokenObj = await tokenStore.read();
            return {HttpHeaders.authorizationHeader: tokenObj?.authorization};
          },
        ),
      );

      link = Link.split((request) => request.isSubscription, wsLink, link);
    }

    client = GraphQLClient(
      link: link,
      cache: GraphQLCache(store: HiveStore()),
      queryRequestTimeout: const Duration(seconds: 10),
    );
  }

  Stream<QueryResult> subscribe(
    String document, {
    Map<String, dynamic>? variables,
  }) {
    _logger?.debug(
      'Starting GraphQL subscription',
      extra: {'document': document, 'variables': variables},
    );
    return client.subscribe(
      SubscriptionOptions(document: gql(document), variables: variables ?? {}),
    );
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
        await tokenStore.delete();
        _logger?.warn('Token refresh failed, clearing token');
      }
    } catch (e) {
      _logger?.error('Token refresh error: $e');
      await tokenStore.delete();
      rethrow;
    } finally {
      _isRefreshing = false;
      _refreshCompleter?.complete();
      _refreshCompleter = null;
    }
  }

  Future<QueryResult> query(
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
    try {
      final result = await _executeWithRetry(
        () => client.query(
          QueryOptions(
            document: gql(document),
            variables: variables ?? {},
            fetchPolicy: FetchPolicy.cacheAndNetwork,
          ),
        ),
        maxRetries: maxRetries,
        retryDelay: retryDelay,
      );

      // If network succeeded, return result
      if (!result.hasException) return result;

      // Network failed, try cache if enabled
      if (useCache) {
        _logger?.info('Network failed, trying cache fallback');
        final cacheResult = await client.query(
          QueryOptions(
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
      }

      return result;
    } catch (e) {
      // On exception, try cache fallback if enabled
      if (useCache) {
        _logger?.info('Exception occurred, trying cache fallback');
        try {
          final cacheResult = await client.query(
            QueryOptions(
              document: gql(document),
              variables: variables ?? {},
              fetchPolicy: FetchPolicy.cacheOnly,
            ),
          );

          if (cacheResult.data != null && !cacheResult.hasException) {
            _logger?.info('Cache fallback successful after exception');
            return cacheResult;
          }
        } catch (_) {
          // Cache also failed, rethrow original exception
        }
      }
      rethrow;
    }
  }

  Future<QueryResult> mutate(
    String document, {
    Map<String, dynamic>? variables,
    int maxRetries = 2,
    Duration retryDelay = const Duration(seconds: 3),
  }) async {
    _logger?.debug(
      'Executing GraphQL mutation',
      extra: {'document': document, 'variables': variables},
    );
    return _executeWithRetry(
      () => client.mutate(
        MutationOptions(document: gql(document), variables: variables ?? {}),
      ),
      maxRetries: maxRetries,
      retryDelay: retryDelay,
    );
  }

  Future<QueryResult> _executeWithRetry(
    Future<QueryResult> Function() operation, {
    required int maxRetries,
    required Duration retryDelay,
  }) async {
    var attempts = 0;
    QueryResult? lastError;

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
              if (token == null) return result;

              // Check if token is actually expired before refreshing
              if (_isTokenExpired(token)) {
                _logger?.info('Token expired, attempting refresh');
                await refreshAccessToken(token);
                // Retry immediately after refresh
                continue;
              } else {
                // Token is not expired, so this is a genuine auth error
                _logger?.warn(
                  'Auth error with non-expired token, not refreshing',
                );
                return result;
              }
            } catch (_) {
              // Refresh failed, let the error bubble up
              _logger?.error('Token refresh failed during retry');
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

  bool _isTokenExpired(OAuthToken token) {
    // If expiresAt is null, we can't determine expiration, so we assume not expired
    final expiresAt = token.expiresAt;
    if (expiresAt == null) return false;

    // Add a small buffer (30 seconds) to refresh before actual expiration
    final now = DateTime.now();
    const bufferTime = Duration(seconds: 30);

    return now.add(bufferTime).isAfter(expiresAt);
  }

  static Future<OAuthToken?> defaultRefreshToken(
    OAuthToken? currentToken,
    GraphQLClient _,
  ) async {
    final refreshToken = currentToken?.refreshToken;
    if (refreshToken == null) return null;

    final refreshClient = GraphQLClient(
      link: HttpLink(EnvConfig.refreshUrl),
      cache: GraphQLCache(),
    );

    final result = await refreshClient.mutate(
      MutationOptions(
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

    if (result.hasException) return null;

    final data = result.data?['refreshToken'];
    if (data == null) return null;

    return const OAuthTokenCodec().decode(data as Map<String, dynamic>);
  }
}
