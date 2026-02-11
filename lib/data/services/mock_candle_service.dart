import 'dart:math';

import 'package:deriv_chart/deriv_chart.dart';

class MockCandleService {
  static List<Candle> generateCandles(int count) {
    final rand = Random();
    final List<Candle> candles = [];

    double lastClose = 1000;
    final now = DateTime.now();

    for (int i = 0; i < count; i++) {
      double open = lastClose;
      double close = open + rand.nextDouble() * 6 - 3;
      double high = max(open, close) + rand.nextDouble() * 2;
      double low = min(open, close) - rand.nextDouble() * 2;

      final time = now.subtract(Duration(minutes: count - i));

      candles.add(
        Candle(
          epoch: time.millisecondsSinceEpoch,
          open: open,
          high: high,
          low: low,
          close: close,
          currentEpoch: time.millisecondsSinceEpoch,
        ),
      );

      lastClose = close;
    }

    return candles;
  }
}
