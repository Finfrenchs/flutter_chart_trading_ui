import 'package:deriv_chart/deriv_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MiniChart extends StatelessWidget {
  final List<Candle> candles;

  const MiniChart({super.key, required this.candles});

  @override
  Widget build(BuildContext context) {
    if (candles.isEmpty) return const SizedBox();

    final spots = candles
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.close))
        .toList();

    final isUp = candles.last.close >= candles.first.close;

    final color = isUp ? const Color(0xff16c784) : const Color(0xffea3943);

    return LineChart(
      LineChartData(
        minY: candles.map((e) => e.low).reduce((a, b) => a < b ? a : b),
        maxY: candles.map((e) => e.high).reduce((a, b) => a > b ? a : b),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(show: false),
        lineTouchData: LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false, // <<< penting (trading look)
            color: color,
            barWidth: 2.2,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }
}
