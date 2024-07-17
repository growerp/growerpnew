import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  try {
    await integrationDriver(
      onScreenshot: (screenshotName, screenshotBytes, [args]) async {
        final File image = await File('screenshots/$screenshotName.png')
            .create(recursive: true);
        image.writeAsBytesSync(screenshotBytes);
        return true;
      },
    );
  } catch (e) {
    debugPrint('Error occured: $e');
  }
}
