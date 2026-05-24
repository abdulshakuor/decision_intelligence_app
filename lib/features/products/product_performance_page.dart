import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/loading_widget.dart';

class ProductPerformancePage extends StatefulWidget {
  final int productId;
  final String productName;
  const ProductPerformancePage({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<ProductPerformancePage> createState() => _ProductPerformancePageState();
}

class _ProductPerformancePageState extends State<ProductPerformancePage> {
  final _apiClient = ApiClient();
  Map<String, dynamic>? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await _apiClient.get(
        '${ApiConstants.productById(widget.productId)}/performance',
        queryParams: {'days': 30});

      setState(() { _data = res.data['data']; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('أداء ${widget.productName}')),
        body: _isLoading ? const LoadingWidget() : _data == null
          ? const Center(child: Text('لا توجد بيانات'))
          : ListView(padding: const EdgeInsets.all(16), children: [

              // بطاقات الأداء
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10, crossAxisSpacing: 10,
                childAspectRatio: 1.6,
                children: [
                  _kpiTile('الوحدات المباعة',
                    '${_data!['totalUnitsSold']}', AppColors.primary),
                  _kpiTile('إجمالي الإيرادات',
                    '${_data!['totalRevenue']?.toStringAsFixed(0)} ر.س', AppColors.secondary),
                  _kpiTile('إجمالي الربح',
                    '${_data!['totalProfit']?.toStringAsFixed(0)} ر.س', AppColors.opportunity),
                  _kpiTile('هامش الربح',
                    '${_data!['profitMarginPercent']}%', AppColors.accent),
                ],
              ),
              const SizedBox(height: 20),

              // الأسعار
              Card(child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('معلومات السعر',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  _priceRow('سعر التكلفة', _data!['costPrice']),
                  _priceRow('سعر البيع', _data!['sellingPrice']),
                  _priceRow('الربح/وحدة', _data!['profitPerUnit']),
                ]),
              )),
              const SizedBox(height: 16),

              // مخطط المبيعات اليومية
              Card(child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('المبيعات اليومية (آخر 30 يوم)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildDailyChart(),
                  ),
                ]),
              )),
              const SizedBox(height: 16),

              // حالة المخزون
              Card(child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('حالة المخزون في الفروع',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  ...(_data!['stockByBranch'] as List? ?? []).map((stock) =>
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(children: [
                        Container(
                          width: 10, height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: stock['status'] == 'حرج'
                              ? AppColors.danger : AppColors.secondary),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(stock['branchName'] ?? '')),
                        Text('${stock['quantity']} وحدة',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: stock['status'] == 'حرج'
                              ? AppColors.danger : null)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: stock['status'] == 'حرج'
                              ? AppColors.danger.withOpacity(0.1)
                              : AppColors.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12)),
                          child: Text(stock['status'] ?? '',
                            style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold,
                              color: stock['status'] == 'حرج'
                                ? AppColors.danger : AppColors.secondary)),
                        ),
                      ]),
                    )),
                ]),
              )),
            ]),
      ),
    );
  }

  Widget _kpiTile(String title, String value, Color color) {
    return Card(child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: color),
            maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(title, style: const TextStyle(
            fontSize: 12, color: Colors.grey)),
        ],
      ),
    ));
  }

  Widget _priceRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Expanded(child: Text(label, style: const TextStyle(color: Colors.grey))),
        Text('${value?.toStringAsFixed(2)} ر.س',
          style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildDailyChart() {
    final dailySales = _data!['dailySales'] as List? ?? [];
    if (dailySales.isEmpty) return const Center(child: Text('لا توجد مبيعات'));

    final spots = dailySales.asMap().entries.map((e) =>
      FlSpot(e.key.toDouble(), (e.value['units'] ?? 0).toDouble())).toList();

    return LineChart(LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (v) =>
          FlLine(color: Colors.grey.withOpacity(0.15), strokeWidth: 1),
      ),
      titlesData: const FlTitlesData(
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppColors.primary,
          barWidth: 3,
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primary.withOpacity(0.1)),
          dotData: FlDotData(show: spots.length < 15),
        ),
      ],
    ));
  }
}