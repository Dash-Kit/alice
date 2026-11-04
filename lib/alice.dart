import 'dart:io';

import 'package:alice_lightweight/core/alice_http_adapter.dart';
import 'package:http/http.dart' as http;
import 'package:alice_lightweight/core/alice_core.dart';
import 'package:alice_lightweight/core/alice_dio_interceptor.dart';
import 'package:alice_lightweight/core/alice_http_client_adapter.dart';
import 'package:alice_lightweight/model/alice_http_call.dart';
import 'package:alice_lightweight/utils/alice_custom_colors.dart';
import 'package:alice_lightweight/utils/alice_share_logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

export 'package:alice_lightweight/utils/alice_custom_colors.dart';

class Alice {
  /// Should inspector use dark theme
  final bool darkTheme;

  GlobalKey<NavigatorState> _navigatorKey;
  AliceCore _aliceCore;
  AliceHttpClientAdapter _httpClientAdapter;
  AliceHttpAdapter _httpAdapter;

  Alice._(this.darkTheme, this._navigatorKey, this._aliceCore,
      this._httpClientAdapter, this._httpAdapter);

  /// Creates alice instance.
  /// Usage Example
  /// ```dart
  /// Alice()
  ///   customColors: AliceCustomColors(
  ///     red: Colors.red,
  ///     green: Colors.blue
  ///   )
  /// )
  /// ```
  factory Alice({
    GlobalKey<NavigatorState> navigatorKey =
        const GlobalObjectKey<NavigatorState>('AliceNavigatorState'),
    @Deprecated(
      'This value is not used anymore. '
      'Theme.of(context).brightness is used instead',
    )
    bool darkTheme = false,
    AliceCustomColors customColors = const AliceCustomColors(),
    void Function(AliceHttpCall aliceHttpCall)? quickShareAction,
  }) {
    late final AliceCore aliceCore;
    final defaultQuickShareAction = (call) {
      SharePlus.instance.share(
        ShareParams(
          text: call.getCurlCommand(),
          subject: 'cURL Command',
          sharePositionOrigin: sharePositionOrigin(aliceCore.getContext()),
        ),
      );
    };
    aliceCore = AliceCore(
      navigatorKey,
      customColors,
      quickShareAction ?? defaultQuickShareAction,
    );
    final httpClientAdapter = AliceHttpClientAdapter(aliceCore);
    final httpAdapter = AliceHttpAdapter(aliceCore);

    return Alice._(
        darkTheme, navigatorKey, aliceCore, httpClientAdapter, httpAdapter);
  }

  /// Set custom navigation key. This will help if there's route library.
  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _aliceCore.setNavigatorKey(navigatorKey);
  }

  /// Get currently used navigation key
  GlobalKey<NavigatorState> getNavigatorKey() {
    return _navigatorKey;
  }

  /// Get Dio interceptor which should be applied to Dio instance.
  AliceDioInterceptor getDioInterceptor() {
    return AliceDioInterceptor(_aliceCore);
  }

  /// Handle request from HttpClient
  void onHttpClientRequest(HttpClientRequest request, {dynamic body}) {
    _httpClientAdapter.onRequest(request, body: body);
  }

  /// Handle response from HttpClient
  void onHttpClientResponse(
      HttpClientResponse response, HttpClientRequest request,
      {dynamic body}) {
    _httpClientAdapter.onResponse(response, request, body: body);
  }

  /// Handle both request and response from http package
  void onHttpResponse(http.Response response, {dynamic body}) {
    _httpAdapter.onResponse(response, body: body);
  }

  /// Opens Http calls inspector. This will navigate user to the new fullscreen
  /// page where all listened http calls can be viewed.
  void showInspector() {
    _aliceCore.navigateToCallListScreen();
  }

  /// Handle generic http call. Can be used to any http client.
  void addHttpCall(AliceHttpCall aliceHttpCall) {
    assert(aliceHttpCall.request != null, "Http call request can't be null");
    assert(aliceHttpCall.response != null, "Http call response can't be null");
    _aliceCore.addCall(aliceHttpCall);
  }
}
