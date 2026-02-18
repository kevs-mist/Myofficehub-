import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:myofficehub/app.dart';

void main() {
  test('App widget can be instantiated', () {
    const app = ProviderScope(child: MyOfficeHubApp());
    expect(app, isA<Widget>());
  });
}
