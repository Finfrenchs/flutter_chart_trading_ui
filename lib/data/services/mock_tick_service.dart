import 'dart:async';
import 'dart:math';

import 'package:deriv_chart/deriv_chart.dart';

class MockTickService {
  final _controller = StreamController<Tick>.broadcast();

  Stream<Tick> get stream => _controller.stream;

  double _price = 1000;
  final _random = Random();
  Timer? _timer;

  void start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      // random walk (simulate stock movement)
      double change = (_random.nextDouble() - 0.5) * 6;

      // volatility control
      _price += change;

      // prevent negative price
      if (_price < 50) _price = 50;

      final tick = Tick(
        epoch: DateTime.now().millisecondsSinceEpoch,
        quote: double.parse(_price.toStringAsFixed(2)),
      );

      _controller.add(tick);
    });
  }

  void stop() {
    _timer?.cancel();
  }
}
