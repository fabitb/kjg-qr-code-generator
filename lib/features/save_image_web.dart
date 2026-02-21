import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'package:flutter/widgets.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

extension PrettyQrImageExtension on QrImage {
  Future<String?> exportAsImage(
      final BuildContext context, {
        required final int size,
        required final PrettyQrDecoration decoration,
      }) async {
    final imageBytes = await toImageAsBytes(
      size: size,
      decoration: decoration,
      configuration: createLocalImageConfiguration(context),
    );

    final imageUrl = web.URL.createObjectURL(
      web.Blob([imageBytes!.buffer.asUint8List().toJS].toJS),
    );

    final saveImageAnchor =
        web.document.createElement('a') as web.HTMLAnchorElement
          ..href = imageUrl
          ..style.display = 'none'
          ..download = 'qr-code.png';

    web.document.body?.appendChild(saveImageAnchor);
    saveImageAnchor.click();

    web.URL.revokeObjectURL(imageUrl);
    web.document.body?.removeChild(saveImageAnchor);

    return null;
  }
}
