import 'dart:typed_data';

import 'package:alice_lightweight/helper/alice_save_helper.dart';
import 'package:alice_lightweight/model/alice_http_call.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

/// Returns the global rect of the widget behind [context], for share_plus.
/// The share sheet is a popover on iPad and, since iOS 26, on iPhone too,
/// and it doesn't open without a non-empty source rect.
Rect? sharePositionOrigin(BuildContext? context) {
  if (context == null || !context.mounted) {
    return null;
  }
  final box = context.findRenderObject();
  if (box is! RenderBox || !box.hasSize) {
    return null;
  }
  return box.localToGlobal(Offset.zero) & box.size;
}

Future<XFile> saveLogs(List<AliceHttpCall> logs) async {
  final callStrings = await Future.wait(
      logs.map((log) async => await AliceSaveHelper.buildCallLog(log)));

  final String logsString = callStrings.fold('', (value, log) {
    if (value.isEmpty) {
      return log;
    }
    return "$value\n\n\n$log";
  });

  final bytes = Uint8List.fromList(logsString.codeUnits);
  final file = XFile.fromData(bytes);

  return file;
}

void shareFile(XFile file, {Rect? sharePositionOrigin}) {
  SharePlus.instance.share(
    ShareParams(
      files: [file],
      title: 'Alice - HTTP Call Details',
      subject: "Alice logs",
      sharePositionOrigin: sharePositionOrigin,
    ),
  );
}
