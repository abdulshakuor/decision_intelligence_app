import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/loading_widget.dart';

class BranchDetailPage extends StatefulWidget {
  final int branchId;
  final String branchName;
  const BranchDetailPage({
    super.key,
    required this.branchId,
    required this.branchName,
  });

  @override
  State<BranchDetailPage> createState() => _BranchDetailPageState();
}

class _BranchDetailPageState extends State<BranchDetailPage> {
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
        '${ApiConstants.branches}/${widget.branchId}/performance',
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
        appBar: AppBar(title: Text('أداء ${widget.branchName}')),
        body: _isLoading ? const LoadingWidget() : _data == null
          ? const Center(child: Text('لا توجد بيانات'))
          : ListView(padding: const EdgeInsets.all(16), children: [
              // بطاقات KPI
              GridView.count(
                crossAxisCount: 2, shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10, crossAxisSpacing: 10,
                childAspectRatio: 1.6,
                children: [
                  _kpi('إجمالي المبيعات',
                    '${_data!['totalSales']?.toStringAsFixed(0)} ر.س',
                    AppColors.primary),
                  _kpi('عدد الفواتير',
                    '${_data!['totalInvoices']}',
                    AppColors.secondary),
                  _kpi('متوسط الفاتورة',
                    '${_data!['avgInvoiceValue']?.toStringAsFixed(0)} ر.س',
                    AppColors.accent),
                  _kpi('مخزون حرج',
                    '${_data!['criticalStockItems']}',
                    AppColors.danger),
                ],
              ),
              const SizedBox(height: 20),

              // رسم بياني يومي
              Card(child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('المبيعات اليومية',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    SizedBox(height: 220, child: _buildChart()),
                  ],
                ),
              )),
              const SizedBox(height: 16),

              // تفاصيل يومية
              Card(child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('التفاصيل اليومية',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    ...(_data!['dailySales'] as List? ?? []).reversed.take(10).map((day) =>
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(children: [
                          const Icon(Icons.calendar_today,
                            size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(child: Text(day['date'] ?? '')),
                          Text('${day['count']} فاتورة',
                            style: const TextStyle(
                              color: Colors.grey, fontSize: 13)),
                          const SizedBox(width: 16),
                          Text('${day['total']?.toStringAsFixed(0)} ر.س',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary)),
                        ]),
                      )),
                  ],
                ),
              )),
            ]),
      ),
    );
  }

  Widget _kpi(String title, String value, Color color) {
    return Card(child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: TextStyle(
            fontSize: 17, fontWeight: FontWeight.bold, color: color),
            maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    ));
  }

  Widget _buildChart() {
    final days = _data!['dailySales'] as List? ?? [];
    if (days.isEmpty) return const Center(child: Text('لا توجد بيانات'));

    return BarChart(BarChartData(
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: const FlTitlesData(
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      barGroups: days.asMap().entries.map((e) =>
        BarChartGroupData(x: e.key, barRods: [
          BarChartRodData(
            toY: (e.value['total'] ?? 0).toDouble(),
            color: AppColors.primary,
            width: 12,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ])).toList(),
    ));
  }
}