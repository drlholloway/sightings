import 'dart:math' as math;

/// Descriptive statistics for one parameter across a bin.
class BinStats {
  const BinStats({
    required this.key,
    required this.n,
    required this.min,
    required this.max,
    required this.mean,
    required this.stddev,
    required this.p5,
    required this.p25,
    required this.median,
    required this.p75,
    required this.p95,
    required this.histogram,
    required this.values,
  });

  final String key;
  final int n;
  final double min, max, mean, stddev, p5, p25, median, p75, p95;
  final List<HistogramBucket> histogram;

  /// Sorted values.
  final List<double> values;

  static const empty = BinStats(
      key: '',
      n: 0,
      min: 0,
      max: 0,
      mean: 0,
      stddev: 0,
      p5: 0,
      p25: 0,
      median: 0,
      p75: 0,
      p95: 0,
      histogram: [],
      values: []);

  /// Percentile rank (0..100) of [v] within this bin: the share of values
  /// strictly below it plus half of the ties.
  double percentileOf(double v) {
    if (n == 0) return 0;
    var below = 0, ties = 0;
    for (final x in values) {
      if (x < v) {
        below++;
      } else if (x == v) {
        ties++;
      }
    }
    return 100 * (below + ties / 2) / n;
  }

  /// Interpolated percentile (0..1) of the sorted values.
  static double percentile(List<double> sorted, double p) {
    if (sorted.isEmpty) return 0;
    if (sorted.length == 1) return sorted.first;
    final pos = p * (sorted.length - 1);
    final lo = pos.floor(), hi = pos.ceil();
    if (lo == hi) return sorted[lo];
    return sorted[lo] + (sorted[hi] - sorted[lo]) * (pos - lo);
  }

  factory BinStats.compute(String key, Iterable<double> raw,
      {int buckets = 12}) {
    final v = raw.where((x) => x.isFinite).toList()..sort();
    if (v.isEmpty) return BinStats.empty;
    final n = v.length;
    final mean = v.reduce((a, b) => a + b) / n;
    final variance = n > 1
        ? v.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) /
            (n - 1)
        : 0.0;
    return BinStats(
      key: key,
      n: n,
      min: v.first,
      max: v.last,
      mean: mean,
      stddev: math.sqrt(variance),
      p5: percentile(v, 0.05),
      p25: percentile(v, 0.25),
      median: percentile(v, 0.5),
      p75: percentile(v, 0.75),
      p95: percentile(v, 0.95),
      histogram: histogramOf(v, buckets),
      values: v,
    );
  }

  static List<HistogramBucket> histogramOf(List<double> sorted, int buckets) {
    if (sorted.isEmpty) return const [];
    final lo = sorted.first, hi = sorted.last;
    if (hi == lo) {
      return [HistogramBucket(lo: lo, hi: hi, count: sorted.length)];
    }
    final width = (hi - lo) / buckets;
    final counts = List<int>.filled(buckets, 0);
    for (final x in sorted) {
      var i = ((x - lo) / width).floor();
      if (i >= buckets) i = buckets - 1;
      counts[i]++;
    }
    return List.generate(
        buckets,
        (i) => HistogramBucket(
            lo: lo + i * width, hi: lo + (i + 1) * width, count: counts[i]));
  }
}

class HistogramBucket {
  const HistogramBucket(
      {required this.lo, required this.hi, required this.count});
  final double lo, hi;
  final int count;
}

/// The k nearest readings to [target] by one key.
List<(int id, double value, double distance)> nearest(
    Map<int, double> byId, double target, int k,
    {int? excludeId}) {
  final list = byId.entries
      .where((e) => e.key != excludeId)
      .map((e) => (e.key, e.value, (e.value - target).abs()))
      .toList()
    ..sort((a, b) => a.$3.compareTo(b.$3));
  return list.take(k).toList();
}
