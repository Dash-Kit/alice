import 'dart:async';

import 'package:alice_lightweight/model/alice_http_call.dart';
import 'package:alice_lightweight/model/alice_http_error.dart';
import 'package:alice_lightweight/model/alice_http_response.dart';
import 'package:alice_lightweight/ui/page/alice_calls_list_screen.dart';
import 'package:alice_lightweight/utils/alice_custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class AliceCore {
  /// Rx subject which contains all intercepted http calls
  final BehaviorSubject<List<AliceHttpCall>> callsSubject =
      BehaviorSubject.seeded([]);
  final AliceCustomColors customColors;

  /// Function which will be called on long press on share button.
  /// It has AliceHttpCall as argument and should be used to handle share action.
  ///
  /// By default it will share cURL command.
  final void Function(AliceHttpCall aliceHttpCall)? quickShareAction;

  GlobalKey<NavigatorState> _navigatorKey;
  bool _isInspectorOpened = false;
  StreamSubscription? _callsSubscription;

  /// Creates alice core instance
  AliceCore(this._navigatorKey, this.customColors, [this.quickShareAction]);

  /// Dispose subjects and subscriptions
  void dispose() {
    callsSubject.close();
    _callsSubscription?.cancel();
  }

  /// Set custom navigation key. This will help if there's route library.
  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    this._navigatorKey = navigatorKey;
  }

  /// Opens Http calls inspector. This will navigate user to the new fullscreen
  /// page where all listened http calls can be viewed.
  void navigateToCallListScreen() {
    var context = getContext();
    if (context == null) {
      print(
          "Cant start Alice HTTP Inspector. Please add NavigatorKey to your application");
      return;
    }
    if (!_isInspectorOpened) {
      _isInspectorOpened = true;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AliceCallsListScreen(this, customColors),
        ),
      ).then((onValue) => _isInspectorOpened = false);
    }
  }

  /// Get context from navigator key. Used to open inspector route.
  BuildContext? getContext() => _navigatorKey.currentState?.overlay?.context;

  /// Add alice http call to calls subject
  void addCall(AliceHttpCall call) {
    callsSubject.add([...callsSubject.value, call]);
  }

  /// Add error to exisng alice http call
  void addError(AliceHttpError error, int requestId) {
    AliceHttpCall? selectedCall = _selectCall(requestId);

    if (selectedCall == null) {
      print("Selected call is null");
      return;
    }

    selectedCall.error = error;
    callsSubject.add([...callsSubject.value]);
  }

  /// Add response to existing alice http call
  void addResponse(AliceHttpResponse? response, int? requestId) {
    assert(response != null, "response can't be null");
    assert(requestId != null, "requestId can't be null");
    if (response == null || requestId == null) {
      return;
    }

    AliceHttpCall? selectedCall = _selectCall(requestId);

    if (selectedCall == null) {
      print("Selected call is null");
      return;
    }
    selectedCall.loading = false;
    selectedCall.response = response;
    if (selectedCall.request?.time.millisecondsSinceEpoch != null) {
      selectedCall.duration = response.time.millisecondsSinceEpoch -
          selectedCall.request!.time.millisecondsSinceEpoch;
    }

    callsSubject.add([...callsSubject.value]);
  }

  /// Add alice http call to calls subject
  void addHttpCall(AliceHttpCall aliceHttpCall) {
    assert(aliceHttpCall.request != null, "Http call request can't be null");
    assert(aliceHttpCall.response != null, "Http call response can't be null");
    callsSubject.add([...callsSubject.value, aliceHttpCall]);
  }

  /// Remove all calls from calls subject
  void removeCalls() {
    callsSubject.add([]);
  }

  AliceHttpCall? _selectCall(int requestId) => callsSubject.value
      .firstWhere((call) => call.id == requestId, orElse: null);
}
