import 'package:dca75_store/dca75_store.dart';
import 'package:test/test.dart';

void main() {
  test('empty', () {
    final s = BinStats.compute('k', const []);
    expect(s.n, 0);
    expect(s.percentileOf(1), 0);
  });
  test('single value', () {
    final s = BinStats.compute('k', [5]);
    expect(s.median, 5);
    expect(s.stddev, 0);
    expect(s.histogram.single.count, 1);
    expect(s.percentileOf(5), 50);
  });
  test('ignores non-finite', () {
    final s = BinStats.compute('k', [1, double.nan, 3, double.infinity]);
    expect(s.n, 2);
    expect(s.mean, 2);
  });
  test('interpolated percentiles', () {
    expect(BinStats.percentile([1, 2, 3, 4], 0.5), 2.5);
    expect(BinStats.percentile([1, 2, 3, 4], 0.0), 1);
    expect(BinStats.percentile([1, 2, 3, 4], 1.0), 4);
  });
  test('histogram covers range and last bucket is inclusive', () {
    final h = BinStats.histogramOf([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10], 5);
    expect(h.length, 5);
    expect(h.map((b) => b.count).reduce((a, b) => a + b), 11);
    expect(h.last.count, 3); // 8, 9, 10
  });
  test('nearest', () {
    final n =
        nearest({1: 10.0, 2: 12.0, 3: 30.0, 4: 11.0}, 11.0, 2, excludeId: 4);
    expect(n.map((e) => e.$1), [1, 2]);
  });
  test('outlier fences need enough values and some spread', () {
    expect(
        BinStats.compute('hfe', [100, 200, 300, 900]).isOutlier(900), isFalse);
    expect(
        BinStats.compute('hfe', [100, 100, 100, 100, 100]).upperFence, isNull);
    final s = BinStats.compute('hfe', [100, 110, 120, 130, 140, 150, 400]);
    expect(s.outlierCount, 1);
    expect(s.isOutlier(400), isTrue);
    expect(s.isOutlier(150), isFalse);
    expect(BinStats.empty.isOutlier(1), isFalse);
  });
}
