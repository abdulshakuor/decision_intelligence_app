import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/loading_widget.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _apiClient = ApiClient();

  Map<String, dynamic>? _salesReport;
  Map<String, dynamic>? _inventoryReport;
  List<dynamic>? _productRanking;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);

      final results = await Future.wait([
        _apiClient.get('${ApiConstants.baseUrl}/reports/sales-summary',
          queryParams: {
            'startDate': monthStart.toIso8601String(),
            'endDate': now.toIso8601String(),
          }),
        _apiClient.get('${ApiConstants.baseUrl}/reports/inventory-report'),
        _apiClient.get('${ApiConstants.baseUrl}/reports/product-ranking'),
      ]);

      setState(() {
        _salesReport = results[0].data['data'];
        _inventoryReport = results[1].data['data'];
        _productRanking = results[2].data['data']?['products'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التقارير'),
          bottom: TabBar(
            controller: _tabCtrl,
            tabs: const [
              Tab(text: 'المبيعات', icon: Icon(Icons.trending_up)),
              Tab(text: 'المخزون', icon: Icon(Icons.warehouse)),
              Tab(text: 'المنتجات', icon: Icon(Icons.leaderboard)),
            ],
          ),
        ),
        body: _isLoading ? const LoadingWidget() : TabBarView(
          controller: _tabCtrl,
          children: [
            _buildSalesTab(),
            _buildInventoryTab(),
            _buildRankingTab(),
          ],
        ),
      ),
    );
  }

  // ======== تبويب المبيعات ========
  Widget _buildSalesTab() {
    if (_salesReport == null) return const Center(child: Text('لا توجد بيانات'));

    return ListView(padding: const EdgeInsets.all(16), children: [
      // ملخص
      Row(children: [
        _miniKpi('إجمالي المبيعات',
          '${_salesReport!['totalSales']?.toStringAsFixed(0)} ر.س', AppColors.primary),
        const SizedBox(width: 12),
        _miniKpi('عدد الفواتير',
          '${_salesReport!['totalInvoices']}', AppColors.secondary),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        _miniKpi('متوسط الفاتورة',
          '${_salesReport!['avgInvoiceValue']?.toStringAsFixed(0)} ر.س', AppColors.accent),
        const SizedBox(width: 12),
        _miniKpi('الفروع',
          '${(_salesReport!['byBranch'] as List?)?.length ?? 0}', AppColors.info),
      ]),
      const SizedBox(height: 24),

      // مقارنة الفروع
      Card(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('أداء الفروع',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ...(_salesReport!['byBranch'] as List? ?? []).map((b) {
            final pct = b['percentage'] ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(b['branch'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w500))),
                  Text('${b['total']?.toStringAsFixed(0)} ر.س',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: (pct / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.grey.shade200,
                  color: AppColors.primary,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                Text('$pct% من الإجمالي',
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ]),
            );
          }),
        ]),
      )),
    ]);
  }

  // ======== تبويب المخزون ========
  Widget _buildInventoryTab() {
    if (_inventoryReport == null) return const Center(child: Text('لا توجد بيانات'));

    final critical = _inventoryReport!['criticalItems'] as List? ?? [];

    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(children: [
        _miniKpi('منتجات المخزون',
          '${_inventoryReport!['totalProducts']}', AppColors.primary),
        const SizedBox(width: 12),
        _miniKpi('منتجات حرجة',
          '${_inventoryReport!['criticalCount']}', AppColors.danger),
      ]),
      const SizedBox(height: 16),

      if (critical.isNotEmpty) ...[
        const Text('المنتجات الحرجة',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ...critical.map((item) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text('${item['quantity']}',
                style: const TextStyle(
                  color: AppColors.danger, fontWeight: FontWeight.bold))),
            ),
            title: Text(item['productName'] ?? ''),
            subtitle: Text('${item['branchName']} • ينقص: ${item['deficit']}',
              style: const TextStyle(fontSize: 12)),
          ),
        )),
      ],
    ]);
  }

  // ======== تبويب ترتيب المنتجات ========
  Widget _buildRankingTab() {
    if (_productRanking == null) return const Center(child: Text('لا توجد بيانات'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _productRanking!.length,
      itemBuilder: (context, index) {
        final p = _productRanking![index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: index < 3
                ? AppColors.accent.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
              child: Text('${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: index < 3 ? AppColors.accent : Colors.grey)),
            ),
            title: Text(p['name'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              '${p['totalQuantity']} وحدة • ربح: ${p['totalProfit']?.toStringAsFixed(0)} ر.س'),
            trailing: Text('${p['totalRevenue']?.toStringAsFixed(0)} ر.س',
              style: const TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  Widget _miniKpi(String title, String value, Color color) {
    return Expanded(child: Card(child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ]),
    )));
  }
}