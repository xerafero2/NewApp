import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GeckoWebView extends StatefulWidget {
  final String url;
  final String userAgent;
  final void Function(GeckoWebViewController controller)? onReady;

  const GeckoWebView({
    super.key,
    required this.url,
    this.userAgent = '',
    this.onReady,
  });

  @override
  State<GeckoWebView> createState() => GeckoWebViewState();
}

class GeckoWebViewState extends State<GeckoWebView> {
  late final int _viewId;
  late final GeckoWebViewController _controller;

  static const _channel = MethodChannel('com.multibrowser/geckoview_manager');
  static int _nextId = 1;

  @override
  void initState() {
    super.initState();
    _viewId = _nextId++;
    _controller = GeckoWebViewController._('com.multibrowser/geckoview_$_viewId');
    _channel.invokeMethod('registerView', {'id': _viewId});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onReady?.call(_controller);
    });
  }

  @override
  void dispose() {
    _channel.invokeMethod('disposeView', {'id': _viewId});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AndroidView(
      viewType: 'com.multibrowser/geckoview',
      creationParams: {
        'id': _viewId,
        'url': widget.url,
        'userAgent': widget.userAgent,
      },
      creationParamsCodec: const StandardMessageCodec(),
      layoutDirection: TextDirection.ltr,
    );
  }
}

class GeckoWebViewController {
  final MethodChannel _channel;
  GeckoWebViewController._(String channelName) : _channel = MethodChannel(channelName);

  Future<void> load(String url) => _channel.invokeMethod('load', {'url': url});
  Future<void> reload() => _channel.invokeMethod('reload');
  Future<void> back() => _channel.invokeMethod('back');
  Future<void> forward() => _channel.invokeMethod('forward');
  Future<void> setUserAgent(String ua) =>
      _channel.invokeMethod('setUserAgent', {'ua': ua});
  Future<void> evaluateJS(String js) =>
      _channel.invokeMethod('evaluateJS', {'js': js});
}
