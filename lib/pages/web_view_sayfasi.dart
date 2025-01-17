import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewSayfasi extends StatefulWidget {
  final String url;
  final String baslik;

  const WebViewSayfasi({
    super.key,
    required this.url,
    required this.baslik,
  });

  @override
  State<WebViewSayfasi> createState() => _WebViewSayfasiState();
}

class _WebViewSayfasiState extends State<WebViewSayfasi> {
  late final WebViewController _controller;
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _yukleniyor = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _yukleniyor = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.baslik),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_yukleniyor)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
} 