import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  const variables = ['MAPBOX_PUBLIC_TOKEN', 'API_URL'];
  const envs = ['.env.dev'];

  test('ensure $envs files are contain proper variables', () {
    for (var element in envs) {
      dotenv.testLoad(fileInput: File(element).readAsStringSync());
      for (var key in variables) {
        expect(dotenv.env[key], isNotEmpty);
      }
    }
  });
}
