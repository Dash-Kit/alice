import 'package:alice_lightweight/core/alice_core.dart';
import 'package:alice_lightweight/helper/alice_save_helper.dart';
import 'package:alice_lightweight/model/alice_http_call.dart';
import 'package:alice_lightweight/ui/widget/alice_call_error_widget.dart';
import 'package:alice_lightweight/ui/widget/alice_call_overview_widget.dart';
import 'package:alice_lightweight/ui/widget/alice_call_request_widget.dart';
import 'package:alice_lightweight/ui/widget/alice_call_response_widget.dart';
import 'package:alice_lightweight/utils/alice_constants.dart';
import 'package:alice_lightweight/utils/alice_custom_colors.dart';
import 'package:alice_lightweight/utils/alice_share_logs.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class AliceCallDetailsScreen extends StatefulWidget {
  final AliceHttpCall call;
  final AliceCore core;
  final AliceCustomColors customColors;

  AliceCallDetailsScreen(this.call, this.core, this.customColors);

  @override
  _AliceCallDetailsScreenState createState() => _AliceCallDetailsScreenState();
}

class _AliceCallDetailsScreenState extends State<AliceCallDetailsScreen>
    with SingleTickerProviderStateMixin {
  AliceHttpCall get call => widget.call;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Theme(
      data: ThemeData(
        brightness: brightness,
        colorScheme: ColorScheme.fromSeed(
          seedColor: brightness == Brightness.dark
              ? AliceConstants.green(widget.customColors)
              : AliceConstants.blue(widget.customColors),
          brightness: brightness,
        ),
      ),
      child: StreamBuilder<List<AliceHttpCall>>(
        stream: widget.core.callsSubject,
        initialData: [widget.call],
        builder: (context, callsSnapshot) {
          if (callsSnapshot.hasData) {
            AliceHttpCall? call = callsSnapshot.data?.firstWhere(
                (snapshotCall) => snapshotCall.id == widget.call.id,
                orElse: null);
            if (call != null) {
              return _buildMainWidget();
            } else {
              return _buildErrorWidget();
            }
          } else {
            return _buildErrorWidget();
          }
        },
      ),
    );
  }

  Widget _buildMainWidget() {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        floatingActionButton: GestureDetector(
          key: Key('quick_share_action_key'),
          onLongPress: () => widget.core.quickShareAction?.call(call),
          child: Builder(
            builder: (buttonContext) => FloatingActionButton(
              backgroundColor: AliceConstants.lightRed(widget.customColors),
              key: Key('share_key'),
              onPressed: () async {
                final origin = sharePositionOrigin(buttonContext);
                SharePlus.instance.share(
                  ShareParams(
                    title: 'Alice - HTTP Call Details',
                    subject: 'Request Details',
                    text: await _getSharableResponseString(),
                    sharePositionOrigin: origin,
                  ),
                );
              },
              child: Icon(Icons.share, color: Colors.white),
            ),
          ),
        ),
        appBar: AppBar(
          bottom: TabBar(
            indicatorColor: AliceConstants.lightRed(widget.customColors),
            tabs: _getTabBars(),
          ),
          title: Text('Alice - HTTP Call Details'),
        ),
        body: TabBarView(
          children: _getTabBarViewList(),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(child: Text("Failed to load data"));
  }

  Future<String> _getSharableResponseString() async {
    return AliceSaveHelper.buildCallLog(widget.call);
  }

  List<Widget> _getTabBars() {
    List<Widget> widgets = [];
    widgets.add(Tab(icon: Icon(Icons.info_outline), text: "Overview"));
    widgets.add(Tab(icon: Icon(Icons.arrow_upward), text: "Request"));
    widgets.add(Tab(icon: Icon(Icons.arrow_downward), text: "Response"));
    widgets.add(
      Tab(
        icon: Icon(Icons.warning),
        text: "Error",
      ),
    );
    return widgets;
  }

  List<Widget> _getTabBarViewList() {
    List<Widget> widgets = [];
    widgets.add(AliceCallOverviewWidget(widget.call));
    widgets.add(AliceCallRequestWidget(widget.call));
    widgets.add(AliceCallResponseWidget(widget.call, widget.customColors));
    widgets.add(AliceCallErrorWidget(widget.call));
    return widgets;
  }
}
