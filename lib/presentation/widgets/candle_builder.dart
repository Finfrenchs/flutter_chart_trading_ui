import 'package:deriv_chart/deriv_chart.dart';

class CandleBuilder {
  final int timeframe; // seconds (60 = M1)

  Candle? _current;
  int? _currentBucket;

  final List<Candle> candles = [];

  CandleBuilder({this.timeframe = 60});

  Candle? addTick(Tick tick) {
    final int bucket = tick.epoch ~/ (timeframe * 1000);

    // candle baru
    if (_currentBucket != bucket) {
      if (_current != null) {
        candles.add(_current!);
      }

      _currentBucket = bucket;

      _current = Candle(
        epoch: DateTime.fromMillisecondsSinceEpoch(
          bucket * timeframe * 1000,
        ).millisecondsSinceEpoch,
        open: tick.quote,
        high: tick.quote,
        low: tick.quote,
        close: tick.quote,
      );

      return _current;
    }

    // update candle berjalan
    _current = Candle(
      epoch: _current!.epoch,
      open: _current!.open,
      high: tick.quote > _current!.high ? tick.quote : _current!.high,
      low: tick.quote < _current!.low ? tick.quote : _current!.low,
      close: tick.quote,
    );

    return null;
  }
}
