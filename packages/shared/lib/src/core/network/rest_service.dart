import 'dart:convert';
import 'dart:io';
import 'package:bootstrap/interfaces/http/token_store.dart';
import 'package:bootstrap/interfaces/logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:shared/shared.dart';

class RestService {
  RestService(
    this.tokenStore, {
    http.Client? client,
    Logger? logger,
  }) : _client = client ?? http.Client(),
       _logger = logger;

  final TokenStore tokenStore;
  final http.Client _client;
  final Logger? _logger;

  void dispose() {
    _client.close();
  }

  Future<Map<String, String>> _getRequestHeaders() async {
    final tokenObj = await tokenStore.read();
    return {
      HttpHeaders.authorizationHeader: tokenObj?.authorization ?? '',
      'x-client-key': EnvConfig.instance.clientKey,
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<http.Response> post(String path, {Object? body}) async {
    final url = Uri.parse('${EnvConfig.instance.apiUrl}$path');
    final headers = await _getRequestHeaders();
    
    _logger?.debug('REST POST: $url', extra: {'body': body});

    try {
      final response = await _client.post(
        url,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      
      _handleResponse(response);
      return response;
    } catch (e) {
      _logger?.error('REST POST error on $path: $e');
      rethrow;
    }
  }

  Future<http.Response> get(String path, {Map<String, String>? queryParams}) async {
    final baseUri = Uri.parse('${EnvConfig.instance.apiUrl}$path');
    final url = baseUri.replace(queryParameters: queryParams);
    final headers = await _getRequestHeaders();
    
    _logger?.debug('REST GET: $url');

    try {
      final response = await _client.get(url, headers: headers);
      _handleResponse(response);
      return response;
    } catch (e) {
      _logger?.error('REST GET error on $path: $e');
      rethrow;
    }
  }

  void _handleResponse(http.Response response) {
    if (response.statusCode >= 400) {
      _logger?.warn('REST Request failed', extra: {
        'url': response.request?.url.toString(),
        'status': response.statusCode,
        'body': response.body,
      });
    }
  }
}
