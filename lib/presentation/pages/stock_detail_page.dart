import 'dart:async';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';

import '../../data/services/mock_tick_service.dart';
import '../widgets/candle_builder.dart';
import 'trading_view_page.dart';

//versi candle
class StockDetailPage extends StatefulWidget {
  final String symbol;

  const StockDetailPage({super.key, required this.symbol});

  @override
  State<StockDetailPage> createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage> {
  final ChartController _controller = ChartController();
  final MockTickService _tickService = MockTickService();

  final CandleBuilder _builder = CandleBuilder(timeframe: 60);

  List<Candle> _candles = [];
  StreamSubscription? _sub;

  late DataSeries<Candle> _mainSeries;

  @override
  void initState() {
    super.initState();

    _tickService.start();

    _sub = _tickService.stream.listen((tick) {
      final newCandle = _builder.addTick(tick);

      setState(() {
        _candles = List.from(_builder.candles);

        // update candle berjalan (VERY IMPORTANT)
        if (_builder.candles.isNotEmpty) {
          _candles[_candles.length - 1] = _builder.candles.last;
        }

        // simpan history lebih panjang (ini penting buat scale)
        if (_candles.length > 120) {
          _candles.removeAt(0);
        }

        _mainSeries = CandleSeries(
          _candles,
          style: const CandleStyle(
            candleBullishBodyColor: Color(0xFF00C390),
            candleBearishBodyColor: Color(0xFFDE0040),
            candleBullishWickColor: Color(0xFF00C390),
            candleBearishWickColor: Color(0xFFDE0040),
            neutralColor: Color(0xFF6E6E6E),
          ),
        );
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.scrollToLastTick();
      });
    });

    // _sub = _tickService.stream.listen((tick) {
    //   final newCandle = _builder.addTick(tick);

    //   setState(() {
    //     _candles = List.from(_builder.candles);

    //     // update candle berjalan
    //     if (newCandle == null && _builder.candles.isNotEmpty) {
    //       _candles[_candles.length - 1] = _builder.candles.last;
    //     }

    //     // limit history (VERY IMPORTANT)
    //     if (_candles.length > 200) {
    //       _candles.removeAt(0);
    //     }

    //     _mainSeries = CandleSeries(
    //       _candles,
    //       style: const CandleStyle(
    //         candleBullishBodyColor: Color(0xFF00C390),
    //         candleBearishBodyColor: Color(0xFFDE0040),
    //         candleBullishWickColor: Color(0xFF00C390),
    //         candleBearishWickColor: Color(0xFFDE0040),
    //         neutralColor: Color(0xFF6E6E6E),
    //       ),
    //     );
    //   });

    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     _controller.scrollToLastTick();
    //   });
    // });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _tickService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_candles.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.symbol),
        actions: [
          IconButton(
            icon: const Icon(Icons.candlestick_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TradingViewPage(symbol: widget.symbol),
                ),
              );
            },
          ),
        ],
      ),

      body: ListView(
        children: [
          /// MAIN CHART
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: DerivChart(
              controller: _controller,
              mainSeries: _mainSeries,
              activeSymbol: widget.symbol,
              granularity: 60,
              pipSize: 2,
              isLive: true,
              dataFitEnabled: true,
              showCrosshair: true,
              verticalPaddingFraction: 0.25,
              showCurrentTickBlinkAnimation: true,

              /// MODERN TRADING LOOK
              chartAxisConfig: const ChartAxisConfig(
                defaultIntervalWidth: 22, // zoom level
                showQuoteGrid: true,
                showEpochGrid: true,
                showFrame: false,
                smoothScrolling: true,
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// FULL CHART BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.open_in_full),
              label: const Text("Open Advanced Chart"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TradingViewPage(symbol: widget.symbol),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

//versi tick
// class StockDetailPage extends StatefulWidget {
//   final String symbol;

//   const StockDetailPage({super.key, required this.symbol});

//   @override
//   State<StockDetailPage> createState() => _StockDetailPageState();
// }

// class _StockDetailPageState extends State<StockDetailPage> {
//   final ChartController _controller = ChartController();
//   final MockTickService _tickService = MockTickService();

//   List<Tick> _ticks = [];

//   late DataSeries<Tick> _mainSeries;
//   StreamSubscription? _sub;

//   @override
//   void initState() {
//     super.initState();

//     // start mock websocket
//     _tickService.start();

//     // listen tick stream
//     _sub = _tickService.stream.listen((tick) {
//       setState(() {
//         _ticks = List.from(_ticks)..add(tick);

//         // limit buffer (VERY IMPORTANT, kalau tidak app kamu nanti drop FPS)
//         if (_ticks.length > 300) {
//           _ticks.removeAt(0);
//         }

//         _mainSeries = LineSeries(_ticks);
//       });

//       // auto scroll ke harga terbaru
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _controller.scrollToLastTick();
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _sub?.cancel();
//     _tickService.stop();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.symbol)),
//       body: _ticks.isEmpty
//           ? const Center(child: CircularProgressIndicator())
//           : ListView(
//               children: [
//                 SizedBox(
//                   height: 360,
//                   child: DerivChart(
//                     controller: _controller,
//                     mainSeries: _mainSeries,
//                     activeSymbol: widget.symbol,

//                     // 1 candle = 60 seconds
//                     granularity: 60,

//                     // decimal precision saham
//                     pipSize: 2,

//                     // karena kita streaming
//                     isLive: true,

//                     // auto fit
//                     dataFitEnabled: true,

//                     showCrosshair: true,
//                   ),
//                 ),

//                 //button to full chart,
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) =>
//                               TradingViewPage(symbol: widget.symbol),
//                         ),
//                       );
//                     },
//                     child: const Text("View Full Chart"),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }
