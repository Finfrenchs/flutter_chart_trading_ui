import 'package:flutter/material.dart';

import '../../data/services/mock_candle_service.dart';
import '../widgets/mini_chart.dart';
import 'stock_detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Market Watch"), centerTitle: false),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 10,
        itemBuilder: (_, i) {
          final symbol = "BBCA$i";
          final candles = MockCandleService.generateCandles(40);

          final last = candles.last.close;
          final first = candles.first.close;
          final change = last - first;
          final pct = (change / first) * 100;

          final isUp = change >= 0;
          final color = isUp
              ? const Color(0xff16c784)
              : const Color(0xffea3943);

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StockDetailPage(symbol: symbol),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xff111111),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  /// TOP ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        symbol,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            last.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${change >= 0 ? "+" : ""}${pct.toStringAsFixed(2)}%",
                            style: TextStyle(color: color),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// MINI CHART
                  SizedBox(height: 70, child: MiniChart(candles: candles)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
