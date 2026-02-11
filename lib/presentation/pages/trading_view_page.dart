import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TradingViewPage extends StatefulWidget {
  final String symbol;

  const TradingViewPage({super.key, required this.symbol});

  @override
  State<TradingViewPage> createState() => _TradingViewPageState();
}

class _TradingViewPageState extends State<TradingViewPage> {
  late final WebViewController controller;
  late final String html;

  @override
  void initState() {
    super.initState();

    /// FORCE LANDSCAPE
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    /// FULLSCREEN (hapus status & nav bar)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    html =
        '''
    <!DOCTYPE html>
    <html>
    <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
    <style>
    html, body, #tv_chart {
      margin:0;
      padding:0;
      height:100%;
      width:100%;
      background-color:#0d1117;
    }
    </style>
    </head>

    <body>
    <div id="tv_chart"></div>

    <script src="https://s3.tradingview.com/tv.js"></script>

    <script>
    new TradingView.widget({
      "container_id": "tv_chart",
      "autosize": true,
      "symbol": "${widget.symbol}",
      "interval": "15",
      "timezone": "Asia/Jakarta",
      "theme": "dark",
      "style": "1",
      "locale": "id",
      "hide_side_toolbar": false,
      "allow_symbol_change": false,
      "withdateranges": true,
      "save_image": false,
      "studies": ["RSI@tv-basicstudies","MACD@tv-basicstudies"],
    });
    </script>

    </body>
    </html>
    ''';

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..loadHtmlString(html);
  }

  @override
  void dispose() {
    /// BALIK KE NORMAL SAAT KELUAR
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            /// CHART FULLSCREEN
            Positioned.fill(child: WebViewWidget(controller: controller)),

            /// BACK BUTTON OVERLAY (kayak Binance)
            Positioned(
              top: 12,
              left: 12,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
