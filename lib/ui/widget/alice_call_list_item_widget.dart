import 'package:alice_lightweight/helper/alice_conversion_helper.dart';
import 'package:alice_lightweight/model/alice_http_call.dart';
import 'package:alice_lightweight/model/alice_http_response.dart';
import 'package:alice_lightweight/utils/alice_constants.dart';
import 'package:alice_lightweight/utils/alice_custom_colors.dart';
import 'package:flutter/material.dart';

class AliceCallListItemWidget extends StatelessWidget {
  final AliceHttpCall call;
  final Function itemClickAction;
  final AliceCustomColors customColors;

  const AliceCallListItemWidget(
    this.call,
    this.itemClickAction,
    this.customColors,
  );

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => itemClickAction(call),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMethodAndEndpointRow(context),
                      const SizedBox(height: 4),
                      _buildServerRow(),
                      const SizedBox(height: 4),
                      _buildStatsRow(),
                    ],
                  ),
                ),
                _buildResponseColumn(context),
              ],
            ),
          ),
          _buildDivider(),
        ],
      ),
    );
  }

  Widget _buildMethodAndEndpointRow(BuildContext context) {
    Color textColor = _getEndpointTextColor(context);
    return Row(
      children: [
        Text(call.method, style: TextStyle(fontSize: 16, color: textColor)),
        Padding(padding: EdgeInsets.only(left: 10)),
        Flexible(
          child: Container(
            child: Text(
              call.endpoint,
              overflow: TextOverflow.visible,
              style: TextStyle(fontSize: 16, color: textColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServerRow() {
    return Row(
      children: [
        _getSecuredConnectionIcon(call.secure),
        Expanded(
          child: Text(
            call.server,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 1,
          child: Text(
            _formatTime(call.request?.time),
            style: TextStyle(fontSize: 12),
          ),
        ),
        Flexible(
          flex: 1,
          child: Text(
            "${AliceConversionHelper.formatTime(call.duration)}",
            style: TextStyle(fontSize: 12),
          ),
        ),
        Flexible(
          flex: 1,
          child: Text(
            "${AliceConversionHelper.formatBytes(call.request?.size ?? 0)} / "
            "${AliceConversionHelper.formatBytes(call.response?.size ?? 0)}",
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: AliceConstants.grey(customColors));
  }

  String _formatTime(DateTime? time) {
    if (time == null) {
      return '';
    }

    return "${formatTimeUnit(time.hour)}:"
        "${formatTimeUnit(time.minute)}:"
        "${formatTimeUnit(time.second)}:"
        "${formatTimeUnit(time.millisecond)}";
  }

  String formatTimeUnit(int timeUnit) {
    return (timeUnit < 10) ? "0$timeUnit" : "$timeUnit";
  }

  Widget _buildResponseColumn(BuildContext context) {
    List<Widget> widgets = [];
    if (call.loading) {
      widgets.add(
        SizedBox(
          child: new CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(
              AliceConstants.lightRed(customColors),
            ),
          ),
          width: 20,
          height: 20,
        ),
      );
      widgets.add(const SizedBox(height: 4));
    }
    widgets.add(
      Text(
        _getStatus(call.response),
        style: TextStyle(fontSize: 16, color: _getStatusTextColor(context)),
      ),
    );
    return Container(
      width: 50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: widgets,
      ),
    );
  }

  Color _getStatusTextColor(BuildContext context) {
    int status = call.response?.status ?? -1;
    if (status == -1) {
      return AliceConstants.red(customColors);
    } else if (status < 200) {
      return Theme.of(context).textTheme.bodyLarge?.color ?? Colors.green;
    } else if (status >= 200 && status < 300) {
      return AliceConstants.green(customColors);
    } else if (status >= 300 && status < 400) {
      return AliceConstants.orange(customColors);
    } else if (status >= 400 && status < 600) {
      return AliceConstants.red(customColors);
    } else {
      return Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    }
  }

  Color _getEndpointTextColor(BuildContext context) {
    if (call.loading) {
      return AliceConstants.grey(customColors);
    } else {
      return _getStatusTextColor(context);
    }
  }

  String _getStatus(AliceHttpResponse? response) {
    if (response == null) {
      return 'null';
    }
    if (response.status == -1) {
      return "ERR";
    } else if (response.status == 0) {
      return "???";
    } else {
      return "${response.status}";
    }
  }

  Widget _getSecuredConnectionIcon(bool secure) {
    IconData iconData;
    Color iconColor;
    if (secure) {
      iconData = Icons.lock_outline;
      iconColor = AliceConstants.green(customColors);
    } else {
      iconData = Icons.lock_open;
      iconColor = AliceConstants.red(customColors);
    }
    return Padding(
      padding: EdgeInsets.only(right: 3),
      child: Icon(iconData, color: iconColor, size: 12),
    );
  }
}
