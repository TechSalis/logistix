import 'package:shared/shared.dart';

abstract class CapturedOrderRemoteDataSource {
  Future<bool> uploadBatch(String base64Gzip);
}

class CapturedOrderRemoteDataSourceImpl extends BaseRemoteDataSource
    implements CapturedOrderRemoteDataSource {
  CapturedOrderRemoteDataSourceImpl(super.gqlService);

  @override
  Future<bool> uploadBatch(String base64Gzip) async {
    const mutation = r'''
      mutation UploadCapturedOrderBatch($batch: String!) {
        uploadCapturedOrderBatch(batch: $batch)
      }
    ''';

    return mutate<bool>(
      mutation,
      key: 'uploadCapturedOrderBatch',
      variables: {
        'batch': base64Gzip,
      },
    );
  }
}
