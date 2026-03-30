import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';

abstract class CapturedOrderRepository {
  Future<void> saveParsedResult(String? rawText, List<dynamic> orders);
  Future<void> syncBatches({int batchSize = 100, int threshold = 0});
  Future<int> getPendingCount();
}

class CapturedOrderRepositoryImpl implements CapturedOrderRepository {
  const CapturedOrderRepositoryImpl(this._capturedOrderDao, this.remoteDataSource);
  
  final CapturedOrderDao _capturedOrderDao;
  final CapturedOrderRemoteDataSource remoteDataSource;

  @override
  Future<void> saveParsedResult(String? rawText, List<dynamic> orders) async {
    final entries = orders.map((order) => CapturedOrdersCompanion.insert(
      rawText: Value(rawText),
      parsedData: jsonEncode(order),
    )).toList();
    
    await _capturedOrderDao.insertCapturedOrders(entries);
  }

  @override
  Future<int> getPendingCount() async {
    final count = await _capturedOrderDao.getPendingCount();
    return count ?? 0;
  }

  @override
  Future<void> syncBatches({int batchSize = 100, int threshold = 0}) async {
    // 1. Fetch non-uploaded orders
    final pendingOrders = await _capturedOrderDao.getPendingOrders();

    if (pendingOrders.isEmpty || pendingOrders.length < threshold) return;

    // 2. Group into batches
    for (var i = 0; i < pendingOrders.length; i += batchSize) {
      final chunk = pendingOrders.sublist(
        i,
        i + batchSize > pendingOrders.length
            ? pendingOrders.length
            : i + batchSize,
      );

      final batchData = {
        'metadata': {
          'count': chunk.length,
          'exportedAt': DateTime.now().toIso8601String(),
          'batchId': DateTime.now().millisecondsSinceEpoch,
        },
        'orders': chunk
            .map(
              (o) => {
                'id': o.id,
                'rawText': o.rawText,
                'parsedData': jsonDecode(o.parsedData),
                'capturedAt': o.capturedAt.toIso8601String(),
              },
            )
            .toList(),
      };

      // 3. Compress & Encode (Offload to Isolate)
      final base64Batch = await compute(_compressAndEncode, batchData);

      // 4. Upload
      final success = await remoteDataSource.uploadBatch(base64Batch);

      if (success) {
        // 5. Mark as uploaded
        final ids = chunk.map((o) => o.id).toList();
        await _capturedOrderDao.markAsUploaded(ids);
      }
    }
  }

  /// Heavy lifting helper for compute isolate
  static String _compressAndEncode(Map<String, dynamic> data) {
    final jsonString = jsonEncode(data);
    final bytes = utf8.encode(jsonString);
    final compressed = gzip.encode(bytes);
    return base64.encode(compressed);
  }
}
